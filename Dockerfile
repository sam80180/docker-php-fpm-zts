FROM php:7.1-fpm

RUN apt-get update ; apt-get install -y libxml2-dev libssl-dev libcurl4-openssl-dev libedit-dev

# https://github.com/docker-library/php/issues/249#issuecomment-446563798
RUN cd /usr/src && tar -xf php.tar.xz && cd php-7.1.17 && \
	./configure `php-config --configure-options` --enable-maintainer-zts && make && make install

RUN cp /usr/src/php-7.1.17/php.ini-production /usr/local/etc/php/php.ini && \
	cp /usr/src/php-7.1.17/php.ini-production /usr/local/etc/php/php-cli.ini

# install pthreads
RUN apt-get install -y git && \
	git clone https://github.com/krakjoe/pthreads.git && cd pthreads && \
	git checkout 527286336ffcf5fffb285f1bfeb100bb8bf5ec32 && \
	phpize && ./configure && make clean ; make && make install && \
	PHP_ZTS_CLI_INI_FILE="/usr/local/etc/php/php-cli.ini" && \
	lineNo=`grep -n ";extension=" ${PHP_ZTS_CLI_INI_FILE} | head -n 1 | awk 'BEGIN {FS=":"} {print $1}'` && \
	sed -i "${lineNo}iextension=pthreads.so" ${PHP_ZTS_CLI_INI_FILE}
