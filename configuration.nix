{ config, pkgs, ... }:

{
  # Import hardware scan configuration
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone
  time.timeZone = "UTC";

  # Enable networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system
  services.xserver = {
    enable = true;
    # Enable the GNOME Desktop Environment
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account
  users.users.nixuser = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable sudo for the user
    initialPassword = "changeme";
  };

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    # Basic utilities
    wget
    git
    vim
    htop
    curl
    
    # Browser
    firefox
    
    # Development tools
    vscode
    gnumake
    gcc
    
    # System tools
    gnome.gnome-terminal
    gnome.nautilus
    
    # Additional useful applications
    vlc
    libreoffice
  ];

  # Enable system services
  services = {
    # Enable SSH server
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
      };
    };
    
    # Enable printing support
    printing.enable = true;
  };

  # This value determines the NixOS release with which your system is to be compatible
  system.stateVersion = "25.05"; # Did you read the comment?
}
