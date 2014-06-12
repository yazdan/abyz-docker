# abyz-drupal
#
# VERSION               1.0.0

FROM    ubuntu:14.04
MAINTAINER Abbas Yazdanpanah <yazdanpanah.a@gmail.com> 
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main restricted universe multiverse" > /etc/apt/sources.list
RUN apt-get update
#RUN apt-get -y upgrade

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
#RUN ln -s /bin/true /sbin/initctl

# Basic Requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-client apache2 libapache2-mod-php5 php5-mysql php-apc python-setuptools curl git unzip

# Drupal Requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imap php5-memcache memcached drush mc

RUN apt-get -y install openssh-server
RUN apt-get -y install stunnel4
RUN apt-get clean

# Retrieve drupal
RUN rm -rf /var/www/html ; cd /var ; drush dl drupal ; mv /var/drupal*/ /var/www/html
RUN chmod a+w /var/www/html/sites/default ; mkdir /var/www/html/sites/default/files ; chown -R www-data:www-data /var/www/html


# Supervisor Config
RUN /usr/bin/easy_install supervisor
ADD ./supervisord.conf /etc/supervisord.conf

# Drupal Initialization and Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# Apache start script
ADD ./startapache.sh /startapache.sh
RUN chmod 755 /startapache.sh
RUN a2enmod rewrite

# private expose
EXPOSE 80
EXPOSE 22

# ssh config
RUN echo "root:root" | chpasswd
RUN mkdir /var/run/sshd
ADD sshd_config /etc/ssh/sshd_config

# apache config
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf

#stunnel config
ADD stunnel.conf /etc/stunnel/


CMD ["/bin/bash", "/start.sh"]
