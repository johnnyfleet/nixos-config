{
  config,
  pkgs,
  ...
}: {
  programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    /*
       package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );
    */

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      # GCC 16 makes discarded-qualifiers an error and the plugin builds with -Werror
      (obs-advanced-masks.overrideAttrs (old: {
        env =
          (old.env or {})
          // {
            NIX_CFLAGS_COMPILE = toString (old.env.NIX_CFLAGS_COMPILE or "") + " -Wno-error=discarded-qualifiers";
          };
      }))
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
  };
}
