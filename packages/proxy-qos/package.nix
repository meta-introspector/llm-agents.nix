{ lib, writeShellScriptBin, curl, jq, coreutils, gnused, gnugrep }:

writeShellScriptBin "proxy-qos" ''
  set -eu
  export PATH=${lib.makeBinPath [ curl jq coreutils gnused gnugrep ]}:$PATH
  exec ${toString ../../scripts/proxy-qos.sh} "$@"
''
