FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    software-properties-common \
    tzdata

RUN echo "America/Sao_Paulo" | tee /etc/timezone && \
    ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

RUN add-apt-repository ppa:ondrej/php -y

RUN apt-get update && apt-get install -y --allow-unauthenticated \
    php7.3 \
    php-xml \
    php7.3-dev \
    php7.3-xml \
    php7.3-curl \
    php-pear \
    curl \
    gnupg \
    libapache2-mod-php7.3 \
    apache2 \
    git

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update && ACCEPT_EULA=Y apt-get install -y \
    msodbcsql17 \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install sqlsrv \
    && pecl install pdo_sqlsrv \
    && pecl install rar

RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.3/mods-available/sqlsrv.ini \
    && printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.3/mods-available/pdo_sqlsrv.ini

RUN phpenmod -v 7.3 sqlsrv pdo_sqlsrv

#RUN apt-get install -y \    libapache2-mod-php7.3 \    apache2 \    && rm -rf /var/lib/apt/lists/*

RUN a2dismod mpm_event \
    && a2enmod mpm_prefork \
    && a2enmod php7.3 \
    && a2enmod rewrite

#COPY ./html /src

RUN git clone https://github.com/misaelbg/WebEngine.git /src

RUN rm -rf /var/www/html && mv /src /var/www/html &&\
    find /var/www/html/ -type d -exec chmod 755 {} \; &&\
    find /var/www/html/ -type f -exec chmod 644 {} \; &&\
    chmod -R 777 /var/www/html/includes/cache /var/www/html/includes/logs &&\
    chmod 777 /var/www/html/includes/config/modules/*.xml &&\
    chmod 777 /var/www/html/includes/config/*.json &&\
    chmod 777 /var/www/html/includes/config/*.xml &&\
    chmod 444 /var/www/html/.htaccess &&\
    chmod -R 777 /var/www/html/templates

RUN echo "short_open_tag=On" >> /etc/php/7.3/apache2/php.ini
RUN echo "extension=rar.so" >> /etc/php/7.3/apache2/php.ini
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /etc/php/7.3/apache2/php.ini
RUN sed -i 's/post_max_size = 8M/post_max_size = 100M/g' /etc/php/7.3/apache2/php.ini 

RUN mkdir /var/www/uploads && chmod -R 777 /var/www/uploads

RUN printf '\n<Directory "/var/www/html/">\n  AllowOverride All\n  Allow from All\n</Directory>' >> /etc/apache2/sites-enabled/000-default.conf

#ENTRYPOINT service apache2 restart
EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
