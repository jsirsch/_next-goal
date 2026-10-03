{ pkgs }:

pkgs.writeShellScriptBin "vulnix-scan" ''
  #!/usr/bin/env bash
  echo "Running vulnix scan..."
  
  if [ $# -eq 0 ]; then
    echo "No arguments provided. Building current flake and scanning the output..."
    nix build .
    ${pkgs.vulnix}/bin/vulnix -w ./nix/vulnix-whitelist.toml ./result
  else
    ${pkgs.vulnix}/bin/vulnix -w ./nix/vulnix-whitelist.toml "$@"
  fi
''
