r"""AstroSSTool - read-only screenshare forensic scanner for Minecraft Java.

Entry point.  Run from an ELEVATED prompt:

    python ss.py

Nothing here downloads, uploads, updates or phones home; the socket layer is
disabled in-process before any module loads (see ssforensics/netlock.py).
Nothing here writes to the inspected system apart from the three report files
it produces on the Desktop.

Exit codes, for staff who script around it:
    0  nothing found
    1  findings to review
    2  signs of tampering
    3  the scan itself could not run
"""
from __future__ import annotations

import argparse
import os
import sys
import time
import traceback

from rich.console import Console
from rich.panel import Panel

from ssforensics import netlock

# Engage the network lock before anything else is imported or run.
netlock.engage()

from ssforensics import modules as module_registry  # noqa: E402
from ssforensics import report as report_mod  # noqa: E402
from ssforensics import signatures as signature_mod  # noqa: E402
from ssforensics.context import Config, ScanContext  # noqa: E402
from ssforensics.util import paths as pathutil  # noqa: E402
from ssforensics.util import winapi  # noqa: E402

console = Console()

BANNER_TEXT = """[bold #c084fc]    ___         __             _____ _____ _____ _____ _____ 
   /   |  _____/ /__________  / ___// ___// ___// ___// ___/ 
  / /| | / ___/ __/ ___/ __ \ \__ \ \__ \ \__ \ \__ \ \__ \  
 / ___ |(__  ) /_j /  / /_/ /___/ /___/ /___/ /___/ /___/ /  
/_/  |_/____/\__/_/   \____//____//____//____//____//____/ [/]
[bold #a855f7]                   --- FORENSIC SUITE v{version} ---                   [/]"""


def print_astro_banner(version: str):
    panel = Panel(
        BANNER_TEXT.format(version=version),
        border_style="#9333ea",
        padding=(1, 2),
        title="[bold #e0e0e0]AstroSSTool Engine[/bold #e0e0e0]",
        subtitle="[italic #9ca3af]Read-Only Offline Mode[/italic #9ca3af]",
        style="on #161618"
    )
    console.print(panel)
    console.print("[dim #9ca3af]  This tool INSPECTS and REPORTS. It does not modify the system, does not[/dim #9ca3af]")
    console.print("[dim #9ca3af]  download anything, and has no network access at all. Cannot prove innocence.[/dim #9ca3af]\n")


def parse_args(argv=None):
    p = argparse.ArgumentParser(
        prog="ss.py",
        description="Read-only forensic scanner for consensual, staff-run "
                    "Minecraft screenshares (AstroSSTool). Reports findings by severity, "
                    "'nothing found', or signs of tampering - never 'innocent'.",
        epilog="Run elevated. Without administrator rights, prefetch, BAM, "
               "AmCache, the USN journal and process memory are all "
               "unreadable and the scan will say so.")
    p.add_argument("--out", metavar="DIR", default="",
                   help="output directory (default: a timestamped folder on "
                        "the Desktop)")
    p.add_argument("--signatures", metavar="FILE", default=None,
                   help="path to signatures.json (default: alongside this script)")
    p.add_argument("--session-hours", type=float, default=12.0, metavar="H",
                   help="how far back the 'reviewed window' reaches, in hours "
                        "(default 12). Findings inside it are weighted higher.")
    p.add_argument("--fresh-boot-minutes", type=int, default=20, metavar="M",
                   help="flag the scan if the machine booted within this many "
                        "minutes (default 20)")
    p.add_argument("--usn-max-mb", type=int, default=512, metavar="MB",
                   help="cap on how much USN journal to walk (default 512)")
    p.add_argument("--mem-max-mb", type=int, default=3072, metavar="MB",
                   help="cap on how much javaw memory to string-scan per "
                        "process (default 3072)")
    p.add_argument("--no-mem-scan", action="store_true",
                   help="skip the javaw memory string scan")
    p.add_argument("--disk-budget", type=int, default=240, metavar="SECONDS",
                   help="wall-clock budget for the on-disk jar scan and the "
                        "stray-directory sweep (default 240). What is left "
                        "unscanned is reported.")
    p.add_argument("--input-capture", type=int, default=0, metavar="SECONDS",
                   help="observe live mouse/keyboard input for N seconds to "
                        "detect injected input and machine-regular clicking. "
                        "Ask the player to click during the window.")
    p.add_argument("--extra-root", action="append", default=[], metavar="DIR",
                   help="additional directory to scan for jars (repeatable)")
    p.add_argument("--only", default="", metavar="M1,M2",
                   help="run only these modules")
    p.add_argument("--skip", default="", metavar="M1,M2",
                   help="skip these modules")
    p.add_argument("--quick", action="store_true",
                   help="lower the journal, memory and jar caps for a fast pass")
    p.add_argument("--no-open", action="store_true",
                   help="do not open the HTML report when finished")
    p.add_argument("--verbose", action="store_true",
                   help="print progress from inside each module")
    p.add_argument("--list-modules", action="store_true",
                   help="list modules and exit")
    p.add_argument("--selftest", action="store_true",
                   help="report which evidence sources are readable on this "
                        "machine and exit (run this first, elevated)")
    return p.parse_args(argv)


