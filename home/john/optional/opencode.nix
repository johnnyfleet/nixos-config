# opencode (https://opencode.ai) - terminal AI coding agent, set up to use OpenRouter so
# models can be switched freely (`/models` in the TUI, or `opencode -m openrouter/<slug>`).
#
# The OpenRouter API key is a sops secret, decrypted at boot on the NixOS side and owned by john:
#
#   # hosts/<host>/default.nix
#   sops.secrets.openrouter-api-key = {
#     owner = "john";
#     sopsFile = ../../secrets/<host>.yaml;
#   };
#
# opencode reads it at runtime via its `{file:...}` substitution, so the key never enters
# the Nix store. Hosts that don't declare the secret still get opencode - use `/connect`.
{
  lib,
  osConfig,
  ...
}: let
  secret = osConfig.sops.secrets."openrouter-api-key" or null;
in {
  programs.opencode = {
    enable = true;

    # Written to ~/.config/opencode/opencode.json (read-only, managed by home-manager).
    settings =
      {
        autoupdate = false; # Nix manages the version.
        share = "manual";

        # Default model; change per session with `/models`. List options with
        # `opencode models openrouter`.
        model = "openrouter/anthropic/claude-sonnet-4.5";
        small_model = "openrouter/anthropic/claude-haiku-4.5"; # titles/summaries
      }
      // lib.optionalAttrs (secret != null) {
        provider.openrouter.options.apiKey = "{file:${secret.path}}";
      };
  };
}
