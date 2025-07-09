#!/usr/bin/env bash
set -e
nix build .#nixosConfigurations.myvm.config.system.build.vm --show-trace
# this produces `result/` in your cwd
./result/bin/run-nixos-vm 
