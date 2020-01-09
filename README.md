
# Builder

This is used to build custom images for the ARM archtecture, on systems with
x86_64 architecture, i.e. for building customized images for the Raspberry Pi.

Note: This has currently been tested only on Archlinux

## Building Images

- Install necessary dependencies

```sh
make setup
```

- Make necessary changes to config.sh

- Build Image

```sh
make build
```

## TODO

- Add icon to README
- Add Vagrant support to compile img on all architectures.

