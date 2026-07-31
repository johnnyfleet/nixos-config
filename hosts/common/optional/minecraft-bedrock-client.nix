{
  config,
  lib,
  pkgs,
  ...
}: let
  # BedrockOnLinux is a pure-Python launcher (customtkinter GUI + native Xbox
  # Live login). At runtime it downloads the UMU launcher and the GDK-Proton
  # engine into ~/.local/share/bedrock-on-linux, so we only package the Python
  # app here and hand it the deps + host tools it shells out to.
  # Upstream: https://github.com/Wyze3306/BedrockOnLinux
  pythonEnv = pkgs.python3.withPackages (ps:
    with ps; [
      cryptography # signs the MSA / Xbox Live login tokens
      customtkinter # GUI toolkit
      darkdetect # pulled in by customtkinter
      packaging # pulled in by customtkinter
      xlib # python-xlib: primary-monitor lookup under X11
      certifi # CA bundle for the engine/umu downloads
      tkinter # Tk backend for customtkinter
    ]);

  bedrock-on-linux = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "bedrock-on-linux";
    version = "2.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "Wyze3306";
      repo = "BedrockOnLinux";
      rev = "v${finalAttrs.version}";
      hash = "sha256-/ofPZbfsPh/mY7b3tp5hOtuO3dnpVJJWuKvgzWobCpk=";
    };

    nativeBuildInputs = [pkgs.makeWrapper];

    # No build system upstream; the app is a plain Python package plus a
    # launcher shim that adds its own directory to sys.path.
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/bedrock-on-linux
      cp -r bol $out/lib/bedrock-on-linux/
      cp bedrock-on-linux $out/lib/bedrock-on-linux/

      # The launcher boots its engine through umu-launcher, which downloads the
      # Steam Linux Runtime; its helper binaries (pressure-vessel-wrap etc.) are
      # ordinary FHS ELFs linked against /lib64/ld-linux, which does not exist on
      # NixOS. Running the whole process tree inside steam-run's FHS sandbox
      # provides that loader so the Wine prefix can actually initialise.
      #
      # BOL_NO_PIP=1 stops the launcher's best-effort pip bootstrap (it would
      # fail on NixOS anyway) — every dependency is provided via pythonEnv.
      makeWrapper ${pkgs.steam-run}/bin/steam-run $out/bin/bedrock-on-linux \
        --add-flags "${pythonEnv}/bin/python3" \
        --add-flags "$out/lib/bedrock-on-linux/bedrock-on-linux" \
        --set BOL_NO_PIP 1 \
        --prefix PATH : ${lib.makeBinPath [pkgs.curl pkgs.wget pkgs.gnutar pkgs.zstd]}

      install -Dm644 data/bedrock-on-linux.desktop \
        $out/share/applications/bedrock-on-linux.desktop
      install -Dm644 data/icon.png \
        $out/share/icons/hicolor/256x256/apps/bedrock-on-linux.png

      runHook postInstall
    '';

    meta = {
      description = "Run Minecraft Bedrock (Windows GDK) on Linux, multiplayer included";
      homepage = "https://github.com/Wyze3306/BedrockOnLinux";
      license = lib.licenses.mit;
      mainProgram = "bedrock-on-linux";
      platforms = ["x86_64-linux"];
    };
  });
in {
  # Install the BedrockOnLinux client and open the firewall for LAN multiplayer.
  environment.systemPackages = [bedrock-on-linux];

  # Bedrock game + LAN discovery: 19132 (IPv4) and 19133 (IPv6). Both must be
  # open inbound for the "see LAN games" broadcast/pong replies to arrive.
  networking.firewall.allowedUDPPorts = [19132 19133];
}
