#!/bin/bash

alias ls='ls --color=auto'
alias ll='ls -lhar'
alias zsh-update-plugins="find ""$ZDOTDIR/plugins -type d -exec test -e '{}/.git' ';' -print0 | xargs -I {} -0 git -C {} pull -q"

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# confirm before overwriting something
# alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

alias lgit="lazygit"

alias oil="nvim +StartOil"

function dc {
  (
    if [ -n "$DC_DIR" ]; then
      cd "$DC_DIR" || exit 1
    fi
    docker-compose "$@"
  )
}

alias zsm="zmx-session-manager"

function dcr {
  local services="${*}"

  if [ ${#services[@]} -eq 0 ]; then
    dc down &&
      dc up -d --build &&
      dc logs -f
  else
    dc down "${services[@]}" &&
      dc up -d --build "${services[@]}" &&
      dc logs -f "${services[@]}"
  fi
}

function conda {
  "$CONDA_BIN/conda" "$@"
}

function ca {
  local env=$1
  if [ -z "$env" ]; then
    env=$(conda info --envs | grep -v '^#' | grep -v '^$' | fzf | awk '{print $NF}')
  fi
  if [ -z "$env" ]; then
    echo "Failed to get env"
    return 1
  fi
  echo "$env"
  source "$CONDA_BIN/activate" "$env"
}

alias cl="conda env list"
alias ci="conda install"
alias cpi="pip install"
alias cx="conda deactivate"

function require_clean_work_tree() {
  # Update the index
  git update-index -q --ignore-submodules --refresh
  err=0

  # Disallow unstaged changes in the working tree
  if ! git diff-files --quiet --ignore-submodules --; then
    echo >&2 "err: you have unstaged changes."
    git diff-files --name-status -r --ignore-submodules -- >&2
    err=1
  fi

  # Disallow uncommitted changes in the index
  if ! git diff-index --cached --quiet HEAD --ignore-submodules --; then
    echo >&2 "err: your index contains uncommitted changes."
    git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2
    err=1
  fi

  if [ "$err" = 1 ]; then
    echo >&2 "Please commit or stash them."
    return 1
  fi
}

function sgit() {
  if ! require_clean_work_tree; then
    return 1
  fi
  git "$@"
}

function gsw() {
  sgit switch "$@"
}

alias gst='git status'
alias gpr='git pull --rebase'

zsh_config_file="$ZDOTDIR/.zshrc"

alias zsh-config='nvim $zsh_config_file'
alias zsh-reload='exec zsh'

alias j="jump"

alias zz="z -"

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

if command -v zoxide &>/dev/null; then
  # alias cd="zd"
  zd() {
    if [ $# -eq 0 ]; then
      builtin cd ~ && return
    elif [ -d "$1" ]; then
      builtin cd "$1"
    else
      z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
    fi
  }
fi

open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias d='docker'
alias r='rails'
# nvim
alias n='nvim'
alias nv='nvim -c "nnoremap q :q!<CR>" -'
alias g='git'
alias t='tailscale'
alias tsa='tailscale status --active'
alias sctl='sudo systemctl'
alias sctlu='systemctl --user'

function ldir() {
  find . -mindepth 1 -maxdepth 1 -type d \( ! -iname ".*" \) | sed 's|^\./||g'
}

alias gh='google-chrome --proxy-server="http://127.0.0.1:8080"'

function mkdir_cd() {
  args=()
  pos_args=()
  while [[ $# -gt 0 ]]; do
    case $1 in
    --cd)
      do_cd=1
      shift
      ;;
    -*)
      args+=("$1")
      shift
      ;;
    *)
      pos_args+=("$1")
      shift
      ;;
    esac
  done

  /usr/bin/mkdir "${args[@]}" "${pos_args[@]}"

  if [ ! -z "$do_cd" ] && [ "${#pos_args[@]}" -eq 1 ]; then
    builtin cd "${pos_args[@]}" || return 1
  fi
}

alias mkdir='mkdir_cd'

function touch_mkdir() {
  args=()
  pos_args=()
  while [[ $# -gt 0 ]]; do
    case $1 in
    -p)
      do_mkdir=1
      shift
      ;;
    -*)
      args+=("$1")
      shift
      ;;
    *)
      pos_args+=("$1")
      shift
      ;;
    esac
  done

  if [ ! -z "$do_mkdir" ] && [ "${#pos_args[@]}" -eq 1 ]; then
    file="${pos_args[1]}"
    /usr/bin/mkdir -p "$(dirname "$file")"
  fi

  /usr/bin/touch "${args[@]}" "${pos_args[@]}"
}

alias touch='touch_mkdir'

alias fzfd="find . -type d -print | fzf"
alias zf="cd \$(fzfd)"

if ! which bat >/dev/null; then
  alias bat="batcat"
fi

alias fzfp="fzf --preview \"bat --color=always --style=numbers --line-range=:500 {}\""

function ocrpdf() {
  python3 -m ocrmypdf --force-ocr -l eng+rus "$1" "$1"
}

function getext() {
  echo "${1##*.}"
}

function getfilename() {
  echo "${1%.*}"
}

function webptopng() {
  dwebp "$1" -o "$(getfilename "$1").png"
}

function convertext() {
  magick "$1" "$(getfilename "$1").#2"
}

function randfile() {
  find "$1" | shuf -n 1 | tr -d "\n"
}

function copy_image() {
  xclip -selection clipboard -target image/png -i <"$1"
}

function archi() {
  yay -Sy --noconfirm "$@"
}

function debian_install() {
  sudo apt install -y "$@"
}

function sysi() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
  fi
  if [ "$OS" = "Arch Linux" ]; then
    archi "$@"
  elif [ "$OS" = "Ubuntu" ]; then
    debian_install "$@"
  else
    echo "Not supported for your OS"
  fi
}

