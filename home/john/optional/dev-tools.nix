# Setup dev tools like direnv to make it easier for local development. 
{ pkgs, inputs, system, ... }:
{
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  home.packages = with pkgs; [
    gemini-cli
    warp-terminal
    windsurf  # AI IDE
    claude-code
    claude-monitor
    uv #Python package manager. 
  ];
}