function install_joinmarket {

    if [[ $1 == "docker" ]] ; then joinmarket_docker="true" ; fi

    set_terminal

    grep -q "bitcoin-end" $ic || { 
        announce "Please install Bitcoin first. Aborting." && return 1 
        }
    
    joinmarket_preamble
    
    #Parmabox is needed for Macs becuase Bitcoin on Macs don't have bitcoin-cli
    if [[ $OS == "Mac" ]] ; then
        if ! grep -q "parmabox-end" $ic ; then

            yesorno "Parmanode needs to install Parmabox before installing
        JoinMarket. OK?" || { echo "Aborting..." ; sleep 2 ; return 1 ; }     
            install_parmabox silent
        fi

        if ! docker ps | grep -q parmabox ; then
        while true ; do
        yesorno "ParmaBox needs to be running. Let Parmanode start it?" && { docker start parmabox ; break ; }
        return 1
        done
        fi
    fi

    isbitcoinrunning
    if [[ $bitcoinrunning == "false" ]] ; then
        announce "Bitcoin needs to be running. Please start it. Aborting."
        return 1
    fi

    if [[ $OS == "Mac" ]] && ! docker exec parmabox cat /home/parman/bitcoin-installed 2>$dn ; then
        install_bitcoin_docker silent parmabox joinmarket || return 1
        docker cp $bc parmabox:/home/parman/.bitcoin/bitcoin.conf >$dn 2>&1
        docker exec -u root parmabox /bin/bash -c "chown -R parman:parman /home/parman/.bitcoin/"
        docker exec -u root parmabox /bin/bash -c "echo 'rpcconnect=host.docker.internal' | tee -a /home/parman/.bitcoin/bitcoin.conf" >$dn 2>&1
    fi

    make_joinmarket_wallet || { enter_continue "aborting" ; return 1 ; }

    mkdir -p $HOME/.joinmarket >$dn 2>&1 && installed_conf_add "joinmarket-start"

    clone_joinmarket || { enter_continue "aborting" ; return 1 ; }
    
    if [[ $joinmarket_docker == "true" ]] ; then
        build_joinmarket || { enter_continue "aborting" ; return 1 ; }
        run_joinmarket_docker || { if [[ $silentexit == "true" ]] ; then return 1 ; fi ; enter_continue "aborting" ; return 1 ; }
    elif [[ -z $joinmarket_docker ]] ; then
        joinmarket_dependencies || return 1
        cd $hp/joinmarket
        ./install.sh || { announce "Something went wrong. Aborting." ; return 1 ; }
    fi


    if [[ $OS == "Linux" && $joinmarket_docker == "true"  ]] ; then 
        install_bitcoin_docker silent joinmarket || return 1
        docker cp $bc joinmarket:/root/.bitcoin/bitcoin.conf >$dn 2>&1
    fi

    if [[ $joinmarket_docker == "true" ]] ; then
        counter=0
        while [[ $counter -lt 7 ]] ; do
            docker exec joinmarket ps >$dn 2>&1 && break
            sleep 1
            counter=$((counter + 1))
        done
    fi
########################################################################################################################

    run_wallet_tool_joinmarket install || { enter_continue "aborting" ; return 1 ; }

    make_joinmarket_config || { enter_continue "aborting" ; return 1 ; }

    parmashell_4_jm

    installed_conf_add "joinmarket-end"

    success "JoinMarket has been installed"

}


