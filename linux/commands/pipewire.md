# PipeWire & PulseAudio CLI Control (`pactl`)

Commands for inspecting audio devices, server status, and switching device audio profiles.

---

## Device & Server Inspection

### List All Available Audio Devices (Sound Cards)

```bash
pactl list cards
```

### Inspect Multimedia Server Status

```bash
pactl info
```

---

## Switch Device Audio Profiles

Switch between device profiles (e.g., switching Bluetooth headphones between high-fidelity
playback `a2dp-sink` and low-latency headset microphone mode `headset-head-unit`):

```bash
pactl set-card-profile <DEVICE_NAME> <PROFILE_NAME>
```

### Examples

```bash
# Switch to headset unit profile (HFP/HSP with mSBC codec):
pactl set-card-profile bluez_card.64_A2_F9_FE_EB_39 headset-head-unit-msbc

# Switch to high-fidelity audio sink (A2DP with aptX):
pactl set-card-profile bluez_card.64_A2_F9_FE_EB_39 a2dp-sink-aptx
```

> [!NOTE]  
>
> Obtain `<DEVICE_NAME>` and supported `<PROFILE_NAME>` values from the output of
> `pactl list cards`.
