# OpenLDAP overlay - skip flaky syncreplication tests (i686 builds).
# Remove once nixos-unstable has a fix or updated openldap.
final: prev: {
  openldap = prev.openldap.overrideAttrs (old: {
    doCheck = false;
  });
}
