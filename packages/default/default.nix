{
  pkgs,
  perSystem,
  ...
}:
let
  allPackages = perSystem.self;

  excludedNames = [
    "bernstein"
    "zeroclaw"
    "localgpt"
    "reasonix"
    "claw-code"
    "goose-cli"
    "gastown"
    "gnhf"
    "nanocoder"
    "oh-my-codex"
    "omp"
    "auto-claude"
    "catnip"
    "cc-switch-cli"
    "ccstatusline"
    "claude-agent-acp"
    "claude-code-router"
    "claude-code"
    "claude-plugins"
    "claudebox"
    "cli-proxy-api"
    "eca"
    "openclaw"
    "pi"
    "picoclaw"
    "openfang"
  ];

  isFreePackage =
    pkg:
    let
      license = pkg.meta.license or null;
      isUnfree = builtins.isAttrs license && ((license ? unfree) || ((license ? shortName) && license.shortName == "unfree"));
    in
    !isUnfree;

  # Filter to visible, runnable packages
  visibleNames = builtins.filter (
    name:
    name != "default"
    && !(builtins.elem name excludedNames)
    && !(allPackages.${name}.passthru.hideFromDocs or false)
    && isFreePackage allPackages.${name}
  ) (builtins.attrNames allPackages);

  # Build "name\tdescription\tcategory" lines
  packageLines = map (
    name:
    "${name}\t${allPackages.${name}.meta.description or ""}\t${allPackages.${name}.passthru.category or "Uncategorized"}"
  ) visibleNames;

  packageList = builtins.concatStringsSep "\n" packageLines;
in
pkgs.callPackage ./package.nix { inherit packageList; }
