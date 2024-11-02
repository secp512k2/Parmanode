#functions here:
    # enter_continue
    # enter_exit
    # choose
    # invalid
    # previous menu
    # please wait
    # announce
    # errormessage

function enter_continue {
echo -e "$@"
unset enter_cont
if [[ $installer == parmanodl ]] ; then return 0 ; fi
echo -e " ${yellow}Hit ${cyan}<enter>${yellow} to continue.$orange"  
read enter_cont 
export enter_cont
if [[ $enter_cont == q ]] ; then exit ; fi
if [[ $enter_cont == d ]] ; then #switch
    if [[ $debug == 1 ]] ; then export debug=0 ; fi
    if [[ $debug == 0 ]] ; then export debug=1 ; fi
fi

return 0
}

function enter_or_quit {
echo -e " ${yellow}Hit ${cyan}<enter>${yellow} to continue.$yellow, or $red q$yellow to quit.$orange" 
read enter_cont ; export enter_cont
if [[ $enter_cont == debugon ]] ; then export debug=1 ; fi
if [[ $enter_cont == debugoff ]] ; then export debug=0 ; fi
if [[ $enter_cont == q ]] ; then exit ; fi
return 0

}

function enter_abort {
echo -e " ${yellow}Hit ${cyan}<enter>${yellow} to continue, or$red a$yellow to abort.$orange" 
#use this in a loop...
#read choice ; case $choice in a|A) return 1 ;; "") break ;; esac ; done
return 0
}

function enter_return { enter_continue "$@" ; }

function enter_exit {
echo -e " ${yellow}Hit ${cyan}<enter>${yellow} to exit.$orange" ; read
return 0
}

function choose {

if [[ $1 == "xmq" ]]
then
echo -e " ${yellow}Type your$cyan choice$yellow from above options, or:$red (m)$yellow for main,$green (q)$yellow to quit. 
 Then <enter> : $orange"
return 0
fi

if [[ $1 == "xpmq" ]]
then
echo -e " ${yellow}Type your$cyan choice$yellow from above options, or:$cyan (p)$yellow for previous,$red (m)$yellow for main,$green (q)$yellow to quit. 
 Then <enter> : $orange"
return 0
fi

if [[ $1 == "emq" ]]
then
echo -e " ${yellow}Hit$cyan enter$yellow to continue, or:$red (m)$yellow for main,$green (q)$yellow to quit.$orange" 
return 0
fi

if [[ $1 == "epmq" ]]
then
echo -e " ${yellow}Hit$cyan enter$yellow to continue, or:$cyan (p)$yellow for previous,$red (m)$yellow for main,$green (q)$yellow to quit.$orange" 
return 0
fi

if [[ $1 == "xpq" ]]
then
echo -e " ${yellow}Type your$cyan choice$yellow from above options, or:$cyan (p)$yellow for previous,$green (q)$yellow to quit. 
 Then <enter> : $orange"
return 0
fi

if [[ $1 == "xq" ]]
then
echo -e " ${yellow}Type your ${cyan}choice${yellow}, or$cyan (q)$yellow to quit, then <enter>: $orange"
return 0
fi

if [[ $1 == "eq" ]]
then
echo -e " ${yellow}Hit ${cyan}<enter>${yellow}, to continue, or ${cyan}(q)${yellow} to quit, then <enter>: $orange"
return 0
fi

if [[ $1 == "x" ]]
then
echo -e " ${yellow}Type your ${cyan}choice${yellow}, then <enter>: $orange"
return 0
fi

if [[ $1 == "epq" ]]
then
if [[ -z $2 ]] ; then CONTINUE="continue" ; fi
echo -e " ${yellow}Hit ${cyan}<enter>${yellow} to $2, ${cyan}(p)${yellow} for previous, ${cyan}(q)${yellow} to quit, then <enter>: $orange"
# while true ; do 
# case $choice in q|Q|QUIT|Quit) exit 0 ;; p|P) return 1 ;; "") break ;; *) invalid ;; esac ; done
return 0
fi

if [[ $1 == "esq" ]]
then
echo -e " ${yellow}Hit ${cyan}<enter>${yellow} to continue, ${cyan}(s)${yellow} to skip, ${cyan}(q)${yellow} to quit, then <enter>: $orange"
# while true ; do 
# case $choice in q|Q|QUIT|Quit) exit 0 ;; p|P) return 1 ;; "") break ;; *) invalid ;; esac ; done
return 0
fi

if [[ $1 == "qc" ]]
then
echo -e " ${yellow}Hit ${cyan}(q)${yellow} then <enter> to quit, ${cyan}anything${yellow} else to continue.$orange"
return 0
fi

return 1 
}

function invalid {

set_terminal

echo -e " ${yellow}Invalid choice. Hit ${cyan}<enter>${yellow} before trying again. $orange" ; read invalid
if [[ $invalid == 'q' || $invalid == "exit" ]] ; then exit ; fi
return 0
}

function previous_menu { 

echo -e " ${yellow}Hit ${cyan}<enter>${yellow} to go back to the previous menu.$orange" ; read
return 0
}

function please_wait_no_clear { 
echo -e "
Please wait, this may take some time ...
"
return 0
}

function please_wait { 
set_terminal

takes="some time"
if [[ -n $1 ]] ; then takes="$1" ; fi #changes $takes if needed

echo -e "
Please wait, this may take ${takes}...
"
return 0
}

function announce {
set_terminal ; echo -e "
########################################################################################

    $1"
if [[ -z $2 ]] ; then
echo -e "
########################################################################################
"
else
echo -e "    $2

########################################################################################
"
fi
if [[ $2 == enter || $3 == enter ]] ; then return 0 ; else enter_continue ; return 0 ; fi
}

function errormessage {
echo -e ""
echo -e " There has been an error. See log files for more info."
enter_continue
}

function yesorno {

if [[ -n $2 ]] ; then
y=$2
else
y="y"
fi

if [[ -n $3 ]] ; then
yes=$3
else
yes="yes"
fi

if [[ -n $4 ]] ; then
n=$4
else
n="n"
fi

if [[ -n $5 ]] ; then
no=$5
else
no="no"
fi


while true ; do
set_terminal ; echo -ne "
########################################################################################

    $1
$cyan
                            $y)$orange   \r\033[49C$yes
$cyan
                            $n)$orange   \r\033[49C$no

########################################################################################

    Type '${cyan}y$orange' or '${cyan}n$orange' then $green<enter>$orange
    OR '${red}q$orange' to quit, or '${red}m$orange' for main menu

"
read choice
case $choice in
q|Q) exit ;; m|M) back2main ;;
"$y") return 0 ;;
"$n") return 1 ;;
*)
invalid
;;
esac
done
}


