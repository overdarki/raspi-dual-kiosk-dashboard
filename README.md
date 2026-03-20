# raspi-dual-kiosk-dashboard

A lightweight bash-based kiosk setup for Raspberry Pi that launches two Chromium instances in full-screen kiosk mode — one per HDMI output — and autostarts on login.

## Why this project?

Since none of the currently available solutions worked for my setup, I am publishing this workaround to help anyone trying to run a dual-monitor dashboard in Kiosk mode on Raspberry Pi OS.

### The Problem
The main challenge was that the `--window-position` flag was consistently ignored when running the startup sequence as an autostart script, even though it worked fine when entered manually in the terminal.

### The Solution (Workaround)
During testing, I discovered that Chromium in Kiosk mode always initializes on the screen where the mouse cursor is currently located. 

To solve this, this script uses a strategic timing and positioning workaround:
1. **Target Display 1:** The mouse cursor is moved to the first screen before the first Chromium instance is launched.
2. **Delay:** A short pause ensures the first instance is correctly assigned to the display.
3. **Target Display 2:** The mouse is then moved to the coordinates of the second detected screen, and the second Chromium instance is started.
4. **Cleanup:** Finally, the mouse cursor is hidden using `unclutter` and moved to the bottom-right corner of the screen as a fail-safe.

---

## Requirements

- Raspberry Pi (tested on Pi 5) with Raspberry Pi OS (Wayland/wlroots compositor)
- Two monitors connected via HDMI-1 and HDMI-2
- The following packages installed:

```bash
sudo apt install wlrctl unclutter
```

---

## Installation

### 1. Clone or copy the script

```bash
wget -O /home/pi/raspi-dual-kiosk-dashboard.sh https://raw.githubusercontent.com/overdarki/raspi-dual-kiosk-dashboard/refs/heads/main/raspi-dual-kiosk-dashboard.sh
chmod +x /home/pi/raspi-dual-kiosk-dashboard.sh
```

### 2. Set your dashboard URLs

Edit the script and replace the placeholder URLs:

```bash
URL_DISPLAY_1="https://your-first-dashboard.example.com"
URL_DISPLAY_2="https://your-second-dashboard.example.com"
```

### 3. Enable autostart

Create a `.desktop` entry so the script runs automatically on login:

```bash
mkdir -p /home/pi/.config/autostart

cat << EOF > /home/pi/.config/autostart/raspi-dual-kiosk-dashboard.desktop
[Desktop Entry]
Type=Application
Name=Raspi Dual Kiosk Dashboard
Exec=/bin/bash /home/pi/raspi-dual-kiosk-dashboard.sh
EOF
```

---

## How it works

On startup the script:

1. Waits a few seconds for the desktop environment to be ready
2. Uses `xrandr` to detect the horizontal offset of the second monitor (`HDMI-A-2`)
3. Moves the mouse cursor to the primary display and launches the first Chromium instance there
4. Moves the cursor to the second display and launches the second Chromium instance there
5. Parks the cursor in the bottom-right corner and starts `unclutter` to hide it during inactivity

Chromium is launched with a set of flags that suppress all UI chrome, dialogs, update prompts, and gestures to ensure a clean, uninterrupted kiosk experience.

---

## Configuration

| Variable | Description |
|---|---|
| `URL_DISPLAY_1` | URL loaded on the primary display (HDMI-1, left) |
| `URL_DISPLAY_2` | URL loaded on the secondary display (HDMI-2, right) |
| `sleep 5` (startup) | Delay before launching — increase if the desktop takes longer to load on older Raspberry Pi devices |

---

## Troubleshooting

**Both windows open on the same display**
Increase the `sleep 10` delay between the two Chromium launches to give the first instance more time to claim its window before the cursor moves.

**Second monitor not detected**
Verify that `xrandr` lists `HDMI-A-2 connected`. The connector name may differ on your hardware — check with:
```bash
xrandr | grep connected
```
Then update the `grep` pattern in the script accordingly.

**Script doesn't run on login**
Make sure the `.desktop` file exists in `~/.config/autostart/` and that the autostart directory is being processed by your desktop environment (standard on LXDE/LXQt-based Raspberry Pi OS).

---

## License

MIT
