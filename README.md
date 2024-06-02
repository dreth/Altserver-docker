# Altserver-docker

A dockerized version of [AltServer-Linux](https://github.com/NyaMisty/AltServer-Linux) for self-hosted environments.

## Run the server

### docker-compose

To start up the application, just get the binaries (AltServer, netmuxd and anisette-server binaries) and run the docker-compose stack:

```shell
docker-compose up -d
```

### Using `docker run`

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
  altserver-docker && \
docker logs -f altserver
```

## Logs

Logs will be stored in the directory where the container is ran inside `./logs`

## Provision libraries

Provision automatically pulls the libraries it requires (libCoreADI.so and libstoreservicescore.so) from the apple music android apk, but this requires a 60+MB download it does automatically, so I decided to include these in the root of the repo already and have the `docker-entrypoint.sh` decompress them where Provision normally would. This is optional and can be removed/commented from the `docker-entrypoint.sh` if you prefer to have Provision download and pull them from the apk.

## Credits

I authored this repo but I did NOT author the projects it depends on. In particular:

- [AltServer-Linux](https://github.com/NyaMisty/AltServer-Linux)
- [netmuxd](https://https://github.com/jkcoxson/netmuxd/)
- [Provision](https://github.com/Dadoum/Provision/)
- [Altstore](https://altstore.io)

And some other projects which inspired me to create this repo:

- [altserverd](https://github.com/hkfuertes/altserverd) which I took inspiration and some code from.
- [AltServer-Linux-PyScript](https://github.com/powenn/AltServer-Linux-PyScript/issues) which I audited and took inspiration from.

## Contributing

Feel free to open an issue or a PR if you have any suggestions or improvements to this repo. I'm always open to feedback and contributions!
