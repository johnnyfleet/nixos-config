# OpenLDAP overlay - skip flaky syncreplication tests.
#
# test017-syncreplication-refresh uses fixed sleep windows and fails
# intermittently when openldap is built from source on loaded CI runners.
# Disabled on all platforms: this invalidates the x86_64 binary cache once,
# but CI pushes the rebuilt closure to Attic so the cost is paid a single time.
#
# Remove once nixos-unstable has a fix or updated openldap.
final: prev: {
  openldap = prev.openldap.overrideAttrs (old: {
    doCheck = false;
  });
}
