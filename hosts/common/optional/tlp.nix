## Applies TLP and thermald to manage laptop power settings.

{ pkgs, ... }:
{ 
  services.thermald.enable = true;

  services.tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_ENERGY_PERF_POLICY_ON_BAT = "balanced";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

          # HWP + EPP (the real tuning knobs on Tiger Lake)
          CPU_HWP_ON_AC = "performance";
          CPU_HWP_ON_BAT = "balance_performance";   # key change from 'power'
          CPU_HWP_DYN_BOOST_ON_AC = 1;
          CPU_HWP_DYN_BOOST_ON_BAT = 1;

          # Allow short turbo bursts on battery
          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 1;

          CPU_MIN_PERF_ON_AC = 0;
          CPU_MAX_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_BAT = 0;
          CPU_MAX_PERF_ON_BAT = 65;

          #Optional helps save long term battery health
          START_CHARGE_THRESH_BAT0 = 50; # 50 and below it starts to charge
          STOP_CHARGE_THRESH_BAT0 = 90; # 90 and above it stops charging

        };
  };
  
  # Disable power-profiles-daemon as it conflicts with TLP
  services.power-profiles-daemon.enable = false;
}