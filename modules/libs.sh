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
  _files=$(git diff --cached --name-only --diff-filter=ACM "${revision}")
}

# checks 
_puppet_git_hooks_check () {
  local filenameregex=$1
  shift
  local checkcommand=$1
  shift
  local allfiles=$@
  local filteredfiles=

  if filteredfiles=$(echo $allfiles | tr ' ' '\n' | grep -E $filenameregex); then
    printf "\e${_colors[lightblue]}checking\e${_colors[restore]} %-${_columwidth}s" "${checkcommand}"

    local _base_command=$(awk '{print $1;}' <<< $checkcommand)
    if type $_base_command > /dev/null 2>&1; then
        if ${checkcommand} ${filteredfiles} > /dev/null 2>&1; then
          printf "\r\e${_colors[green]} OK \e${_colors[restore]}%-${_columwidth}s\n" "${checkcommand}"
        else
          printf "\r\e${_colors[default]}%-${_columwidth}s\e${_colors[restore]}\n" ' '
          printf "\r\e${_colors[default]}%-${_columwidth}s\e${_colors[restore]}\n" '==================================================='
          printf "\r\e${_colors[yellow]}nOK \e${_colors[restore]}%-${_columwidth}s\n" "${checkcommand}"
          _rc=1
          ${checkcommand} ${filteredfiles}
          echo
        fi
    else
      printf "\r\e${_colors[default]}%-${_columwidth}s\e${_colors[restore]}\n" ' '
      printf "\r\e${_colors[default]}%-${_columwidth}s\e${_colors[restore]}\n" '==================================================='
      printf "\r\e${_colors[yellow]}nOK \e${_colors[restore]}%-${_columwidth}s\n" "${checkcommand} ${filteredfiles}"
      printf "\e${_colors[red]}%s\e${_colors[restore]}\n" "FAILED: ${_base_command} not installed"
      _rc=1
    fi
  fi
}
