#!/usr/bin/env bash
STARTED_AT=$(date +%s)
./vendor/bin/phpunit --version
if [ -n "$(ls patches/)" ]; then
    for i in patches/*.patch; do
        patch -N -p0 -i $i || true;
    done;
fi
php artisan migrate
php artisan migrate:refresh
if [ $? -ne 0 ]; then
    exit 1
fi
I=1
FLAG=0
for FILENAME in $(find tests/ -type f -name "*Test.php")
do
    printf '-'
    I=$(($I + 1))
    OUTPUT=$(./vendor/bin/phpunit $FILENAME)
    if [ $? -ne 0 ]; then
        FLAG=$(($FLAG + 1))
        printf "\n$FILENAME\n"
        echo "$OUTPUT"
        exit 1
    fi
done

printf "\n\n"
if [ $FLAG -eq 0 ]; then
    echo 'OK ('$I' files)'
else
    echo 'ERRORS!'
    echo 'Files: '$I', Errors: '$FLAG'.'
fi
FINISHED_AT=$(date +%s)
echo 'Time taken: '$(($FINISHED_AT - $STARTED_AT))' seconds'
exit $FLAG
