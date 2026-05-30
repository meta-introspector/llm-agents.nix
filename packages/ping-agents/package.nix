{ lib, writeShellApplication, nix, coreutils }:

writeShellApplication {
  name = "ping-agents";

  runtimeInputs = [
    nix
    coreutils
  ];

  text = ''
    set -eu

    packages=$(nix run .#free-agents)
    names=$(printf '%s\n' "$packages" | awk '/^- / { print $2 }')

    if [ -z "$names" ]; then
      echo "No runnable packages found" >&2
      exit 1
    fi

    printf '%s\n' "$names" | while IFS= read -r pkg; do
      [ -z "$pkg" ] && continue
      printf '%s ... ' "$pkg"
      if timeout 10 nix run ".#''${pkg}" -- --help >/dev/null 2>&1; then
        echo OK
      else
        echo FAIL
      fi
    done
  '';

  meta = with lib; {
    description = "Ping all free runnable agent CLIs with a lightweight health check";
    license = licenses.mit;
    mainProgram = "ping-agents";
    platforms = platforms.all;
  };

  passthru.hideFromDocs = true;
}
