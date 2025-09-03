#!/bin/bash
# shellcheck disable=SC2154

_puppet_git_hooks_check_trailing_whitespaces () {
  local say_checkname='trailing whitespaces'

  if grep -qvE '\.md$|^files\/' "$tmp_file"; then
    _puppet_git_hooks_say 'checking' "$say_checkname"

    files_with_trailing_whitespaces=()
    while read -r line; do
      if grep -qIE ' $' <<< "$line"; then
        files_with_trailing_whitespaces+=("$line")
      fi
    done < "$tmp_file"

    if [[ "${#files_with_trailing_whitespaces[@]}" -eq 0 ]]; then
        _puppet_git_hooks_say 'OK' "$say_checkname"
    else
        _puppet_git_hooks_say 'nOK' "$say_checkname"
        echo "Found trailing whitespaces in:"
        echo "${files_with_trailing_whitespaces[@]}"
    fi
  fi
}
