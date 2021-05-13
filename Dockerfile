FROM centos:7
MAINTAINER Larry Loi<larry.loi@gamesourcecloud.com>

# Dockerfile for systemd base image
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

# Update centos library & install required library
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y nc vim curl mailx mysql-devel mysql nodejs libv8-dev && \
    yum clean all

RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    curl -L get.rvm.io | bash -s stable && \
    source /etc/profile.d/rvm.sh && \
    /usr/local/rvm/bin/rvm reload

COPY .ruby-version $REL_PATH/.ruby-version

RUN \
    source /etc/profile.d/rvm.sh && \
    /bin/bash -l -c "rvm install --force $(cat .ruby-version); gem install bundler; rvm cleanup all"

LABEL application=centos7-ruby2.7.2
