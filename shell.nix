{ pkgs ? import <nixpkgs> {} }:

let
  vulnix-scan = import ./nix/vulnix-scan.nix { inherit pkgs; };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    ghc
    cabal-install
    haskell-language-server
    hlint
    vulnix-scan
  ];
}
