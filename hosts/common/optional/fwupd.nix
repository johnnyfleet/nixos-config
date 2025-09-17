## Installs fwupd and fwupdmgr to manage firmware updates.

{ pkgs, ... }:
{ 
  services.fwupd.enable = true;      # starts the fwupd system daemon
  services.bolt.enable = true;       # good idea for Thunderbolt management
  # Optional: if you’re using Secure Boot with shim, fwupd handles it fine
}