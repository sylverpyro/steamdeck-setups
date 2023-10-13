# Get a remote desktop for the deck
Unless you like typing on a tiny screen with the SD OSK : )
* Windows: https://media.steampowered.com/steamlink/windows/latest/SteamLink.zip

# Install Flatpacks
## Broken (functionally)
Broken: Heroic (EGL, GOG, and Amazon Games - Frequently breaks however)
  - Heroic almost never properly works, or at least doesn't work for long
  - Cloud save support is in beta any only for Heroic (no GOG support)
  - Alternative: Use non-steam launchers below

Semi-Broken: Lutris (works for everything Heroic does not, including EGL and GOG)
  - Lutris has a better record than Heroic, but still frequently has problems with many games and sometimes just completely breaks
  - No cloud save support for other storefronts
  - Alternative: Use non-steam launchers below
## Working and useful
* Brave  (personal browser preference)
* Moonlight Client (Better streaming client than RemotePlay)
* Ludusavi (Save AND CLOUD SAVE backup manager)
```
flatpak install -y com.brave.Browser com.moonlight_stream.Moonlight com.github.mtkennerly.ludusavi
```

# Set a sudo password
This is needed for coreutils and Decky
```
passwd
```

# Get and run coreutils
Sets up some known optomizations for the SD, updated frequently
```
curl https://raw.githubusercontent.com/CryoByte33/steam-deck-utilities/main/install.sh | bash -s --
```

# Get decky plugin manager
Unless you don't like plugins
```
curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
```

# Get Emudeck
If you emulate
```
curl -L https://raw.githubusercontent.com/dragoonDorise/EmuDeck/main/install.sh | bash
```

# Add your SD card to Steam
* In Desktop mode, add a new Steam Library
  - Steam -> Settings -> Downloads -> Add Steam library Folder

If you are re-using an SD card from a previuos install, you'll need to move your `steamapps` directory into the new SteamLib folder  

**NOTE:** Usually this does not work very well.  You're better off deleting the `steamapps` dir and re-downloading your Steam games
```
# Move an old 'steamapps' folder into the new (expected) steam library
cd /run/media/mmcblk0p1
rmdir SteamLibrary/steamapps
mv steamapps SteamLibrary/
```
Then restart Steam to force it to scan the new library folder.
  
# Fix MTU probing for Ubisoft Connect
This fixes problems where the Ubisoft Connect client and games cannot reach the Ubisoft Servers
* https://github.com/ValveSoftware/Proton/issues/6260
```
sudo sysctl -w net.ipv4.tcp_mtu_probing=1
echo net.ipv4.tcp_mtu_probing=1 | sudo tee /etc/sysctl.d/zzz-custom-mtu-probing.conf
```

# Get non-steam game storefrontts
Thankfully moraroy@github has created a very nice non-steam-launcher installer tool just for this.  

Notes
* Humble App requires Firefox in order to authenticate properly (Brave has a bug with xdg-open)
* At the time of this writing you'll want to make sure to select all of the launchers you want at once, otherwise it will add launchers multiple times (one additional copy for each time you run it)
```
curl --output ~/Desktop/NonSteamLaunchers.desktop -Ls https://github.com/cchrkk/NSLOSD-DL/releases/download/DlLinkFix/NonSteamLaunchers.desktop
```

# Set some performance tweaks
NOTE: I only apply some of the tweaks this author recommends.  I omit 
* Silencing the Watchdog timer
  * This functionality force reboots your device if it ever locks up SO BADLY that it longer will accept any input OR power button long-presses
  * You can disable it, but recovering from a soft-lock may become difficult
* Disabling CPU vulnrability mitigations (i.e. retbleed)

Source: https://medium.com/@a.b.t./here-are-some-possibly-useful-tweaks-for-steamos-on-the-steam-deck-fcb6b571b577#6c57

```
# Performance CPU govenor (SteamDeck default: schedutil)
## According to *opinions* this doesn't cost much in the way of power consumption
## as selective-core-sleep remains enabled
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

# MGLRU memory management 
# This will actually be default in some future Linux kernel release, it just
# isn't quite yet
cat << EOF | sudo tee /etc/tmpfiles.d/mglru.conf
w /sys/kernel/mm/lru_gen/enabled - - - - 7
w /sys/kernel/mm/lru_gen/min_ttl_ms - - - - 0
EOF

# Increase the request limit for memory to 2GB (default: 64k)
# This is a widely known ancient limit in the default Linux config that
# maintiners have declined to change as it only affects a limited number
# of use cases (i.e. Gaming, research software, ect.)
cat << EOF | sudo tee /etc/security/limits.d/memlock.conf
* hard memlock 2147484
* soft memlock 2147484
EOF

# Set I/O Scheduler to Kyber (default: mq-deadline)
# Supposedly Kyber is superior as it's more modern.  Probably will
# only notice if you're playing games that need to stream a lot of
# data/textures from the ssd
cat << EOF | sudo tee /etc/udev/rules.d/64-ioschedulers.rules
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="kyber"
ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
EOF

# Disable setting file access times 'atime' (defulat: atime)
# (note: could use relatime if access times ever become importnat)
# WARNING: Don't run this more than once as it will add multiple 'noatime'
#          flags to the mount line
sudo sed -i -e '/home/s/\bdefaults\b/&,noatime/' /etc/fstab
```
