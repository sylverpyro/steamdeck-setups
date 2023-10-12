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
    display_name="$(basename "$game_dir")"
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

    # Print out the info needed to assemble the shortcut
    printf 'name       : %s\n' "$display_name"
    printf 'target     : "%s"\n' "$egl_exe"
    printf 'start in   : "%s"\n' "$egl_start_dir"
    printf 'launch opts: STEAM_COMPAT_DATA_PATH="%s" %%command%% -com.epicgames.launcher://apps/%s%%3A%s%%3A%s?action=launch&silent=true\n' \
      "$egl_comp_dir" "$namespaceId" "$itemId" "$artifactId"
    #  "$egl_comp_dir" "$namespaceId" "$itemId" "$artifactId"
    echo ""
  done < <(find "$egl_game_info_dir" -mindepth 1 -maxdepth 1 -type d -print0)
}

work() {
  generate_egl_data
}

main() {
  defaults
  work
}

main
