#!/bin/bash -

# Author: sylverpyro <sylverpyro@users.noreply.github.com>
# Report bugs, issues, and ideas at
#  https://github.com/sylverpyro/steamdeck-setups/issues
# Version: pre-0.1 (alpha)

# Main supprot target is SteamDeck.  Will likely work on any other
# Linux or SteamOS device. 

# Roadmap
# 0.1
#  - Suport for main storefronts: EGL, GOG, EA, Ubisoft, Battle.net, Amazon
#  - Output accurate data for generating steam links for all installed games
# 0.2
#  - Support for generating shortcut data that can be manually added to Steam's shortcuts.vdf
# 0.3
#  - Detect if a shortcut is already in shortcuts.vdf or not and add if missing
# 0.4
#  - Support for other storefronts: itch.io
# 0.5
#  - Switchable compatdata folder paths
#  - config file support (stores paths compatdata folders)
#  - support for compatdata/storefront install folders on sdcard
# 0.6
#  - Auto Detect compatdata folders for all storefronts
# 1.0
#  - All features above
# 2.0
#  - Auto-fetch image data from SteamGridDB
# 3.0
#  - Create shortcuts for NON-INSTALLED games (i.e. library)
#    - Set shortcuts to install & launch the game if selected

# Not on roadmap / may not address
# - Support for game-per-compatdata/prefix
#   - Both detecting these and generating the proper links likely a nightmare
# - Support for Heroic or Lutris installed games
#   - Both of these have built-in steam shortcut generation already
# - Roms
#   - There's tons of great tool for this already (Steam Rom Manager)
# - Windows and OSX Support
#   - There's not a lot of bulk import tools out there for either platform
#   - Very well may some day make a python version that works on Windows
#   - This is EXTREMELY low priority and likely will only occur after 2.0

defaults() {
  # All defaults assume a stock Steamdeck config with all data stored
  # in the main steamapps library at $HOME/.local/share/Steam
  # All Storefront defaults assume they were intalled with 
  # Non-Steam-Game-Launchers on the main storage device (not sdcard)
  # https://github.com/moraroy/NonSteamLaunchers-On-Steam-Deck
  # Support for arbitrary storefront compatdata folders coming in 0.5
  # support for sdcard installed storefronts coming in 0.5

  # The main steam root
  steam_root="$HOME/.local/share/Steam"
  # The steamapps folder
  steamapps_dir="$steam_root/steamapps"
  # The compatdata folder (i.e. proton/wine prefixes)
  compdata_dir="$steamapps_dir/compatdata"

  # Epic Games Launcher paths
  egl_storefront_name="Epic Games Store"
  egl_comp_dir="$compdata_dir/EpicGamesLauncher"
  egl_pfx="$egl_comp_dir/pfx"
  egl_start_dir="$egl_pfx/drive_c/Program Files (x86)/Epic Games"
  egl_exe="$egl_pfx/drive_c/Program Files (x86)/Epic Games/Launcher/Portal/Binaries/Win32/EpicGamesLauncher.exe"
  egl_games_dir="$egl_pfx/drive_c/Program Files/Epic Games"
  # Single file containing all insalled games, names, and IDs
  egl_game_index="$egl_pfx/drive_c/ProgramData/Epic/UnrealEngineLauncher/LauncherInstalled.dat"
  # Alt index sources
  ## Each .item file contains the information for a single game
  # egl_game_items="$egl_pfx/drive_c/ProgramData/Epic/EpicGamesLauncher/Data/Manifests/*.item"
  ## Each directory for each game has a .mancpn file with the required ID data
  # egl_game_mancpn="drive_c/Program Files/Epic Games/*/.egstore/*.mancpn"
  egl_game_manifests="$egl_pfx/drive_c/ProgramData/Epic/EpicGamesLauncher/Data/Manifests"
  egl_game_info_dir="$egl_pfx/drive_c/Program Files/Epic Games"
  #egl_game_info_ext='.mancpn'
  egl_overlay="$egl_pfx/drive_c/Program Files (x86)/Epic Games/Launcher/Portal/Extras/Overlay/EOSOverlayRenderer-Win32-Shipping.exe"
  egl_overlay_64="$egl_pfx/drive_c/Program Files (x86)/Epic Games/Launcher/Portal/Extras/Overlay/EOSOverlayRenderer-Win64-Shipping.exe"

  # GOG
  gog_comp_dir="$compdata_dir/GogGalaxyLauncher"
  gog_pfx="$gog_comp_dir/pfx"
  gog_start_dir="$gog_pfx/drive_c/Program Files (x86)/GOG Galaxy"
  gog_exe="$gog_pfx/drive_c/Program Files (x86)/GOG Galaxy/GalaxyClient.exe"
  gog_games_dir="$gog_pfx/drive_c/Program Files (x86)/GOG Galaxy/Games"

  # EA App
  ## NOTE: EA App games currently do not use either the launcher path or dir for
  ##       generating the shortcut - it's based on the games dir and game exe only
  ea_comp_dir="$compdata_dir/TheEAappLauncher"
  ea_pfx="$ea_comp_dir/pfx"
  ea_exe="$ea_pfx/drive_c/Program Files/Electronic Arts/EA Desktop/EA Desktop/EADesktop.exe"
  ea_games_dir="$ea_pfx/drive_c/Program Files/EA Games"

  # Uplay/Ubisoft Connect
  uc_comp_dir="$compdata_dir/UplayLauncher"
  uc_pfx="$uc_comp_dir/pfx"
  uc_start_dir="$uc_pfx/drive_c/Program Files (x86)/Ubisoft/Ubisoft Game Launcher"
  uc_exe="$uc_comp_dir/drive_c/Program Files (x86)/Ubisoft/Ubisoft Game Launcher/upc.exe"
  uc_games_dir="$uc_pfx/drive_c/Program Files (x86)/Ubisoft/Ubisoft Game Launcher/games"

  # Amazon Games
  amz_comp_dir="$compdata_dir/AmazonGamesLauncher"
  amz_pfx="$amz_comp_dir/pfx"
  amz_exe="drive_c/users/steamuser/AppData/Local/Amazon Games/App/Amazon Games.exe"
  amz_games_dir="$amz_pfx/drive_c/Amazon Games/Library"
}

