FROM balabit/syslog-ng:latest
LABEL maintainer="Sebthemonster <contact@sebthemonster.com>"

COPY syslog-ng.conf/rails /etc/syslog-ng/conf.d/rails
COPY logrotate.d/app /etc/logrotate.d/app
ENTRYPOINT ["/usr/sbin/syslog-ng", "-F", "--no-caps"]
