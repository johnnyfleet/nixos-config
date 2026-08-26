## Applies TLP to manage laptop power settings.
##
## thermald is deliberately NOT enabled here. On ThinkPads it detects
## /sys/devices/platform/thinkpad_acpi/dytc_lapmode and exits immediately with
## "Thermald can't run on this platform" — Lenovo's DYTC firmware already does
## adaptive thermal management, and two controllers driving the same RAPL and
## cooling-device nodes fight each other. Because it exits 0, systemd reports
## no failure, so an enabled-but-dead unit is invisible. Verified on
## john-laptop (X1 Carbon Gen 9): DYTC regulates correctly under sustained
## all-core load. If you ever do need it, services.thermald.ignoreCpuidCheck
## forces it past the check — but expect it to conflict with DYTC.
{pkgs, ...}: {
  # services.thermald.enable = true;  # see header — dead on this platform

  services.tlp = {
    enable = true;
    settings = {
      # Governors (intel_pstate): 'powersave' + HWP/EPP do the real tuning.
      # 'powersave' is NOT slow here — with HWP the governor only picks the
      # algorithm and EPP (below) sets the aggressiveness.
      #
      # MEASURED 2026-08-19 (john-laptop, X1C9): switching AC from
      # 'performance' to 'powersave' did NOT reduce idle temps — package idled
      # 60-62C before and 58-64C after. With EPP still 'performance', cores
      # keep boosting to 3-4 GHz on trivial background work, so unpinning the
      # P-states changes little. Kept because it is the correct setting for
      # intel_pstate+HWP, not because it bought thermal headroom. The idle
      # temperature lever on this machine is PLATFORM_PROFILE_ON_AC (DYTC).
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # HWP / EPP
      CPU_HWP_ON_AC = "performance";
      CPU_HWP_ON_BAT = "balance_power";
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 1; # allow brief firmware-managed boost for snappy interactions

      # Turbo/boost
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0; # sustained turbo off; HWP dynamic boost handles short bursts

      # Sustained performance caps
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 55;

      # Platform profile (firmware dependent; harmless if unsupported)
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power"; # was balanced; saves more power

      # --- AC: keep everything wide open ---
      RUNTIME_PM_ON_AC = "on"; # no runtime PM on AC
      PCIE_ASPM_ON_AC = "default";
      WIFI_PWR_ON_AC = 1; # 1 = off (no wifi power saving)
      SATA_LINKPWR_ON_AC = "max_performance";

      # --- Battery: aggressively save power ---
      RUNTIME_PM_ON_BAT = "auto";
      PCIE_ASPM_ON_BAT = "powersupersave";
      WIFI_PWR_ON_BAT = 5; # max wifi power saving
      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
      USB_AUTOSUSPEND = 1;

      # I/O scheduler: mq-deadline is responsive for NVMe
      DISK_IOSCHED = "mq-deadline";

      # Battery charge thresholds (preserve battery longevity)
      START_CHARGE_THRESH_BAT0 = 50;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };

  services.power-profiles-daemon.enable = false;
}
