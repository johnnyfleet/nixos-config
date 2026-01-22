{
  config,
  pkgs,
  ...
}: {
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Add my user to the docker group - so I can control it
  users.users.john.extraGroups = ["docker"];

  # Set Rootless mode
  /*
     virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  */

  # Add extra tools
  environment.systemPackages = with pkgs; [
    ctop # Top-like interface for containers.
    docker-compose # Compose
  ];
}
