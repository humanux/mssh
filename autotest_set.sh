#/bin/bash
PATH_ROOT=$PWD
DEVEL_FLAG=devel
GIT_ROOT_PATH=git://qe-git.englab.nay.redhat.com/s2
GIT_ROOT_PATH_DEV=git@qe-git.englab.nay.redhat.com:\~/repo/s2
cd $PATH_ROOT
if [ $# != 1 ]
then
	DEVEL_FLAG="-$DEVEL_FLAG"
	git clone $GIT_ROOT_PATH/staf-kvm$DEVEL_FLAG
        git clone $GIT_ROOT_PATH/autotest$DEVEL_FLAG
else
	if [ "$1" == 's' ]
	then
		DEVEL_FLAG=
		git clone $GIT_ROOT_PATH/staf-kvm$DEVEL_FLAG
		git clone $GIT_ROOT_PATH/autotest$DEVEL_FLAG
	else
		DEVEL_FLAG="-$DEVEL_FLAG"
		if [ "$1" == 'd' ]
		then
			git clone $GIT_ROOT_PATH_DEV/staf-kvm$DEVEL_FLAG
			git clone $GIT_ROOT_PATH_DEV/autotest$DEVEL_FLAG
		else
			git clone $GIT_ROOT_PATH/staf-kvm$DEVEL_FLAG
			git clone $GIT_ROOT_PATH/autotest$DEVEL_FLAG

		fi
	fi
fi
mv $PATH_ROOT/autotest$DEVEL_FLAG $PATH_ROOT/staf-kvm$DEVEL_FLAG
cd $PATH_ROOT/staf-kvm$DEVEL_FLAG
ln -s  autotest$DEVEL_FLAG/client  kvm-test
