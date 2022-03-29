FROM --platform=linux/arm/v7 rafa606/robotiqcontrol
WORKDIR /
ENV SSL_CERT_FILE=/usr/lib/ssl/certs/ca-certificates.crt
SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o \
        Dpkg::Options::="--force-confnew" \
        vim screen libnss-mdns && \
     echo $'\
[server]\n\
host-name=robotiq\n\
use-ipv4=yes\n\
enable-dbus=no\n\
ratelimit-interval-usec=1000000\n\
ratelimit-burst=1000\n\
[wide-area]\n\
enable-wide-area=yes\n\
[publish]\n\
publish-hinfo=no\n\
publish-workstation=no\n\
\n\
[reflector]\n\
\n\
[rlimits]\n' > /etc/avahi/avahi-daemon.conf \
    && echo source /opt/ros/noetic/setup.bash >> /etc/bash.bashrc \
    && echo export ROS_MASTER_URI=http://smart_app.local:11311 >> /etc/bash.bashrc \
    && echo export ROS_IP=robotiq.local >> /etc/bash.bashrc \
    && echo $'\
#!/bin/bash\n\
main(){\n\
echo [server] >> /etc/avahi/avahi-daemon.conf\n\
echo allow-interfaces=$(ip --brief a l | grep brwifi | awk \'{print $1}\' | sed \'s/@.*//\') >> /etc/avahi/avahi-daemon.conf\n\
service ssh start\n\
service avahi-daemon restart\n\
source /opt/ros/noetic/setup.bash\n\
export ROS_MASTER_URI=http://smart_app.local:11311\n\
export ROS_IP=robotiq.local\n\
bash\n\
}\n\
main $@' > /entrypoint.bash
ENTRYPOINT ["bash", "/entrypoint.bash"]
