#!/usr/bin/env bash

up_or_down=$1
offset=""

if [ "$up_or_down" = "up" ]; then
  offset=0
elif [ "$up_or_down" = "down" ]; then
  offset=1
else
  echo "Usage: move-to-new-workspace up/down"
fi

# Move the current window to a newly created workspace below the current one

# Fetch workspaces JSON once to prevent race conditions
WS_JSON=$(niri msg -j workspaces)

CURR_IDX=$(echo "$WS_JSON" | jq -r '.[] | select(.is_focused == true) | .idx')
CURR_OUT=$(echo "$WS_JSON" | jq -r '.[] | select(.is_focused == true) | .output')

# Number of workspaces on the current output
LAST_WS=$(echo "$WS_JSON" | jq -r "[.[] | select(.output == \"$CURR_OUT\")] | length")

# Target index is below the current one
TARGET_WSPACE_INDX=$((CURR_IDX + offset))

# Create a temporary workspace at the end, move it to the target index,
# move the focused column (window group) to it, and clean up.

temp_ws_name=_tempws

niri msg action set-workspace-name "$temp_ws_name" --workspace "$LAST_WS" &&
  niri msg action move-workspace-to-index "$TARGET_WSPACE_INDX" --reference "$temp_ws_name" &&
  niri msg action move-column-to-workspace "$temp_ws_name" &&
  niri msg action unset-workspace-name "$temp_ws_name"
