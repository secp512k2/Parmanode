return 0
# not live


########################################################################################
# This is the install script kept at
# https://parmanode.com/install_4mac.sh - the URL is easier to remember and shorter 
# than if keeping it on Github.

########################################################################################
#!/bin/sh

printf '\033[8;38;88t' && echo -e "\033[38;2;255;145;0m" 

if [ -d $HOME/parman_programs/parmanode ] ; then
clear
#update parmanode if it exists...
if ! git config --global user.email ; then git config --global user.email sample@parmanode.com ; fi
if ! git config --global user.name ; then git config --global user.name Parman ; fi
cd $HOME/parman_programs/parmanode && git config pull.rebase false && git pull >$dn 2>&1

#make desktop clickable icon...
if [ ! -e $HOME/Desktop/run_parmanode.sh ] ; then
cat > $HOME/Desktop/run_parmanode.sh << 'EOF'
#!/bin/bash
cd $HOME/parman_programs/parmanode/
./run_parmanode.sh
EOF
sudo chmod +x $HOME/Desktop/run_parmanode*
echo "New clickable desktop icon made."
fi

#no further changes needed.
echo "Parmnode already downloaded."
exit
fi

#Assuming not previously installed parmanode...

    if ! which git ; then 

        if ! which brew >$dn ; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
        if ! which brew >$dn ; then export warning=1 ; fi
        fi

        if ! which ssh >$dn ; then 
            if [ $warning = 1 ] ; then echo "problem with homebrew, needed to install git. Aborting." ; sleep 4 ; exit ; fi
            brew install ssh 
        fi

        if ! which gpg >$dn ; then 
            if [ $warning = 1 ] ; then echo "problem with homebrew, needed to install git. Aborting." ; sleep 4 ; exit ; fi
            brew install gpg 
        fi

        brew install git
    fi

#####################################################################################################

# Parmanode first time install most likely...

sudo -k
if [[ ! -e /Library/Developer/CommandLineTools ]] ; then git --version ; fi 
clear
echo "
########################################################################################
    
    Please make sure that any pop-up prompts to install developer tools have finished 
    installing before continuing here.

########################################################################################
"
sudo sleep 0.1

mkdir -p $HOME/parman_programs >$dn 2>&1 
cd $HOME/parman_programs
git clone https://github.com/armantheparman/parmanode.git

#make desktop clickable icon...
cat > $HOME/Desktop/run_parmanode.sh << 'EOF'
#!/bin/bash
cd $HOME/parman_programs/parmanode/
./run_parmanode.sh
EOF
sudo chmod +x $HOME/Desktop/run_parmanode.sh >$dn 2>&1
clear
echo "
########################################################################################

    There should be an icon on the desktop for you, \"run_parmanode.sh\".

    If you double click it, and your Mac is configured to open a text editor instead
    of running the program, that can be overcome by typing this in terminal:


            $HOME/parman_programs_parmanode/run_parmanode.sh

    It's case sensitive.

########################################################################################
"
exit
