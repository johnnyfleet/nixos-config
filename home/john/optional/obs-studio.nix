{ config, pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-advanced-masks
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
  };
}