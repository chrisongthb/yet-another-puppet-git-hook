#!/bin/bash

# declare variables
_columwidth='60'
_rc=0
_files=

# declare bash colors
declare -A _colors
_colors[red]='[0;31m'
_colors[green]='[0;32m'
_colors[blue]='[0;34m'
_colors[lightblue]='[0;94m'
_colors[yellow]='[0;33m'
_colors[default]='[0m'
_colors[restore]='[0m'

# get files, that are staged for commit
_puppet_git_hooks_git_init () {
  # change pwd to toplevel, to match dot files
  cd $(git rev-parse --show-toplevel)
  # Get correct git revision
  # adopted from https://github.com/gini/puppet-git-hooks/blob/master/hooks/pre-commit
  if git rev-parse --quiet --verify HEAD > /dev/null; then
      revision=HEAD
  else
      # Initial commit: diff against an empty tree object
      revision=4b825dc642cb6eb9a060e54bf8d69288fbee4904
  fi
  _files=$(git diff --cached --name-only --diff-filter=ACM "${revision}" | tr '\n' ' ')
}

_puppet_git_hooks_say () {
  local _say_state="$1"
  local _say_checkname="$2"

  case "$_say_state" in
    "checking")
      printf "\r\e${_colors[default]}%-${_columwidth}s\e${_colors[restore]}\n" ' '
      printf "\r\e${_colors[default]}%-${_columwidth}s\e${_colors[restore]}\n" '==================================================='
      printf "\e${_colors[lightblue]}checking\e${_colors[restore]} %-${_columwidth}s" "${_say_checkname}"
      ;;
    "OK")
      printf "\r\e${_colors[green]} OK \e${_colors[restore]}%-${_columwidth}s\n" "${_say_checkname}"
      ;;
    "nOK")
      printf "\r\e${_colors[yellow]}nOK \e${_colors[restore]}%-${_columwidth}s\n" "${_say_checkname}"
      _rc=1
      ;;
    "FAILED")
      printf "\r\e${_colors[red]}FAILED \e${_colors[restore]}%-${_columwidth}s\n" "${_say_checkname}"
      _rc=1
      ;;
  esac

}

# checks 
_puppet_git_hooks_check () {
  local filenameregex=$1
  shift
  local checkcommand=$1
  shift
  local allfiles=$@
  local filteredfiles=

  if filteredfiles=$(echo $allfiles | tr ' ' '\n' | grep -E "$filenameregex"); then
    _puppet_git_hooks_say "checking" "${checkcommand}"

    local _base_command=$(awk '{print $1;}' <<< $checkcommand)
    if type $_base_command > /dev/null 2>&1; then
        if ${checkcommand} ${filteredfiles} > /dev/null 2>&1; then
          _puppet_git_hooks_say "OK" "${checkcommand}"
        else
          _puppet_git_hooks_say "nOK" "${checkcommand}"
          ${checkcommand} ${filteredfiles}
        fi
    else
      _puppet_git_hooks_say "FAILED" "${checkcommand}"
      echo "command not found: ${_base_command}"
    fi
  fi
}
