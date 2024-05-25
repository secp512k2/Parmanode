function verify_electrum {

cd $HOME/parmanode/electrum

gpg --import ./*Thomas*

if [[ $computer_type == "LinuxPC" ]] ; then
    if ! gpg --verify --status-fd 1 electrum*.asc electrum*.AppImage 2>&1 | grep "GOOD" ; then 
        echo "GPG verification failed. Aborting."
        log "electrum" "verification failed. Aborting."
        enter_continue
        return 1
    fi
fi

if [[ $computer_type == "Pi" ]] ; then
    if ! gpg --verify --status-fd 1 Electrum*.asc Electrum*.tar.gz 2>&1 | grep "GOOD" ; then
        echo "GPG verification failed. Aborting."
        log "electrum" "verification failed. Aborting."
        enter_continue
        return 1
    fi
fi

if [[ $OS == "Mac" && $python_install != "true" ]] ; then
    if ! gpg --verify --status-fd 1 electrum*.asc electrum*.dmg 2>&1 | grep "GOOD" ; then 
        echo "GPG verification failed. Aborting."
        log "electrum" "verification failed. Aborting."
        enter_continue
        return 1
    fi
elif [[ $OS == Mac && $python_install == "true" ]] ; then
    if ! gpg --verify --status-fd 1 Electrum*.asc Electrum*.gz 2>&1 | grep "GOOD" ; then 
        echo "GPG verification failed. Aborting."
        log "electrum" "verification failed. Aborting."
        enter_continue
        return 1
    fi
fi




set_terminal ; echo -e "
########################################################################################

    The Electrum download has been verified with pgp$green successfully$orange

########################################################################################
"
enter_continue
please_wait

}