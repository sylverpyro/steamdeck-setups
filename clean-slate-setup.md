# Get a remote desktop for the deck
* Windows: https://media.steampowered.com/steamlink/windows/latest/SteamLink.zip

# Install Flatpacks
* Heroic (works well... when it's not broken... for EGL and GOG)
* Lutris (works for everything Heroic does not, including EGL and GOG)
* Brave  (personal browser preference)
* Moonlight Client (Better streaming client than RemotePlay)
* Ludusavi (Save AND CLOUD SAVE backup manager)
```
flatpak install -y com.brave.Browser com.heroicgameslauncher.hgl com.moonlight_stream.Moonlight com.github.mtkennerly.ludusavi net.lutris.Lutris
```

# Set a sudo password
This is needed for coreutils and Decky
```
passwd
```

# Get and run coreutils
```
curl https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/install.sh | bash -s --
```
* Don't forget to reboot and set VRAM to 4GB after everything is done

# Get decky plugin manager
```
curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
```

# Get Emudeck
```
curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash
```

# Add your SD card to Steam
* In Desktop mode, add a new Steam Library
  - Steam -> Settings -> Downloads -> Add Steam library Folder

If you are re-using an SD card from a previuos install, you'll need to move your `steamapps` directory into the new SteamLib folder  
**WARNING:** Ultimately this does not work very well.  You're better off deleting the `steamapps` dir and re-downloading your Steam games
```
cd /run/media/mmcblk0p1
rmdir SteamLibrary/steamapps
mv steamapps SteamLibrary/
```
Then restart Steam to force it to scan the new library folder
  
# Fix MTU probing for Ubisoft Connect
This fixes problems where the Ubisoft Connect client and games cannot reach the Ubisoft Servers
* https://github.com/ValveSoftware/Proton/issues/6260
```
sudo sysctl -w net.ipv4.tcp_mtu_probing=1
echo net.ipv4.tcp_mtu_probing=1 | sudo tee /etc/sysctl.d/zzz-custom-mtu-probing.conf
```
