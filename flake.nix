{
  description = "next-goal: A Haskell Brick TUI using RIO";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        vulnix-scan = import ./nix/vulnix-scan.nix { inherit pkgs; };
        
        # Build the Haskell TUI project
        next-goal-tui = pkgs.haskellPackages.callCabal2nix "next-goal-tui" ./tui {};
      in
      {
        packages.default = next-goal-tui;

        devShells.default = pkgs.mkShell {
          # Inherit dependencies from the package
          inputsFrom = [ next-goal-tui.env ];
          buildInputs = with pkgs; [
            cabal-install
            haskell-language-server
            hlint
            vulnix-scan
          ];
        };

        apps.vulnix-scan = {
          type = "app";
          program = "${vulnix-scan}/bin/vulnix-scan";
        };

        checks = {
          # Placeholder for when Haskell files are added
          # hlint-check = pkgs.runCommand "hlint-check" {} ''
          #   ${pkgs.hlint}/bin/hlint ${self}
          #   touch $out
          # '';
        };
      }
    );
}
