#
# build config
#
PACKAGES="dev-lang/php:5.6 dev-php/pecl-memcache dev-php/pecl-redis dev-php/pecl-ssh2"
#PACKAGES="dev-lang/php:5.6 dev-php/pecl-memcache dev-php/pecl-redis"
PHP_TIMEZONE="${BOB_TIMEZONE:-UTC}"
ICONV_FROM=gentoobb/glibc

#
# this method runs in the bb builder container just before starting the build of the rootfs
#
configure_rootfs_build()
{
    echo 'PHP_TARGETS="php5-6"' >> /etc/portage/make.conf
    echo 'PHP_INI_VERSION="production"' >> /etc/portage/make.conf

    update_use 'dev-lang/php' '+bcmath' '+calendar' '+curl' '+curlwrappers' '+fpm' '+gd' '+mhash' \
               '+mysql' '+mysqli' '+pdo' '+soap' '+sockets' '+xml' '+xmlreader' '+xmlrpc' '+xmlwriter' \
               '+xslt' '+xpm' '+zip' '+intl'
    update_use 'app-eselect/eselect-php' '+fpm'
    update_keywords 'dev-php/pecl-redis' '+~amd64'
    update_keywords 'dev-php/pecl-memcache' '+~amd64'
    update_keywords 'dev-php/pecl-ssh2' '+~amd64'

    # skip bash, perl, autogen. pulled in as dep since php 5.5.22
    provide_package app-shells/bash dev-lang/perl sys-devel/autogen
}

#
# this method runs in the bb builder container just before tar'ing the rootfs
#
finish_rootfs_build()
{
    # set php iconv default to UTF-8, if you need full iconv functionality set ICONV_FROM=gentoobb/glibc above
    sed -i 's/^;iconv.input_encoding = ISO-8859-1/iconv.input_encoding = UTF-8/g' $EMERGE_ROOT/etc/php/fpm-php5.6/php.ini
    sed -i 's/^;iconv.internal_encoding = ISO-8859-1/iconv.internal_encoding = UTF-8/g' $EMERGE_ROOT/etc/php/fpm-php5.6/php.ini
    sed -i 's/^;iconv.output_encoding = ISO-8859-1/iconv.output_encoding = UTF-8/g' $EMERGE_ROOT/etc/php/fpm-php5.6/php.ini
    # set php time zone
    sed -i "s@^;date.timezone =@date.timezone = $PHP_TIMEZONE@g" $EMERGE_ROOT/etc/php/fpm-php5.6/php.ini
    # use above changes also for php cli config
    cp $EMERGE_ROOT/etc/php/fpm-php5.6/php.ini $EMERGE_ROOT/etc/php/cli-php5.6/php.ini
    # required by null-mailer
    copy_gcc_libs
    chmod 0640 $EMERGE_ROOT/etc/nullmailer/remotes
    # prepare adminer / phpinfo micro sites
    mkdir -p $EMERGE_ROOT/var/www/phpinfo
    echo "<?php phpinfo(); ?>" > $EMERGE_ROOT/var/www/phpinfo/phpinfo.php
}
