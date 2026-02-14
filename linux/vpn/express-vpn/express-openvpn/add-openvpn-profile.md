## ExpressVPN Using OpenVPN Connection

This guide will show you how to set up ExpressVPN using OpenVPN profiles in Ubuntu.
A full guide is also available at 
[Manual Config for Linux Ubuntu with OpenVPN](https://www.expressvpn.com/support/vpn-setup/manual-config-for-linux-ubuntu-with-openvpn/).

### Step 1: Create The Directories

Run the following commands to create the required directories:

```bash
mkdir -p ~/.expressvpn/profiles
mkdir -p ~/.expressvpn/keys
```

### Step 2: Download The OpenVPN Profiles and Credentials

Go to the [ExpressVPN Manual Setup](https://portal.expressvpn.com/setup#manual):

- Copy the `Username` and `Password` that are shown there and put them in a `credentials.txt` file.
- Download profiles (**.ovpn**) for the servers that you want to be able to connect to.

### Step 3: Download The VPN Keys and Certificates

Go to the [Account](https://www.expressvpn.com/support/vpn-setup/manual-config-for-linux-ubuntu-with-openvpn/#account)
section and download the [Zip File](https://s23429.pcdn.co/wp-content/uploads/2015/11/my_expressvpn_keys-1.zip)
containing the VPN keys and certificates.

> Note: The link to the **Zip File** might change in the future, you can find the current 
> link on the above **Account** section.

### Step 4: Extract The Downloaded OpenVPN Profiles and The Keys File

Extract all the downloaded files.

Copy the profiles to the created directory:
```bash
cp *.ovpn ~/.expressvpn/profiles
```

Copy the key files to the created directory:
```bash
cp *.crt *.key ~/.expressvpn/keys
```

Move the `credentials.txt` file to the created directory and 
make it accessible only by the root user:
```bash
mv credentials.txt ~/.expressvpn/
sudo chown root:root ~/.expressvpn/credentials.txt
sudo chmod 600 ~/.expressvpn/credentials.txt
```

To see the credentials when you want to add profiles, run this:
```bash
sudo cat ~/.expressvpn/credentials.txt
```

### Step 5: Open The VPN Settings and Import a Profile

Go to the following location and select one of the profiles (**.ovpn**) you have already 
downloaded on the **Step 1**:

> Ubuntu Settings → Network → VPN → **+** → Import from file...

### Step 6: Configure The Profile

On the opened window, set these settings on different tabs:

#### Details Tab:

- **Make available to other users:** `On`

#### Identity Tab:

- **Name:** A name to recognize the profile (e.g. `Exp-London`, `Exp-Estonia`)
- **Type:** `Password with Certificates (TLS)`
- **Username:** Put the username you got on the **Step 1**
- **Password:** Put the password you got on the **Step 1**

> Note: On the **Password** field click on the button on the right 
> and select **Store the password for all users**.

Click on the **Advanced** button on the same tab:

- **Use custom gateway port:** `1195`
- **Data Compression:** `Off`
- **Use custom tunnel Maximum Transmission Unit (MTU):** `1500`
- **Use custom UDP fragment size:** `1300`
- **Restrict tunnel TCP Maximum Segment Size (MSS):** `On`
- **Randomize remote hosts:** `On`

#### Security Tab:

- **Cipher:** `AES-256-GCM`
- **HMAC Authentication:** `SHA-512`

#### TLS Authentication Tab:

- **Key File:** Locate the folder where the Zip file from the **Step 2** was saved earlier, 
  then select the `ta.key` file and click **Open**.
- **Key Direction:** `1`

> Click on the **Apply** button on the **Advanced Properties** form.

> Click on the **Add** button on the **Add VPN** form.

> Now you can connect to the added VPN server through the Ubuntu VPN toggle.

> Important:
> On the official ExpressVPN guide it is mentioned to use **Custom cipher key size** and also
> to enable **Data compression**. But enabling any of these settings will cause the VPN
> connection to fail. Other than that, enabling data compression is considered a security
> risk and should be avoided.

### Adding Profiles Using Command Line

Instead of manually adding every profile using the Ubuntu VPN settings, you can run the
`openvpn-add` and `openvpn-bulk-add` scripts to add profiles automatically.

> Note: Modify the **TA_KEY_PATH** in the `openvpn-add` script to point to the location 
> where you have saved the `ta.key` file if needed.

Make the scripts executable:
```bash
chmod +x ./scripts/openvpn-add
chmod +x ./scripts/openvpn-bulk-add
```

Copy the both scripts into the local `bin` folder to be able 
to run them as a command from anywhere:
```bash
cp ./scripts/openvpn-add ~/.local/bin/
cp ./scripts/openvpn-bulk-add ~/.local/bin/
```

Run this command to add a single profile:
```bash
openvpn-add
```

Run this command to add multiple profiles from a directory:
```bash
openvpn-bulk-add
```

> Notes: 
> - Do not run the scripts as root user (**sudo**). Run as normal user.
> - After adding each profile using the scripts, the VPN won't connect. To fix this, you need 
> to edit that profile and go to the **Identity Tab** and add an arbitrary space in the name 
> field and remove it just for the **Apply** button to get enabled and then click on 
> the **Apply** button. Now the VPN can be used without issues.
