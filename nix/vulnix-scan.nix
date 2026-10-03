{ pkgs }:

pkgs.writeShellScriptBin "vulnix-scan" ''
  #!/usr/bin/env bash
  echo "Running vulnix scan..."
  ${pkgs.vulnix}/bin/vulnix "$@"
''
