function parmased {
file="$1"
string="$2"
new_string="$3"
placement="$4"
silent="$5"

newfile=$tmp/string.txt

# Find how many lines in the file have the string; remove whitespace
search_lines=$(sudo cat $file | grep "$string" | wc -l | tr -d ' ')

# Find how big is the document (lines)
file_lines=$(sudo cat $1 | wc -l | tr -d ' ')

# Function is designed for one instance of string found; ward otherwise
if [[ $search_lines -gt 1 && $silent != silent ]] ; then
echo -e "
########################################################################################
$red
    More than one search match found. Continue?
$orange
                               y)      Yes
$green
                               n)      No
$orange
########################################################################################
"
choose "xpmq" ; read choice
jump $choice || { invalid ; continue ; } ; set_terminal
case $choice in
q|Q) exit ;;  p|P|n) return 1 ;; m|M) back2main ;;
y)
echo ""
echo "OK, will only be using first string instance"
enter_continue ; jump $enter_cont
;;
esac
fi

#get the line_number of the search (document counts starts at line 1 not zero)
line_number=$(cat $file | grep -n "$string" | head -n 1 | cut -d : -f 1 | tr -d ' ')

# For "after" placement - insert a new line after the string is found.
if [[ $placement == "after" ]] ; then

    #Write a new file up to and including the search string.
    head -n $line_number $file | sudo tee $newfile >$dn 2>&1

    #print the new string to add
    echo "$new_string" | sudo tee -a $newfile >$dn 2>&1

    #add the rest
    remaining_lines=$((file_lines - line_number))
    tail -n $remaining_lines $file | sudo tee -a $newfile >$dn 2>&1

    #rename
    sudo mv $newfile $1
fi
}