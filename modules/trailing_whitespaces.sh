#!/bin/bash

_puppet_git_hooks_check_trailing_whitespaces () {
  local filteredfiles=
  local say_checkname='trailing whitespaces'

  if filteredfiles=$(echo $@ | tr ' ' '\n' | grep -vE '\.md$|^files\/'); then
    _puppet_git_hooks_say "checking" "$say_checkname"
    if type grep > /dev/null 2>&1; then
      if ! grep -qIE ' $' ${filteredfiles}; then
        _puppet_git_hooks_say "OK" "$say_checkname"
      else
        _puppet_git_hooks_say "nOK" "$say_checkname"
        echo "Found trailing whitespaces in:"
        grep --color=auto -HnoE ' $' ${filteredfiles}
      fi
    else
      _puppet_git_hooks_say "FAILED" "$say_checkname"
      echo "command not found: grep"
    fi
  fi
}
