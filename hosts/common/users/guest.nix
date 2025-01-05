{
  config,
  pkgs,
  secrets,
  ...
}:
{
  # A default user able to use sudo
  users.users.guest = {
    isNormalUser = true;
    home = "/home/guest";
    extraGroups = [ "wheel" ];
    initialPassword = "guest";
  };
}