def default_out_dir() -> str:
    stamp = time.strftime("%Y%m%d-%H%M%S")
    return os.path.join(pathutil.desktop_dir(), f"AstroSSTool-Report-{stamp}")


def selftest() -> int:
    """Capability probe: what can this scan actually read?

    Worth running before a screenshare so the operator knows in advance which
    modules will be blind, rather than discovering it in front of the player.
    """
    from ssforensics import collect
    from ssforensics.util import bam, evt, prefetch, raw_ntfs, reg, usn

    print_astro_banner(report_mod.TOOL_VERSION)
    admin = winapi.is_admin()
    console.print(f"  [bold]elevated:[/bold] {'[green]YES[/green]' if admin else '[red]NO - most checks will be blind[/red]'}")
    console.print(f"  [bold]boot time:[/bold] {winapi.boot_time()}  (up {winapi.uptime_seconds() / 3600:.1f} h)\n")
    rows = []

    def probe(label, fn):
        try:
            rows.append((label, "OK", str(fn())[:96]))
        except Exception as exc:  # noqa: BLE001
            rows.append((label, "FAIL", f"{type(exc).__name__}: {exc}"[:96]))

    probe("prefetch directory", lambda: f"{len(prefetch.list_prefetch_files())} .pf files")
    probe("prefetch parse", lambda: prefetch.parse(prefetch.list_prefetch_files()[0]).name)
    probe("BAM/DAM", lambda: f"{len(bam.entries())} entries")
    probe("ShimCache", lambda: str(len(reg.value(
        reg.HKLM, r"SYSTEM\CurrentControlSet\Control\Session Manager"
                  r"\AppCompatCache", "AppCompatCache") or b"")) + " bytes")
    probe("AmCache (raw hive read)",
          lambda: f"{len(collect._amcache_bytes()[0])} bytes via "
                  f"{collect._amcache_bytes()[1]}")
    probe("USN journal", lambda: f"journal {usn.query('C').journal_id}")
    probe("raw NTFS volume", lambda: f"{raw_ntfs.NtfsVolume('C').record_count} MFT records")
    probe("System event log", lambda: f"{len(evt.events('System', limit=3))} events")
    probe("Security event log", lambda: f"{len(evt.events('Security', limit=3))} events")
    probe("PowerShell log",
          lambda: f"{len(evt.events('Microsoft-Windows-PowerShell/Operational', limit=3))} events")
    probe("service query", lambda: winapi.query_service("SysMain"))
    probe("process snapshot", lambda: f"{len(winapi.system_process_snapshot())} processes")
    probe("signatures.json",
          lambda: f"{signature_mod.load().total()} signatures")

    width = max(len(r[0]) for r in rows)
    for label, state, detail in rows:
        state_str = f"[green]{state}[/green]" if state == "OK" else f"[red]{state}[/red]"
        console.print(f"  {label.ljust(width)}  {state_str}  {detail}")
    console.print()
    
    failures = [r for r in rows if r[1] == "FAIL"]
    if failures and not admin:
        console.print("  [yellow]Re-run from an elevated prompt: most of these failures are just missing administrator rights.[/yellow]")
    elif failures:
        console.print("  [yellow]Running elevated and still failing: each failure above is a source of evidence this machine will not hand over.[/yellow]")
    else:
        console.print("  [green]All evidence sources readable.[/green]")
    return 0


