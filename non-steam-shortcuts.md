# Goals
1. Document how to manually create shortcuts for Steam to launch games from all major non-steam storefronts using their native launcher for save support
   - Epic, GOG, Ubisoft, EA (App)
2. Script generation of shortcut fields
3. Script addition of shortcuts directly to Steam's shortcuts VDF file
4. Investiage other launchers/app stores
   - itch.io, Battle.net

# Resources
## Epic Games
Windows link example: com.epicgames.launcher://apps/ff50f85ed609454e80ac46d9496da34d%3A9c7c10e8e1a648f8a9e35f28a1d45900%3Af7a0ebb44f93430fb1c4388a395eba96?action=launch&silent=true   
Generic: com.epicgames.launcher://apps/NamespaceId%ItemId%ArtifactId?acton=launch&silent=true  
Loop Hero ID combination: ff50f85ed609454e80ac46d9496da34d % 3A9c7c10e8e1a648f8a9e35f28a1d45900 % 3Af7a0ebb44f93430fb1c4388a395eba96
Hadies ID combination: 
Installed App ID List: C:\ProgramData\Epic\UnrealEngineLauncher\LauncherInstalled.dat
  * Possibly also: C: \ Program Files \ Epic Games \ "Name of the Game" \.egstore \ MANCPN
  * Possibly also: Epic\\EpicGamesLauncher\\Data\\Manifests


## Uplay/Ubisoft Connect
List of UPlay app IDs: https://github.com/Haoose/UPLAY_GAME_ID  
Launch command: "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\Uplay.exe" "uplay://launch/410/0"  
Installed List: C:\\Program Files (x86)\\Ubisoft\\Ubisoft Game Launcher\\data

## GOG
Launch Command: 
* Target : "C:\Program Files (x86)\GOG Galaxy\GalaxyClient.exe" /command=runGame /gameId=1433856545 /path="C:\GOG Games\Victor Vran"
* Start In : "C:\Program Files (x86)\GOG Galaxy"
* NOTE: /command=runGame (not launch)
GameIDs: ? The ico files have the Game ID
Installed List: 


## EA App


# Steam VDF shortcut strcutre
https://github.com/CorporalQuesadilla/Steam-Shortcut-Manager/wiki/Steam-Shortcuts-Documentation
