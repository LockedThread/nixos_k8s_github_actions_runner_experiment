{ config, pkgs, inputs, ... }:

{

  imports = [
    inputs.rke2.nixosModules.default
  ];

  # Import hardware scan configuration
  #imports =
  #  [ 
  #    ./hardware-configuration.nix
  #  ];

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable automatic filesystem resizing on first boot
  boot.growPartition = true;
  fileSystems."/".autoResize = true;

  # Set your time zone
  time.timeZone = "UTC";

  # Enable networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    # Disable the firewall
    firewall.enable = false;
  };

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

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
    
    lsof

    # Browser
    firefox
    
    # Development tools
    gnumake
    gcc
    
    # System tools
    gnome-terminal
    nautilus

    rke2_1_31
    cilium-cli
  ];

  # Add symlinks for RKE2 binaries
  environment.shellInit = ''
    export PATH=$PATH:/var/lib/rancher/rke2/bin
  '';

  # Create symlinks for RKE2 binaries
  environment.etc = {
    "profile.d/rke2-bin.sh" = {
      text = ''
        export PATH=$PATH:/var/lib/rancher/rke2/bin
      '';
      mode = "0644";
    };
  };

  # 1) Load the kernel bits RKE2 needs:
  boot.kernelModules = [ "overlay" "br_netfilter" "nft_expr_counter" ];
  boot.kernel.sysctl."net.bridge.bridge-nf-call-iptables"  = 1;
  boot.kernel.sysctl."net.bridge.bridge-nf-call-ip6tables" = 1;
  boot.kernel.sysctl."net.ipv4.ip_forward"             = 1;
  # 2) (Optional) Mask nm-cloud-setup so RKE2’s preflight check can’t enable it


  # RKE2 services configuration
  services = {
    # Enable SSH server
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
      };
    };
    numtide-rke2 = {
      enable = true;
      role = "server";
      extraFlags = [
        "--disable"
        "rke2-ingress-nginx"
      ];
      settings.kube-apiserver-arg = [ "anonymous-auth=false" ];
      settings.tls-san = [ "server.local" ];
      settings.debug = true;
      settings.write-kubeconfig-mode = "0644";
      settings.cni = "cilium";
      settings.disable-kube-proxy = true;

      #manifests = {
      #  "rke2-cilium-config.yaml" = ./manifests/rke2-cilium-config.yaml;
      #};
    };

  };

  # Add this section to properly handle the manifest file
  systemd.tmpfiles.rules = [
    "f /var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml - - - - ${./manifests/rke2-cilium-config.yaml}"
  ];

  # This value determines the NixOS release with which your system is to be compatible
  system.stateVersion = "25.11";
}
