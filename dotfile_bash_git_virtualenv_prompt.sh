#!/bin/bash
#
# DESCRIPTION:
#
#   Set the bash prompt according to:
#    * the active virtualenv
#    * the branch/status of the current git repository
#    * the return value of the previous command
#
# USAGE:
#
#   1. Save this file as ~/.bash_prompt
#   2. Add the following line to the end of your ~/.bashrc or ~/.bash_profile:
#        . ~/.bash_prompt
#   OR, if you are using a version controlled copy of this script, create a symlink to it
#   from your home directory so you can receive any updates.
#
# HISTORY:
# 
# This script is an amalgamation of work by Paul Irish and Scott Woods


# The various escape codes that we can use to color our prompt.
MAGENTA=$(tput setaf 5)
VIOLET=$(tput setaf 61)
ORANGE=$(tput setaf 172)
RED="\[\033[0;31m\]"
YELLOW="\[\033[1;33m\]"
YELLOW=$(tput setaf 11)
GREEN="\[\033[0;32m\]"
BLUE="\[\033[1;34m\]"
LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
WHITE="\[\033[1;37m\]"
LIGHT_GRAY="\[\033[0;37m\]"
PURPLE="\e[1;35m"
CYAN="\e[1;36m"
COLOR_NONE="\[\e[0m\]" 

# Detect whether the current directory is a git repository.
function is_git_repository {
  git branch > /dev/null 2>&1
}

# Determine the branch/state information for this git repository.
function set_git_branch {
  # Capture the output of the "git status" command.
  git_status="$(git status 2> /dev/null)"

  # Set color based on clean/staged/dirty.
  state="on "
  if [[ ${git_status} =~ "working directory clean" ]]; then
    state=""
  elif [[ ${git_status} =~ "Changes to be committed" ]]; then
    state="${MAGENTA} *"
  else
    state="${VIOLET} *"
  fi

  # Set arrow icon based on status against remote.
  remote_pattern="Your branch is (.*) of"
  remote="${LIGHT_RED} "
  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
      remote+="↑"
    else
      remote+="↓"
    fi
  else
    remote+=""
  fi
  diverge_pattern="# Your branch and (.*) have diverged"
  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    remote="↕"
  fi

  # Get the name of the branch.
   branch_pattern="^(# )?On branch ([^${IFS}]*)"
  if [[ ${git_status} =~ ${branch_pattern} ]]; then
      branch=${BASH_REMATCH[2]}
  fi

  # Set the final branch string.
  BRANCH="on ${CYAN}${branch}${state}${remote}${COLOR_NONE} "
}

# Return the prompt symbol to use, colorized based on the return value of the
# previous command.
function set_prompt_symbol () {
  if test $1 -eq 0 ; then
      PROMPT_SYMBOL="\$"
  else
      PROMPT_SYMBOL="${LIGHT_RED}\$${COLOR_NONE}"
  fi
}

# Determine active Python virtualenv details.
function set_virtualenv () {
  if test -z "$VIRTUAL_ENV" ; then
      PYTHON_VIRTUALENV=""
  else
      PYTHON_VIRTUALENV="${GREEN}(`basename \"$VIRTUAL_ENV\"`)${COLOR_NONE} "
  fi
}

# Set the full bash prompt.
function set_bash_prompt () {
  # Set the PROMPT_SYMBOL variable. We do this first so we don't lose the
  # return value of the last command.
  set_prompt_symbol $?

  # Set the PYTHON_VIRTUALENV variable.
  set_virtualenv

  # Set the BRANCH variable.
  if is_git_repository ; then
    set_git_branch
  else
    BRANCH=''
  fi

  # Set the bash prompt variable.
  # Set Terminal title
  PS1="\[\033]0;\w\007\]"
  PS1+="
${PYTHON_VIRTUALENV}\u in ${YELLOW}\w${COLOR_NONE} ${BRANCH}
${PROMPT_SYMBOL} "
}

# Tell bash to execute this function just before displaying its prompt.
PROMPT_COMMAND=set_bash_prompt
