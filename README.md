# yet-another-puppet-git-hook
## Overview
This repo provides a pre-commit hook, which checks the linting and syntax of `.pp`, `.epp`, `.yaml` files and of the `Puppetfile`.

## Installation 
### Dependencies
The hook requires the following software:
* https://github.com/adrienverge/yamllint
* https://github.com/puppetlabs/r10k/
* https://github.com/rodjek/puppet-lint
* puppet binary

### Configure pre-commit hook
* clone this repo
* navigate to your puppet repo
* `cd .git/hooks/`
* `ln -s <path-to-this-repo>/pre-commit`

## Usage
Just follow your current workflow. The pre-commit hook will only check those files, that are staged for this commit (not the whole repo). 
I recommend using dot files in the puppet repo root (e.g. [`.puppet-lint.rc`](https://github.com/rodjek/puppet-lint#configuration-file), [`.yamllint`](https://yamllint.readthedocs.io/en/stable/rules.html)), instead of changing the check invocation.

## Extending pre-commit
Try using the function `_puppet_git_hooks_check` in `pre-commit`. In case the check invocation is complex, just define your own function in a new file beneath `modules/` and call it in pre-commit. All files in `modules/` will be sourced.

## References
I used ideas from https://github.com/gini/puppet-git-hooks and https://github.com/drwahl/puppet-git-hooks

## Support
Please create bug reports and feature requests in [GitHub issues](https://github.com/chrisongthb/yet-another-puppet-git-hook/issues).

