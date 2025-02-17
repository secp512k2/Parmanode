function enable_bre_tor {

if [[ $OS == "Mac" ]] ; then no_mac ; return 1 ; fi
if ! which tor >$dn 2>&1 ; then install_tor ; fi
if ! sudo test -e /etc/tor/torrc ; then
set_terminal ; echo -e "
########################################################################################
$cyan    /etc/tor/torrc$orange file does not exist. You may have a non-standard Tor installation.
    Parmanode won't be able to automate this process for you. Sorry! Aborting.
########################################################################################
"
enter_continue ; return 1 ;
fi
please_wait

if ! id | grep -q "debian-tor" ; then sudo usermod -aG debian-tor $USER >$dn 2>&1 ; fi

if ! sudo cat /etc/tor/torrc | grep "# Additions by Parmanode..." >$dn 2>&1 ; then
echo "# Additions by Parmanode..." | sudo tee -a /etc/tor/torrc >$dn 2>&1
fi

if sudo grep "ControlPort 9051" /etc/tor/torrc | grep -v '^#' >$dn 2>&1 ; then true ; else
    echo "ControlPort 9051" | sudo tee -a /etc/tor/torrc >$dn 2>&1
    fi

if sudo grep "CookieAuthentication 1" /etc/tor/torrc | grep -v '^#' >$dn 2>&1 ; then true ; else
    echo "CookieAuthentication 1" | sudo tee -a /etc/tor/torrc >$dn 2>&1
    fi

if sudo grep "CookieAuthFileGroupReadable 1" /etc/tor/torrc | grep -v '^#' >$dn 2>&1 ; then true ; else
    echo "CookieAuthFileGroupReadable 1" | sudo tee -a /etc/tor/torrc >$dn 2>&1
    fi

if sudo grep "DataDirectoryGroupReadable 1" /etc/tor/torrc | grep -v '^#' >$dn 2>&1 ; then true ; else
    echo "DataDirectoryGroupReadable 1" | sudo tee -a /etc/tor/torrc >$dn 2>&1
    fi

# if there's this search string, that doesn't start with #, then...
if sudo grep "HiddenServiceDir /var/lib/tor/bre-service/" \
    /etc/tor/torrc | grep -v "^#" >$dn 2>&1 ; then true ; else
    echo "HiddenServiceDir /var/lib/tor/bre-service/" | sudo tee -a /etc/tor/torrc >$dn 2>&1
    fi

if sudo grep "HiddenServicePort 3004 127.0.0.1:3002" \
    /etc/tor/torrc | grep -v "^#" >$dn 2>&1 ; then true ; else
    echo "HiddenServicePort 3004 127.0.0.1:3002" | sudo tee -a /etc/tor/torrc >$dn 2>&1
    fi

sudo systemctl restart tor
restart_bre 
get_onion_address_variable "bre" 
clear
enter_continue "
########################################################################################

    Changes have been made to the$cyan torrc$orange file to create/enable a hidden service
    for BRE. Please give it a few moments to work - initially, it may still appear
    disabled, but give it a minute.

########################################################################################
"
}