function py_check_module() {
  python3 -c "import $1" 2>/dev/null || return 1
  return 0
}

function pyi() {
  module=$1
  pymodule=$2

  if [ -z "$pymodule" ]; then
    pymodule=$module
  fi

  if py_check_module "$pymodule"; then
    echo "$module is already installed"
    return 0
  fi

  sudo pacman -Sy --noconfirm "python-$module"

  if py_check_module "$pymodule"; then
    echo "$module installed with pacman"
    return 0
  fi

  pipx install --include-deps "$module"

  if py_check_module "$pymodule"; then
    echo "$module installed with pipx"
    return 0
  fi

  pip install --user "$module"

  if py_check_module "$pymodule"; then
    echo "$module installed with pip"
    return 0
  fi

  # https://stackoverflow.com/questions/76499565/python-does-not-find-module-installed-with-pipx
  pip install --user --break-system-packages "$module"
  # "$HOME/.venvs/MyEnv/bin/python" -m pip install --user "$module"

  if py_check_module "$pymodule"; then
    echo "$module installed with pip --break-system-packages"
    return 0
  else
    echo "$module not installed"
    return 1
  fi
}

function clip-in() {
  xclip -selection clipboard
}

function clip-out() {
  xclip -selection clipboard -o
}

function my-public-ip() {
  curl -s ifconfig.me
}

function pdf2png() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    -e | --extension)
      ext="$2"
      shift
      shift
      ;;
    -*)
      echo "Unknown option $1"
      return 1
      ;;
    *)
      file="$1"
      shift
      ;;
    esac
  done
  inkscape "$file" "--export-type=$ext"
}

alias vs='echo "Your IP is: $(my-public-ip)"'

function tsen {
  exit_node=$(tailscale exit-node list | awk '{print $2}' | grep tail | cat - <(echo "None") | fzf)
  if [ "$exit_node" = "None" ]; then
    exit_node=""
  fi
  sudo tailscale set --exit-node="$exit_node"
}

alias tget='sudo tailscale file get .'

alias nfzf='nvim "$(fzf)"'

function gpg-export() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    -d | --directory)
      dir="$2"
      shift
      shift
      ;;
    -* | --*)
      echo "Unknown option $1"
      return 1
      ;;
    *)
      key_id="$1"
      shift
      ;;
    esac
  done

  if [ -z "$key_id" ]; then
    echo "Please provide a key id"
    return 1
  fi

  if [ -z "$dir" ]; then
    dir="$HOME/.gpg"
  fi

  mkdir -p "$dir"
  gpg --export-secret-keys --armor "$key_id" >"$dir/private-key.asc"
  gpg --export --armor $key_id >"$dir/public-key.asc"
  #scp -r "$dir" "$target:$dir"
}

