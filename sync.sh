#!/bin/bash

# port for rsync over ssh
PORT="your_port"
# backup hostname or IP
HOST="example.com"
# Your SSH ID KEY
SSH_ID="$HOME/.ssh/your_key"
# username for rsync over ssh
USER="your_user"
# backup directory path on backup host
SYNC_DIRECTORY="/home/backup/test"
# exclude-list file
EXCLUDE="sync_exclude"
# max file size limit for sync (default: 50M)
MAX_FSIZE="50M"

# Check ssh connection
check_ssh() {
    ssh_connect=$(ssh -q -o BatchMode=yes -o ConnectTimeout=5 -i $SSH_ID $USER@$HOST -p $PORT echo $?)
    if [[ $ssh_connect == 0 ]] ; then
    	echo $HOST : "ssh connection successful"
    elif [[ $status == "Permission denied"* ]] ; then
        echo $HOST $status "Permission denied.Check your ssh connection"
	exit 1
    else
       	echo $HOST $status "Check your network and ssh connection"
	exit 1
    fi
}

# Check remote backup directory
check_remotedirectory() {
    check_directory=$(ssh -q -o BatchMode=yes -i $SSH_ID $USER@$HOST -p $PORT [ -d "$SYNC_DIRECTORY" ] &&  echo $?)
    if [[ $check_directory == 0 ]] ; then
    	echo $SYNC_DIRECTORY found.OK.
    else
    	echo $SYNC_DIRECTORY not found.check this!!!
	exit 1
    fi
}

# end of controls before run script
check_end() {
    # check root control!
    if [ "$EUID" == "0" ] ; then
    	echo "You not be root to run this script.You are silly!" 1>&2
    	exit 1
    fi
    # check required commands
    CMDS="ssh rsync"
    for i in $CMDS
    do
    	command -v $i > /dev/null 2>&1 && continue || { echo "$i command not found."; exit 1;}
    done
}

# check root and command control before run script
check_end  

command_usage() {
    # usage and parametres control
    usage="$(basename "$0") [-h] [-c] [-r]
    backup and sync your home directory to remote server
    Arguments:
	-h help 
	-c check ssh for remote secure connection
	-r check remote backup/sync directory"
    # if you want to add a parametre with argument.you can use ':'. 
    #for example, "set -- $(getopt hrc: "$@")" -> you have to an argument for 'c' parametre's.
    set -- $(getopt hrc "$@")
    while [ $# -gt 0 ]
    do
    	case "$1" in
    	    (-h) echo "$usage"
	        exit
	     	;;
	    (-r) check_remotedirectory
	     	;;
	    (-c) check_ssh
	        ;;
	    (--) break
	        ;;
	    (*) echo "$0: error - unrecognized option $1" 1>&2
	        exit 1
	        ;;
        esac
        shift
    done
}

command_usage

start_sync() {

#rsync -avz --exclude-from "$EXCLUDE" --max-size=50M -e 'ssh -p '$PORT'' $HOME "$USER"@"$HOST":"$SYNC_DIRECTORY"

}
