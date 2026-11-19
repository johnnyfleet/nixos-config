# Single source of truth for who can decrypt what. See docs/sops.md.
#
# After editing this file:
#   nix run .#sops-config                 # regenerates .sops.yaml
#   sops updatekeys -y secrets/*.yaml     # re-encrypts to the new recipient set (YubiKey touch)
{
  # Can decrypt EVERY secrets file. Used by a human to edit/rekey.
  admins = {
    # Break-glass: private key lives only in 1Password (see `sops-breakglass`).
    breakglass = "age1xa3e76y4g3526ge8gxhsf4g2ge7g4kn6ct3yp0nwmassnu4h65tsfc9c99";

    # YubiKeys (age-plugin-yubikey, PIV slot 1, PIN once/touch cached).
    # Identity stubs for these are in ./yubikey-identities.txt.
    yk-19256040 = "age1yubikey1qdt7y47k4ry4k0ej2zulupzx287tep48qukrjnccyp805ms707hk2pagaac"; # 5C NFC
    yk-23457070 = "age1yubikey1qwg0evp76hwum3kqnle5lqz9ag8gdpzatgxl4pqq5ml2pau2tq6s2s5dgvr"; # 5C NFC
    yk-17669500 = "age1yubikey1qf0tz62wlrs9jt0k2shgr6ghr32yu5mj8mzhgcpqwvvu2svkt9uxqn956nj"; # 5C Nano (lives in john-laptop)
  };

  # Machines, keyed by networking.hostName. Value is the age form of the SSH host key:
  #   ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
  # A host can decrypt secrets/common.yaml and secrets/<host>.yaml.
  # null = host has a secrets file but no key yet (admins only until it is installed).
  hosts = {
    john-laptop = "age1esff9mgd0nwqgcfx3yhqsyhkufc6xrske6z2v4s9mwxs956083zq0t0pde";
    john-sony-laptop = "age1rvdsvvrud5nw94d5fu78yy8zhtr6x5qg0gsukfj36a2cglywfusslw647p";
    minecraft-server = null;
    john-laptop-test = "age1vslyu40979e67dhn7dc6qatrnjl4qrrk82pfajtlz9wv45mcraeqshrncp";
    # sops-new-host inserts new hosts above this line
  };
}
