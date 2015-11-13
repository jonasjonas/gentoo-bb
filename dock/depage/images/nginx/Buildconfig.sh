#
# build config
#
PACKAGES="www-servers/nginx"

#
# this method runs in the bb builder container just before starting the build of the rootfs
#
configure_rootfs_build()
{
    echo 'NGINX_MODULES_HTTP="access auth_basic autoindex charset fastcgi http2 \
             gzip gzip_static limit_req map proxy rewrite scgi ssi stub_status"' >> /etc/portage/make.conf
    echo 'NGINX_MODULES_MAIL=""' >> /etc/portage/make.conf
    update_use 'dev-libs/libpcre' '-readline'
    update_keywords 'www-servers/nginx' '+~amd64'
}

#
# this method runs in the bb builder container just before tar'ing the rootfs
#
finish_rootfs_build()
{
    mkdir -p $EMERGE_ROOT/etc/nginx/conf.d
}
