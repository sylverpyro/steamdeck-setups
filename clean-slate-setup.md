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

# Get any and all the extra game launchers
Thankfully moraroy@github has created a very nice non-steam-launcher installer tool just for this.  

Run this and click the desktop icon  
**NOTES**
* Humble App requires Firefox in order to authenticate properly (Brave has a bug with xdg-open)
```
curl --output ~/Desktop/NonSteamLaunchers.desktop -Ls https://github.com/cchrkk/NSLOSD-DL/releases/download/DlLinkFix/NonSteamLaunchers.desktop
```

# Set some performance tweaks
NOTE: I only apply some of the tweaks this author recommends.  I omit 
* Silencing the Watchdog timer
* Disabling CPU vulnrability mitigations (i.e. retbleed)
Source: https://medium.com/@a.b.t./here-are-some-possibly-useful-tweaks-for-steamos-on-the-steam-deck-fcb6b571b577#6c57
```
# Performance CPU govenor (SteamDeck default: schedutil)
cat << EOF | sudo tee /etc/systemd/system/cpu_performance.service
[Unit]
Description=CPU performance governor
[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower frequency-set -g performance
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable cpu_performance.service

# MGLRU memory management (will be default in some future Linux kernel release)
cat << EOF | sudo tee /etc/tmpfiles.d/mglru.conf
w /sys/kernel/mm/lru_gen/enabled - - - - 7
w /sys/kernel/mm/lru_gen/min_ttl_ms - - - - 0
EOF

# Increase the request limit for memory to 2GB (default: 64k)
cat << EOF | sudo tee /etc/security/limits.d/memlock.conf
* hard memlock 2147484
* soft memlock 2147484
EOF

# Set I/O Scheduler to Kyber (default: mq-deadline)
cat << EOF | sudo tee /etc/udev/rules.d/64-ioschedulers.rules
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="kyber"
ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
EOF

# Remove setting 'atime' (defulat: atime) (note: could use relatime)
sudo sed -i -e '/home/s/\bdefaults\b/&,noatime/' /etc/fstab
```
