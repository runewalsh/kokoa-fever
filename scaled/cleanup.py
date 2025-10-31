import os, os.path as path
from shutil import rmtree
from contextlib import suppress

base = path.dirname(__file__)
with suppress(OSError): os.unlink(path.join(base, "lpr\\Game (scaled).res"))
with suppress(OSError): os.unlink(path.join(base, "bin\\Game (scaled).dbg"))
with suppress(OSError): rmtree(path.join(base, "lpr\\lib"))