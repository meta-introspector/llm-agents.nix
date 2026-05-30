{
  lib,
  stdenvNoCC,
  makeWrapper,
  bash,
  iptables,
  iproute2,
  ripgrep,
}:

stdenvNoCC.mkDerivation {
  pname = "iptables-capture";
  version = "0.1.0";

  src = ../../scripts/iptables-capture.sh;

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/iptables-capture
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/iptables-capture \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          iptables
          iproute2
          ripgrep
        ]
      }
  '';

  passthru.category = "Utilities";

  meta = with lib; {
    description = "Helper for installing and removing a transparent iptables capture rule";
    homepage = "https://github.com/numtide/llm-agents.nix";
    changelog = "https://github.com/numtide/llm-agents.nix";
    license = licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with maintainers; [ ];
    mainProgram = "iptables-capture";
    platforms = platforms.linux;
  };
}
