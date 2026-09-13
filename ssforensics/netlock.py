from __future__ import annotations
import sys
import socket

def engage():
    """Disable socket connections entirely to guarantee offline status."""
    class LockedSocket(socket.socket):
        def __init__(self, *args, **kwargs):
            raise RuntimeError("AstroSSTool is strictly offline. Network access is blocked.")
    
    socket.socket = LockedSocket
    socket.create_connection = lambda *a, **kw: (_ for _ in ()).throw(RuntimeError("Offline mode active."))
