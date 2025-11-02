## Applies TLP and thermald to manage laptop power settings.

{ pkgs, ... }:
{
  services.thermald.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      # Governors (intel_pstate): 'powersave' + HWP/EPP do the real tuning
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # HWP / EPP
      CPU_HWP_ON_AC = "performance";
      CPU_HWP_ON_BAT = "balance_power";      # was balance_performance
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;          # save a lot of watts on Zoom

      # Turbo/boost
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;                   # big saver; flip to 1 if you miss snap

      # Sustained performance caps
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 55;               # was 65; try 50–60

      # Platform profile (firmware dependent; harmless if unsupported)
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "balanced";

      # Nice-to-haves that often help battery during calls/browsing
      RUNTIME_PM_ON_BAT = "auto";
      PCIE_ASPM_ON_BAT = "powersupersave";
      WIFI_PWR_ON_BAT = 5;
      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
      USB_AUTOSUSPEND = 1;

      START_CHARGE_THRESH_BAT0 = 50;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };

  services.power-profiles-daemon.enable = false;
}