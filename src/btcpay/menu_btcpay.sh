function menu_btcpay {
while true ; do
btcpaylog="$HOME/.btcpayserver/btcpay.log"

set_btcpay_version_and_menu_print 

menu_bitcoin menu_btcpay #gets variables output1 for menu text, and $bitcoinrunning
isbtcpayrunning
if [[ $btcpayrunning != "true" ]] \
&& docker ps | grep -q btcpay ; then
containeronly="${cyan}Container RUNNING$orange"
else
unset containeronly
fi

if echo $output1 | grep -q "choose" ; then
output2=$(echo "$output1" | sed 's/start/sb/g') #choose start to run changed to choose sb to run. Option text comes from another menu.
else
output2="$output1"
fi
debug "before clear"
clear
unset menu_tor enable_tor_menu tor_on 

if sudo cat $macprefix/var/lib/tor/btcpay-service/hostname 2>$dn | grep -q "onion" \
   && sudo grep -q "7003" $torrc \
   && sudo grep -q "btcpay-service" $torrc ; then 

    get_onion_address_variable btcpay 
    menu_tor="    TOR: $bright_blue
        http://$ONION_ADDR_BTCPAY:7003$orange
        "
else
    if ! sudo grep -q "7003" $torrc ; then
    enable_tor_menu="$bright_blue             tor)$orange          Enable Tor
    "
    else
    unset enable_tor_menu 
    fi
fi
debug "before set terminal"
set_terminal_custom 52 
echo -en "
########################################################################################
                                ${cyan}BTCPay Server Menu${orange}
                                    $yellow$menu_btcpay_version$orange
########################################################################################

"
if [[ $btcpayrunning == "true" ]] ; then echo -e "
                   BTCPay SERVER IS$green RUNNING$orange" 
else
echo -e "
                   BTCPay SERVER IS$red NOT RUNNING$orange"
fi

echo -ne "
$output2" 

echo -e "

$cyan
             s)$orange            Start/Stop Docker container and BTCPay
$cyan
             rs)$orange           Restart BTCPay Docker container
$cyan
             c)$orange            Connect BTCPay to LND
$cyan
             conf)$orange         Config files ...
$cyan
             log)$orange          Logs ...
$cyan
             sb)$orange           Start/Stop Bitcoin
$cyan
             br)$orange           Backup / Restore BTCPay data (coming soon) ...
$cyan
             up)$orange           Update BTCPay (coming soon) ...
$cyan
             exp)$orange          Manage container $bright_blue (for experts) $orange
$cyan
             pp)$orange           BTC ParmanPay - Online payment app, worldwide access

$enable_tor_menu
    FOR ACCESS:     

        http://${IP}:23001$yellow           
        from any computer on home network    $orange

        http://localhost:23001$yellow       
        from this computer $orange

$menu_tor
########################################################################################
" 
choose "xpmq" ; read choice 
jump $choice || { invalid ; continue ; } ; set_terminal
case $choice in 
Q|q|QUIT|Quit|quit) exit 0 ;; m|M) back2main ;;
p|P) 
if [[ $1 == overview ]] ; then return 0 ; fi
menu_use 
;; 
conf)
set_terminal ; echo -e "
########################################################################################
    
    Next time, you can go directly to either the BTCPay log or the NBXplorer configs 
    by typing$green bc$orange or$green nc$orange. 

$cyan
             bc)$orange           BTCPay config file (${red}bcv$orange for vim)
$cyan
             nc)$orange           NBXplorer config file (${red}ncv$orange for vim)


########################################################################################
"
            choose xpmq ; read choice 
            jump $choice || { invalid ; continue ; } ; set_terminal
            case $choice in
            q|Q) exit ;; p|P) continue ;; m|M) back2main ;; "") continue ;;
            bc)
            menu_btcpay_conf_selection bc
            ;;
            bcv)
            menu_btcpay_conf_selection bcv
            ;;
            nc)
            menu_btcpay_conf_selection nc
            ;;
            ncv)
            menu_btcpay_conf_selection ncv
            ;;
            esac
