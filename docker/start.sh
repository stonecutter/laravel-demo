#!/usr/bin/env bash

set -e

role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}

cd /var/www/laravel
php artisan migrate --force
rm -f public/storage
php artisan voyager:install

if [ "$env" != "local" ]; then
    echo "Caching configuration..."
    php artisan config:cache
    php artisan view:cache
    if [[ ${role} != *"voyager"* ]];then
        php artisan route:cache
    fi
fi

if [[ "$role" =~ "scheduler" ]]; then
    echo "start cron"
    crontab /var/spool/cron/crontabs/root
    /etc/init.d/cron start
    /etc/init.d/cron status
fi

if [[ "$role" =~ "app" ]]; then

    exec apache2-foreground

elif [ "$role" =~ "queue" ]; then

    echo "Running the queue..."
    php artisan queue:work --queue={wechat-mini-program-push} --verbose --tries=3 --timeout=90

else
    tail -f /var/log/faillog
fi
