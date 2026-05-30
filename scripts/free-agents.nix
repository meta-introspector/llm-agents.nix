let
  flake = builtins.getFlake (toString ./..);
  packages = flake.packages.x86_64-linux;
  names = builtins.attrNames packages;

  freePackages = builtins.filter (
    name:
    if name == "free-agents" || name == "ping-agents" || name == "nvidia-cli" then
      false
    else
      let
        evaluated = builtins.tryEval packages.${name};
      in
      evaluated.success
      && (
        let
          pkg = evaluated.value;
          license = pkg.meta.license or null;
          isUnfree = builtins.isAttrs license && ((license ? unfree) || ((license ? shortName) && license.shortName == "unfree"));
        in
        !isUnfree && (pkg.meta ? mainProgram)
      )
  ) names;

  grouped = builtins.foldl' (
    acc: name:
    let
      pkg = packages.${name};
      category = pkg.passthru.category or "Uncategorized";
    in
    acc // { ${category} = (acc.${category} or [ ]) ++ [ name ]; }
  ) {
    "AI Coding Agents" = [ ];
    "AI Assistants" = [ ];
    "Claude Code Ecosystem" = [ ];
    "ACP Ecosystem" = [ ];
    "MCP" = [ ];
    "Usage Analytics" = [ ];
    "Workflow & Project Management" = [ ];
    "Code Review" = [ ];
    "Utilities" = [ ];
    Uncategorized = [ ];
  } freePackages;

  renderCategory = category:
    let
      pkgsInCategory = grouped.${category} or [ ];
    in
    if pkgsInCategory == [ ] then [ ] else [ category ] ++ builtins.map (name: "- ${name}") pkgsInCategory ++ [ "" ];
in
builtins.concatStringsSep "\n" (builtins.concatMap renderCategory [
  "AI Coding Agents"
  "AI Assistants"
  "Claude Code Ecosystem"
  "ACP Ecosystem"
  "MCP"
  "Usage Analytics"
  "Workflow & Project Management"
  "Code Review"
  "Utilities"
  "Uncategorized"
])
