## Applies TLP and thermald to manage laptop power settings.
{pkgs, ...}: {
  services.thermald.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      # Governors (intel_pstate): 'powersave' + HWP/EPP do the real tuning
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
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
