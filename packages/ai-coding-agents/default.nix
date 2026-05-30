{
  pkgs,
  perSystem,
  ...
}:
pkgs.callPackage ./package.nix {
  llm-agents-launcher = perSystem.self.default;
}
