#!/bin/bash

_puppet_git_hooks_check_trailing_whitespaces () {
  local filteredfiles="$@"
  local say_checkname='trailing whitespaces'

  _puppet_git_hooks_say "checking" "$say_checkname"
  if type grep > /dev/null 2>&1; then
    if ! grep -qE ' $' ${filteredfiles}; then
      _puppet_git_hooks_say "OK" "$say_checkname"
    else
      _puppet_git_hooks_say "nOK" "$say_checkname"
      echo "Found trailing whitespaces in:"
      grep -El ' $' ${filteredfiles}
    fi
  else
    _puppet_git_hooks_say "FAILED" "$say_checkname"
    echo "command not found: grep"
  fi
}
