## Applies TLP and thermald to manage laptop power settings.

{ pkgs, ... }:
{ 
  services.thermald.enable = true;

  services.tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

          CPU_MIN_PERF_ON_AC = 0;
          CPU_MAX_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_BAT = 0;
          CPU_MAX_PERF_ON_BAT = 20;

        #Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 50; # 50 and below it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 90; # 90 and above it stops charging

        };
  };
  
  # Disable power-profiles-daemon as it conflicts with TLP
  services.power-profiles-daemon.enable = false;
}