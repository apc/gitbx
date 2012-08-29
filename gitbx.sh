#!/bin/sh
#TODO: 
#1. write usage
#2. allow user to specify which branch to push.

choice=docs #default directory for dropbox repositories. The flag -p sets $choice to 'packages'.

# Get argument for naming remote repo before flags. This will look for arguments after `gitbx` before the firt flag.
n=1
while [ $# -gt 0 ]
do
  case $1 in
    -*) break;;
    *) eval "arg_$n=\$1"; n=$(( $n + 1 )) ;;
  esac
  shift
done

#Define flags. -n allows to specift the name for the remote repo.
while getopts "pn:" OPTION 
do
	case $OPTION in
		p) 
			choice=packages;;
		n) 
			arg_1=$OPTARG ;;
	esac
done
# Check if there already is a remote named 'dropbox'
if [ -d ".git/refs/remotes/dropbox" ]; then 
	echo "Gitbx: Error: You already have a remote repository in your Dropbox folder."; 
	exit
else 
	if [ -d .git ]; then #Check to see that this is a git repository.
		if [ -z "$arg_1" ]; then #Prompt for name of remote repo if not initially specified.
			echo "What would you like to name the dropbox remote?"
			read remotebox;
		else
			remotebox="$arg_1";
		fi;
		# echo "~/dropbox/git/$choice/$remotebox.git" Uncomment this for debugging purposes.
		git ls-remote dropbox &>/dev/null 
		# Check to see whether there is an alias named 'remote', even if 
		# .git/refs/remotes/dropbox does not exist. 
		# This will only happen if one manually deletes the remote info 
		# without doing `git rm dropbox`.
		if test $? = 0; then 
			read -p "Gitbx: Warning: A remote named 'dropbox' already exists, even though .git/refs/remotes/dropbox does not. Would you like to reset it? (y/n) " -n 1 -r
			echo
			if [[ $REPLY =~ ^[yY] ]]; then
				git remote rm dropbox &>/dev/null ;
			else
				if [[ $REPLY =~ ^[nN] ]]; then
					echo "Gitbx: Fair enough. I guess I cannot help you this time. Good bye."
					exit;
				else
					echo "Gitbx: Error: I'm afraid you gave an invalid answer, so you you will have to start over."
					exit;
				fi;
			fi;
		fi;
		# Create bare repository in dropbox. 
		cd ~/dropbox/git/$choice/ && git init --bare --quiet $remotebox.git && cd - &>/dev/null 
		# Point the alias 'dropbox' to that remote.
		git remote add dropbox ~/dropbox/git/$choice/$remotebox.git
		# Push master branch.
		git push -u --quiet dropbox master
		echo "Initialized a bare repository at ~/Dropbox/Git/$choice/$remotebox.git."	
	else
		echo "Gitbx: Error: You need to set up a local repository first. If this is a TeX directory, try using gittex.";
	fi;
fi;
