# Goblintechkeys GTK01 — Mac & Vial Configuration Reference

## Device

**Device:** Goblintechkeys GTK01  
**Manufacturer reported by USB:** LUCKY  
**Firmware/configuration:** QMK + Vial  
**USB Vendor ID:** `0x5241`  
**USB Product ID:** `0x0115`  
**Serial:** `vial:f64c2b3c`

The GTK01 is a single-key programmable USB keyboard/macropad. Although it has only one physical switch, Vial/QMK allows that switch to trigger macros and different actions based on how it is pressed.

---

# 1. Connecting to macOS

When first connected, macOS may launch **Keyboard Setup Assistant** and ask:

> Press the key immediately to the right of the Shift key...

The GTK01 doesn't have that key.

This happens because macOS recognizes the GTK01 as a USB keyboard but cannot determine its physical keyboard layout.

**The Keyboard Setup Assistant can be closed/ignored.**

It isn't required to use or configure the GTK01.

---

# 2. Configure with Vial

Open the **Vial Keyboard Configurator** with the GTK01 connected.

Vial recognizes the device as:

`GOBLINTECHKEYS GTK01`

The main **Keymap** screen displays the single physical key.

Originally the key was assigned:

`M0`

This means pressing the physical switch executes **Macro 0**.

---

# 3. Factory M0 Macro

The original M0 macro was:

    [["down", "KC_LGUI"], ["tap", "KC_SPACE"], ["up", "KC_LGUI"], ["delay", 500], ["text", "http://adb-2548836972759138.18.azuredatabricks.net/one"], ["delay", 500], ["tap", "KC_ENTER"]]

This performs:

    Command + Space
           ↓
    Open Spotlight
           ↓
    Wait 500 ms
           ↓
    Type URL
           ↓
    Wait 500 ms
           ↓
    Press Enter

`KC_LGUI` corresponds to the **Command (⌘)** key on macOS.

The GTK01 therefore isn't directly launching a website. It is pretending to be a keyboard and entering commands into macOS.

---

# 4. Generic "Launch Something" Macro

The basic pattern is:

    [["down", "KC_LGUI"], ["tap", "KC_SPACE"], ["up", "KC_LGUI"], ["delay", 500], ["text", "SEARCH TEXT"], ["delay", 500], ["tap", "KC_ENTER"]]

It performs:

    ⌘ Space
    Wait
    Type SEARCH TEXT
    Wait
    Enter

Anything Spotlight can reliably find can potentially be launched this way.

---

# 5. Launch DBRX Harness

Example M0:

    [["down", "KC_LGUI"], ["tap", "KC_SPACE"], ["up", "KC_LGUI"], ["delay", 500], ["text", "DBRX Harness.app"], ["delay", 500], ["tap", "KC_ENTER"]]

Result:

    GTK01
      ↓
    Spotlight
      ↓
    Search "DBRX Harness.app"
      ↓
    Enter
      ↓
    Launch DBRX Harness

---

# 6. Launch Slack

Create **M1** with:

    [["down", "KC_LGUI"], ["tap", "KC_SPACE"], ["up", "KC_LGUI"], ["delay", 500], ["text", "Slack"], ["delay", 500], ["tap", "KC_ENTER"]]

This performs:

    ⌘ Space
      ↓
    "Slack"
      ↓
    Enter

Before creating a macro like this, manually test:

    ⌘ Space → Slack

Make sure the desired application is the first Spotlight result.

---

# 7. Using Tap Dance

Vial's **Tap Dance** feature allows one physical key to perform different actions depending on how it is pressed.

Go to:

**Vial → Tap Dance → TD(0)**

Available actions include:

- On tap
- On hold
- On double tap
- On tap + hold

This makes the single GTK01 switch considerably more useful.

---

# 8. Double Press to Launch DBRX Harness

Our desired configuration:

    Single tap → Nothing
    Double tap → M0 / DBRX Harness

Configure **TD(0)**:

| Tap Dance Setting | Assignment |
|---|---|
| On tap | None |
| On hold | M1 |
| On double tap | M0 |
| On tap + hold | None |
| Tapping term | 200 ms |

Then go to:

**Keymap → physical key**

Change the physical key assignment from:

    M0

to:

    TD(0)

The physical switch now invokes Tap Dance rather than directly invoking M0.

---

# 9. Hold to Launch Slack

Create M1:

    [["down", "KC_LGUI"], ["tap", "KC_SPACE"], ["up", "KC_LGUI"], ["delay", 500], ["text", "Slack"], ["delay", 500], ["tap", "KC_ENTER"]]

Then configure:

**Tap Dance → TD(0) → On Hold → Macro → M1**

