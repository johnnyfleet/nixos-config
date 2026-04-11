## Voice dictation daemon using RealtimeSTT with hotkey toggle.
## Requires ydotool.nix to be enabled for text injection.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.voice-dictate;

  pythonEnv = pkgs.python312.withPackages (ps: with ps; [
    pip
  ]);

  daemonSrc = ../../../scripts/voice_daemon.py;

  triggerScript = pkgs.writeShellScriptBin "voice-dictate-trigger" ''
    PIPE_PATH="/tmp/voice-dictate.pipe"
    STATE_PATH="/tmp/voice-dictate.state"

    if [[ ! -p "$PIPE_PATH" ]]; then
        ${pkgs.libnotify}/bin/notify-send -u critical -a "Voice Dictate" "Voice Dictate" "Daemon not running!"
        exit 1
    fi

    state="idle"
    if [[ -f "$STATE_PATH" ]]; then
        state=$(cat "$STATE_PATH")
    fi

    if [[ "$state" == "listening" ]]; then
        echo "stop" > "$PIPE_PATH"
    else
        echo "start" > "$PIPE_PATH"
    fi
  '';

  venvDir = "/home/${cfg.user}/.local/venvs/voice";
in {
  options.modules.voice-dictate = {
    enable = mkEnableOption "Voice Dictate — hotkey-triggered voice dictation daemon";

    user = mkOption {
      type = types.str;
      default = "john";
      description = "User to run the voice dictation service as";
    };

    postSpeechSilence = mkOption {
      type = types.float;
      default = 1.2;
      description = "Seconds of silence before committing final transcription";
    };

    finalModel = mkOption {
      type = types.str;
      default = "base.en";
      description = "Whisper model for final transcription (base.en, tiny.en, small.en)";
    };

    realtimeModel = mkOption {
      type = types.str;
      default = "tiny.en";
      description = "Whisper model for live preview transcription";
    };
  };

  config = mkIf cfg.enable {
    # Ensure ydotool is available for text injection
    programs.ydotool = {
      enable = true;
      group = "users";
    };

    # Put trigger script on system PATH
    environment.systemPackages = [
      triggerScript
    ];

    # Systemd user service for the daemon
    systemd.user.services.voice-dictate = {
      description = "Voice Dictate — RealtimeSTT daemon";
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session.target"];
      partOf = ["graphical-session.target"];

      path = [
        pkgs.wl-clipboard
        pkgs.ydotool
        pkgs.libnotify
        pkgs.sox
        pkgs.kdotool
      ];

      environment = {
        PYTHONUNBUFFERED = "1";
        YDOTOOL_SOCKET = "/run/ydotoold/socket";
        LD_LIBRARY_PATH = lib.makeLibraryPath [
          pkgs.portaudio
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
        ];
      };

      serviceConfig = {
        Type = "simple";
        ExecStartPre = "${pkgs.writeShellScript "voice-dictate-setup" ''
          if [ ! -d "${venvDir}" ]; then
            ${pythonEnv}/bin/python3 -m venv "${venvDir}"
          fi
          ${venvDir}/bin/pip install --quiet --upgrade pip
          ${venvDir}/bin/pip install --quiet RealtimeSTT requests
        ''}";
        ExecStart = "${venvDir}/bin/python ${daemonSrc}";
        Restart = "on-failure";
        RestartSec = 10;
        RestartSteps = 5;
        RestartMaxDelaySec = 60;
        TimeoutStartSec = 120;
        StartLimitIntervalSec = 300;
        StartLimitBurst = 3;
      };
    };
  };
}
