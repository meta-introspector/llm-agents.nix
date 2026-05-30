{
  lib,
  writeShellApplication,
  jq,
  letta-code,
}:

writeShellApplication {
  name = "letta-ping";

  runtimeInputs = [ letta-code jq ];

  text = ''
    if [[ -z "''${LETTA_API_KEY:-}" && -f "$HOME/.letta/settings.json" ]]; then
      LETTA_API_KEY="$(jq -r '.env.LETTA_API_KEY // empty' "$HOME/.letta/settings.json")"
      export LETTA_API_KEY
    fi
    exec letta ping "$@"
  '';

  meta = with lib; {
    description = "Inspect the latest Letta session usage and quota metadata";
    license = licenses.mit;
    mainProgram = "letta-ping";
    platforms = platforms.all;
  };

  passthru = {
    hideFromDocs = true;
  };
}
