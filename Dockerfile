FROM php:7.2-apache
MAINTAINER Mats Löfgren <mats.lofgren@matzor.eu>
MAINTAINER Guy Pascarella <guy.pascarella@gmail.com>

RUN a2enmod rewrite

RUN apt-get update && apt-get install -y \
    git libfreetype6-dev libpng-dev libjpeg-dev zlib1g unzip wget && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-install mysqli mbstring && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ &&\
    docker-php-ext-install gd calendar


ENV Q2A_VERSION 1.7.5
ENV Q2A_FILE_NAME question2answer-${Q2A_VERSION}.zip
ENV Q2A_DOWNLOAD_URL https://github.com/q2a/question2answer/releases/download/v${Q2A_VERSION}/${Q2A_FILE_NAME}

RUN mkdir -p /var/www && \
    rm -rf /var/www/html && \
    cd /var/www && pwd && \
    wget ${Q2A_DOWNLOAD_URL} && \
    unzip /var/www/${Q2A_FILE_NAME} && \
    mv /var/www/question2answer-${Q2A_VERSION} /var/www/html && \
    rm -f /var/www/${Q2A_FILE_NAME}

ADD q2a-install-plugin /usr/local/bin/q2a-install-plugin

# Install some common plugins
RUN /usr/local/bin/q2a-install-plugin NoahY/q2a-badges && \
	/usr/local/bin/q2a-install-plugin jhubert/qa-hipchat-notifications && \
	/usr/local/bin/q2a-install-plugin zakkak/qa-ldap-login && \
	/usr/local/bin/q2a-install-plugin arjunsuresh/q2a-xml-rpc && \
	/usr/local/bin/q2a-install-plugin nakov/q2a-plugin-open-questions && \
	/usr/local/bin/q2a-install-plugin q2a-projects/q2a-tag-descriptions && \
	/usr/local/bin/q2a-install-plugin arjunsuresh/categorydescription && \
	/usr/local/bin/q2a-install-plugin arjunsuresh/tag-search

ADD entrypoint.sh /entrypoint.sh
RUN chown root:root /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
