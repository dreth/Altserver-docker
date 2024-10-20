# Altserver-docker

A dockerized version of [AltServer-Linux](https://github.com/NyaMisty/AltServer-Linux) with Wi-Fi sync capability. 

**NOTE:** I still keep track of this project as unfortunately it's the only way to have a reliable AltServer on Linux, however, as of iOS 18, it seems that _AltServer_ is not open source and the upstream repo that [AltServer-Linux tracks from](https://github.com/rileytestut/AltServer-Windows) is also unmaintained. Therefore, I would strongly recommend to switching to [SideStore](https://sidestore.io/), which _does not_ require an AltServer to run. Otherwise, your apps will likely become unverified over time. 

## Requirements

- Docker
- Avahi running on host system
- usbmuxd **NOT** running on host system

## Installation

### Installing Docker (if not installed already)

#### Linux:
Option 1 (preferred): [Docker Engine](https://docs.docker.com/engine/install/)

Option 2: [Docker Desktop](https://docs.docker.com/desktop/install/linux-install/)

#### Windows:
[Install WSL2](https://docs.docker.com/desktop/wsl/) then use the Linux install instructions or install using [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/).

#### macOS:
Install using [Docker Desktop](https://docs.docker.com/desktop/install/mac-install/).

### Installing Avahi on Host System

#### Arch-based distros:
```shell
pacman -S avahi
```

#### Debian/Ubuntu-based distros:
```shell
apt install avahi-daemon
```

#### Fedora-based distros:
```shell
dnf install avahi
```

#### Enable and start the service using systemd:
```shell
sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon
```

### Stopping or removing usbmuxd from Host System

#### Stop and disable the service using systemd:
```shell
sudo systemctl stop usbmuxd
sudo systemctl disable usbmuxd
```

#### Arch-based distros:
```shell
pacman -R usbmuxd
```

#### Debian/Ubuntu-based distros:
```shell
apt remove usbmuxd
```

#### Fedora-based distros:
```shell
dnf remove usbmuxd
```

### Run Using Docker Compose (recommended)

To start up the application, you can run:

```shell
docker compose up -d
```

Or optionally if you'd like to build it yourself, modify the docker-compose.yml, uncomment the build config and run the docker-compose stack with the optional build flag:

```shell
docker compose up -d --build
```

### Run Using `docker run`

Just run `run.sh`, or manually in your terminal:

```shell
docker build . -t altserver-docker && \
docker stop altserver || true && \
docker rm altserver || true && \
sudo docker run -d \
  -v "./lib:/root/.config/Provision/lib" \
  -v "./logs:/altserver/logs" \
  -v "./bin:/altserver/bin" \
  -v "/dev/bus/usb:/dev/bus/usb" \
  -v "/var/lib/lockdown:/var/lib/lockdown" \
  -v "/var/run:/var/run" \
  -v "/sys/fs/cgroup:/sys/fs/cgroup:ro" \
  --name altserver \
  --network host \
  --privileged \
  altserver-docker 
```

## Install AltStore on iOS Device

1. Make sure you have your Device UDID (can be found using [this guide](https://discussions.apple.com/thread/250783627)).

2. Run this command to install AltStore to your device:

```shell
docker exec -it altserver /altserver/bin/AltServer -u "<UDID>" -a "<Apple ID>" -p "<Password>" /altserver/bin/AltStore.ipa
```

NOTE: Only tested with Docker running on Linux. YMMV when running Docker on other operating systems.

## Logs

Logs will be stored in the directory where the container is ran inside `./logs`

## Optional environment variables

### Overriding architectures for libraries and binaries

It's possible to override which architecture of altserver, netmuxd, anisette-server and provision libraries (for anisette) are downloaded by setting the following environment variables in the docker compose file:

```yaml
  environment:
    - OVERRIDE_ALTSERVER_ARCH=x86_64
    - OVERRIDE_NETMUXD_ARCH=x86_64
    - OVERRIDE_ANISETTE_ARCH=x86_64
    - OVERRIDE_PROVISION_LIBS_ARCH=x86_64
```

or alternatively adding them in the `docker run` command before the image name:

```shell
  -e OVERRIDE_ALTSERVER_ARCH=x86_64 \
  -e OVERRIDE_NETMUXD_ARCH=x86_64 \
  -e OVERRIDE_ANISETTE_ARCH=x86_64 \
  -e OVERRIDE_PROVISION_LIBS_ARCH=x86_64 \
```

You can check for which architectures are available by checking the releases of each project:

- [AltServer-Linux](https://github.com/NyaMisty/AltServer-Linux/releases)
- [netmuxd](https://github.com/jkcoxson/netmuxd/releases)
- [Provision](https://github.com/Dadoum/Provision/releases) (this is the anisette-server)
- The libraries are pulled from the apple music android apk, so the only available options are `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`

### Overriding whether provision libraries are decompressed from the repo or downloaded

It's possible to allow provision to download the libraries it needs from the apple music android apk by setting the following environment variable in the docker compose file:

```yaml
  environment:
    - ALLOW_PROVISION_TO_DOWNLOAD_LIBS=true
```

or alternatively adding it in the `docker run` command before the image name:

```shell
  -e ALLOW_PROVISION_TO_DOWNLOAD_LIBS=true \
```

When this variable is present, the libraries will be downloaded by provision, if it's not present, the libraries will be decompressed from the repo.

## Provision libraries

Provision automatically pulls the libraries it requires (libCoreADI.so and libstoreservicescore.so) from the apple music android apk, but this requires a 60+MB download it does automatically, so I decided to include these in the root of the repo already and have the `docker-entrypoint.sh` decompress them where Provision normally would. This is optional and can be overridden by setting the `ALLOW_PROVISION_TO_DOWNLOAD_LIBS` environment variable to `true`.

### Updating lib.tar.xz

To update lib.tar.xz just run:

```shell
bash scripts/provision-deps-manual-download.sh
```

from the root of the repo.

## Credits

I authored this repo but I did NOT author the projects it depends on. In particular:

- [AltServer-Linux](https://github.com/NyaMisty/AltServer-Linux)
- [netmuxd](https://github.com/jkcoxson/netmuxd/)
- [Provision](https://github.com/Dadoum/Provision/)
- [Altstore](https://altstore.io)

And some other projects which inspired me to create this repo:

- [altserverd](https://github.com/hkfuertes/altserverd) which I took inspiration and some code from.
- [AltServer-Linux-PyScript](https://github.com/powenn/AltServer-Linux-PyScript/issues) which I audited and took inspiration from.

## Contributing

Feel free to open an issue or a PR if you have any suggestions or improvements to this repo. I'm always open to feedback and contributions!
