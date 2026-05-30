{ lib, writeShellApplication, llm-agents-launcher }:

writeShellApplication {
  name = "ai-coding-agents";

  runtimeInputs = [ llm-agents-launcher ];

  text = ''
    export DEFAULT_CATEGORY="AI Coding Agents"
    exec llm-agents-launcher "$@"
  '';

  meta = with lib; {
    description = "Open the launcher directly to the AI Coding Agents category";
    license = licenses.mit;
    mainProgram = "ai-coding-agents";
    platforms = platforms.all;
  };

  passthru.hideFromDocs = true;
}
