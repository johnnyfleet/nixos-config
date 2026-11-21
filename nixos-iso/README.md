# ISO Build

This folder contains a flake and config to correctly setup a live iso with my custom config, to make nixos-anywhere or provisioning easier to run. 

cd into this folder and run

``` bash
nix build .#iso
```

Remember this is anchored to a flake lock file so when doing a new one look to update first

``` bash
nix flake update
```

## Testing the ISO in a VM

After building, boot the ISO in QEMU (BIOS mode, simplest). The graphical Plasma ISO needs at least 4GB of RAM.

``` bash
qemu-system-x86_64 \
  -enable-kvm -cpu host -smp 4 -m 4096 \
  -vga virtio -display gtk \
  -cdrom result/iso/*.iso \
  -nic user,model=virtio-net-pci,hostfwd=tcp::2222-:22
```

The `hostfwd` forwards host port 2222 to the VM's SSH, so (if sshd is enabled) you can test the nixos-anywhere workflow with `ssh-keygen -R "[localhost]:2222" && ssh -p 2222 nixos@localhost`.

### Optional extras

**UEFI boot** (what real laptops use) - add:

``` bash
-bios $(nix build --no-link --print-out-paths nixpkgs#OVMF.fd)/FV/OVMF.fd
```

**YubiKey passthrough** - plug it in and add the following (check the product ID with `lsusb | grep -i yubi`; `0x0407` is the common OTP+FIDO+CCID one). You may need `sudo` or a udev rule for raw USB access, and the host loses the key while the VM has it.

``` bash
-usb -device qemu-xhci -device usb-host,vendorid=0x1050,productid=0x0407
```

**Install target disk** - create a scratch disk and attach it to rehearse an install:

``` bash
qemu-img create -f qcow2 /tmp/test-disk.qcow2 40G
# then add:
-drive file=/tmp/test-disk.qcow2,if=virtio
```

For rehearsing a full john-laptop install with secrets, see the `john-laptop-test` config in [`docs/sops.md`](../docs/sops.md).
