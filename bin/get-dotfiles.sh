#!/bin/bash

git clone --bare git@github.com:markwatkinson/dotfiles.git $HOME/.dotfiles
function dotfiles {
   git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}
mkdir -p .dotfiles-backup
dotfiles checkout
if [ $? = 0 ]; then
  echo "Checked out dotfiles";
  else
    echo "Couldn't check out dotfiles due to existing files. Backing up existing files. to .dotfiles-backup";
    dotfiles checkout 2>&1 | grep -E "^\s+\S+" | awk {'print $1'} | xargs -d $'\n' sh -c 'for arg do echo "Backing up $arg"; mkdir -p .dotfiles-backup/"$arg"; mv "$arg" ".dotfiles-backup/$arg"; done' _
    echo 'Backed up'
fi;

dotfiles checkout
dotfiles config status.showUntrackedFiles no
echo 'Done'
