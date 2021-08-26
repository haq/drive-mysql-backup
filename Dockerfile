FROM php:cli-alpine

# update index of available packages
RUN apk update

# install (docker-cli & tzdata)
RUN apk add --no-cache docker-cli tzdata

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# create the app directory
WORKDIR /app

# copy only the package files
COPY composer.json composer.lock /app/
RUN composer install --optimize-autoloader --no-dev

# copy the source
COPY . /app

# schedule the cron job
RUN echo "0 0 * * * cd /app && php index.php" | crontab -
CMD ["crond", "-f"]
