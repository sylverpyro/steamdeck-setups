# Goals
1. Document how to manually create shortcuts for Steam to launch games from all major non-steam storefronts using their native launcher for save support
   - Epic, GOG, Ubisoft, EA (App)
2. Script generation of shortcut fields
3. Script addition of shortcuts directly to Steam's shortcuts VDF file
4. Investiage other launchers/app stores
   - itch.io, Battle.net

# Resources
## Epic Games
Windows link example: 
```
com.epicgames.launcher://apps/ff50f85ed609454e80ac46d9496da34d%3A9c7c10e8e1a648f8a9e35f28a1d45900%3Af7a0ebb44f93430fb1c4388a395eba96?action=launch&silent=true
```
Generic: 
```
com.epicgames.launcher://apps/NamespaceId%3AItemId%3AArtifactId?acton=launch&silent=true
Field Seperator = %3A
```
Loop Hero ID combination: 
```
ff50f85ed609454e80ac46d9496da34d %3A 9c7c10e8e1a648f8a9e35f28a1d45900 %3A f7a0ebb44f93430fb1c4388a395eba96
```
Hadies ID combination:  
```
min %3A fb39bac8278a4126989f0fe12e7353af %3A Min
```
Installed App ID List:
* `C:\ProgramData\Epic\UnrealEngineLauncher\LauncherInstalled.dat`
   * InstallLocation == InstallLocation
   * NamespaceId == NamespaceId
   * ItemId == ItemId
   * ArtifactId == ArtifactId
* Also: `c:\programData\Epic\EpicGamesLauncher\Data\Manifests`
   * InstallLocation == InstallLocation 
   * CatalogNamespace == NamespaceID
   * CatalogItemId == ItemID
   * AppName == ArtifactID

Individual App IDs: `C:\Program Files\Epic Games\GAME_NAME\.egstore\*.mancpn`
  * CatalogNamespace == NamespaceID
  * CatalogItemId == ItemID
  * AppName == ArtifactID


Disable Overlay
* Rename both:
   * `C:\Program Files (x86)\Epic Games\Launcher\Portal\Extras\Overlay\EOSOverlayRenderer-Win64-Shipping.exe`
   * `C:\Program Files (x86)\Epic Games\Launcher\Portal\Extras\Overlay\EOSOverlayRenderer-Win32-Shipping.exe`

Steam Shortcut (Windows) For Hades:
   * Target: `"C:\Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"`
   * Start In: `"C:\Program Files (x86)\Epic Games\"`
   * Launch Options: `%command% -com.epicgames.launcher://apps/min%3Afb39bac8278a4126989f0fe12e7353af%3AMin?action=launch&silent=true`

Steam Shortcut (SteamOS) For Hades:
   * Target: `"/home/deck/.local/Steam/steamapps/comptadata/EpicGamesLauncher/pfx/drive_c/Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"`
   * Start In:  `"/home/deck/.local/Steam/steamapps/comptadata/EpicGamesLauncher/pfx/drive_c/Program Files (x86)\Epic Games\"`
   * Launch Options: `STEAM_COMP_DATA="/home/deck/.local/Steam/steamapps/comptadata/EpicGamesLauncher" %command% -com.epicgames.launcher://apps/min%3Afb39bac8278a4126989f0fe12e7353af%3AMin?action=launch&silent=true`

## Uplay/Ubisoft Connect
List of UPlay app IDs: https://github.com/Haoose/UPLAY_GAME_ID  
Launch command: `"C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\Uplay.exe" "uplay://launch/410/0"  `
Installed List: `C:\\Program Files (x86)\\Ubisoft\\Ubisoft Game Launcher\\data  `

## GOG
Launch Command:  
* Target : `"C:\Program Files (x86)\GOG Galaxy\GalaxyClient.exe" /command=runGame /gameId=1433856545 /path="C:\GOG Games\Victor Vran"  `
* Start In : `"C:\Program Files (x86)\GOG Galaxy"  `
* NOTE: `/command=runGame` (not launch)  
GameIDs: ? The ico files have the Game ID  
Installed List:  


## EA App


# Steam VDF shortcut strcutre
https://github.com/CorporalQuesadilla/Steam-Shortcut-Manager/wiki/Steam-Shortcuts-Documentation
