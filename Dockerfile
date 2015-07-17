FROM ubuntu:14.04.2
MAINTAINER Jim Lin <jim_lin@quantatw.com>


ADD apt.conf /etc/apt/ 
ADD .gitconfig /root/
#RUN apt-get update
#RUN apt-get update -qq
ADD sources.list /etc/apt/
RUN rm /var/lib/apt/lists/* -rvf
# install adb tool

# Stop debconf from complaining about missing frontend
ENV DEBIAN_FRONTEND noninteractive

# 32-bit libraries and build deps for ADB
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y install --no-install-recommends libc6:i386 libstdc++6:i386 && \
	apt-get -y install --no-install-recommends openjdk-7-jdk wget python-setuptools  unzip tar python-pip git python-opencv ipython && \
    apt-get -y install --no-install-recommends python-scipy python-matplotlib python-numpy python-tk

# Install a basic SSH server
RUN apt-get install -y --no-install-recommends openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# install uiautomator wrapper
RUN pip install --proxy=http://10.242.104.204:5678/ uiautomator
RUN pip install --proxy=http://10.242.104.204:5678/ nose
ENV https_proxy=http://10.242.104.204:5678/
ENV http_proxy http://10.242.104.204:5678/
# Install ADB
RUN wget --progress=dot:giga -O /opt/sdk.tgz \
    http://dl.google.com/android/android-sdk_r24.1.2-linux.tgz && \
    tar xzf /opt/sdk.tgz  -C /opt && \
    rm /opt/sdk.tgz 

# SET ENV
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
# Install tools
#RUN echo y | android update sdk --filter platform-tools,extra-android-support --no-ui --force
RUN echo y | android update sdk --no-ui --filter 2,platform-tools --force
#chmod for andoird-sdk-linux
RUN chmod a+x /opt/android-sdk-linux -R

# Set up insecure default key
RUN mkdir -m 0750 /.android
ADD files/insecure_shared_adbkey /.android/adbkey
ADD files/insecure_shared_adbkey.pub /.android/adbkey.pub

# Clean up
RUN apt-get -y --purge remove wget && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/cache/apt/*

# Add user jenkins to the image
RUN adduser --quiet jenkins 
RUN adduser jenkins sudo
# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:jenkins" | chpasswd

USER jenkins
# Add files for development environment
RUN mkdir -p /home/jenkins/.ssh
ADD .gitconfig /home/jenkins/
ADD .bashrc /home/jenkins/
ADD .profile /home/jenkins/
USER root

RUN chown jenkins:jenkins -R /home/jenkins
# Expose default ADB port
#EXPOSE 5037

# Start the server by default. This needs to run in a shell or Ctrl+C won't
# work.
#CMD /usr/local/bin/adb -a -P 5037 fork-server server
#
# Standard SSH port
EXPOSE 22
#
CMD ["/usr/sbin/sshd", "-D"]
#  
