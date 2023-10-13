#!/bin/bash -

defaults() {
  steam_root="$HOME/.local/share/Steam"
  steamapps_dir="$steam_root/steamapps"
  compdata_dir="$steamapps_dir/compatdata"

  # Epic Games Launcher
  egl_comp_dir="$compdata_dir/EpicGamesLauncher"
  egl_pfx="$egl_comp_dir/pfx"
  egl_start_dir="$egl_pfx/drive_c/Program Files (x86)/Epic Games"
  egl_exe="$egl_pfx/drive_c/Program Files (x86)/Epic Games/Launcher/Portal/Binaries/Win32/EpicGamesLauncher.exe"
  egl_games_dir="$egl_pfx/drive_c/Program Files/Epic Games"
  egl_game_index="$egl_pfx/drive_c/ProgramData/Epic/UnrealEngineLauncher/LauncherInstalled.dat"
  # Alt index sources
  ## Each .item file contains the information for a single game
  # egl_game_index="$egl_pfx/drive_c/ProgramData/Epic/EpicGamesLauncher/Data/Manifests/*.item"
  ## Each directory for each game has a .mancpn file with the required ID data
  # egl_game_index="drive_c/Program Files/Epic Games/*/.egstore/*.mancpn"
  egl_game_manifests="$egl_pfx/drive_c/ProgramData/Epic/EpicGamesLauncher/Data/Manifests"
  egl_game_info_dir="$egl_pfx/drive_c/Program Files/Epic Games"
  egl_game_info_ext='.mancpn'
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
  if [[ ! -d "$egl_comp_dir" ]]; then echo "  Warning: $egl_comp_dir cannot be found"; fi
  if [[ ! -d "$egl_start_dir" ]]; then echo "  Warning: $egl_start_dir cannot be found"; fi
  if [[ ! -f "$egl_exe" ]]; then echo "  Warning: $egl_exe cannot be found" ; fi
  if [[ -f "$egl_overlay" ]]; then
    echo "NOTE: EGL Overlay enabled - disable with: mv \"$egl_overlay\" \"${egl_overlay}-disabled\""
  fi
  if [[ -f "$egl_overlay_64" ]]; then
    echo "NOTE: EGL Overlay enabled - disable with: mv \"$egl_overlay_64\" \"${egl_overlay_64}-disabled\""
  fi
  # Demo that works
  #display_name=Hades
  #namespaceId=min
  #itemId=fb39bac8278a4126989f0fe12e7353af
  #artifactId=Min
  #printf 'name       : %s\n' "$display_name"
  #printf 'target     : "%s"\n' "$egl_exe"
  #printf 'start in   : "%s"\n' "$egl_start_dir"
  #printf 'launch opts: STEAM_COMPAT_DATA_PATH="%s" %%command%% -com.epicgames.launcher://apps/%s%%3A%s%%3A%s?action=launch&silent=true\n' \
  #  "$egl_comp_dir" "$namespaceId" "$itemId" "$artifactId"
  #echo ""

  while IFS= read -r -d $'\0' game_dir; do
    # Pull the game's name off the game directory
    #display_name="$(basename "$game_dir")"

    # Find the .mancpn file for the game which contains the ID info we need to build the launch command
    mancpn_file="$(find "$game_dir" -name '*.mancpn')"

    # NOTE: We need to sript out all non printing characters except NEWLINE as these
    #       files are DOS formatted

    # Get the NameSpace ID
    namespaceId=$(tr -cd '[:print:]\n' <"$mancpn_file" | grep '"CatalogNamespace": ' | tr -d '", \t' | cut -d ':' -f 2)
    #echo "name Id: $namespaceId"

    # Get the Catalog Item ID
    itemId=$(tr -cd '[:print:]\n' <"$mancpn_file" | grep '"CatalogItemId": ' | tr -d '", \t' | cut -d ':' -f 2)
    #echo "item ID: $itemId"

    # Get the Artifact ID
    artifactId=$(tr -cd '[:print:]\n' <"$mancpn_file" | grep '"AppName": ' | tr -d '", \t' | cut -d ':' -f 2)
    #echo "art  ID: $artifactId"

    # The easiest definitive location to get the display name is actually out of the
    # install manifest at.  The probelm is there's no way to guess from the name or
    # path which file is ours, so we need to grep for it based on the Catalog ID as that
    # is likely globally unique across ALL items
    item_file="$(grep -H "\"MainGameCatalogItemId\": \"$itemId\"," "$egl_game_manifests/"*.item | cut -d ':' -f 1)"
    # Now grab the dispaly name from the file
    display_name="$(grep -m 1 '"DisplayName": ' "$item_file" | cut -d '"' -f 4)"

    # Print out the info needed to assemble the shortcut
    printf 'name       : %s\n' "$display_name"
    printf 'target     : "%s"\n' "$egl_exe"
    printf 'start in   : "%s"\n' "$egl_start_dir"
    printf 'launch opts: STEAM_COMPAT_DATA_PATH="%s" %%command%% -com.epicgames.launcher://apps/%s%%3A%s%%3A%s?action=launch&silent=true\n' \
      "$egl_comp_dir" "$namespaceId" "$itemId" "$artifactId"
    echo ""
  done < <(find "$egl_game_info_dir" -mindepth 1 -maxdepth 1 -type d -print0)
}

