{ pkgs, perSystem, ... }:
pkgs.callPackage ./package.nix {
  letta-code = perSystem.self.letta-code;
}
