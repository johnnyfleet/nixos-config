## TEMPORARY — heatsink fan bearing is failing (replacement part on order, 2026-08-14).
##
## Goal: keep the fan below its spin-up threshold as much as possible, on BOTH
## AC and battery, by capping how much heat the SoC is allowed to produce.
## This deliberately does NOT touch fan control — slowing a fan on a machine
## that is already struggling to shed heat is how you cook a CPU. Instead we
## cap the heat at the source so the fan has little reason to ramp.
##
## Three levers, strongest first:
##   1. RAPL package power limits (PL1/PL2) — the single biggest influence on
##      fan behaviour. Stock is 64 W/64 W here; we cut to a laptop-idle-ish
##      budget so sustained load simply cannot generate ramp-worthy heat.
##   2. TLP overrides — turbo off, EPP "power", low-power platform profile and
##      a hard max_perf_pct cap, applied on AC as well as battery.
##   3. Intel iGPU clock cap — the GPU shares the same package power budget and
##      is a common cause of fan spin-up during video playback / compositing.
##
## IMPORT AFTER ../common/optional/tlp.nix — it lib.mkForce-overrides that
## module's performance-oriented values.
##
## TO REVERT: delete the import line in hosts/john-laptop/default.nix, delete
## this file, and rebuild. Nothing here leaves state behind — the RAPL and GPU
## limits are re-read from firmware on the next boot.
{
  lib,
  pkgs,
  ...
}: let
  # Sustained package power budget (PL1) and short-burst ceiling (PL2), watts.
  # Stock on this machine is 64/64. 10/12 keeps package temps low enough that
  # the fan mostly stays at its lowest step. Raise if the machine feels too
  # sluggish, lower if the fan is still audible.
  pl1Watts = 10;
  pl2Watts = 12;

  # Intel Xe iGPU clock cap in MHz (hardware max on this part is 1300).
  gpuMaxMhz = 600;

  # intel_pstate max_perf_pct, i.e. percentage of the maximum p-state.
  # ~30% lands around 1.4 GHz, which this CPU handles fanlessly.
  cpuMaxPerfPct = 30;
in {
  ##################### 1. PACKAGE POWER + GPU CLOCK CAP #####################
  # TLP has no RAPL support, so this is a small oneshot that writes the
  # powercap and drm sysfs nodes directly. Firmware (and the DPTF/dytc path on
  # ThinkPads) will happily reset these on AC/battery transitions and on
  # resume, hence the timer and udev hook below.

  systemd.services.thermal-limp-mode = {
    description = "Cap CPU package power and iGPU clock (failing fan workaround)";
    wantedBy = [
      "multi-user.target"
      "post-resume.target"
    ];
    after = ["post-resume.target"];

    serviceConfig = {
      Type = "oneshot";
      # Deliberately NOT RemainAfterExit — the timer below needs to be able to
      # re-run this unit to undo firmware resets.
      RemainAfterExit = false;
    };

    script = ''
      set -u

      # Write $2 to sysfs node $1, warning rather than failing if the firmware
      # has locked the node (some BIOS revisions lock RAPL after POST).
      apply() {
        [ -w "$1" ] || return 0
        if ! echo "$2" > "$1" 2>/dev/null; then
          echo "thermal-limp-mode: could not write $2 to $1 (locked by firmware?)" >&2
        fi
      }

      rapl=/sys/class/powercap/intel-rapl:0
      apply "$rapl/constraint_0_power_limit_uw" ${toString (pl1Watts * 1000000)}
      apply "$rapl/constraint_1_power_limit_uw" ${toString (pl2Watts * 1000000)}

      for node in /sys/class/drm/card*/gt_max_freq_mhz /sys/class/drm/card*/gt_boost_freq_mhz; do
        apply "$node" ${toString gpuMaxMhz}
      done
    '';
  };

  # Firmware resets the power limits on power-source changes and after resume;
  # re-assert them regularly so a reset is never in effect for long.
  systemd.timers.thermal-limp-mode = {
    description = "Periodically re-assert the failing-fan power caps";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "2min";
      AccuracySec = "10s";
      Unit = "thermal-limp-mode.service";
    };
  };

  # Re-assert immediately on AC plug/unplug rather than waiting for the timer.
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ACTION=="change", RUN+="${pkgs.systemd}/bin/systemctl start --no-block thermal-limp-mode.service"
  '';

  ########################## 2. TLP OVERRIDES ################################
  # Same aggressive settings on AC and battery — the fan does not care which
  # one we are on. mkForce because ../optional/tlp.nix sets these for
  # performance.

  services.tlp.settings = {
    # No turbo at all, on either power source. This is the setting that stops
    # short bursts (compiles, page loads) from triggering a fan ramp.
    CPU_BOOST_ON_AC = lib.mkForce 0;
    CPU_BOOST_ON_BAT = lib.mkForce 0;
    CPU_HWP_DYN_BOOST_ON_AC = lib.mkForce 0;
    CPU_HWP_DYN_BOOST_ON_BAT = lib.mkForce 0;

    # powersave governor + "power" EPP on AC too.
    # NOTE: TLP >= 1.4 renamed CPU_HWP_ON_* to CPU_ENERGY_PERF_POLICY_ON_*.
    # tlp.nix still uses the old names, which 1.9.1 ignores — these are the
    # keys that actually take effect.
    CPU_SCALING_GOVERNOR_ON_AC = lib.mkForce "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = lib.mkForce "power";
    CPU_ENERGY_PERF_POLICY_ON_BAT = lib.mkForce "power";

    # Hard ceiling on sustained clocks.
    CPU_MAX_PERF_ON_AC = lib.mkForce cpuMaxPerfPct;
    CPU_MAX_PERF_ON_BAT = lib.mkForce cpuMaxPerfPct;

    # Firmware thermal/power profile: lowest on both sources.
    PLATFORM_PROFILE_ON_AC = lib.mkForce "low-power";
    PLATFORM_PROFILE_ON_BAT = lib.mkForce "low-power";
  };

  ############################ 3. THERMAL DAEMON #############################
  # thermald is already enabled by tlp.nix; make sure it is definitely on, as
  # it is the thing that reacts if the degraded heatsink does let temps climb.
  services.thermald.enable = true;
}
