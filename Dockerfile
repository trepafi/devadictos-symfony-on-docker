FROM phusion/baseimage:0.9.17
MAINTAINER Lubert Palacios  <trepafi@gmail.com>

RUN apt-get update && \
    apt-get install -y php5 php5-common php5-cli \
                       php5-fpm php5-mcrypt php5-mysql php5-apcu \
                       php5-gd php5-imagick php5-curl php5-intl

CMD ["php5-fpm", "-F"]
RUN usermod -u 1000 www-data

# ADD ./symfony-on-docker /code
ADD ./entrypoint.sh /init/entrypoint.sh
RUN chmod 700 /init/entrypoint.sh

VOLUME /code
WORKDIR /code

EXPOSE 8000
ENTRYPOINT /init/entrypoint.sh
