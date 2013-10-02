#!/bin/sh
# 
# gitbx: A simple script for using Dropbox for private repositories.
# ==================================================================
# A.P.C.
# 
# TODO: 
# 1. The -l option might conflict with -p. Need to go through this and find
# a less cumbersome solution.
# 2. Test to see whether Dropbox is installed needs to be improved.
# 3. Allow user to push changes using gitbx directly.
# 4. README could be improved.
# 5. Write man.
# 6. Create option for moving the dropbox repository.
# 7. Allow user not to use subdir at all and go straight to myGitbx.

# Main variables
mySubdir=docs #default subdirectory for dropbox repositories. The flag -p sets $mySubdir to 'packages'.
myGitbx=/Users/apc/Dropbox/Git # Default location for Dropbox repositories.
mySubdir2=packages

# Set myBranch to current branch: cf. http://stackoverflow.com/a/2111099/938774
branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,') &&
myBranch=$branch

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

# Set variables to values given in arguments before option flags.

myName=$arg_1

if [ -z "$arg_2" ]; then
	continue;
else
	mySubdir=$arg_2;
fi;

if [ -z "$arg_3" ]; then
	continue;
else
	myBranch=$arg_3;
fi;

#Define flags. 
# -n allows to specify the name for the remote repo. 
# -l allows to specify a location within myGitbx. 
# -b allows to specify a branch to push to remote.
# -p uses mySubdir2 to specify location for the remote repo.
# If the value for the corresponding variables has been already set as argument
# of gibx, this will yield an error message.
while getopts "pn:l:b:" OPTION 
do
	case $OPTION in
		p)  
			if [ -z "$arg_2" ]; then
				mySubdir=$mySubdir2;
			else
				echo "Gitbx: Error: Conflicting options. I can't place your remote in both $mySubdir2 and $arg_2." 
				exit;
			fi;
				;;
		n) 
			if [ -z "$arg_1" ]; then
				myName=$OPTARG;
			else
				echo "Gitbx: Error: Conflicting options. I can't name your remote both '$myName' and '$arg_1'."
				exit;
			fi;
				;;
		l)
			if [ -z "$arg_2" ]; then
				mySubdir=$OPTARG ;
			else
				echo "Gitbx: Error: Conflicting options. I can't place your remote in both $mySubdir and $arg_2."
				exit;
			fi;
				;;
		b)
			if [ -z "$arg_3" ]; then
				myBranch=$OPTARG ;
			else
				echo "Gitbx: Error: Conflicting options. I can't push both branches $OPTARG and $arg_3 at once."
				exit;
			fi;
			;;
	esac
done

# Check if ~/Dropbox exists.
if [ -d ~/Dropbox ]; then
	continue;
else
	echo "Gitbx: Error: It appears that you have not yet installed Dropbox in your system. \n Please verify that Dropbox is installed, and modify gitbx.sh to specify the location of your Dropbox folder.";
fi;

# Check if myGitbx exists. Give user the option to create it if not.
if [ -d "$myGitbx" ]; then
	continue;
else
	read -p "Gitbx: Warning: The directory $myGitbx does not exist. Would you like gitbx to create it for you? (y/n) " -n 1 -r
	if [[ $REPLY =~ ^[yY] ]]; then
				mkdir -p $myGitbx &>/dev/null
	else
		if [[ $REPLY =~ ^[nN] ]]; then
			echo
			echo "Gitbx: Fair enough. I guess I cannot help you this time. Good bye."
			exit;
		else
			echo
			echo "Gitbx: Error: I'm afraid you gave an invalid answer, so you you will have to start over."
			exit;
		fi;
	fi;
fi;

# Check if there already is a remote named 'dropbox'
if [ -d ".git/refs/remotes/dropbox" ]; then 
	echo "Gitbx: Error: You already have a remote repository in your Dropbox folder. Good bye."; 
	exit;
else 
	# Check to see that this is a git repository. 
	# Gives an error message if it is not.
	if [ -d .git ]; then 
		# Prompt for name of remote repo if not initially specified.
		if [ -z "$myName" ]; then 
			echo "What would you like to name the dropbox remote?"
			read myName;
		else
			continue ;
		fi;
		# echo "~/dropbox/git/$mySubdir/$myName.git" Uncomment this for debugging purposes.
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
		# 
		# First check whether mySubdir exists.
		# Give user the option to create it if it doesn't.
		if [ -d $myGitbx/$mySubdir ]; then
			continue
		else
			read -p "Gitbx: Warning: The directory $myGitbx/$mySubdir/ does not exist. Would you like gitbx to create it for you? (y/n) " -n 1 -r
			echo
			if [[ $REPLY =~ ^[yY] ]]; then
				mkdir -p $myGitbx/$mySubdir &>/dev/null
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

		# Create bare repository in myGitbx/mySubdir
		cd $myGitbx/$mySubdir/ && git init --bare --quiet $myName.git && cd - &>/dev/null 

		# Point the alias 'dropbox' to that remote.
		git remote add dropbox $myGitbx/$mySubdir/$myName.git

		# Push myBranch.
		git push -u --quiet dropbox $myBranch
		echo "Gitbx: Initialized a bare repository at $myGitbx/$mySubdir/$myName.git."	
	else
		echo "Gitbx: Error: You need to set up a local repository first. If this is a TeX directory, try using gittex.";
	fi;
fi;
