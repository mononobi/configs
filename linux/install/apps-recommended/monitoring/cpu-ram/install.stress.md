# CPU Stress Testing and Temperature Monitoring

These tools allow you to stress-test your CPU and monitor temperatures in real-time.

## 1. Installation

Install the required tools:

```bash
sudo apt install s-tui stress
```

## 2. Sensor Detection

To ensure you can see the motherboard and CPU temperatures, you may need to scan for hardware
sensors. Note that on modern systems, this is usually not necessary and might not find
anything.

```bash
sudo sensors-detect
```

> **Note**: Answer with the default (just press `Enter`) to all questions. At the end, if it
> asks to add modules to `/etc/modules`, type `yes`.

If the previous command did not succeed (e.g., because your system is modern), run this
command:

```bash
sensors
```

It should output values for different sensors. Only if the `sensors` command did not produce
output, try loading the kernel module manually:

```bash
sudo modprobe nct6775
sensors
```

> **Warning**: If the second `sensors` command still does not produce any output, you cannot
> use this stress test. If it produced valid output, you can continue.

## 3. Running the Monitoring Tool

Run the monitoring tool:

```bash
sudo s-tui
```

If `s-tui` shows a temperature graph, the setup is successful.

To start the stress test, use the arrow keys to navigate to the "Stress" option in the left
sidebar and press `Space` (or click it if mouse support is active).

Once done, simply press `q` to quit `s-tui`.

## Metrics to Look For

- **Frequency**: Should stay steady roughly close to the maximum (depending on boost). It
  should not drop suddenly to 400MHz or 800MHz, as that indicates thermal throttling.
- **Temperature**: The CPU is designed to run hot. Seeing 85°C or even 90°C is normal under a
  100% synthetic load.
- **System Stability**: Let it run for 10 minutes. If the screen doesn't go blank, the VRMs are
  doing their job.

### Common Sensor Names

- **CPU Temperature**: Tctl / Tccd1 / CPU / Tdie
- **VRM Temperature**: Composite / Motherboard / Temp1 / temp2 / nct6798
- **iGPU Temperature**: Edge
- **RAM Temperature**: Spd*

> **Tip**: If you see a temperature that starts low (e.g., 40°C) and very slowly climbs to
> 50-60°C and stays there, that is the VRM. If it shoots up instantly to 100°C or more, that's
> a problem.
