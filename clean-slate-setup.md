# Get a remote desktop for the deck
* Windows: https://media.steampowered.com/steamlink/windows/latest/SteamLink.zip

# Install Flatpacks
* Heroic
* Brave
* Moonlight Client
```
flatpak install -y com.brave.Browser com.heroicgameslauncher.hgl com.moonlight_stream.Moonlight com.github.mtkennerly.ludusavi
```

# Set a sudo password
* `passwd`

# Get and run coreutils
* `curl -L https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/InstallCryoUtilities.desktop | sh`
* Don't forget to reboot and set VRAM to 4GB

# Get decky plugin manager
* `curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh`

# Get Emudeck
* `curl -L https://www.emudeck.com/EmuDeck.desktop | sh`

# Add your SD card to Steam
* In Desktop mode, add a new Steam Library
  - Steam -> Settings -> Downloads -> Add Steam library Folder

If you are re-using an SD card from a previuos install that used the 'format' method of adding the library
```
cd /run/media/mmcblk0p1
rmdir SteamLibrary/steamapps
mv steamapps SteamLibrary/
```
Then restart Steam to force it to scan the new library folder
  
