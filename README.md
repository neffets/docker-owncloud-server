# neffets / ownCloud Server

Use the base images provided by https://github.com/owncloud-docker/server

and improves them with external user auth via imap

The ownCloud image is the community edition, it is built from [owncloud/server](https://registry.hub.docker.com/u/owncloud/server/). This ownCloud image is designed to work with a data volume in the host filesystem and with separate MariaDB and Redis containers.

## Volumes

* /mnt/data


## Ports

* 80
* 443

## Configuration

Amongst the normal owncloud configuration which will be accessible in data/config/config.php
you can add user_external authentication via imap, see ```example.config-imap.php```

```
$CONFIG['user_backends'] =
  array (
    0 =>
    array (
      'class' => 'OC_User_IMAP',
      'arguments' =>
      array (
        0 => '{imap.example.com:993/imap/ssl}INBOX',
      ),
    ),
  );
```

## Build

new method:
```
IMAGE_NAME=neffets/owncloud:${VERSION} ./hooks/build2
```

old method:
```
. .env; IMAGE_NAME=neffets/owncloud:${VERSION} ./hooks/build
```

You can then rebuild the docker container via:
e.g. docker build -t neffets/owncloud:10.0.3 -f Dockerfile.10.0.3 .

The apps "user_ldap", "activity", "calendar" can be added automatically.
The "contacts" app is no longer downloadable directly, please get it from https://marketplace.owncloud.com/apps/contacts and put it into the source/ folder.

For automated builds, if "contacts" app is not available, tehn You can put the extracted "contacts" app into
your volume folder data/apps/contacts/. Enable "contacts" app via:
```
docker container -it $CONTAINERNAME occ app:enable contacts
```

## Using

### Launch with `docker-compose`

The installation of `docker-compose` is not covered by these instructions, please follow the [official installation instructions](https://docs.docker.com/compose/install/). After the installation of `docker-compose` you can continue with the following commands to start the ownCloud stack. First we are defining some required environment variables, then we are downloading the required `docker-compose.yml` file. The `.env` and `docker-compose.yml` are expected in the current working directory, when running `docker-compose` commands, for the ownCloud version you can choose any of the available tags:

```bash
cat << EOF > .env
VERSION=10.0
DOMAIN=localhost
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin
HTTP_PORT=80
HTTPS_PORT=443
EOF

wget -O docker-compose.yml https://raw.githubusercontent.com/owncloud-docker/server/master/docker-compose.yml

# Finally start the containers in the background
docker-compose up -d
```

More commands of interest (try adding `-h` for help):

```bash
docker-compose exec owncloud bash
docker-compose stop
docker-compose start
docker-compose down
docker-compose logs
```

By default `docker-compose up` will start Redis, MariaDB and ownCloud containers, the `./data` and `./mysql` directories are used to store the contents persistently. The container ports `80` and `443` are bound as configured in the `.env` file.

### Commandline commands

You can run `occ` commands inside the ownCloud docker image, without caring for sudo and apache user, as the command is wrapped in a little script caring for that. Just run:

```
occ user:report

occ app:enable user_external
occ app:enable calendar
occ app:enable contacts

occ upgrade --no-app-disable
```

You can also run commands via `docker exec`, or `docker-compse exec`:

```
docker exec -ti example_owncloud_1 occ user:report
docker-compose exec owncloud occ user:report
```

### Upgrade to newer version

In order to upgrade an existing container-based installation you just need to shutdown the setup and replace the used container version. While booting the containers the upgrade process gets automatically triggered, so you don't need to perform any other manual step.


### Custom apps

Installed apps or config.php changes inside the docker container are retained across stop/start as long as you keep the volumes configured.


### Custom certificates

By default we generate self-signed certificates on startup of the containers, you can replace the certificates with your own certificates. Place them into `./data/certs/ssl-cert.crt` and `./data/certs/ssl-cert.key`.


### Accessing the ownCloud

By default you can access the ownCloud instance at [https://localhost/](https://localhost/) as long as you have not changed the port binding. The initial user gets set by the environment variables `ADMIN_USERNAME` and `ADMIN_PASSWORD`, per default it's set to `admin` for username and password.

## Authors

* orig: [Thomas Boerger](https://github.com/tboerger)
* orig: [Felix Boehm](https://github.com/felixboehm)
* here: [neffets](https://github.com/neffets)

## License

MIT