generate_gog_data() {
  #gog_comp_dir="$compdata_dir/GogGalaxyLauncher"
  #gog_pfx="$gog_comp_dir/pfx"
  #gog_start_dir="$gog_pfx/drive_c/Program Files (x86)/GOG Galaxy"
  #gog_exe="$gog_pfx/drive_c/Program Files (x86)/GOG Galaxy/GalaxyClient.exe"
  #gog_games_dir="$gog_pfx/drive_c/Program Files (x86)/GOG Galaxy/Games"

  trim="$gog_pfx/drive_c/"

  while IFS= read -r -d $'\0' game_dir; do
    #echo "game dir: $game_dir"

    # Convert the Linux install path to a Windows install path since we need to present
    # this to a windows exe shortly in a wine pfx
    full_install_dir="$(realpath --no-symlinks "$game_dir")"
    #echo "full dir: $full_install_dir"
    trimmed_install_dir="C:/${full_install_dir/$trim/}"
    #echo "trimmed dir: $trimmed_install_dir"
    converted_dir="${trimmed_install_dir//\//\\}"
    #echo "Converted dir: $converted_dir"

    # Some games have MULTIPLE .info files as each DLC get's a file
    # e.g. Shovel Knight TT, Dead Cells + DLC
    # To get the MAIN game ID we need to either check the .ico file
    # OR scan for 'rootGameId' across all .info files
    # choosing to go the former
    icon_file="$(find "$game_dir" -maxdepth 1 -type f -name 'goggame-*.ico')"
    #echo "icon file: $icon_file"

    # Extract the ID from the ico file name
    gameId="$(basename --suffix='.ico' "$icon_file" | cut -d '-' -f 2)"
    #echo "gameid: $gameId"

    # Get a handle for the game's .info file
    info_file="$game_dir/goggame-$gameId.info"
    #echo "info file: $info_file"

    # Extract the gameID from the games .info file
    #gameId="$(tr -cd '[:print:] \n' <"$info_file" | grep '"gameId":' | tr -d ' ",' | cut -d ':' -f 2)"

    # Extract the game name from the .info file
    # This occurs multiple times in the file and we're lazy and don't want to add
    # a JSON processor so just take the first hit
    # NOTE: try grep -m 1 instead of head -n 1
    display_name="$(tr -cd '[:print:] \n' <"$info_file" | grep '"name":' | head -n 1 | cut -d '"' -f 4 | head -n 1)"
    #echo "dispaly name: $display_name"
    #echo ""
    
    printf 'name       : %s\n' "$display_name"
    printf 'target     : "%s"\n' "$gog_exe"
    printf 'start in   : "%s"\n' "$gog_start_dir"
    printf 'launch opts: STEAM_COMPAT_DATA_PATH="%s" %%command%% /command=runGame /gameID=%s /path="%s" \n' "$gog_comp_dir" "$gameId" "$converted_dir"
    echo ""
  done < <(find "$gog_games_dir" -mindepth 1 -maxdepth 1 -type d -print0)
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
