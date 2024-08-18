function make_tor_script_mac {

#If brew installed on mac, but not tor, install tor in the background with crontab
#Once it's installed the crontab entry is deleted. A flag is added in the entry for selective search and delete later.
#If the tor install fails, can let crontab keep trying to install every minute. So, REMOVE_TOR_FLAG file added
#at the end of the script to prevent it running.

if [[ $OS != Mac ]] ; then return 0 ; fi
if ! which brew >/dev/null ; then return 0 ; fi

enable_tor_general
debug "t1"
  if grep -q "REMOVE_TOR_FLAG" < /etc/crontab ; then #flag exists only if crontab run at least once to completion
    debug "t2"
    sudo cat /etc/crontab | sudo sed '/REMOVE_TOR_FLAG/d' | sudo tee /tmp/crontab >/dev/null && \
    sudo mv /tmp/crontab /etc/crontab && \
    rm $dp/REMOVE_TOR_FLAG >/dev/null 2>&1
    rm $dp/tor_srcipt.sh
    return 0
  fi
    debug "t3"

  if which tor >/dev/null ; then rm $dp/tor_srcipt.sh >/dev/null 2>&1 ; return 0 ; fi
    debug "t4"

cat << EOF > $dp/tor_script.sh
#!/bin/bash

export USER=$USER >/dev/null
export HOME=$HOME >/dev/null
export PATH=$PATH >/dev/null

if ! which brew ; then return 0 ; fi
if which tor ; then return 0 ; fi

brew install tor > $dp/debug.log 2>&1 && \
if ! grep -q "tor-end" < $ic ; then echo "tor-end" >> $ic ; fi

touch $dp/REMOVE_TOR_FLAG >/dev/null
EOF
debug "t5"
sudo chmod +x $dp/tor_script.sh >/dev/null

echo "* * * * * $USER [ -x $HOME/.parmanode/tor_script.sh ] && $HOME/.parmanode/tor_script.sh #REMOVE_TOR_FLAG" | sudo tee -a /etc/crontab >/dev/null 2>&1
debug "t6"
}

