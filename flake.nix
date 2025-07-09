{
  description = "My NixOS VM";

  inputs.rke2.url = "github:numtide/nixos-rke2";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, rke2 }: {
    nixosConfigurations.myvm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit rke2; inputs = { inherit rke2; }; };  # Add this line
      modules = [
        ./configuration.nix  # your usual NixOS config
        ({ config, pkgs, ... }: {
          boot.growPartition = true;

          virtualisation.vmVariant = {
            virtualisation = {
              # in MiB
              diskSize = 40 * 1024;
              memorySize = 4096;
              cores = 2;
              # Add port forwarding
              forwardPorts = [
                # SSH
                { from = "host"; host.port = 2222; guest.port = 22; }
                # Kubernetes API Server
                { from = "host"; host.port = 6443; guest.port = 6443; }
              ];
            };
          };
        })
      ];
    };
  };
}
