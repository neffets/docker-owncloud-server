FROM owncloud/base:latest AS build
MAINTAINER neffets <software@neffets.de>

RUN curl -sLo - ${OWNCLOUD_TARBALL} | tar xfj - -C /var/www/
#ADD owncloud-${VERSION}.tar.bz2 /var/www/

COPY ./entrypoint-70-enable-userexternal.sh /etc/entrypoint.d/.
COPY source/ /

RUN curl -sLo user_ldap.tar.gz ${LDAP_TARBALL} && \
  echo "$LDAP_CHECKSUM user_ldap.tar.gz" | sha256sum -c - && \
  mkdir -p /var/www/owncloud/apps/user_ldap && \
  tar xfz user_ldap.tar.gz -C /var/www/owncloud/apps/user_ldap --strip-components 1 && \
  rm -f user_ldap.tar.gz

RUN curl -sLo activity.tar.gz ${ACTIVITY_TARBALL} && \
  echo "$ACTIVITY_CHECKSUM activity.tar.gz" | sha256sum -c - && \
  mkdir -p /var/www/owncloud/apps/activity && \
  tar xfz activity.tar.gz -C /var/www/owncloud/apps/activity --strip-components 1 && \
  rm -f activity.tar.gz

RUN curl -sLo calendar.tar.gz ${CALENDAR_TARBALL} && \
  echo "$CALENDAR_CHECKSUM calendar.tar.gz" | sha256sum -c - && \
  mkdir -p /var/www/owncloud/apps/calendar && \
  tar xfz calendar.tar.gz -C /var/www/owncloud/apps/calendar --strip-components 1 && \
  rm -f calendar.tar.gz

RUN ( test -r ${CONTACTS_TARBALL} && mv -f ${CONTACTS_TARBALL} contacts.tar.gz && \
  echo "$CONTACTS_CHECKSUM contacts.tar.gz" | sha256sum -c - && \
  mkdir -p /var/www/owncloud/apps/contacts && \
  tar xfz contacts.tar.gz -C /var/www/owncloud/apps/contacts --strip-components 1 && \
  rm -f contacts.tar.gz ) || echo "contacts app not found, put it into data/apps/contacts/"

RUN find /var/www/owncloud \( \! -user www-data -o \! -group www-data \) -print0 | xargs -r -0 chown www-data:www-data


FROM owncloud/base:latest
MAINTAINER neffets <software@neffets.de>

RUN apt-get update && \
  apt-get install -y php-imap && \
  phpenmod imap && \
  apt-get clean all;

COPY --from=build /var/www/owncloud/apps/ /var/www/owncloud/apps/

LABEL org.label-schema.version=$VERSION
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vcs-url="https://github.com/neffets/docker-owncloud-server.git"
LABEL org.label-schema.name="ownCloud Server"
LABEL org.label-schema.vendor="neffets"
LABEL org.label-schema.schema-version="1.0"
