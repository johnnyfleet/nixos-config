# This module includes additional packages that were originally installed on the laptop
# but I don't think are needed anymore. Will lie dormant but can be included to bring all back

{ pkgs, ... }:
{

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    # BASE_PACKAGES:
    ansible # Ansible, duh
    ansible-lint # Linting to check playbooks
    apostrophe # Markdown editor - nice and clean.
    arduino # Arduino IDE
    asciidoctor # Convert asciidocs to different formats
    chezmoi
    chromium
    #crossover-extras # Install crossover and dependencies that are required to install windows apps.
    discord
    filezilla # FTP client
    freerdp
    #gestures # To get multi finger gestures on touchpad working
    gimp # Image editor.
    gparted # Disk Partition Manager
    guake # drop-down style terminal
    makemkv # MakeMKV - DVD/Blue-Ray to MKV formatter.
    mqtt-explorer # Allows you to view MQTT messages
    mutt # Email CLI client for reading root mail.
    packer # create VM images
    pandoc # Convert markdown and asciidoc
    qmmp # winamp like music player
    retext # Simple markdown editor
    rpcbind # Network and RPC program
    scribus # PDF editor (for cd covers)
    terminator # Improved shell
    unzip

  ];
}
