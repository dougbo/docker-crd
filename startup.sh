#!/bin/bash


### initialize for our container owner ###

# chromote wants a user to operate on behalf of
DOCKERENV_HOME=/home/$DOCKERENV_USER
useradd -m -d $DOCKERENV_HOME -g users $DOCKERENV_USER
adduser $DOCKERENV_USER sudo

chsh -s /bin/bash $DOCKERENV_USER

# set up that user's ssh environment
mkdir $DOCKERENV_HOME/.ssh
echo "$DOCKERENV_AUTHKEYS" >$DOCKERENV_HOME/.ssh/authorized_keys
chmod -R go-rx $DOCKERENV_HOME/.ssh
chown -R $DOCKERENV_USER:users $DOCKERENV_HOME/.ssh

# for debugging, since we don't have a password and containers are open
SUDOFILE=/etc/sudoers.d/$DOCKERENV_USER
echo "$DOCKERENV_USER   ALL=(ALL:ALL) NOPASSWD: ALL" >$SUDOFILE
chmod 0440 $SUDOFILE

# the default sizes work tragically on a laptop -- we're making a small
# number of windows, not some arbitrary workspace
echo "export CHROME_REMOTE_DESKTOP_DEFAULT_DESKTOP_SIZES=800x600" >> $DOCKERENV_HOME/.profile


### finish initializing the system ###

# gather up syslog in the containing vm's log infrastructure
echo "*.*	@$DOCKERENV_HOST" >>/etc/rsyslog.conf

# random system fixups
# chmod 666 /dev/null

# restarts the core windowing and logging services service
/etc/init.d/rsyslog restart

/etc/init.d/dbus restart
/etc/init.d/xdm restart

# Start the ssh service
mkdir /var/run/sshd 

/usr/sbin/sshd -D
