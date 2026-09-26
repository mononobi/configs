# .NET 9 Installation

Use the following commands to install the .NET 9 SDK, ASP.NET Core Runtime, and .NET Runtime, as well as configure developer certificates and install the MAUI Android workload.

## 1. Install .NET 9 SDK and Runtimes

Add the repository and install the packages:

```bash
sudo add-apt-repository ppa:dotnet/backports
sudo apt-get update && sudo apt-get install -y dotnet-sdk-9.0
sudo apt-get update && sudo apt-get install -y aspnetcore-runtime-9.0
sudo apt-get install -y dotnet-runtime-9.0
```

## 2. Post-Installation Setup

Trust the development certificates and install the `.NET MAUI` Android workload:

```bash
sudo dotnet dev-certs https --trust
sudo dotnet workload install maui-android
```