def run_scan(args) -> int:
    cfg = Config(
        out_dir=args.out or default_out_dir(),
        signatures_path=args.signatures,
        session_hours=args.session_hours,
        fresh_boot_minutes=args.fresh_boot_minutes,
        usn_max_mb=64 if args.quick else args.usn_max_mb,
        mem_scan=not args.no_mem_scan,
        mem_max_mb=512 if args.quick else args.mem_max_mb,
        max_jar_scan=400 if args.quick else 4000,
        disk_budget_seconds=60 if args.quick else args.disk_budget,
        input_capture_seconds=args.input_capture,
        open_report=not args.no_open,
        quick=args.quick,
        only=[s for s in args.only.split(",") if s.strip()],
        skip=[s for s in args.skip.split(",") if s.strip()],
        extra_roots=list(args.extra_root),
        verbose=args.verbose,
    )

    try:
        sigs = signature_mod.load(cfg.signatures_path)
    except (OSError, ValueError) as exc:
        console.print(f"[bold red]ERROR:[/bold red] could not load signatures.json: {exc}", file=sys.stderr)
        return 3
    if sigs.load_errors:
        for err in sigs.load_errors:
            console.print(f"  [yellow]signature warning: {err}[/yellow]", file=sys.stderr)

    print_astro_banner(report_mod.TOOL_VERSION)
    console.print(f"  [bold]signatures[/bold] : {sigs.total()} across {len(sigs.counts())} categories ({sigs.source})")
    console.print(f"  [bold]output[/bold]     : {cfg.out_dir}")
    if not winapi.is_admin():
        console.print()
        console.print("  [bold red]*** NOT RUNNING ELEVATED ***[/bold red]")
        console.print("  [yellow]Prefetch, BAM, AmCache, the USN journal, the MFT and other[/yellow]")
        console.print("  [yellow]processes' memory are all unreadable without administrator[/yellow]")
        console.print("  [yellow]rights. The report will mark those modules as blocked.[/yellow]")
    console.print()

    for priv in ("SeBackupPrivilege", "SeDebugPrivilege", "SeSecurityPrivilege"):
        winapi.enable_privilege(priv)

    ctx = ScanContext(cfg, sigs)
    selected = module_registry.load(cfg.only or None, cfg.skip or None)
    for mod in selected:
        ctx.register(mod.NAME, mod.TITLE)

    for mod in selected:
        status = ctx.status(mod.NAME)
        started = time.perf_counter()
        console.print(f"  [cyan][{mod.NAME}][/cyan] {mod.TITLE} ...", flush=True)
        try:
            mod.run(ctx)
            if status.state == "pending":
                status.state = "ran"
        except KeyboardInterrupt:
            status.state = "failed"
            status.reason = "interrupted by the operator"
            console.print("  [red]interrupted[/red]", flush=True)
            break
        except Exception as exc:  # noqa: BLE001
            ctx.fail(mod.NAME, f"{type(exc).__name__}: {exc}", exc)
            if cfg.verbose:
                traceback.print_exc()
        finally:
            status.duration = time.perf_counter() - started
            console.print(f"      [green]{status.state}[/green], {status.findings} finding(s), {status.duration:.1f}s", flush=True)

    for name in ctx.module_order:
        status = ctx.modules[name]
        if status.state in ("failed", "degraded"):
            ctx.emit_rule(
                "tamper", "module_failed_to_run",
                f"Module '{name}' ({status.title}) finished in state "
                f"'{status.state}': {status.reason or 'no reason recorded'}. "
                "Whatever that module would have examined was not examined. "
                "Treat this as reduced coverage, not as a clean result.",
                artifacts=[f"module={name}", f"state={status.state}",
                           f"reason={status.reason}"] + status.notes[:10],
                severity="suspicious" if status.state == "failed" else "info",
                title=f"Module did not fully run: {name}")

    result = report_mod.finalise(ctx, cfg.out_dir, open_report=cfg.open_report)
    report_mod.print_console_summary(ctx, result)

    key = result["payload"]["verdict"]["key"]
    if key == "tampering":
        return 2
    if key in ("findings", "blocked"):
        return 1
    return 0


def main(argv=None) -> int:
    args = parse_args(argv)
    if sys.platform != "win32":
        console.print("[red]This tool only runs on Windows.[/red]", file=sys.stderr)
        return 3
    if args.list_modules:
        for name, title in module_registry.names():
            console.print(f"  [cyan]{name:<20}[/cyan] {title}")
        return 0
    if args.selftest:
        return selftest()
    try:
        return run_scan(args)
    except KeyboardInterrupt:
        console.print("\n[red]interrupted[/red]", file=sys.stderr)
        return 3


if __name__ == "__main__":
    sys.exit(main())
