# audio-output-switcher

A single bash script that switches macOS audio output to a named device. No dependencies beyond macOS itself — it uses an inline Swift snippet to call CoreAudio directly.

## Requirements

- macOS (tested on Sequoia)
- Xcode Command Line Tools (`xcode-select --install`)

## Usage

```bash
# Switch to the default device (Multi Monitor 220)
./switch-audio.sh

# Switch to a specific device by name
./switch-audio.sh "External Speakers"
```

To change the default device, edit the fallback value on line 5 of `switch-audio.sh`:

```bash
DEVICE_NAME="${1:-MacBook Pro Speakers}"
```

## Finding device names

List all output devices on your system:

```bash
system_profiler SPAudioDataType
```

## Automation

To auto-switch when Bluetooth speakers connect, use the macOS **Shortcuts** app:

1. Create a new Automation triggered by **Bluetooth** device connection
2. Add a **Run Shell Script** action pointing to this script
