# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="$HOME/bin:$PATH"

# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit promptinit
compinit
promptinit

# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=10000
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install

# prompt walters

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias top='btop'
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

powerinfo() {
  pnow=$(cat /sys/class/power_supply/BAT*/power_now)
  enow=$(cat /sys/class/power_supply/BAT*/energy_now)
  cnow=$(cat /sys/class/power_supply/BAT*/capacity)

  pstatus=$(cat /sys/class/power_supply/BAT*/status)
  draw=$(printf '%.3g\n' $(($pnow / 1000000.0)))
  remaining=$(($enow / "$pnow.0"))
  remaining_h=$(($remaining|0))
  remaining_m_f=$((($remaining - $remaining_h)*60))
  remaining_m=$(($remaining_m_f|0))
  remaining_m_padded=${(l:2::0:)remaining_m}

  col="\033[1;31m"
  col_reset="\033[0m"
  draws_ymbol="-"
  draw_label="Draw rate"
  remaining_label="Remaining"

  if [[ "$pstatus" == "Charging" ]]; then
    col="\033[0;32m"
    draw_symbol="+"
    draw_label="Charge rate"
    remaining_label="Time to full charge"
  fi

  echo "Status: $col$pstatus$col_reset"
  echo "Level: $cnow%"
  echo "$draw_label: $draw_symbol$draw W"
  echo "$remaining_label: $remaining_h:$remaining_m_padded"
}




## Keybindings section
bindkey -e
bindkey '^[[7~' beginning-of-line                               # Home key
bindkey '^[[H' beginning-of-line                                # Home key
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
fi
bindkey '^[[8~' end-of-line                                     # End key
bindkey '^[[F' end-of-line                                     # End key
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
fi
bindkey '^[[2~' overwrite-mode                                  # Insert key
bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^[[5~' history-beginning-search-backward               # Page up key
bindkey '^[[6~' history-beginning-search-forward                # Page down key

# Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
bindkey '^[[1;5D' backward-word                                 #
bindkey '^[[1;5C' forward-word                                  #
bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^[[Z' undo                                             # Shift+tab undo last action



source ~/.powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