nvim-app() {
  NVIM_APPNAME="$1" nvim
}

alias nvim-my='nvim-app nvim-my'
alias nvim-omarchy='nvim-app nvim-omarchy'
alias nvim-lazyvim='nvim-app nvim-lazyvim'

function cat-all() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    --nd)
      nd=1
      shift
      ;;
    *)
      args+=("$1")
      shift
      ;;
    esac
  done

  if [ -z "$nd" ]; then
    args+=("-not" "-path" "*/.git/*" "-type" "f")
  fi

  for file in $(find "${args[@]}"); do
    echo "# FILE: $file"
    echo "\`\`\`"
    cat "$file"
    echo "\`\`\`"
  done
}

function copy-to-nextcloud() {
  local help=""
  local user=""
  local target=""
  local overwrite=""
  local files=()

  while [[ $# -gt 0 ]]; do
    case $1 in
    --help)
      help="yes"
      shift 1
      ;;
    --user | -u)
      user="$2"
      shift 2
      ;;
    --target-directory | -t)
      target="$2"
      shift 2
      ;;
    -f | --overwrite)
      overwrite=yes
      shift
      ;;
    *)
      files+=("$1")
      shift
      ;;
    esac
  done
  if [ -n "$help" ]; then
    echo "Usage: copy-to-nextcloud [OPTIONS] [FILES...]"
    echo "Options:"
    echo "  --user, -u <username>     Nextcloud username (optional, will prompt if not provided)"
    echo "  --target-directory, -t    Subdirectory in user's files (e.g. 'Documents/projects')"
    echo "  -f, --overwrite           Overwrite existing files without prompting"
    echo "  --help                    Show this help"
    return 0
  fi

  docker_container="manual-install-nextcloud-aio-nextcloud-1"

  if [ -z "$user" ]; then
    # echo "Please provide a nextcloud username (--user|-u, see --help)" && return 1
    get_users() {
      docker exec -u www-data "$docker_container" php occ user:list --output=json 2>/dev/null | jq -r 'keys[]' 2>/dev/null
    }
    user=$(get_users | fzf --prompt="Select user: ")
    echo "Selected user is: $user"
  fi

  datadirectory=$(docker exec "$docker_container" awk -F"'" '/datadirectory/ {print $4}' /var/www/html/config/config.php)

  if [ -z "$target" ]; then
    get_target_dirs() {
      echo "/"
      docker exec "$docker_container" bash -c "find '$datadirectory/$user/files' -type d 2>/dev/null" | sed "s|^$datadirectory/$user/files/||"
    }
    target=$(get_target_dirs | fzf --prompt='Select target directory: ' --preview='ls -la {}' --preview-window=right:50%)
    if [[ "$target" == "/" ]]; then
      target=""
    fi
  fi

  dst="$datadirectory/$user/files/$target"
  docker exec "$docker_container" mkdir -p "$dst"

  for file in "${files[@]}"; do
    exists=$(docker exec "$docker_container" find "$dst" -name "$(basename "$file")")

    if [ -n "$exists" ] && [ -z "$overwrite" ]; then
      echo "File $(basename "$file") exists in $target. Overwrite? (y/N):"
      read -r reply
    else
      reply="y"
    fi
    if [[ $reply =~ ^[Yy]$ ]]; then
      echo "copy file: $file"
      docker cp "$file" "$docker_container:$dst"
    else
      echo "Copy cancelled."
    fi
  done

  docker exec "$docker_container" chown -R www-data:www-data "$dst"
  docker exec -u www-data "$docker_container" php occ files:scan "$user"
}

function to-davinci() {
  local help=""
  local loglevel="info"
  local target="."
  local level="big" # small, medium, big, large
  local files=()

  while [[ $# -gt 0 ]]; do
    case $1 in
    --help)
      help="yes"
      shift 1
      ;;
    --quiet | -q)
      loglevel="error"
      shift 1
      ;;
    --loglevel | -l)
      loglevel="$2"
      shift 2
      ;;
    --level)
      level="$2"
      shift 2
      ;;
    --target-directory | -t)
      target="$2"
      shift 2
      ;;
    *)
      files+=("$1")
      shift
      ;;
    esac
  done
  if [ -n "$help" ]; then
    cat <<EOF
