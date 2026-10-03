# PlayStation Controller Support

To add native support for PS3, PS4, or PS5 controllers to all PlayStation emulators, copy the
related `udev` rules file using the appropriate command below.

## PlayStation 3 Controller

```bash
sudo cp 99-ds3-controllers.rules /etc/udev/rules.d/
```

## PlayStation 4 Controller

```bash
sudo cp 99-ds4-controllers.rules /etc/udev/rules.d/
```

## PlayStation 5 Controller

```bash
sudo cp 99-dualsense-controllers.rules /etc/udev/rules.d/
```

## Reload udev Rules

After copying the appropriate rules file, execute the following command to reload the `udev`
rules:

```bash
sudo udevadm control --reload-rules
```

> **Note:** Disconnect and then reconnect the controller after reloading the rules.

## Emulator Configuration

Now, in each emulator application, go to the controller settings and select the newly added
controller.
