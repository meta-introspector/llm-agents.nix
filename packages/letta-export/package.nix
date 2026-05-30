{
  lib,
  writeShellApplication,
  jq,
  letta-code,
}:

writeShellApplication {
  name = "letta-export";

  runtimeInputs = [ letta-code jq ];

  text = ''
    if [[ -z "''${LETTA_API_KEY:-}" && -f "$HOME/.letta/settings.json" ]]; then
      LETTA_API_KEY="$(jq -r '.env.LETTA_API_KEY // empty' "$HOME/.letta/settings.json")"
      export LETTA_API_KEY
    fi
    exec letta dump "$@"
  '';

  meta = with lib; {
    description = "Dump the latest Letta session transcript";
    license = licenses.mit;
    mainProgram = "letta-export";
    platforms = platforms.all;
  };

  passthru = {
    hideFromDocs = true;
  };
}
