# yet-another-puppet-git-hook

<!-- vscode-markdown-toc -->
* 1. [Overview](#Overview)
* 2. [Installation](#Installation)
	* 2.1. [Dependencies](#Dependencies)
	* 2.2. [Manually configure pre-commit hook](#Manuallyconfigurepre-commithook)
	* 2.3. [Automatically configure pre-commit hook](#Automaticallyconfigurepre-commithook)
* 3. [Usage](#Usage)
* 4. [Extending pre-commit](#Extendingpre-commit)
* 5. [References](#References)
	* 5.1. [ToDos](#ToDos)
* 6. [Support](#Support)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='Overview'></a>Overview
This repo provides a pre-commit hook, which checks the linting and syntax of `.pp`, `.epp`, `.yaml` files and of the `Puppetfile`.

##  2. <a name='Installation'></a>Installation 
###  2.1. <a name='Dependencies'></a>Dependencies
The hook requires the following software:
* https://github.com/adrienverge/yamllint
* https://github.com/puppetlabs/r10k/
* https://github.com/rodjek/puppet-lint
* puppet binary
* https://github.com/mmckinst/puppet-lint-legacy_facts-check
* https://github.com/relud/puppet-lint-strict_indent-check

Please check, that your PATH is valid (all commands are executable), e.g. add things like `export PATH="${PATH}:$(find ~/.gem/ruby/ -maxdepth 2 -type d -name bin)"` to your .bashrc

###  2.2. <a name='Manuallyconfigurepre-commithook'></a>Manually configure pre-commit hook
* clone this repo
* navigate to your puppet repo
* `cd .git/hooks/`
* `ln -s <path-to-this-repo>/pre-commit`
* `chmod +x pre-commit`

###  2.3. <a name='Automaticallyconfigurepre-commithook'></a>Automatically configure pre-commit hook
Either include this profile (tested on Ubuntu 18.04) in your role or safe the included `/usr/share/git-core/templates/hooks/post-checkout` directly. This script will install the pre-commit hook, when a repo is cloned. Afterwards, it will do a git pull on the yet-another-puppet-git-hook repo (pre-commit hook) by every branch checkout.
```puppet
# installs and configures https://github.com/chrisongthb/yet-another-puppet-git-hook

class profile::git_pre_commit_hook {

  $gem_proxy = lookup('profile::git_pre_commit_hook::gem_install_proxy', Optional[Stdlib::HTTPUrl], first, Undef)

  # provide required packages
  ensure_packages( 'yamllint', {'ensure' => 'present'})
  if $gem_proxy {
    ensure_packages(
      [
        'r10k',
        'puppet-lint',
        'puppet-lint-legacy_facts-check',
        'puppet-lint-strict_indent-check',
      ], {
        ensure   => 'installed',
        provider => 'gem',
        install_options => { '--http-proxy' => $gem_proxy }
      }
    )
  }
  else {
    ensure_packages(
      [
        'r10k',
        'puppet-lint',
        'puppet-lint-legacy_facts-check',
        'puppet-lint-strict_indent-check',
      ], {
        ensure   => 'installed',
        provider => 'gem'
      }
    )
  }

  # Rollout post-checkout in git-init(1) template,
  # which manages pre-commit hook in local git repos
  # lint:ignore:single_quote_string_with_variables
  file { '/usr/share/git-core/templates/hooks/post-checkout':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => '#!/bin/bash
# This file is managed by Puppet

# Do nothing, if we do not checkout a branch:
#   $3 is a flag indicating whether the checkout was a branch checkout
#   the post-checkout hook is also run after git clone and the flag is always "1"
#   see docs for more information
#   https://git-scm.com/docs/githooks#_post_checkout
#
# These are all parameters given to post-checkout:
# 0000000000000000000000000000000000000000 702529a575af026b10a82c5a855df7c455056d09 1
# We could also use the null-ref as test, but we want the hooks to be up to date.
# Hence, we do an update on every branch switch.
#
if [ "$3" == "1" ]; then
  # just to be sure we are in repo root
  cd $(git rev-parse --show-toplevel)
  repo_uri=$(git config --get remote.origin.url)

  echo "Configuring pre-commit hook..."
  if [ -d ~/.yet-another-puppet-git-hook/.git/ ]; then
    cd ~/.yet-another-puppet-git-hook
    git fetch --all --quiet
    git reset --hard --quiet origin/master
    cd $OLDPWD
  else
    rm -rf ~/.yet-another-puppet-git-hook/
    git clone https://github.com/chrisongthb/yet-another-puppet-git-hook.git ~/.yet-another-puppet-git-hook/
  fi
  ln -s --force ~/.yet-another-puppet-git-hook/pre-commit .git/hooks/
  chmod +x .git/hooks/pre-commit
fi
',
  }
  # lint:endignore
}
```

##  3. <a name='Usage'></a>Usage
Just follow your current workflow. The pre-commit hook will only check those files, that are staged for this commit (not the whole repo). 
I recommend using dot files in the puppet repo root (e.g. [`.puppet-lint.rc`](https://github.com/rodjek/puppet-lint#configuration-file), [`.yamllint`](https://yamllint.readthedocs.io/en/stable/rules.html)), instead of changing the check invocation.

##  4. <a name='Extendingpre-commit'></a>Extending pre-commit
Try using the function `_puppet_git_hooks_check` in `pre-commit`. In case the check invocation is complex, just define your own function in a new file beneath `modules/` and call the function in pre-commit. You may want to use the `_puppet_git_hooks_say` method for colored output, see also `modules/libs.sh`. All files matching `*.sh` in `modules/` gonna be sourced.

##  5. <a name='References'></a>References
I used ideas from https://github.com/gini/puppet-git-hooks and https://github.com/drwahl/puppet-git-hooks

###  5.1. <a name='ToDos'></a>ToDos
* implement erb template check

##  6. <a name='Support'></a>Support
Please create bug reports and feature requests in [GitHub issues](https://github.com/chrisongthb/yet-another-puppet-git-hook/issues).