The resulting configuration is:

                         GTK01
                            │
                            ▼
                          TD(0)
                         /     \
                        /       \
                     HOLD      DOUBLE TAP
                      │             │
                      ▼             ▼
                     M1            M0
                      │             │
                      ▼             ▼
                    Slack      DBRX Harness

Single tap currently does nothing.

---

# 10. Current Recommended Configuration

## Physical Key

    GTK01 → TD(0)

## TD(0)

    On Tap        → None
    On Hold       → M1
    On Double Tap → M0
    Tap + Hold    → None
    Tapping Term  → 200 ms

## M0 — DBRX Harness

    [["down", "KC_LGUI"], ["tap", "KC_SPACE"], ["up", "KC_LGUI"], ["delay", 500], ["text", "DBRX Harness.app"], ["delay", 500], ["tap", "KC_ENTER"]]

## M1 — Slack

    [["down", "KC_LGUI"], ["tap", "KC_SPACE"], ["up", "KC_LGUI"], ["delay", 500], ["text", "Slack"], ["delay", 500], ["tap", "KC_ENTER"]]

## Result

| GTK01 Gesture | Action |
|---|---|
| Single tap | Nothing |
| **Double tap** | **Open DBRX Harness** |
| **Hold** | **Open Slack** |
| Tap + hold | Nothing |

---

# 11. Understanding M0/M1 vs TD(0)

This distinction is important.

### Macros define WHAT happens

For example:

    M0 = Open DBRX Harness
    M1 = Open Slack

Additional macros could be:

    M2 = Open ChatGPT
    M3 = Open Chrome
    M4 = Take screenshot
    M5 = Run another shortcut

### Tap Dance defines WHEN it happens

For example:

    TD(0)
       │
       ├── Tap ──────────> Nothing
       │
       ├── Hold ─────────> M1
       │
       ├── Double Tap ───> M0
       │
       └── Tap + Hold ───> Nothing

### Keymap connects the physical switch to Tap Dance

    Physical GTK01 switch
              ↓
            TD(0)
              ↓
       gesture detected
              ↓
        appropriate macro
              ↓
           macOS action

This separation makes future changes easy.

---

# 12. Changing Applications Later

If you want the double tap to open something different, you generally **do not need to change TD(0)**.

Just change M0.

For example:

### ChatGPT

    [["down", "KC_LGUI"], ["tap", "KC_SPACE"], ["up", "KC_LGUI"], ["delay", 500], ["text", "ChatGPT"], ["delay", 500], ["tap", "KC_ENTER"]]

### Google Chrome

    [["down", "KC_LGUI"], ["tap", "KC_SPACE"], ["up", "KC_LGUI"], ["delay", 500], ["text", "Google Chrome"], ["delay", 500], ["tap", "KC_ENTER"]]

The Tap Dance configuration remains unchanged.

---

# 13. Adjusting Hold/Double-Tap Timing

The current **Tapping Term** is:

    200 ms

This is used by Tap Dance to distinguish between different gestures.

Start with **200 ms**.

If double tapping feels difficult or hold actions trigger unexpectedly, experiment with:

    250 ms

or:

    300 ms

The goal is to find a timing that makes double tapping comfortable without making hold actions feel sluggish.

---

# 14. Other Things a Single GTK01 Key Can Do

Because it is a QMK/Vial device, the button isn't limited to launching applications.

Possible uses include:

- Launch an application
- Open a website
- Open an installed Chrome/PWA app
- Mute/unmute
- Play/pause media
- Adjust volume
- Lock the Mac
- Take a screenshot
- Copy/paste
- Send keyboard shortcuts
- Type frequently used text
- Execute multi-step macros
- Trigger macOS Shortcuts or other automation tools

A particularly powerful approach is:

    GTK01
       ↓
    Unique keyboard shortcut
       ↓
    macOS Shortcut / automation
       ↓
    Complex workflow

This lets the GTK01 initiate operations much more sophisticated than what can reasonably be encoded directly into a keyboard macro.

---

# Quick Reference

## Current setup

    SINGLE TAP
        ↓
      Nothing

    DOUBLE TAP
        ↓
       M0
        ↓
    DBRX Harness

    HOLD
        ↓
       M1
        ↓
      Slack

## M0

    [["down", "KC_LGUI"], ["tap", "KC_SPACE"], ["up", "KC_LGUI"], ["delay", 500], ["text", "DBRX Harness.app"], ["delay", 500], ["tap", "KC_ENTER"]]

## M1

    [["down", "KC_LGUI"], ["tap", "KC_SPACE"], ["up", "KC_LGUI"], ["delay", 500], ["text", "Slack"], ["delay", 500], ["tap", "KC_ENTER"]]

## Architecture

    Physical Key
         ↓
       TD(0)
         ↓
    ┌────┴─────┐
    │          │
   HOLD    DOUBLE TAP
    │          │
   M1         M0
    │          │
  Slack    DBRX Harness