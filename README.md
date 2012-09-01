#gitbx 

A basic script for integrating Git and Dropbox. Essentially automates the process described [here](http://stackoverflow.com/questions/1960799/using-gitdropbox-together-effectively) for using [Dropbox]() to store private repositories. 

#Usage

From within your working local git repository, simply type

    gitbx

and follow the instructions. `gitbx` will create a bare repository inside your dropbox folder, and creates a remote named `dropbox`. Currently it will also push your `master` branch of your local repository. 

You can also type

    gitbx <remote> <location> <branch>

to create a repository named `<remote>.git` inside `~/Dropbox/Git/<location>`. This command will push `<branch>` to the `dropbox` remote.

#Customization

By default, `gitbx` assumes that you keep your bare repositories inside `~/Dropbox/Git/`. You can change that by setting the variable `myGitbx` to the desired value. 

It also allows you to sort your bare repositories inside subdirectories. By default, bare repositories will be created in `~/Dropbox/Git/docs/`. Again, you can change that by setting `mySubdir` to the desired value. 

#Options

You can specify a name for your remote repository by typing: 

    gitbx <your_repo>

or, alternatively, 

    gitbx -n <your_repo>

In addition, you can specify a subdirectory for your remote: 

    gitbx -l <your_subdir>

will tell `gitbx` to create the remote repository inside `<your_subdir>` instead of using the value of `mySubdir`. 

You can have two main subdirectories pre-defined for `gitbx` to use. By default: 

    gitbx -p

will create the remote repository in `~/dropbox/git/packages/`. You can change that by setting the variable `mySubdir2` to the desired value. 

`gitbx` is configured to push your `master` branch. You can change the default behavior by setting the variable `myBranch` to the desired branch. In addition, 

    gibx -b <your_branch>

will push `<your_branch>` instead of `master`. 








