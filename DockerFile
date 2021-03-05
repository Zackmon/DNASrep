FROM ubuntu:16.04
WORKDIR /work

RUN apt-get update && apt-get install -y \
  libssl-dev ssl-cert php7.0 libapache2-mod-php7.0 \
  wget unzip php7.0-mcrypt libmcrypt-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./DNASrep /work/DNASrep

RUN echo "extension=mcrypt.so" > /etc/php/7.0/mods-available/mcrypt.ini \
  && a2enmod ssl && a2ensite default-ssl && phpenmod mcrypt \
  && a2enmod proxy && a2enmod proxy_http && a2enmod proxy_connect


RUN cp -r /work/DNASrep/www/dnas /var/www/dnas \
  && cp -r /work/DNASrep/etc/dnas /etc/dnas \
  && ln -s /etc/apache2/sites-available/dnas.conf /etc/apache2/sites-enabled/dnas.conf \
  && unlink /etc/apache2/sites-enabled/000-default.conf \
  && unlink /etc/apache2/sites-enabled/default-ssl.conf \
  && ln -sf /proc/self/fd/1 /var/log/apache2/access.log \
  && ln -sf /proc/self/fd/1 /var/log/apache2/error.log

COPY ./dnas.conf /etc/apache2/sites-available/dnas.conf



RUN apt-get update && apt-get install bind9 bind9utils bind9-doc dnsutils -y

ADD ./dns_files/db.dnas.rpz /etc/bind/db.dnas.rpz
ADD ./dns_files/named.conf.local /etc/bind/named.conf.local
ADD ./dns_files/named.conf.options /etc/bind/named.conf.options


# DNAS Port
EXPOSE 443
# DNS Server port
EXPOSE 53/udp 53/tcp


ADD ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh


CMD ["/entrypoint.sh"]
