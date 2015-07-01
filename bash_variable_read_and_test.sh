#!/bin/bash
# If an argument was passed to this script, use it as a config file
if [ ! "x$1" = "x" ]; then
    # If the argument is a valid file...
    if [ -f "$1" ]; then
        # Set the $file var
        file=$1
        # Source the contents of the config file into this script
        source $file
        # If that failed, error and quit.
        if [ ! "$?" = "0" ]; then
            echo "Error encountered loading config"
            exit 1
        fi
    # If the file isn't found, let the user know, but still use this to save stuff to later.
    else
        echo "File $1 not found - will save any variables to this config."
    fi
    # Set conf=true, so we know we loaded in a config file successfully.
    conf=true
fi

# Function for checking that a variable's content isn't empty.
check_var(){
    if [ -z "$1" ]||[ "x$1" = "x" ]; then
        echo "Please provide a value...";
        sleep 2
        clear
        return 0
    else
        return 1
    fi
}

# For each item; defined as:   <VAR_NAME>:<MESSAGE_TO_DISPLAY>
for i in access:"Please provide Access ID" other:"Please provide other value"; do
    # Split up the input line
    VAR=$(echo $i | awk -F: '{print$1}')
    MSG=$(echo $i | awk -F: '{print$2}')
    # Parse the variable to get the '$' version
    NEWVAR=$(echo "\$${VAR}")

    # Set A=0 before our loop (to allow breaking out easily later)
    A=0
  
    # Until something is happy, and sets $A to 1...
    until [ $A = 1 ]; do
        # If the variable doesn't already have a value (ie. from the config file...
        if [ "x`eval echo $NEWVAR`" = "x" ]; then
            # Print the chosen message
            echo -n "${MSG}: "
            # Read the desired value from the user
            read $VAR
            # Pass it to our variable check to make sure the user really gave us something.
            eval check_var $NEWVAR
            # Set A to be the return code of the function (1=OK, 0=empty)
            A=$?
            # If we're happy, and a config file was defined at the start, then write our variable out to the config file.
            if [ $A = 1 ]&&[ "$conf" = "true" ]; then
               echo "Appending variable \"$NEWVAR\" to config file."
               echo "$VAR=`eval echo $NEWVAR`" >> $file
            fi
        # If the variable has already been read  in from the config file, let the user know:
        else
            echo "Variable \"$NEWVAR\" has been loaded from the config file - value: `eval echo $NEWVAR`"
            # Break the loop and continue to the next var.
            A=1
        fi
    done
done