Usage: to-davinci [OPTIONS] [FILES...]

Options:
  --target-directory, -t DIR   Output directory (default: .)
  --level                       Quality/size level: small, medium, big, large (default: medium)
  --loglevel, -l                FFmpeg log level (quiet, error, info, verbose, debug)
  --quiet, -q                   Alias for --loglevel error
  --help                        Show this help

Levels:
  small   - size*=1.2: Very small file (6-10MB for a 5MB source), long‑GOP H.264, crf 32
  medium  – size*=6  : Balanced, all‑intra H.264, crf 18, fast editing (33MB for 5MB source)
  big     – size*=10 : ProRes Proxy, 4:2:2, good quality, smooth editing (55MB)
  large   – size*=100: DNxHR HQ, highest quality, huge file (use only when needed)
EOF
    return 0
  fi

  for file in "${files[@]}"; do
    output="$target/${2:-${file%%.*}_resolve.mov}"
    echo "$output"
    local ffmpeg_args=()
    case "$level" in
    small)
      ffmpeg_args=(
        -c:v libx264 -crf 32 -g 250
        -x264-params "keyint=250:min-keyint=25"
        -pix_fmt yuv420p -c:a pcm_s16le
      )
      ;;
    medium)
      ffmpeg_args=(
        -c:v libx264 -g 1 -crf 18
        -pix_fmt yuv420p -c:a pcm_s16le
      )
      ;;
    big)
      ffmpeg_args=(
        -c:v prores -profile:v 0
        -pix_fmt yuv422p -c:a pcm_s16le
      )
      ;;
    large)
      ffmpeg_args=(
        -c:v dnxhd -profile:v dnxhr_hq
        -pix_fmt yuv422p -c:a pcm_s16le
      )
      ;;
    esac
    ffmpeg -loglevel "$loglevel" -i "$file" "${ffmpeg_args[@]}" "$output"
  done
}

pop_last() {
  last="${@: -1}"
  set -- "${@:1:$#-1}"
}

tmux-glob() {
  local pattern="${*: -1}"
  local tmux_args=("${@:1:${#@}-1}")
  local sessions=($(tmux ls -F "#{session_name}" | grep "$pattern"))
  for session in "${sessions[@]}"; do
    echo Session: $session
    eval "tmux ${tmux_args[*]} $session"
  done
}

tmux-init-dir() {
  local help=""
  local socket_name

  socket_name=$(basename "$(pwd)")

  while [[ $# -gt 0 ]]; do
    case $1 in
    --help)
      help="yes"
      shift 1
      ;;
    -L)
      socket_name="$2"
      shift 2
      ;;
    esac
  done

  if [ -n "$help" ]; then
    cat <<EOF
Usage:
    tmux-init-dir [-L socket_name] TARGETS...
    tmux-init-dir --help
EOF
    return 0
  fi

  for folder in ./*/; do
    local name="$(basename "$folder")"
    (
      cd "$folder" || return 1
      tmux -L "$socket_name" new -s "$name" -d
    )
  done
}

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
function p10k-configure() {
  source_file="$HOME/.config/zsh/.p10k.zsh"
  configs_folder="$ZDOTDIR/p10k-configs"
  exit_option="exit"
  create_option="create new config"

  selected_config=$(
    {
      ls "$configs_folder" &
      echo "$create_option" &
      echo "$exit_option"
    } |
      fzf --prompt="Select p10k config: "
  )
  if [ "$selected_config" = "$exit_option" ]; then
    if [ ! -f "$source_file" ]; then
      default_config="$configs_folder/personal.zsh"
      cp "$default_config" "$source_file"
    fi
    source "$source_file"
    return 0
  fi
  if [ "$selected_config" = "$create_option" ]; then
    p10k configure || return 1
    read -p "Continue (y/N)?" choice
    case "$choice" in
    y | Y)
      read -p "Name {}.zsh: " name
      cp "$source_file" "$configs_folder/$name.zsh"
      ;;
    esac
    return 0
  fi
  selected_config_file="$configs_folder/$selected_config"
  cp "$selected_config_file" "$source_file"
  source "$source_file"
}
