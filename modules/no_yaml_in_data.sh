#!/bin/bash
# shellcheck disable=SC2154

_puppet_git_hooks_check_yaml_in_data () {
  local say_checkname='.yaml file extension beneath data/'

  if grep -qE '^data' "$tmp_file"; then
    _puppet_git_hooks_say "checking" "$say_checkname"
    if grep -E '^data' "$tmp_file" | grep -qv '.yaml$'; then
      _puppet_git_hooks_say "nOK" "$say_checkname"
      echo "Found files without .yaml in data/:"
      grep -E '^data' "$tmp_file" | grep -v '.yaml$'
    else
      _puppet_git_hooks_say "OK" "$say_checkname"
    fi
  fi
}
