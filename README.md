asbestos.sh
===========

Simple scripts for managing Firecracker MicroVMs. Only for demonstration purpose (at HackUCI 2021) and is going to be refactored with Rust.

Install
-----

Firecracker is (obviously) required. Install the `firecracker` binary into somewhere listed in your `$PATH`.

```bash
git clone https://github.com/RedL0tus/asbestos.sh asbestos-sh
cd asbestos-sh
sudo make install
```

asbestos.sh will be installed to `/usr/local/bin`.

Usage
-----

First, you need to setup a working directory, and set the environment variable `$ASBESTOS_WORK_DIR` to it.

```bash
export ASBESTOS_WORK_DIR="/tmp/asbestos-sh"
mkdir -p "$ASBESTOS_WORK_DIR"
```

Then, you need to download a usable kernel image and a suitable root filesystem image, here we'll be using the one provided by Amazon:

```
$ asbestos.sh kernel download "https://s3.amazonaws.com/spec.ccfc.min/img/hello/kernel/hello-vmlinux.bin"
$ asbestos.sh rootfs download "https://s3.amazonaws.com/spec.ccfc.min/img/hello/fsfiles/hello-rootfs.ext4"
```

Create a new VM configuration with `asbestos.sh vm configure hello`, the word "hello" will be the name of your new VM.

You'll be asked to provide the number of virtual cores, amount of RAM and the kernel+rootfs pair to use.

```
$ asbestos.sh vm configure hello
>>> asbestos.sh: Found supported workspace at work
>>> asbestos.sh: Available kernel images: hello-vmlinux.bin
>>> asbestos.sh: Available rootfs images: hello-rootfs.ext4
>>> asbestos.sh: Creating virtual machine configuration for hello
Enter core count: 2
Enter size of RAM (in MB): 128
Enter kernel to use: hello-vmlinux.bin
Enter rootfs to use: hello-rootfs.ext4
>>> asbestos.sh: Got this config:
CORE_COUNT=2;
SIZE_RAM=128;
KERNEL_NAME=hello-vmlinux.bin;
ROOTFS_NAME=hello-rootfs.ext4;

Save? (y/N)y
>>> asbestos.sh: Configuration saved to /tmp/asbestos-sh/machines/hello.conf
```

Finally, start the VM and attach to its console:

```
$ asbestos.sh vm start hello
$ asbestos.sh vm attach hello
```

Caveats
-------

 -  The argument halding in these scripts are not robust.
  -  Due to time constraint, not all firecracker's features are supported.
 -  The VMs are currently unable to connect to the network, because doing that will require creating TUN/TAP devices, which needs root permission.
  -  Probably there will be support for user mode networking in the future, probably with things like `slirp4netns`.

Anyway, this will be refactored in the near future for more robustness and more features.
