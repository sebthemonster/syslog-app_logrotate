FROM balabit/syslog-ng:latest
LABEL maintainer="Sebastien Ballarin <sebastien.ballarin@gmail.com>"

COPY logrotate.d/app /etc/logrotate.d/app
