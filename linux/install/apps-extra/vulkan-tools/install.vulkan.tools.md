# Vulkan Tools

`vulkan-tools` is a utility for inspecting Vulkan information on your system. You must have a
Vulkan-enabled GPU to use it.

## Installation

To install `vulkan-tools`, run the following command:

```bash
sudo apt install vulkan-tools
```

## Usage

To get information on your installed Vulkan instance (including Vulkan and Mesa versions),
execute:

```bash
vulkaninfo
```

## Google Chrome Integration

### Checking Vulkan Status

To check whether the Vulkan backend is enabled in Google Chrome, type the following into the
URL bar:

```text
chrome://gpu
```

### Enabling Vulkan Backend

If your GPU supports Vulkan, you can enable it in the Chrome browser as the graphics backend.
Navigate to the following address in the URL bar and set it to **Enabled**:

```text
chrome://flags/#enable-vulkan
```

> **NOTE**: If your GPU supports Vulkan but Chrome crashes after enabling the Vulkan backend,
> it could be because the Mesa driver version on your system is outdated.
