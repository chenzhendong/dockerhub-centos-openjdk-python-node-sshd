FROM centos:latest

WORKDIR /root

RUN yum -y update; \
 yum -y install git sudo wget nc unzip openssh-server openssh-clients lsof net-tools python38 which; \
 yum -y update; \
 yum clean all

RUN cd /root; \
 wget https://download.java.net/java/GA/jdk16/7863447f0ab643c585b9bdebf67c69db/36/GPL/openjdk-16_linux-x64_bin.tar.gz; \
 tar zxvf openjdk-16_linux-x64_bin.tar.gz; \
 mkdir -p /usr/lib/jvm; \
 mv /root/jdk-16 /usr/lib/jvm/; \
 alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-16/bin/java 1000; \
 alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-16/bin/javac 1000; \
 rm -fr /root/openjdk-16_linux-x64_bin.tar.gz

RUN dnf update -y; \
 dnf install -y epel-release; \
 yum -y update; \
 yum install -y supervisor; \
 mkdir -p /etc/supervisor/conf.d; \
 echo -e '[supervisord]\n\
 nodaemon=true\n\
 \n\
 [program:sshd]\n\
 command=/usr/sbin/sshd -D\n\
 ' > /etc/supervisor/conf.d/supervisord.conf

RUN useradd -m -G root,wheel centos; echo "centos:changeit" | chpasswd; mkdir -p /home/centos/.ssh; \
 sed -i -r 's/%wheel[ \t]+ALL=\(ALL\)[ \t]+ALL/%wheel\tALL=(ALL)\tNOPASSWD: ALL/g' /etc/sudoers; \
 chown -R centos /home/centos; \
 chmod 700 /home/centos/.ssh; \
 echo "America/New_York" > /etc/timezone; unlink /etc/localtime; ln -s /usr/share/zoneinfo/America/New_York /etc/localtime; \
 /usr/bin/ssh-keygen -A; \
 rm /run/nologin; \
 yum clean all

USER centos
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash; \
 source /home/centos/.bashrc; \
 nvm install --lts 

EXPOSE 22 80 443 8080 3000
CMD ["sudo", "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
