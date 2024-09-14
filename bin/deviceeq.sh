#!/usr/bin/env bash

declare -A presets=( ["default"]="Blank" ["boseqc"]="BoseQC")

tmppath=/tmp/deviceeq

set_device() {
    echo $1 > "$tmppath"
}

set_eq() {
    local device=`cat "$tmppath"`
    local preset="${presets[default]}"
    if [[ -v presets[$device] ]]; then
        preset="${presets[$device]}"
    fi

    echo "Loading preset $preset"
    easyeffects -l "$preset"
    local code=$?

    if [[ $code -ne 0 ]]; then
        echo "easyeffects -l $preset failed with status $code"
        return 1
    fi
}


listen() {
    touch "$tmppath"
    set_eq

    while inotifywait -r "$tmppath" -e create,delete,modify; do {
        set_eq
    }; done
}



while [[ $# -gt 0 ]]; do
  case $1 in
    --device)
      set_device "$2"
      exit 0
      ;;
    --load-preset)
      set_eq
      exit $?
      ;;
    --listen)
      listen
      shift # past argument
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      ;;
  esac
done


