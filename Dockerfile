FROM balabit/syslog-ng:latest
LABEL maintainer="Sebastien Ballarin <sebastien.ballarin@gmail.com>"

COPY syslog-ng.conf/rails /etc/syslog-ng/conf.d/rails
COPY logrotate.d/app /etc/logrotate.d/app
