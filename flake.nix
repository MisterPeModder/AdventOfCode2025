{
  description = "Elixir environment for Advent of Code 2025";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        erlang = pkgs.beam.packages.erlang_28;
      in
      {
        devShells.default = pkgs.mkShell {
          name = "aoc-2025";
          packages = with pkgs; [
            elixir-ls
            erlang.erlang
            erlang.elixir_1_19
          ];
        };
      }
    );
}
