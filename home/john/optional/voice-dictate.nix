## Voice Dictate — KDE hotkey for toggling voice dictation.
## Pairs with the NixOS module at hosts/common/optional/voice-dictate.nix
## which runs the daemon as a systemd user service.
{pkgs, ...}: {
  programs.plasma.hotkeys.commands."voice-dictate-toggle" = {
    name = "Toggle Voice Dictation";
    key = "Meta+F9";
    command = "voice-dictate-trigger";
  };
}
