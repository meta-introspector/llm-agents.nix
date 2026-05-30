{
  lib,
  stdenvNoCC,
  python3,
  makeWrapper,
}:

stdenvNoCC.mkDerivation {
  pname = "letta-dump";
  version = "0.1.0";

  src = ../../scripts/letta-dump.py;

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/libexec/letta-dump.py
    makeWrapper ${python3}/bin/python3 $out/bin/letta-dump \
      --add-flags $out/libexec/letta-dump.py
    runHook postInstall
  '';

  passthru.category = "Utilities";

  meta = with lib; {
    description = "Convert Letta agent dumps into readable markdown or JSON summaries";
    homepage = "https://github.com/letta-ai/letta-code";
    changelog = "https://github.com/letta-ai/letta-code";
    license = licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with maintainers; [ ];
    mainProgram = "letta-dump";
    platforms = platforms.all;
  };
}
