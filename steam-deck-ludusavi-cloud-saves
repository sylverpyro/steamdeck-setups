# Get Ludusavi v0.18 or higher
```
flatpak install com.github.mtkennerly.ludusavi
```

# Get the latest rclone
rclone unfortunaltely has choses to not release a flatpak as 'there are no security advantages' over the portable install of the client
* https://forum.rclone.org/t/flatpak-support/25207
So we have to install it manually
```
test -d ~/bin || mkdir ~/bin
cd ~/tmp
wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip
cp rclone-*-linux-amd64/rclone ~/bin
rm --recursive rclone-*-linux-amd64*
```

# Configure Ludusavi
**NOTE** Make SURE you give Ludusavi a UNIQUE folder to sync to (see NOTES section)
* Launch Ludusavi
* Click the `OTHER` menu
* In the `Cloud` section
  * Rclone: `/home/deck/bin/rclone`
  * Remote: *Select your cloud provider*
  * Folder: `ludusavi-steam-deck-backup`
  
# Notes
At the time of this writing, Ludusavi will synchronize it's local backup to your cloud provider.  While the transactions on the local copy of your backups is transactional (discrete items are updated each time you run a backup), the Cloud sync is NOT transactional and will simply overwrite the contents of the folder you provide.  

Because of this DO NOT attempt to point two copies of Ludusavi at the same could folder.  You WILL lose data!