;;
bc)
menu_btcpay_conf_selection bc
;;
bcv)
menu_btcpay_conf_selection bcv
;;
nc)
menu_btcpay_conf_selection nc
;;
ncv)
menu_btcpay_conf_selection ncv
;;
c|C|Connect|connect)
connect_btcpay_to_lnd
;;
s|S)
if [[ $btcpayrunning == "false" ]] ; then
start_btcpay
else
stop_btcpay
fi
;;
exp)
btcpay_menu_advanced || return 1
;;

rs)
restart_btcpay
;;

log)
set_terminal ; echo -e "
########################################################################################
    
    Next time, you can go directly to either the BTCPay log or the NBXplorer log 
    by typing$green blog$orange or$green nlog$orange. 

            $cyan
                        blog)$orange         View BTCPay Server log $cyan
            $cyan
                        nlog)$orange         View NBXplorer log $cyan
$orange
########################################################################################
"
            choose xpmq ; read choice 
            jump $choice || { invalid ; continue ; } ; set_terminal
            case $choice in
            q|Q) exit ;; p|P) continue ;; m|M) back2main ;; "") continue ;;
            blog|BLOG|bl|BL)
            menu_btcpay_log
            ;;
            nlog|NLOG|nl|NL|Nl)
            menu_nbxplorer_log
            ;;
            *)
            continue
            ;;
            esac
;;
blog|BLOG)
menu_btcpay_log
;;

nlog|NLOG|nl|NL|Nl)
menu_nbxplorer_log
;;

pp|PP|Pp|pP)
btcparmanpay
;;

tor)
if [[ -n $enable_tor_menu ]] ; then
enable_tor_btcpay
success "BTC Pay over Tor enabled"
continue
fi
;;

sb)
if [[ $btcpbitcoinrunning == "true" ]] ; then
stop_bitcoin
else
start_bitcoin
fi
;;

up)
announce "not available just yet"
continue
#update_btcpay
;;
debug)
true
;;

manr)
menu_btcpay_manr
;;
manp)
menu_btcpay_manp
;;
man)
menu_btcpay_man
;;
br)
#announce "Not available just yet"
#continue
yesorno "Do you want to backup BTCPay or restore?" "bk" "Backup" "res" "Restore" \
      && { backup_btcpay ; continue ; }
      restore_btcpay
;;
*)
invalid ;;
esac  

done
return 0
}

function update_btcpay {
while true ; do
set_terminal ; echo -e "
########################################################################################

    BTCPay cannot be updated in the advertised way when run with Parmanode.
    
    But not to worry. Parmanode can do the update for you, without affecting your
    data.

    It will stop the services running, pull the desired version from GitHub, build
    the binaries again inside the docker container, and restart the service.

    You have options...
$cyan
                a)$orange          Abort!
$green
                pp)$orange         Get the latest version tested by Parman
$red
                yolo)$orange       Get the latest version, without Parman's testing.
$red                
                s)$orange          Select a particular version of your choice

########################################################################################
"
choose xpmq ; read choice 
jump $choice || { invalid ; continue ; } ; set_terminal
case $choice in
q|Q) exit ;; a|A|p|P) return 1 ;; m|M) back2main ;;
esac
done
}

function set_btcpay_version_and_menu_print {
#the version is unknown if the user chooses "latest version from github". The "latest" flag in parmanode.conf triggers the code to
#find the version and set it correctly version from the log file - BTCPay needs to have run at least once for this to work
unset btcpay_version
source $pc

#if variable incorrect, fix it.
if [[ $btcpay_version == latest || -z $btcpay_version ]] ; then

    export btcpay_version=v$(cat $btcpaylog | grep "Adding and executing plugin BTCPayServer -" | tail -n1 | grep -oE '[0-9]+.[0-9]+.[0-9]+$')

    if [[ $(echo $btcpay_version | wc -c) -lt 3 ]] ; then #variable may not have captured correctly, if so, it'll be just 'v\n' with a length of 2.
        unset btcpay_version
        source $pc #revert btcpay_version to original
    else
        #version captured correctly, and set in parmanode_conf
        export menu_btcpay_version=$btcpay_version
        parmanode_conf_add "btcpay_version=$btcpay_version" 
    fi

else
export menu_btcpay_version=$btcpay_version
fi
debug "pause for btcpay version menu print"
}

