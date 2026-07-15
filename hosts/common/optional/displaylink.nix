{...}: {
  # DisplayLink docking station support.
  #
  # The ALOGIC DUPRDX2 / DX2 "Universal" dock (USB ID 17e9:6000) is a
  # DisplayLink dock: the external monitors are NOT driven by the laptop's
  # Intel DisplayPort outputs, they are driven by a DisplayLink chip that
  # streams a compressed framebuffer over USB. That needs the proprietary
  # evdi kernel module + DisplayLinkManager daemon. Without them the USB
  # peripherals on the dock work (plain USB hub) but the screens stay dark.
  #
  # Enabling "displaylink" in videoDrivers pulls in the evdi module, udev
  # rules and the DisplayLinkManager service via
  # nixos/modules/hardware/video/displaylink.nix.
  #
  # NOTE: the DisplayLink driver blob is redistribution-restricted, so it
  # cannot be fetched automatically. It must be downloaded once and added to
  # the Nix store. A rebuild fails with a `requireFile` error until it is
  # present in the store. If a future nixpkgs update bumps the version, the
  # expected file name / hash below change too - the build error prints the
  # new values.
  #
  #   Currently pinned in nixpkgs : 6.2.0-30
  #   Expected file name          : displaylink-620.zip
  #   Expected hash               : sha256-JQO7eEz4pdoPkhcn9tIuy5R4KyfsCniuw6eXw/rLaYE=
  #
  # Steps to (re)provide the driver:
  #
  #   1. Download the matching release (accept the EULA in a browser) from:
  #        https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu
  #      You get e.g. "DisplayLink USB Graphics Software for Ubuntu6.2-EXE.zip".
  #
  #   2. Verify it is the expected version (hash is over file contents, so the
  #      name does not matter yet):
  #        nix hash file ~/Downloads/"DisplayLink USB Graphics Software for Ubuntu6.2-EXE.zip"
  #      It must print the "Expected hash" above.
  #
  #   3. Rename to the expected file name and add it to the Nix store:
  #        mv ~/Downloads/"DisplayLink USB Graphics Software for Ubuntu6.2-EXE.zip" \
  #           ~/Downloads/displaylink-620.zip
  #        nix-store --add-fixed sha256 ~/Downloads/displaylink-620.zip
  #
  #   4. Rebuild as normal:
  #        sudo nixos-rebuild switch --flake ~/.config/nixos-config#john-laptop
  #
  # We run KDE Plasma 6 on Wayland: the xorg.conf / xrandr bits in the
  # upstream module are no-ops there, but evdi + the daemon still work and
  # KWin auto-detects the DisplayLink outputs. Configure them afterwards in
  # System Settings > Display & Monitor.
  services.xserver.videoDrivers = ["displaylink" "modesetting"];

  # The upstream module defines the dlm service but does not give it a
  # wantedBy, so it never starts on boot. Start it at boot so the monitors
  # come up without manual intervention.
  systemd.services.dlm.wantedBy = ["multi-user.target"];
}
