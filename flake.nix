{
  description = "NixOS VM for k8s/GHA runner experiment";

  inputs = {
    # pull in unstable so you get the latest VM bits
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};
    in {
      # this makes `flake show` list a `nixosConfigurations.myvm`
      nixosConfigurations.myvm = pkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix    # your existing config file
          ({ config, pkgs, ... }: {
            virtualisation.memorySize = 4096;  # RAM
            virtualisation.cores      = 2;     # vCPUs
            services.openssh.enable   = true;  # so you can ssh in
          })
        ];
      };
    };
}