function backup_btcpay {
if [[ $btcpayrunning != "true" ]] ; then announce "BTCPay needs to be running." ; return ; fi

while true ; do
set_terminal ; echo -e "
########################################################################################$cyan
                            BTCPAY PARMANODE BACKUP$orange
########################################################################################

    Parmanode will backup your posgres database to a file. This has your BTCPay
    server's details like the store's details and transaction data. There will also 
    be a backup of your Plugins directory.

    The backup will be saved as a tar archive file to the desktop as:
$cyan
    btcpay_parmanode_backup.tar
$orange
    Proceed?
$cyan
                 y)$orange     Yeah, of course, backups are super important
$cyan
                 n)$orange     Nah, que sera sera

########################################################################################
"
choose xpmq ; read choice 
jump $choice || { invalid ; continue ; } ; set_terminal
case $choice in
q|Q) exit ;; p|P) return 1 ;; m|M) back2main ;;
N|n) return 1 ;;
y)
backupdir="$HOME/Desktop/" ; mkdir -p $backupdir >/dev/null 2>&1
target="$backupdir/btcpay_parmanode_backup.tar"
tempdir="$(mktemp -d)"

# check for pre-existance
if [[ -f $target ]] ; then
    yesorno "The file$cyan $target$orange already exists.
                   $red    
             \r    OVERWRITE??$orange" || return 1
fi

#backup directories
cp -r $HOME/.btcpayserver/Plugins   $tempdir/Plugins
cp -r $HOME/.btcpayserver/Main      $tempdir/Main

#backup databases
if ! docker exec -itu postgres btcpay bash -c "pg_dumpall -U postgres" > $tempdir/btcpayserver.sql 2>&1 ; then 
    rm -rf $tempdir 
    enter_continue "Something went wrong with the database backup. Aborting." 
    return 1
fi

