#!/usr/bin/env bash

set -e

ROOT_DIR=$(pwd -P)


info () {
    printf "\r  [ \033[00;34m...\033[0m ] $1\n"
}

user () {
    printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
    printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

link_file () {
    local src=$1 dst=$2

    local overwrite= backup= skip=
    local action=

    if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
    then


        if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
        then
            local currentSrc="$(readlink $dst)"

            if [ "$currentSrc" == "$src" ]
            then

                skip=true;

            else

                user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
                [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
                read -n 1 action

                case "$action" in
                    o )
                        overwrite=true;;
                    O )
                        overwrite_all=true;;
                    b )
                        backup=true;;
                    B )
                        backup_all=true;;
                    s )
                        skip=true;;
                    S )
                        skip_all=true;;
                    * )
                        ;;
                esac

            fi
        fi

        overwrite=${overwrite:-$overwrite_all}
        backup=${backup:-$backup_all}
        skip=${skip:-$skip_all}


        if [ "$overwrite" == "true" ]
        then
            rm -rf "$dst"
            success "removed $dst"
        fi

        if [ "$backup" == "true" ]
        then
            mv "$dst" "${dst}.backup"
            success "moved $dst to ${dst}.backup"
        fi

        if [ "$skip" == "true" ]
        then
            success "skipped $src"
        fi
    fi

    if [ "$skip" != "true" ]  # "false" or empty
    then
        ln -s "$1" "$2"
        success "linked $1 to $2"
    fi
}

install_dotfiles () {
    info 'installing dotfiles'

    local overwrite_all=false backup_all=false skip_all=false

    for src in $(find -H "$ROOT_DIR" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
    do
        dst="$HOME/.$(basename "${src%.*}")"
        link_file "$src" "$dst"
    done
}

install_dotfiles

# If we're on a Mac, let's install software using homebrew.
if [ "$(uname -s)" == "Darwin" ]
then
    info "installing dependencies"
    if source ./install.sh > /tmp/dotfiles-install 2>&1
    then
      success "dependencies installed"
    else
      fail "error installing dependencies"
    fi
fi