function make_joinmarket_wallet {

    if ! grep -q "deprecatedrpc=create_bdb" $bc ; then

        echo "deprecatedrpc=create_bdb" | sudo tee -a $bc >$dn 2>&1
        clear 
        dontrestart="false"

    else
        dontrestart="true" 
    fi

    isbitcoinrunning

    if [[ $bitcoinrunning == "false" ]] ; then
        announce "Bitcoin needs to be running. Please start it. Aborting."
        start_bitcoin
    else
        if [[ $dontrestart == "false" ]] ; then announce "Parmanode needs to restart Bitcoin." ; restart_bitcoin  ; fi
    fi

    if [[ $bitcoinrunning != "true" ]] ; then
        echo -e "${red}Waiting for bitcoin to start... (hit q to exit loop)$orange
        "
        sleep 1

        while true ; do
            read -sn1 -t 1 input #-s silent printing, -n1 one character, -t timeout
            if [[ $input == 'q' ]] ; then return 1 ; fi
            isbitcoinrunning
            if [[ $bitcoinrunning == "true" ]] ; then break ; fi
        done
    fi

    set_terminal
    echo -e "${green}Creating joinmarket wallet with Bitcoin Core/Knots...${orange}"

    while true ; do
        if [[ $OS == "Mac" ]] ; then
            bcdocker="/home/parman/.bitcoin/bitcoin.conf"
            rpcconnect="rpcconnect=host.docker.internal"
            docker exec -u root parmabox /bin/bash -c "grep -q $rpcconnect $bcdocker || echo "$rpcconnect" | tee -a $bcdocker >$dn"
            docker exec parmabox /bin/bash -c 'bitcoin-cli -named createwallet wallet_name=jm_wallet descriptors=false 2>&1 | grep -q "exists"' >$dn 2>&1 && break
            docker exec parmabox /bin/bash -c 'bitcoin-cli -named createwallet wallet_name=jm_wallet descriptors=false' && \
                                               enter_continue "Something seems to have gone wrong." && silentexit="true" ; return 1 #enter_continue catches any error
        elif [[ $OS == "Linux" ]] ; then 
            bitcoin-cli -named createwallet wallet_name=jm_wallet descriptors=false 2>&1 | grep -q "exists" && break
            bitcoin-cli -named createwallet wallet_name=jm_wallet descriptors=false && \
                                               enter_continue "Something seems to have gone wrong." && silentexit="true" ; return 1 #enter_continue catches any error
        fi
        echo -e "$red
        sometimes waiting for bitcoin to laod up is needed.
        Trying again every 10 seconds...$orange
        (q to quit)
        "
        read -sn1 -t 10 input #-s silent printing, -n1 one character, -t timeout

        if [[ $input == 'q' ]] ; then return 1 
        elif [[ -z $input ]] ; then continue 
        else sleep 2 
        fi

    done
    clear

}

function run_wallet_tool_joinmarket {

    set_terminal
    echo -e "${green}Running Joinmarket wallet tool...${orange}"

    if [[ $1 == "install" ]] ; then
    docker exec joinmarket bash -c '/jm/clientserver/scripts/wallet-tool.py' >$dn 2>&1
    else
    docker exec joinmarket bash -c '/jm/clientserver/scripts/wallet-tool.py' #do not exit on failure.
    fi

    return 0
}

function build_joinmarket {

    unset success_build #do not use 'success' as a variable, it deletes the success function
    rm $hp/joinmarket/Dockerfile >$dn 2>&1

    if [[ $OS == Linux ]] ; then
        cp $pn/src/joinmarket/Dockerfile $hp/joinmarket/Dockerfile >$dn 2>&1
    elif [[ $OS == Mac ]] ; then
        cp $pn/src/joinmarket/Dockerfile_mac $hp/joinmarket/Dockerfile >$dn 2>&1
        cp $pn/src/joinmarket/Dockerfile_torrc $hp/joinmarket/ >$dn 2>&1
        cp $pn/src/joinmarket/Dockerfile_torsocks.conf $hp/joinmarket/ >$dn 2>&1
    fi

    cd $hp/joinmarket
    docker build -t joinmarket $nocache . && success_build="true"
    enter_continue 

    if [[ $success_build == "true" ]] ; then return 0 ; else return 1 ; fi
}

