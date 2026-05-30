let
  flake = builtins.getFlake (toString ./..);
  pkgs = flake.packages.x86_64-linux;
  names = builtins.attrNames pkgs;

  connectKeywords = [
    "fastapi"
    "uvicorn"
    "websockets"
    "mcp"
    "prometheus-client"
    "opentelemetry"
    "socket"
    "server"
    "api"
  ];

  hasConnectSurface = pkg:
    let
      text = builtins.concatStringsSep " " (
        [
          (pkg.meta.description or "")
          (pkg.meta.homepage or "")
        ]
        ++ (builtins.attrNames (pkg.dependencies or { }))
      );
    in
    builtins.any (kw: builtins.match ".*${kw}.*" text != null) connectKeywords;

  pingable = builtins.filter (
    name:
    if name == "default" || name == "free-agents" || name == "ping-agents" || name == "nvidia-cli" then
      false
    else
      let
        evaluated = builtins.tryEval pkgs.${name};
      in
      evaluated.success
      && !(evaluated.value.passthru.hideFromDocs or false)
      && (evaluated.value.meta ? mainProgram)
      && hasConnectSurface evaluated.value
  ) names;
in
builtins.concatStringsSep "\n" pingable
