#! /usr/bin/env bash

#set -x

[ -n "$EDITOR" ] || EDITOR="vim -v"

repositories=(
  awesome-buttons
  awesome-cyclefocus
  #awesome-switcher
  awesome-wm-widgets
  #cesious-theme
  #collision
  #dotfiles-JonasPetterson
  freedesktop
  json-lua # Prerequisite for awesome-wm-widgets
  #lain
  nord
  #smart_borders
)

function branches() {
    local repo
    for repo in ${repositories[@]}; do
        if [ -d ${repo} ]; then
            pushd ${repo}
            local current=$(git branch --show-current)
            [ "$current" = master ] || echo "$repo: $current <----------"
            popd
        fi
    done
}

function clone() {
    local repo
    for repo in ${repositories[@]}; do
        echo =============================================
        echo -e "\033[1m${repo}\033[0m"
        git clone https://github.com/linuxdeepin/${repo}.git
    done
}

function pull() {
    local repo
    for repo in ${repositories[@]}; do
        echo =============================================
        if [ -d ${repo} ]; then
            pushd ${repo}
            echo -e "\033[1m$(pwd)\033[0m"

            local remote=$(git remote show)
            remote=$(grep upstream <<< $remote || head -n 1 <<< $remote)

            local current=$(git branch --show-current)

            if [ "$current" != master ]; then
                echo -e "\033[1m************ $repo: $current ************\033[0m"
                git checkout master
            fi

            git pull "$remote" master

            if [ "$current" != master ]; then
                git push origin master
                git checkout "$current"
                git pull --rebase origin master
            fi

            popd
        else
            git clone https://github.com/linuxdeepin/${repo}.git
        fi
    done
}

#branches
pull

#set +x
