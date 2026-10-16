# Running vial-gui from source on modern macOS

Notes for getting `fbs run` working on an Apple Silicon Mac with a current
Python + macOS, where the pinned `requirements.txt` no longer installs.

Verified on: macOS 26 (Darwin 25.6.0, arm64), Python 3.10.20, commit `aef8222`.

---

## TL;DR

```bash
# 1. Create a Python 3.10 venv (NOT 3.12+/3.13+/3.14 — see below)
python3.10 -m venv venv
source venv/bin/activate
pip install --upgrade pip wheel setuptools

# 2. Install the Vial hidapi fork + modern runtime deps
pip install "git+https://github.com/vial-kb/cython-hidapi@fa31fd46e709ac4adba80bd516b1290dd56f43e9#egg=hidapi"
pip install --no-deps fbs==0.9.0
pip install PyQt5 keyboard simpleeval certifi future

# 3. Run
fbs run
```

## Why not just `pip install -r requirements.txt`?

The upstream `requirements.txt` pins 2019-era packages that target **Python
3.6** (the last version `fbs` officially supports). On modern Python they fail
to build because they rely on stdlib modules that have since been removed:

| Package | Blocker | Removed in |
|---|---|---|
| `simpleeval` (old snapshot) | `use_2to3` removed from setuptools | setuptools 58 |
| `PyInstaller==3.4` | build uses `imp` | Python 3.12 |
| `hidapi` (Vial fork, old Cython) | build uses `cgi` | Python 3.13 |
| `PyQt5==5.9.2`, `sip==4.19.8` | no wheels for modern Python | — |

## Why Python 3.10 specifically

Among interpreters commonly installed via Homebrew (3.10 / 3.13 / 3.14), **3.10
is the only one that still has both `imp` and `cgi`** in its stdlib, so the old
Cython used by the hidapi fork can build and PyInstaller isn't a hard blocker.

- Python **3.12+** removed `imp` → PyInstaller 3.4 can't build.
- Python **3.13+** also removed `cgi` → the hidapi fork's old Cython can't build.

Install 3.10 if you don't have it, e.g. `brew install python@3.10`.

## Why the modernized dependency set

We relax the pins to current versions that ship wheels for 3.10:

- **hidapi** — must be the [Vial fork](https://github.com/vial-kb/cython-hidapi)
  at commit `fa31fd46...`. It patches the macOS backend so the raw-HID (`0xFF60`)
  interface can be opened by its IOService path. Do **not** substitute upstream
  `hidapi`.
- **fbs 0.9.0 with `--no-deps`** — `fbs` hard-pins `PyInstaller==3.4`, which
  can't build on 3.10+. PyInstaller is only needed to *freeze/package* a binary
  (`fbs freeze`), **not** to run the app (`fbs run`), so we skip it.
- **PyQt5 / keyboard / simpleeval / certifi / future** — current releases; these
  are the actual runtime imports.

A ready-to-use file is checked in as `requirements-modern.txt`.

### Known limitation

`fbs freeze` (building a distributable `.app`) will **not** work with this setup
— it needs PyInstaller, which can't build at these versions on Python 3.10+.
Running from source (`fbs run`) is unaffected. To build a release, use the
official CI / a Python 3.6 environment as upstream intends.

## macOS: opening the keyboard

On macOS, opening a keyboard's raw-HID interface requires **Input Monitoring**
permission for the process that owns `fbs run` — i.e. **your terminal app**
(Ghostty, iTerm, Terminal, or the VS Code/Cursor app if using its integrated
terminal).

1. **System Settings → Privacy & Security → Input Monitoring**
2. Add and enable your terminal app.
3. **Fully quit** (⌘Q) the terminal and relaunch — the grant only applies to
   processes started afterward.

The device exposes several HID interfaces; expect this pattern on open:

- boot-keyboard interface (`usage_page=0001 usage=06`) → macOS seizes it, open
  fails — **this is normal**, Vial doesn't use it.
- raw-HID interface (`usage_page=ff60 usage=61`) → **this is the one Vial needs**;
  it should open once permissions are set and nothing else holds it.

## Troubleshooting: `RuntimeError: unable to open the device`

`vial_device.py` retries the open 10×, then raises this. Two causes, in order of
likelihood:

1. **A stale `main.py` process is still holding the device.** If a previous
   `fbs run` crashed or was killed without cleaning up its Python child, that
   child keeps the raw-HID interface open exclusively, so every new open fails.
   Clear it:

   ```bash
   pkill -f "src/main/python/main.py"
   ```

   Then `fbs run` again. (This is the most common cause after a rough shutdown.)

2. **Input Monitoring not granted / terminal not restarted.** See the macOS
   section above. Grant the terminal app and fully quit + relaunch it.

To see the *real* error instead of the swallowed retry, open the interface
directly:

```bash
python -c "
import hid
d=[x for x in hid.enumerate() if x.get('vendor_id')==0x5241 and x.get('usage_page')==0xff60][0]
dev=hid.device()
try: dev.open_path(d['path']); print('OPEN OK'); dev.close()
except Exception as e: print('FAILED', repr(e))
"
```

(Replace `0x5241` with your keyboard's vendor ID if different.)