#tar it all up
if tar -czf $target $tempdir/* >$dn 2>&1 ; then
    rm -rf $tempdir 2>$dn 
    success "A backup has been created at $target. \n\n    Please keep it safe. Use Parmanode to
    \r    restore when ever needed. Note, lightning channels are not backed up, go to the
    \r    LND menu for saving the static channel backup file."
    return 0    
else
    rm -rf $tempdir 2>&dn
    enter_continue "Something went wrong" ; jump $enter_cont
    return 1
fi
;;

*)
invalid
;;
esac
done
}

function restore_btcpay {
if [[ $btcpayrunning != "true" ]] ; then announce "BTCPay needs to be running." ; return ; fi
while true ; do
set_terminal ; echo -e "
########################################################################################$cyan
                            BTCPAY PARMANODE RESTORE$orange
########################################################################################

    Parmanode will restore your backup files to the current BTCPay installation.
    This is not a generic restore procedure, but specific to a Parmanode BTCPay
    instance with its own specialised backup - ie the one created with parmanode, 
    that generated the file$cyan btcpay_parmanode_backup.tar.

    If you need assistance with a non-standard recovery, you can hire Parman to assist.
    
    Start the restoration?
$cyan
                             1)$orange          Yeah, restore clean.
$yellow                                         This will destroy the current data 
$yellow                                         in BTCPay server.   
$cyan
                             2)$orange          Yeah, restore and merge.
$yellow                                         This will merge old and new data,
$yellow                                         results might be unpredictable.
$cyan
                             n)$orange          Nah
$orange

########################################################################################
"
choose xpmq ; read choice 
jump $choice || { invalid ; continue ; } ; set_terminal
case $choice in
q|Q) exit ;; n|N|p|P) return 1 ;; m|M) back2main ;;
1) restore_type=clean ; break ;;
2) restore_type=merge ; break ;;
n) return 1 ;;
*) invalid ;;
esac
done

while true ; do
set_terminal ; echo -e "
########################################################################################

    Please type the full path of the parmanode backup file, eg:
$cyan
    $HOME/Desktop/btcpay_parmanode_backup.tar
$orange
########################################################################################
"
read file ; set_terminal
jump $file || { invalid ; continue ; } ; set_terminal
case $file in
q|Q) exit ;; p|P) return 1 ;; m|M) back2main ;; "") invalid ;;
esac
if [[ ! -f $file ]] ; then announce "The file doesn't exist - $file" ; continue ; fi

if ! tar -tf $file | grep -q "btcpayserver.sql" ; then 
announce "This tar file is missing btcpayserver.sql inside. Aborting."
return 0
fi
# if ! tar -tf $file | grep -q "Main" ; then 
# announce "This tar file is missing a Main directory inside. Aborting."
# return 0
# fi
# if ! tar -tf $file | grep -q "Plugins" ; then 
# announce "This tar file is missing a Plugins directory inside. Aborting."
# return 0
# fi

break
done

#copy backup to the container
containerfile="/home/parman/backup.tar"
containerdir="/home/parman/backupdir"
docker exec -du parman btcpay /bin/bash -c "rm -rf $containderdir ; mkdir $containderdir"

if ! docker cp $file btcpay:$containerfile ; then 
    #copy didn't work. clean up...
    docker exec -itu root btcpay rm -rf $containerdir
    docker exec -itu root btcpay rm -rf $containerfile
    enter_continue "Something went wrong copying the backup to the container"
    return 1
fi 

#extract the tar file
if ! docker exec -itu parman btcpay /bin/bash -c "tar -xvf $containerfile $containerdir" ; then
    #extract didn't work. clean up...
    enter_continue "1/2 Something went wrong extracting the backup in the container"
    docker exec -itu root btcpay rm -rf $containerdir
    docker exec -itu root btcpay rm -rf $containerfile
    enter_continue "Something went wrong extracting the backup in the container"
    return 1
fi

#Check psql file is valid
if ! docker exec -itu parman btcpay /bin/bash -c "grep -iq 'PostgreSQL database dump' containerdir/btcpayserver.sql" ; then
    yesorno "Doesn't seem to be a valid Postgres SQL file.
    Ignore error and proceed to import?" || {
        docker exec -itu root btcpay rm -rf $containerdir
        docker exec -itu root btcpay rm -rf $containerfile
        return 1
    }
fi

if [[ $restore_type == clean ]] ; then
    #delete first to avoid merging - the other databases don't matter.
    if ! docker exec -itu postgres btcpay bash -c "psql -U postgres -c 'DROP DATABASE IF EXISTS btcpayserver;'" \
        && docker exec -itu postgres btcpay bash -c "psql -U postgres -c 'DROP DATABASE IF EXISTS nbxplorer;'" \
        && docker exec -itu postgres btcpay bash -c "psql -U postgres -c 'DROP DATABASE IF EXISTS postgres;'"  
    then    
        docker exec -itu root btcpay rm -rf $containerdir
        docker exec -itu root btcpay rm -rf $containerfile
        enter_continue "Something went wrong during database preparation. Aborting." 
        return 1
    fi
fi
#restore directories
docker exec -itu root btcpay rm -rf /home/parman/.btcpayserver/Main 2>$dn
docker exec -itu root btcpay rm -rf /home/parman/.btcpayserver/Plugins 2>$dn

if ! docker exec -itu parman btcpay cp -r $containerdir/Main /home/parman/.btcpayserver/Main ; then
    announce "Something went wrong - couldn't copy Main directory. Aborting."
    return 1
fi

if ! docker exec -itu parman btcpay mv $containerdir/Plugins /home/parman/.btcpayserver/Plugins ; then
    announce "Something went wrong - couldn't copy Plugins directory. Aborting."
    return 1
fi

#restore databases
if docker exec -itu postgres btcpay bash -c "psql < $containerfile" ; then 
    docker exec -du root btcpay bash -c "rm $containerfile" 
    success "Backup restored" 
    return 0
else
    docker exec -itu root btcpay rm -rf $containerdir
    docker exec -itu root btcpay rm -rf $containerfile
    enter_continue "Something went wrong with the import procedure. Aborting." ; jump $enter_cont 
    return 1
fi
}

function menu_btcpay_log {
set_terminal ; log_counter
if [[ $log_count -le 10 ]] ; then
echo -e "
########################################################################################
    
    This will show the BTCpay log file in real-time as it populates.
    
    You can hit$cyan <control>-c$orange to make it stop.

########################################################################################
"
enter_continue ; jump $enter_cont
fi
set_terminal_wider
if ! which tmux >$dn 2>&1 ; then
yesorno "Log viewing needs Tmux installed. Go ahead and to that?" || continue
fi
TMUX2=$TMUX ; unset TMUX 
tmux new -s -d "tail -f $btcpaylog"
TMUX=$TMUX2
}


function menu_nbxplorer_log {
echo -e "
########################################################################################
    
    This will show the NBXplorer log file in real time as it populates.
    
    You can hit$cyan <control>-c$orange to make it stop.

########################################################################################
"
enter_continue ; jump $enter_cont
set_terminal_wider

    if ! which tmux >$dn 2>&1 ; then
    yesorno "Log viewing needs Tmux installed. Go ahead and to that?" || continue
    fi
    TMUX2=$TMUX ; unset TMUX 
    tmux new -s -d "tail -f $HOME/.nbxplorer/nbxplorer.log"
    TMUX=$TMUX2
set_terminal
}

function menu_btcpay_conf_selection {

if [[ $1 == bc ]] ; then
nano $HOME/.btcpayserver/Main/settings.config
elif [[ $1 == bcv ]] ; then
vim_warning ; vim $HOME/.btcpayserver/Main/settings.config
elif [[ $1 == nc ]] ; then
nano $HOME/.nbxplorer/Main/settings.config
elif [[ $1 == ncv ]] ; then
vim_warning ; vim $HOME/.nbxplorer/Main/settings.config
fi

}



function menu_btcpay_manr {
if ! docker exec -itu root btcpay bash -c "grep -q 'parmashell_functions' /etc/bash.bashrc" ; then
docker exec -du root btcpay bash -c "echo 'source /home/parman/parman_programs/parmanode/src/ParmaShell/parmashell_functions' | tee -a /etc/bash.bashrc >/dev/null" 
fi
if ! docker exec -itu root btcpay bash -c "grep -q '#colour_function' /etc/bash.bashrc" ; then
docker exec -du root btcpay bash -c "echo 'colour 2>/dev/null #colour_function' | tee -a /etc/bash.bashrc >/dev/null"
fi
enter_continue "Type exit and <enter> to return from container back to Parmanode."
clear
docker exec -itu root btcpay bash 

}

function menu_btcpay_manp {
if ! docker exec -it btcpay bash -c "grep -q 'parmashell_functions' /etc/bash.bashrc" ; then
docker exec -du root btcpay bash -c "echo 'source /home/parman/parman_programs/parmanode/src/ParmaShell/parmashell_functions' | tee -a /etc/bash.bashrc >/dev/null"
fi
if ! docker exec -itu root btcpay bash -c "grep -q '#colour_function' /etc/bash.bashrc" ; then
docker exec -du root btcpay bash -c "echo 'colour 2>/dev/null #colour_function' | tee -a /etc/bash.bashrc >/dev/null"
fi
clear
#echo -e "${green}The sudo password for parman is 'parmanode'$orange"
enter_continue "Type exit and <enter> to return from container back to Parmanode."
clear
docker exec -itu postgres btcpay bash 
}

function menu_btcpay_man {
if ! docker exec -it btcpay -c "grep -q 'parmashell_functions' /etc/bash.bashrc" ; then
docker exec -du root btcpay bash -c "echo 'source /home/parman/parman_programs/parmanode/src/ParmaShell/parmashell_functions' | tee -a /etc/bash.bashrc >/dev/null" 
fi
if ! docker exec -itu root btcpay bash -c "grep -q '#colour_function' /etc/bash.bashrc" ; then
docker exec -du root btcpay bash -c "echo 'colour 2>/dev/null #colour_function' | tee -a /etc/bash.bashrc >/dev/null"
fi
clear
echo -e "${green}The sudo password for parman is 'parmanode'$orange"
enter_continue "Type exit and <enter> to return from container back to Parmanode."
clear
docker exec -it btcpay bash 
}

function btcpay_menu_advanced {
while true ; do

    if docker exec -du postgres btcpay bash -c "ps ax | grep /usr/lib/postgresq | grep -v grep" ; then
    posgresrunning="${green}RUNNING$orange"
    else
    posgresrunning="${red}NOT RUNNING$orange"
    fi

    if docker exec -it btcpay bash -c "ps ax | grep NBX | grep -v grep | grep csproj" ; then
    nbxplorerrunning="${green}RUNNING$orange"
    else
    nbxplorerrunning="${red}NOT RUNNING$orange"
    fi

    if docker exec -it btcpay bash -c "ps ax | grep btcpay | grep -v grep | grep csproj" ; then
    containerbtcpayrunning="${green}RUNNING$orange"
    else
    containerbtcpayrunning="${red}NOT RUNNING$orange"
    fi


set_terminal ; echo -e "
########################################################################################
$cyan
     Extra features for advanced users...
$orange
$cyan
             dco)$orange          Start Docker container only $containeronly
$cyan
             man)$orange          Manually access container $bright_blue(parman user)$orange
$cyan
             manr)$orange         Manually access container $bright_blue(root user)$orange
$cyan
             manp)$orange         Manually access container $bright_blue(posgres user)$orange
$cyan 
             btcp)$orange         Start BTCPay in container only $containerbtcpayrunning
$cyan 
             nbx)$orange          Start NBXplorer in container only $nbxplorerrunning
$cyan 
             post)$orange         Start Postgres in container only $posgresrunning
$cyan 
             del)$orange          Delete default btcpayserver database (coming soon)
$cyan 
             cr)$orange           Create new default btcpayserver database (coming soon)

########################################################################################
"
choose xpmq ; read choice 
jump $choice || { invalid ; continue ; } ; set_terminal
case $choice in
q|Q) exit ;; p|P) return 0 ;; m|M) back2main ;; 
dco)
if [[ $btcpayrunning == "true" ]] ; then
    yesorno "BTCPay needs to be stopped to run the container only. Do that?" \
    && stop_btcpay && docker start btcpay \
    && enter_continue "The container has been started. NOTE: BTCPay & NBXplorer are$red not running$orange." \
    && return 0 
    return 0 #choosing no
else
docker start btcpay
enter_continue "The container has been started. NOTE: BTCPay & NBXplorer are$red not running$orange."
return 0
fi
;;
man)
menu_btcpay_man
;;
manp)
menu_btcpay_manp
;;
manr)
menu_btcpay_manr
;;
btcp)
start_btcpay_indocker 
enter_continue
;;
nbx)
start_nbxplorer_indocker
enter_continue
;;
post)
start_postgres_btcpay_indocker 
enter_continue
;;
del)
announce "not available just yet"
continue
# -d postgres, default connect to posrgres, necessary otherwise it tries to connect to a database the same as the user's name
yesorno "ARE YOU SURE? THIS IS YOUR BTCPAY STORE DATA!" || continue
docker exec -itu parman btcpay /bin/bash -c "psql -U parman -d postgres -c 'DROP DATABASE btcpayserver;'" 
enter_continue
;;
cr)
announce "not available just yet"
continue
docker exec -itu parman btcpay /bin/bash -c "createdb -O parman btcpayserver"
enter_continue
;;
*)
invalid
;;
esac
done
}
