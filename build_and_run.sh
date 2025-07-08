nix build .#nixosConfigurations.myvm.config.system.build.vm
# this produces `result/` in your cwd
./result/bin/run-nixos-vm