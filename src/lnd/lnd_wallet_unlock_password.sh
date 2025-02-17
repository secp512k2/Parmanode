#restarts LND
function lnd_wallet_unlock_password {

while true ; do
unset lndpassword lndpassword2
set_terminal ; echo -e "
########################################################################################
$cyan
                                LND wallet lock password
$orange 
    To automatically unlock your wallet whenever LND restarts, please$green enter
    exactly the same password$orange you used earlier when you created the wallet $orange
    
    If you don't, that's fine, you just have to manually unlock the wallet ever time
    LND starts.

    $pink
        Type password$orange and hit $cyan<enter> $orange (keystrokes won't be shown)

        Or,$cyan <enter>$orange alone to decline auto-unlock feature.

########################################################################################
"
read -s lndpassword  ; set_terminal
case $lndpassword in
q|Q) exit ;; p|P) return 1 ;;  m|M) back2main ;;
"")
return
;;
esac

echo -e "
########################################################################################
$cyan
Please repeat the password...
$orange
########################################################################################

"
read -s lndpassword2
set_terminal
#delete file, create file, later populate file.
if grep -q "lnd" $ic >$dn 2>&1 ; then
sudo rm $HOME/.lnd/password.txt >$dn 2>&1
touch $HOME/.lnd/password.txt && chmod 600 $HOME/.lnd/password.txt
elif grep -q "litd" $ic >$dn 2>&1 ; then
sudo rm $HOME/.lit/password.txt >$dn 2>&1
touch $HOME/.lit/password.txt && chmod 600 $HOME/.lit/password.txt
fi

if [[ $lndpassword != $lndpassword2 ]] ; then
    echo "Passwords do not match. Try again."
    enter_continue ; continue
else
set_terminal ; echo -e "
########################################################################################
    
    Auto-unlock enabled. You can change the password anytime using the Parmanode LND
    menu, or you can actually edit the text file$cyan $HOME/.lnd/password.txt$orange 
    yourself anytime.

    But do understand that this is$red not where you wallet password is set.$orange It's more
    like a key which is the same as the wallet password, allowing the computer to
    access it, read it and enter the password to unlock your wallet on your behalf.
    
    If you entered a password that doesn't match your wallet's locking password,
    then the wallet is not going to be unlocked.

########################################################################################
"
enter_continue ; jump $enter_cont

    echo "$lndpassword" | sudo tee $HOME/.lnd/password.txt >$dn 
    break
fi

done
}