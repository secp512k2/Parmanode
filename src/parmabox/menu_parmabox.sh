function menu_parmabox {
 while true ; do set_terminal ; echo -e "
########################################################################################
              $cyan              ParmaBox Menu            $orange                   
########################################################################################

$cyan
            pm)$orange        Log into the container as parman   (type exit to return here)
$cyan
            ec)$orange        Run Electrum Wallet Crack tool
$cyan
            s)$orange         Stop the container
$cyan
            rs)$orange        Restart the container
$cyan
            u)$orange         Run an update of Parmanode and the OS inside the container
$cyan
            rf)$orange        Refresh ParmaBox (starts over and includes new updates)

$orange
########################################################################################
"
choose "xpmq" ; read choice ; set_terminal
case $choice in 
m|M) back2main ;;
q|Q|QUIT|Quit) 
exit 0 ;;
p|P) menu_use ;; 
r|R) 
docker exec -it -u root parmabox /bin/bash ;;
pm) 
docker exec -it -u parman parmabox /bin/bash ;;
ec)
electrum_crack ;;
s) 
docker stop parmabox ;;
rs) 
docker start parmabox ;;
u) 
docker exec -it -u root parmabox bash -c "apt update -y && apt -y upgrade" 
echo "Update Parmanode..."
docker exec -it -u parman parmabox bash -c "cd /home/parman/parman_programs/parmanode ; git pull"
sleep 2
;;
rf)
parmabox_refresh
;;
*)
invalid
;;

esac
done
} 

function electrum_crack {
set_terminal ; echo -e "
########################################################################################

    This tool will help you crack a locked electrum wallet file. It is not a
    passphrase cracker, but a password cracker. The password would have been used
    at the start to encrypt the wallet file.

    You must first place the file in the dirctory...
$cyan
   $hp/parmabox/
$orange
   Then the script will prompt you for the file.

########################################################################################
"
choose epmq ; read choice ; set_terminal
case $choice in
q|Q) exit ;; p|P) return 1 ;; m|M) back2main ;;
esac

docker exec -it parmabox /bin/bash -c "python3 /home/parman/parman_programs/parmanode/src/ParmaWallet/electrum_cracker/crack.py"

}