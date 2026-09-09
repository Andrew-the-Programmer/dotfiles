#!/bin/bash

export ZP_ROOT=$HOME
export PATH="$HOME/.local/bin:$PATH"

current_window="$KITTY_WINDOW_ID"

zmx_attach_command=$(zp-select)

if [ -z "$zmx_attach_command" ]; then
  kitten @ close-window --match "id:$current_window"
  exit 1
fi


other_window=$(kitten @ ls | jq -r --arg curr "$current_window" '
    .[0].tabs[].windows[] | select(.id != ($curr | tonumber)) | .id
' | head -1)

if [ -n "$other_window" ]; then
  kitten @ close-window --match "id:$other_window"
fi

eval "$zmx_attach_command"
