FROM ubuntu:14.04
MAINTAINER Jim Lin <jim_lin@quantatw.com>


ADD apt.conf /etc/apt/ 
ADD .gitconfig /root/
RUN apt-get update -qq


# install adb tool

# Stop debconf from complaining about missing frontend
ENV DEBIAN_FRONTEND noninteractive

# 32-bit libraries and build deps for ADB
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y install libc6:i386 libstdc++6:i386 && \
	apt-get -y install wget unzip python-setuptools  python-pip git

# Install a basic SSH server
RUN apt-get install -y --no-install-recommends openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# install uiautomator wrapper
RUN pip install --proxy=http://10.241.104.240:5678/ uiautomator
RUN pip install --proxy=http://10.241.104.240:5678/ git+https://github.com/dtmilano/AndroidViewClient.git
ENV https_proxy=http://10.241.104.240:5678/
ENV http_proxy http://10.241.104.240:5678/
# Install ADB
RUN wget --progress=dot:giga -O /opt/adt.zip \
      http://dl.google.com/android/adt/adt-bundle-linux-x86_64-20140702.zip && \
    unzip /opt/adt.zip adt-bundle-linux-x86_64-20140702/sdk/platform-tools/adb -d /opt && \
    mv /opt/adt-bundle-linux-x86_64-20140702 /opt/adt && \
    rm /opt/adt.zip && \
    ln -s /opt/adt/sdk/platform-tools/adb /usr/local/bin/adb

# Set up insecure default key
RUN mkdir -m 0750 /.android
ADD files/insecure_shared_adbkey /.android/adbkey
ADD files/insecure_shared_adbkey.pub /.android/adbkey.pub

# Clean up
RUN apt-get -y --purge remove wget unzip && \
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
USER root

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
