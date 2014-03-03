#
#

# DOCKERENV_HOST: hostname we are invoked from
# DOCKERENV_HOSTIP: ip of host we are invoked from
# DOCKERENV_USER: user we're setting this host up for

FROM debian
MAINTAINER doug orr "doug.orr@gmail.com"


RUN echo deb http://dl.google.com/linux/chrome-remote-desktop/deb/ stable main >/etc/apt/sources.list.d/chromeos.list
RUN ls -l /etc/apt/sources.list.d
RUN apt-get update
RUN apt-key update
RUN apt-get install -y apt-utils

# get crd
RUN apt-get -y --allow-unauthenticated install chrome-remote-desktop

# get sublime
ENV SUBLIME sublime-text_build-3047_amd64.deb
ADD http://c758482.r82.cf2.rackcdn.com/$SUBLIME /tmp/$SUBLIME
RUN dpkg -i /tmp/$SUBLIME
RUN ln -s /opt/sublime_text/sublime_text /usr/bin/sublime

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Installing the environment required: xserver, xdm, and ssh
RUN apt-get install -y rox-filer ssh fluxbox 
RUN apt-get install -y rsyslog
RUN apt-get install -y xserver-xorg xdm

# Set locale (fix the locale warnings)
RUN apt-get install -y locales

RUN apt-get -y upgrade

# Copy the files into the container
ADD . /src

# minor cleanup
RUN sed 's/# en_US/en_US/g' </etc/locale.gen >/tmp/locale.out; mv /tmp/locale.out /etc/locale.gen
RUN locale-gen
# RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8
RUN ln -s /usr/bin/Xvfb /usr/bin/xvfb


# NOTE: we're single user and various things don't work if they try
# to work with setgid programs that try to read /etc/shadow;
# DON"T STORE PASSWORDS IN THIS CONTAINER
RUN chmod go+r /etc/shadow

# allow ssh -- we'll have to dig the port out of the ps entry later
EXPOSE 22

# Start xdm and ssh services.
CMD ["/bin/bash", "/src/startup.sh"]
