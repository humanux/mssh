#/bin/bash
PATH_ROOT=$PWD
DEVEL_FLAG=devel
GIT_ROOT_PAH=git://x.x.x.x
GIT_ROOT_PATH_DEV=git@x.x.x.x:/path
cd $PATH_ROOT
if [ $# != 1 ]
then
	DEVEL_FLAG="-$DEVEL_FLAG"
	git clone $GIT_ROOT_PATH/staf-kvm$DEVEL_FLAG
        git clone $GIT_ROOT_PATH/autotest$DEVEL_FLAG
else
	if [ "_$1" == '_s' ]
	then
		DEVEL_FLAG=
		git clone $GIT_ROOT_PATH/staf-kvm$DEVEL_FLAG
		git clone $GIT_ROOT_PATH/autotest$DEVEL_FLAG
	else
		DEVEL_FLAG="-$DEVEL_FLAG"
		if [ "_$1" == '_d' ]
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