generate_egl_data() {
  # Make sure the directories are all present
  if [[ ! -d "$egl_comp_dir" ]]; then echo "  Warning: $egl_comp_dir cannot be found"; fi
  if [[ ! -d "$egl_start_dir" ]]; then echo "  Warning: $egl_start_dir cannot be found"; fi
  if [[ ! -f "$egl_exe" ]]; then echo "  Warning: $egl_exe cannot be found" ; fi
  
  # Advise if the overlay has not been disabled yet
  if [[ -f "$egl_overlay" ]]; then
    echo "NOTE: EGL Overlay enabled - disable with: mv \"$egl_overlay\" \"${egl_overlay}-disabled\""
  fi
  if [[ -f "$egl_overlay_64" ]]; then
    echo "NOTE: EGL Overlay enabled - disable with: mv \"$egl_overlay_64\" \"${egl_overlay_64}-disabled\""
  fi

  # Generate the Launcher shortcut
  generate_shortcut_data "$egl_storefront_name" "$egl_exe" "$egl_start_dir" "$egl_comp_dir" ""

  # Generate shortcuts for all installed games
  while IFS= read -r -d $'\0' game_dir; do
    # Pull the game's name off the game directory
    #display_name="$(basename "$game_dir")"

    # Find the .mancpn file for the game which contains the ID info we need to build the launch command
    local mancpn_file="$(find "$game_dir" -name '*.mancpn')"

    # NOTE: We need to sript out all non printing characters except NEWLINE as these
    #       files are DOS formatted

    # Get the NameSpace ID
    local namespaceId=$(tr -cd '[:print:]\n' <"$mancpn_file" | grep '"CatalogNamespace": ' | tr -d '", \t' | cut -d ':' -f 2)
    #echo "name Id: $namespaceId"

    # Get the Catalog Item ID
    local itemId=$(tr -cd '[:print:]\n' <"$mancpn_file" | grep '"CatalogItemId": ' | tr -d '", \t' | cut -d ':' -f 2)
    #echo "item ID: $itemId"

    # Get the Artifact ID
    local artifactId=$(tr -cd '[:print:]\n' <"$mancpn_file" | grep '"AppName": ' | tr -d '", \t' | cut -d ':' -f 2)
    #echo "art  ID: $artifactId"

    # The easiest definitive location to get the display name is actually out of the
    # install manifest at.  The probelm is there's no way to guess from the name or
    # path which file is ours, so we need to grep for it based on the Catalog ID as that
    # is likely globally unique across ALL items
    local item_file="$(grep -H "\"MainGameCatalogItemId\": \"$itemId\"," "$egl_game_manifests/"*.item | cut -d ':' -f 1)"
    
    # Now grab the dispaly name from the item file
    local display_name="$(grep -m 1 '"DisplayName": ' "$item_file" | cut -d '"' -f 4)"

    # Print out the info needed to assemble the shortcut
    printf 'name       : %s\n' "$display_name"
    printf 'target     : "%s"\n' "$egl_exe"
    printf 'start in   : "%s"\n' "$egl_start_dir"
    printf 'launch opts: STEAM_COMPAT_DATA_PATH="%s" %%command%% -com.epicgames.launcher://apps/%s%%3A%s%%3A%s?action=launch&silent=true\n' \
      "$egl_comp_dir" "$namespaceId" "$itemId" "$artifactId"
    
    ## New generation method
    #local cmd_opts="-com.epicgames.launcher://apps/$namespaceId%%3A$itemId%%3A$artifactId?action=launch&silent=true"
    #generate_shortcut_data "$display_name" "$egl_exe" "$egl_start_dir" "$egl_comp_dir" "$cmd_opts"
    
    echo ""
  done < <(find "$egl_game_info_dir" -mindepth 1 -maxdepth 1 -type d -print0)
}

