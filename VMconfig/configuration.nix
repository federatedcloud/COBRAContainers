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
  na423PubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCdlUjrUC4EsIFNvq2DfQMLB5JZWFfveZLk/GaS+gnHOPNgQf6pNmrFSOqAbeGdl7W6R3YxO6KolGDTeBokFNLwU5VL+MPyuGJqW5UUSvjFhAhptlVI+DGJ1Fq1OgO0OsEL0F8TvFplbLr5zsW3cUYA9eJMg2nnAGcKdHOYnylcQ/z5YyHMwNt1acNSr5kLoKDlxgqPsCLZv6ELpPIIzqyunGTI05KhQzHeJFphOf7ZH2UB0f+wtW0wCX+2ITByAqKBaWgHvIAoczn6JWAwi2OjmxUECgFmbUZIUYmYEzfOeW25c8Iv+aTIKASdLvPGiOOSjXWr4L6wM3uiCbLptjLXOS48ODkY8ukRi/74c4AuulZJGrPxK631up+Uar67RvOm5Mf8HeXtdljY5iYmpud8ygm8uD/PLTuA4SI7vpYKaXWYvfFs6S/m7FUdcCV8d3o1EHS4rf4W/OJ63+QQJmNdD7wb5ppLr3AM0FARYWAMP5JuLwf+70AQ/usWnNzIt/wV1ctWI4M3OkvSPDDiZs/w23SSJ2OgT77X4lbe31aFwR1DgLS3+0pw5MeGenXZom7LKQlcOx/oDutRKxxG/PwrKfQxtg9u2kiCCvxFwZCBPXtIhZCtnbjoX1/0SYAGbbF6+Uh4WhnkhRl5PsYiMP+G5ZxQc3BJa1pd0TO1gbPdVw== na423@cornell.edu";
  jz675PubRSA = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSOhKbQcOZ0PgjVmGOaCFyDOzWRqLR82H9uLMOQG170wteVtcpYBctvG14TV8gFvHWPtRESZreLDx4yY79OU9BmW4wq6sGSDeHwRhj1GpWuUYQuc1adxjQWwGEjbLq6MHsnhBm/APc5BiRjpL8KO4JfquIc7M1Zrcgp2KD96axYOS821ThBbW9tOzhD193jJOpwhbWqV7ak0IY+DYP6gIXvmxoSqVNiCvKl1WUG/UuQIxYUjvw7sarC/6la6DiMZPk7pmbgWib40x3e4oyQK9r4MM/YJyxvtII11J8IwA0+UXJ3iiG7nJ0cQwhm7QX96M97WkP5GWRHUIpUspgD6yxhr6YwI/4aFGjbr7BkE0v+LWl0logfHhdXUTY3kXr6phjmyBrImWgcaPObax7K1SgIc/ZjshFOZyIuiYXleNW/msNH0Ua6ExOTLhzX2uI0X8hS3B86YJefnLg+JJKI7jfCd+TSM2BSigjiwFI64cXZApyho8qP1W22gzhx5NdeB/U8lIrQdKMPifkP5TY4+XDx7uyg3gRoCedzl3vq4f1lR4658msO+W6MKxUkbKFeOZ7RRXxD281O6fgdttERIl0K51eekluTecqZSEROKEMOjCg0aJbs07CThSrjB6rYUs6PfEoHJLMPgfkbfvZ31aoNc9en/5YyYneR0gxFcnsUw== jz675@cornell.edu";
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
    firefox
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
    openssh.authorizedKeys.keys = [beb82PubRSA jz675PubRSA];
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
    openssh.authorizedKeys.keys = [beb82PubRSA jz675PubRSA];
    hashedPassword = "$6$QAdG8xQTXgwnoM$gF.a.HmJYBO6gWDmgmPc3roNO2M7BluI6ZbYYTmEioSGqb0Rp1k.krbVVXoKdogr1QffbLgsA9J1Na7vC3MbE1";
  };
  users.users.na423 = {
    isNormalUser = true;
    extraGroups = [ ];
    home = "/home/na423";
    description = "Nana Ankrah";
    openssh.authorizedKeys.keys = [na423PubRSA];
    hashedPassword = "$6$DnyUr/mVOiC$C9OZzlHo82Rp4TBTvhQo..EiQpwbwmke8Sq9l9v//E/FZwAa.7lRFSnSnZ0TkiCLvXN23YwL6UpziteZ3SB.V/";
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
      ln -sfn /run/current-system/sw/bin/ps /bin/ps
      ln -sfn /run/current-system/sw/bin/pwd /bin/pwd
      ln -sfn /run/current-system/sw/bin/python /bin/python
      ln -sfn /run/current-system/sw/bin/rm /bin/rm
      
      mkdir -p /sbin
    '';
  };
  
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";

}
