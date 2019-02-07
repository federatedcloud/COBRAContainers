# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  cloudInitConfig =
    ''
       system_info:
         distro: nixos
         default_user:
           name: nixos
       users:
         - default
       disable_root: true
       preserve_hostname: false
       cloud_init_modules:
         - migrator
         - seed_random
         - bootcmd
         - write-files
         - growpart
         - resizefs
         - update_etc_hosts
         - ca-certs
         - rsyslog
         - users-groups
	 - ssh
       cloud_config_modules:
         - disk_setup
         - mounts
         - ssh-import-id
         - set-passwords
         - timezone
         - disable-ec2-metadata
         - runcmd
         - ssh-import-id
       cloud_final_modules:
         - rightscale_userdata
         - scripts-vendor
         - scripts-per-once
         - scripts-per-boot
         - scripts-per-instance
         - scripts-user
         - ssh-authkey-fingerprints
         - keys-to-console
         - phone-home
         - final-message
         - power-state-change
    '';
  beb82PubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvfDUTxx/eLkFRFZahGAqb7UPI32qSxf+SIEzIsa0ZQ3fGyQpGXwmWUXaJUyK30VedOZ6pnj9McBJ5g3qZm/eTRVcVgOP6KqG/YnChg5Qg7O3fROjeVY77LuYs6MCKavF+nE+CTgQ7IbRYlAMkdaMM6DElQ0huQIf/ekmP9yWvd25fuHoCHMDSB3kfzOU6C+fr0qIuQQkj/oq++pRMYbVgZ6RESWV83ULmorLrn/otH+/DInrVIclA+RsF188VfaJQQOCFNO0eVlBKgl+zFqdTB4XVu3TOTq7mAsAfv08qE5msyv8fZaZLLoL935ktiuogQCy8vgYrhLPb9/mILNqqnWuoozjNDdu7kwZcOg5OzsVhxuhOx70MJHZeBwkXI2O6194ioTWIn4GeI1OBabeaLl5Wp+TfPIL87QSXM9vk1IvAg44Mdux+teuBmdZXtzi4TgtKIs1fX3l3jMmSTmxzU7Mm72Nm2Aa11SVlYprqolOz+rrOiDCelnhhOmG55EbYLlm9nC3dnqULRj9pfrRBvUpWtV+jEyI7nhqx8XFvKf6jSq68JeY0QN1xKaekiNnN0Bo3VoNAtj9DBYfOTlCfs67VxL5+Cvn87wsOfQrdCmeU2TLCAL1UzhNaRHvHsqt30+8NeMe/O/sgwSHHWFbZp0Aq+yb4RBNpEFMB4UjSxw== beb82@cornell.edu";
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda";

  networking.networkmanager.enable = false;
  networking.hostName = ""; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  #
  # Disable firewall in Cloud images by default; should be
  # handled by cloud manager config instead.
  #
  networking.firewall.enable = false;

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # General
    bash-completion nix-bash-completions
    ripgrep rsync wget 
    # Editors
    emacs vim nano
    # Desktop
    icewm
    # Development
    git git-lfs tmux
    # Cloud
    # cloud-init # TODO: not working currently
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    permitRootLogin = "without-password";
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

  # Enable RDP for remote desktop:
  services.xrdp = {
    enable = true;
    defaultWindowManager = "xfce4-session";
  };

  # Enable cloud-init
  # TODO: fix config file install: https://github.com/NixOS/nixpkgs/issues/50366
  services.cloud-init.enable = true;
  services.cloud-init.config = cloudInitConfig;

  # services.nfs.server.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  services.xserver.desktopManager = {
    default = "xfce";
    xterm.enable = false;
    xfce.enable = true;
  };
  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;

  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/nixos";
    description = "Default system user";
    openssh.authorizedKeys.keys = [beb82PubRSA];
  };
  users.users.bebarker = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/bebarker";
    description = "Brandon Elam Barker";
    openssh.authorizedKeys.keys = [beb82PubRSA];
    hashedPassword = "$6$QAdG8xQTXgwnoM$gF.a.HmJYBO6gWDmgmPc3roNO2M7BluI6ZbYYTmEioSGqb0Rp1k.krbVVXoKdogr1QffbLgsA9J1Na7vC3MbE1";
  };
  users.users.cobra = {
    isNormalUser = true;
    extraGroups = [ ];
    home = "/home/cobra";
    description = "Misc; shared user for COBRA";
    openssh.authorizedKeys.keys = [beb82PubRSA];
  };

  virtualisation.docker.enable = true;

  system.activationScripts = {
    text = ''
      ln -sfn /run/current-system/sw/bin/bash /bin/bash
      ln -sfn /run/current-system/sw/bin/cat /bin/cat      
      ln -sfn /run/current-system/sw/bin/chown /bin/chown
      ln -sfn /run/current-system/sw/bin/chmod /bin/chmod
      ln -sfn /run/current-system/sw/bin/dd /bin/dd
      ln -sfn /run/current-system/sw/bin/grep /bin/grep
      ln -sfn /run/current-system/sw/bin/mktemp /bin/mktemp
      ln -sfn /run/current-system/sw/bin/pwd /bin/pwd      
      ln -sfn /run/current-system/sw/bin/python /bin/python
      ln -sfn /run/current-system/sw/bin/rm /bin/rm
      
      mkdir -p /sbin
    '';
  };
  
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";

}