generate_gog_data() {
  # We will need to convert some paths into windows paths relative to the
  # wine prefix so generate a handle for that now
  local trim="$gog_pfx/drive_c/"

  # Generate the storefront shortcut
  generate_shortcut_data "GoG Galaxy" "$gog_exe" "$gog_start_dir" "$gog_comp_dir" ""

  while IFS= read -r -d $'\0' game_dir; do
    #echo "game dir: $game_dir"

    # Convert the Linux game dir path to a Windows path since we need to present
    # this to a windows exe shortly inside a wine pfx so the exe will see
    # C:\ instead of .../pfx/drive_c

    # Get the full path to the game directory
    local full_install_dir="$(realpath --no-symlinks "$game_dir")"
    #echo "full dir: $full_install_dir"

    # Trim off the wine prefix and add C:/ ala-windows
    local trimmed_install_dir="C:/${full_install_dir/$trim/}"
    #echo "trimmed dir: $trimmed_install_dir"

    # Finally, swap all linux dir seperators '/' to windows dir seperators '\'
    local converted_dir="${trimmed_install_dir//\//\\}"
    #echo "Converted dir: $converted_dir"

    # Some games have MULTIPLE .info files as each DLC get's a file
    # e.g. Shovel Knight TT, Dead Cells + DLC
    # To get the MAIN game ID we need to either check the .ico file
    # OR scan for 'rootGameId' across all .info files (which in turn only
    # exists IF there are DLC .info files, otherwise it's just gameId).
    # choosing to go with the former as we only have to process a single file

    # Identify the goggame-*.ico file for the game
    local icon_file="$(find "$game_dir" -maxdepth 1 -type f -name 'goggame-*.ico')"
    #echo "icon file: $icon_file"

    # Extract the gameID from the ico file name
    local gameId="$(basename --suffix='.ico' "$icon_file" | cut -d '-' -f 2)"
    #echo "gameid: $gameId"

    # Generate a file handle for the MAIN gameIDs .info file
    local info_file="$game_dir/goggame-$gameId.info"
    #echo "info file: $info_file"

    ## No longer used
    # Extract the gameID from the games .info file
    #gameId="$(tr -cd '[:print:] \n' <"$info_file" | grep '"gameId":' | tr -d ' ",' | cut -d ':' -f 2)"

    # Extract the game name from the .info file
    # This occurs multiple times in the file and we're lazy and don't want to add
    # a JSON processor so just take the first hit
    # NOTE: try grep -m 1 instead of head -n 1
    local display_name="$(tr -cd '[:print:] \n' <"$info_file" | grep '"name":' | head -n 1 | cut -d '"' -f 4 | head -n 1)"
    #echo "dispaly name: $display_name"
    #echo ""
    
    # Print out the shortcut data
    printf 'name       : %s\n' "$display_name"
    printf 'target     : "%s"\n' "$gog_exe"
    printf 'start in   : "%s"\n' "$gog_start_dir"
    printf 'launch opts: STEAM_COMPAT_DATA_PATH="%s" %%command%% /command=runGame /gameID=%s /path="%s" \n' "$gog_comp_dir" "$gameId" "$converted_dir"
    ## New print method
    #local cmd_opts="/command=runGame /gameID=$gameId /path=\"$converted_dir\""
    #generate_shortcut_data "$display_name" "$gog_exe" "$gog_start_dir" "$gog_comp_dir" "$cmd_opts"
    echo ""
  done < <(find "$gog_games_dir" -mindepth 1 -maxdepth 1 -type d -print0)
  echo ""
}

# Generate shortcut data 
generate_shortcut_data() { # name target start_dir compat_dir command_opts 
  local name="$1"
  local target="$2"
  local start_dir="$3"
  local compat_dir="$4"
  local command_opts="$5"
  printf 'name       : %s\n' "$name"
  printf 'target     : "%s"\n' "$target"
  printf 'start in   : "%s"\n' "$start_dir"
  printf 'launch opts: STEAM_COMPAT_DATA_PATH="%s" %%command%% %s \n' "$compat_dir" "$command_opts"
  echo ""


}

work() {
  generate_egl_data
  generate_gog_data
}

main() {
  defaults
  work
}

main
