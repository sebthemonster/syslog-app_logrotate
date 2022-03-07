# syslog-app_logrotate
A Docker syslog-ng image with logrotate configuration on all app logs in /var/log/app

Image build from [official syslog-ng image](https://registry.hub.docker.com/r/balabit/syslog-ng) or [GitHub page](https://github.com/syslog-ng/syslog-ng/tree/master/docker).

* A syslog-ng configuration file to parse ruby on rails logs to ltsv logs is present in syslog-ng.conf directory : rails.conf file.
  
This configuration use environment variables to set project specific values like tokens, url to logs data platform, port, log file paths...

The log file paths in .env file must be relative to /var/log/app directory.

These values must be written in `logs.env` file if you use docker-compose.yml example file.

* All log files *.log in /var/log/app directory will be automatically rotated according to configuration file logrotate.d/app

* A docker-compose file is given as example to publish rails logs to a logs data platform with sharing logs between docker containers through named volume.

## FROM balabit/syslog-ng README

* Syslog-ng is installed with all of its modules
  * Within the container syslog-ng will start in foreground. This is useful because if there is some error with syslog-ng we can easily check the output console log through the `docker logs [containerID]` command
  * You can use your own `syslog-ng.conf` or fall back to use the default one

The following ports are exposed:
 * Syslog UDP: 514,
 * Syslog TCP: 601,
 * Syslog TLS: 6514

Syslog-ng will listen on these ports and forwards the logs into the file
`/var/log/syslog`. You can check the default configuration in the source
repository of this image.

## Using default configuration
Assume that the following ports are not used on host machine, because they can conflict: `514`, `601`:

```bash
sudo docker run -it -p 514:514/udp -p 601:601 --name syslog-ng balabit/syslog-ng:latest
```
By default syslog-ng will not print any debug messages to the console. If you want to see more debug messages you need to start the containers in this way:

```bash
sudo docker run -it -p 514:514/udp -p 601:601 --name syslog-ng balabit/syslog-ng:latest -edv
```

## Using custom syslog-ng configuration
You can override the default configuration by mounting a configuration file under `/etc/syslog-ng/syslog-ng.conf`:

```bash
sudo docker run -it -v "$PWD/syslog-ng.conf":/etc/syslog-ng/syslog-ng.conf balabit/syslog-ng:latest
```

## Reading logs from other containers
An example is used to describe how syslog-ng can read logs from other containers.

Assume that you have already running an `apache2` container which exposes its logs as a mounted volume under "/var/log/apache2/". We will read the apache logs and send them to a remote host (`1.2.3.4:514`). The example syslog-ng configuration file is stored in the current directory as `syslog-ng.conf`.

```
source s_apache {
  file("/var/log/apache2/access.log");
};

destination d_remote {
  tcp("1.2.3.4" port(514));
};

log {
  source(s_apache);
  destination(d_remote);
};
```

Now we can start syslog-ng:

```bash
sudo docker run -it --volumes-from [containerID for apache2] -v "$PWD/syslog-ng.conf":/etc/syslog-ng/syslog-ng.conf balabit/syslog-ng:latest
```

## Entering into a container
Assume that your running container has a name "syslog-ng". In this case we can enter into this container by executing the following command:

```bash
sudo docker exec -it syslog-ng /bin/bash
```

## More information
For detailed information on how to run your central log server in Docker and other Docker-related syslog-ng use cases, see the blog post [Your central log server in Docker](https://syslog-ng.com/blog/central-log-server-docker/).

## FAQ

### capabilities

If the given configuration requires, syslog-ng tries to set some POSIX capabilities at startup, but (by default) Docker do not grant capabilities to the containers. Mainly there are three methods to circumvent this:
 * If you do not require any capability (i.e. don't want to listen on ports under 1024 - NET_BIND_SERVICE), simply start syslog-ng with the `--no-caps` option.
 * If you know precisely the type of capability you need, use the `--cap-add` option of the Docker service.
 * (For development/testing purpose only!) To grant ALL of the capabilities to your container, start it with the `privileged` option. However, we do not recommend this method in production environments.

## MORE
This image is used in production as it but any improvement is welcome.
