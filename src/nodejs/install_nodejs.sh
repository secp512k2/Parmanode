function install_nodejs {

if [[ $OS == "Linux" ]] ; then true ; else announce "Sorry, only works on Linux for now." ; return 1 ; fi

check_nodejs ; if [[ $reinstall_nodejs == 1 ]] ; then local nodejs_version=old ; fi

if [[ -d $HOME/parmanode/nodejs ]] ; then local nodejs_version=old ; fi

if [[ $nodejs_version == "old" || $nodejs_version == "none" ]] ; then 

#safety first
if [[ ! -e /etc/apt/keyrings/nodesource.gpg ]] ; then
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
fi

#uninstall old versions of installations from parmanode
if [[ -e $HOME/parmanode/nodejs ]] ; then rm -rf $HOME/parmanode/nodejs ; fi
installed_config_remove "nodejs" 

#uninstall old version via package manager
sudo apt purge nodejs npm -y
sudo apt autoremove -y 

#update repository list
sudo rm /etc/apt/sources.list.d/nodesource.list >/dev/null 2>&1
NODE_MAJOR=18 #problems with version20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] \
https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
| sudo tee /etc/apt/sources.list.d/nodesource.list >/dev/null 2>&1

sudo apt-get update -y

set_terminal ; echo -e "
########################################################################################
    
    To proceed, the system must be upgraded with...
$green
                            sudo apt-get -y upgrade
$orange
    Hit$cyan a$orange to abort.

    Hit$cyan <enter>$orange alone to contine.

########################################################################################0
"
read choice
case $choice in a|A) return 1 ;; esac

sudo apt-get upgrade
sudo apt-get install -y ca-certificates 

#this also installs npm (need 7+)
sudo apt-get install -y nodejs && installed_conf_add "nodejs-start"
elif [[ $nodejs_version == "new" ]] ; then installed_conf_add "nodejs-end" ; return 0 
fi

#Now repeat check after installtion, see if we have the right version
check_nodejs
if [[ $nodejs_version == "old" || $nodejs_version == "none" ]] ; then
announce "Couldn't get correct version of NodeJS. Version 16+ is needed. 

    You have version Major number: $nodejs_version. 
    
    Aborting."
return 1
else #If we do, code returns all good
parmanode_conf_add "nodejs-end"
return 0
fi
}

