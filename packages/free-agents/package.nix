{ writeShellScriptBin }:

let
  repoRoot = toString ../..;
in
writeShellScriptBin "free-agents" ''
  set -eu
  nix eval --raw --impure --file ${repoRoot}/scripts/free-agents.nix
''
