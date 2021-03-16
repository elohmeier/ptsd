{ config, lib, pkgs, ... }:
{
  ptsd.secrets.files.gitlab-runner-registration = {
    owner = "gitlab-runner";
  };

  # secret cannot be read by dynamic user, that's why we need a concrete user, waiting for systemd Credentials handling feature
  users.users.gitlab-runner = {
    description = "gitlab-runner user";
    isSystemUser = true;
    group = "gitlab-runner";
  };
  users.groups.gitlab-runner = { };
  users.groups.keys.members = [ "gitlab-runner" ];

  systemd.services.gitlab-runner.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "gitlab-runner";
    Group = "gitlab-runner";
  };

  services.gitlab-runner = {
    enable = true;
    extraPackages = with pkgs; [
      docker-machine
      docker-machine-driver-hetzner
    ];
    services = {
      hcloud = {
        executor = "docker+machine";
        dockerImage = "docker:stable";
        registrationConfigFile = config.ptsd.secrets.files.gitlab-runner-registration.path;

        # run `nix-shell -p gitlab-runner --run "gitlab-runner register --help"` to view available options
        registrationFlags = [
          "--machine-machine-driver hetzner"
          "--machine-machine-name gitlab-ci-%s"
          "--machine-machine-options hetzner-api-token=$HETZNER_API_TOKEN"
          "--machine-machine-options hetzner-image=ubuntu-20.04"
          "--machine-machine-options hetzner-server-type=cx31"
          "--machine-idle-time 300"

          # workaround https://github.com/docker/machine/issues/4858
          "--machine-machine-options engine-install-url=https://releases.rancher.com/install-docker/19.03.9.sh"
        ];
        tagList = [ "docker-images" ];
      };
    };
  };
}
