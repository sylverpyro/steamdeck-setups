# Get Ludusavi v0.18 or higher
```
flatpak install com.github.mtkennerly.ludusavi
```

# Get the latest rclone
Ludusavi does not ship an rclone clinet so if we want 'cloud' support we need to provide one.

rclone unfortunaltely has chosen to not release a flatpak as 'there are no security advantages' over the portable install of the client  
* https://forum.rclone.org/t/flatpak-support/25207  

```
# Make sure there's a bin directory
test -d ~/bin || mkdir ~/bin
# Pull the latest rclone
cd ~/tmp
wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
# Extract it
unzip rclone-current-linux-amd64.zip
# Copy it into bin (force in case this is an update)
cp --force rclone-*-linux-amd64/rclone ~/bin
# Remove the tmp files
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