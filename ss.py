from __future__ import annotations
import sys
import os
import ctypes
import socket
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

# --- Netlock Security ---
class LockedSocket(socket.socket):
    def __init__(self, *args, **kwargs):
        raise RuntimeError("AstroSSTool is strictly offline.")
socket.socket = LockedSocket

console = Console()

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def main_menu():
    if not is_admin():
        console.print("[bold red][!] Must be run as Administrator![/bold red]")
        input("\nPress Enter to exit...")
        sys.exit(1)

    clear_screen()
    
    banner = Panel(
        "[bold #9333ea]ASTROSSTOOL[/bold #9333ea] [dim]- Forensic Suite[/dim]\n[white]Status: [/white][bold green]Offline & Secure[/bold green]",
        border_style="#9333ea",
        padding=(1, 2)
    )
    console.print(banner)
    
    table = Table(show_header=True, header_style="bold #9333ea", border_style="#333333")
    table.add_column("No.", style="cyan", width=5)
    table.add_column("Forensic Module", style="white")
    
    table.add_row("[1]", "Prefetch Analysis (Execution History)")
    table.add_row("[2]", "Registry Audit (AppCompatFlags / RecentApps)")
    table.add_row("[3]", "Cheat Signature / String Scanner")
    table.add_row("[4]", "Run All Checks (Full Audit)")
    table.add_row("[5]", "Exit")
    
    console.print(table)
    choice = console.input("\n[bold #9333ea]AstroSS > [/bold #9333ea]").strip()
    
    if choice == "1":
        console.print("\n[bold yellow][*] Scanning Prefetch directory...[/bold yellow]")
        # Prefetch scan logic
    elif choice == "2":
        console.print("\n[bold yellow][*] Scanning Registry hives...[/bold yellow]")
        # Registry scan logic
    elif choice == "3":
        console.print("\n[bold yellow][*] Searching signatures...[/bold yellow]")
        # Signature scan logic
    elif choice == "4":
        console.print("\n[bold yellow][*] Executing full audit sequence...[/bold yellow]")
    elif choice == "5":
        sys.exit(0)
        
    input("\n[dim]Press Enter to continue...[/dim]")
    main_menu()

if __name__ == "__main__":
    main_menu()
