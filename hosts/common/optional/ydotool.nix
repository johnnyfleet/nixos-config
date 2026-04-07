## Enable ydotool used in my realtime whispr feature.
{pkgs, ...}: {
  programs.ydotool = {
    enable = true;
    group = "users";
  };
}