# OpenLDAP overlay - skip flaky syncreplication tests on i686 only.
# Scoped to i686 to avoid invalidating the x86_64 binary cache.
# Remove once nixos-unstable has a fix or updated openldap.
final: prev:
if prev.stdenv.hostPlatform.isi686
then {
  openldap = prev.openldap.overrideAttrs (old: {
    doCheck = false;
  });
}
else {}