function run_joinmarket_docker {

#-v /var/lib/tor/joinmarket-service:/var/lib/tor/joinmarket-service \

if [[ $OS == Linux ]] ; then

    docker run -d \
               --name joinmarket \
               -v $HOME/.joinmarket:/root/.joinmarket \
               -v /run/tor:/run/tor \
               -v $HOME/.tor:/root/.tor \
               -v /var/lib/tor:/var/lib/tor \
               -v /etc/tor:/etc/tor \
               -v $HOME/.tornoticefile.log:/root/.tornoticefile.log \
               -v $HOME/.torinfofile.log:/root/.torinfofile.log \
               --network="host" \
               --restart unless-stopped \
               joinmarket
    return 0

elif [[ $OS == Mac ]] ; then

    docker run -d \
               --name joinmarket \
               -v $HOME/.joinmarket:/root/.joinmarket \
               -p 61000:61000 \
               -p 2222:22 \
               --restart unless-stopped \
               joinmarket
    return 0
fi

    start_socat joinmarket
    internal_docker_socat_jm_mac 

}

function clone_joinmarket {

    cd $hp && git clone https://github.com/JoinMarket-Org/joinmarket-clientserver.git joinmarket || { enter_continue "Something went wrong$green.$orange" && return 1 ; }
    cd $hp/joinmarket
    git checkout f4c2b1b86857762e1ca2fa6442bceb347523efda  #version 0.9.11 - tag checkout doesn't work for some reason.
    return 0 
}

function parmashell_4_jm {

cat << 'EOF' | tee $tmp/b1 >$dn 2>&1
export LS_OPTIONS='--color=auto'
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
EOF

cat $tmp/b1 $pn/src/ParmaShell/parmashell_functions > $tmp/b2

echo "a" | tee -a $tmp/b2 >$dn 2>&1

docker cp $tmp/b2 joinmarket:/root/.bashrc >$dn 2>&1
}

function joinmarket_preamble {

if [[ $OS == Mac ]] ; then
mac_text="$red $blinkon 
    I M P O R T A N T . . .
$blinkoff $orange
    Sometimes during this installation, Parmanode will require your regular system 
    password, and sometimes it will require the password for the parman user inside 
    the ParmaBox container - this password is set to '${cyan}parmanode$orange' as the default. "
fi

if [[ $joinmarket_docker == "true" ]] ; then
    jmdockertext="It will run on your computer inside a Docker container, alongside Bitcoin Core or
    Bitcoin Knots on the system. Please note the Tumbler GUI will work, but not if
    you SSH into the machine (ie won't work headless); you have to log in directly."
fi


set_terminal ; echo -ne "
########################################################################################

    You are about to install$cyan ParmaJoin$orange, which is software that manages
    the JoinMarket protocol - a decentralized marketplace for Bitcoin users 
    to coordinate CoinJoin transactions. 
    
    $jmdocker_text
    $mac_text

########################################################################################
"
enter_continue ; jump $enter_cont

}

function joinmarket_dependencies {
#JoinMarket requires Python >=3.8, <3.13 installed.

if ! which python3 >$dn 2>&1 ; then install_python3 ; fi

pythonversion=$(python3 --version | grep -oE '[0-9]+\.[0-9]+')

if [[ $pythonversion -gt 3.13 ]] || [[ $pythonversion -lt 3.8 ]] ; then
announce "Python needs to be >v3.8 and <3.13. You have $pythonversion. Aborting."
return 1
fi

if [[ $OS == Mac ]] && ! xcode-select -p ; then 
    if yesorno "Need xcode tools installed. Install it? (takes a while)."  ; then
        xcode-select --install || { announce "Something went wrong" ; return 1 ; }
    else
        return 1
    fi
fi



}


function install_python3 {

if [[ $OS == "Mac" ]] ; then
brew_check || return 1
brew install python3 || { announce "Couldn't install python3. Aborting." ; return 1 ; }
return 0 
fi

if [[ $OS == "Linux" ]] ; then
sudo apt-get update -y 
sudo apt-get install python3
return 0
fi

}
