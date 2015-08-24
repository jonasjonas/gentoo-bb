#
# build config
#
PACKAGES="media-gfx/imagemagick media-gfx/graphicsmagick media-video/ffmpeg"

#
# this method runs in the bb builder container just before starting the build of the rootfs
#
configure_rootfs_build()
{
    echo 'PHP_TARGETS="php5-6"' >> /etc/portage/make.conf
    echo 'PHP_INI_VERSION="production"' >> /etc/portage/make.conf

    update_use 'media-gfx/imagemagick' '+jpeg' '+jpeg2k' '+png' '+tiff' '+webp'
    update_use 'media-gfx/graphicsmagick' '+jpeg' '+jpeg2k' '+png' '+tiff'
    update_use 'media-video/ffmpeg' '+aac' '+faac' '+theora' '+x264' '+xvid' \
        '+aacplus' '+amrenc' '+mp3' '+vorbis' '+webp' '+x265' '+schroedinger'
}

#
# this method runs in the bb builder container just before tar'ing the rootfs
#
finish_rootfs_build()
{
    echo ''
}
