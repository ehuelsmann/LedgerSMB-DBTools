FROM  debian:stretch
MAINTAINER erik erik@hucs.nl

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install \
   lsb-release starman libdbd-pg-perl libdbi-perl libtemplate-perl \
   libplack-perl libclone-perl libyaml-perl libplack-middleware-fixmissingbodyinredirect-perl \
   libplack-middleware-removeredundantbody-perl libhttp-body-perl \
   cpanminus make gcc

RUN cpanm --notest --quiet Dancer2
RUN cpanm --notest --quiet Dancer2::Session::Cookie
RUN cpanm --notest --quiet Dancer2::Plugin::Auth::Extensible;

WORKDIR /srv/LedgerSMB_DBTools
CMD /usr/bin/plackup bin/app.psgi

