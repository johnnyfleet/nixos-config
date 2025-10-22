# Enabling passwordless login on laptop using Yubikey

My main laptop has a fingerprint reader which makes it convenient to unlock and auth sudo quickly. However when working at home on a dual screen, I need to keep the laptop lid open to access the reader button. 

Enabling FIDO2 `pam_u2f` authentication with my Yubikeys adds that convenience but via an external device on USB which is much preferred. 

## Steps to setup

### Include module

Include the following module into the host config:

`hosts/common/optional/Yubikey-u2f-authentication.nix`

### Setup keys

The keys are sensitive information, so generated on each machine that needs it.

Follow these instructions: https://wiki.nixos.org/wiki/Yubikey

``` bash
mkdir -p ~/.config/Yubico
chmod 700 ~/.config/Yubico

# Key 1
, pamu2fcfg > ~/.config/Yubico/u2f_keys

# Repeat for other keys to append to file, these should be all on one line.
, pamu2fcfg -n >> ~/.config/Yubico/u2f_keys

# Secure File
ca

# Check file
cat ~/.config/Yubico/u2f_keys
```

**WARNING:**: This file doesn't accept comments, so you may want to make a note of the order of keys loaded, in case you need to remove later if lost. 
