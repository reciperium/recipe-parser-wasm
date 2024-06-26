{
  description = "Frontend app for reciperium";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    gitignore.url = "github:hercules-ci/gitignore.nix";
    gitignore.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = inputs@{ flake-parts, nixpkgs, gitignore, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        {
          packages.recipe-parser-wasm = pkgs.stdenv.mkDerivation {
            name = "recipe-parser-wasm";
            src = gitignore.lib.gitignoreSource ./.;
            nativeBuildInputs = with pkgs; [
              just
              wasm-pack
              nodejs_20
              rustup
            ] ++ lib.optionals stdenv.isDarwin [
              libiconv
              darwin.apple_sdk_11_0.frameworks.Cocoa
              darwin.apple_sdk_11_0.frameworks.CoreServices
              darwin.apple_sdk_11_0.frameworks.Security
            ];

            # Normally required by autotools, but in this case we configure env variables for the
            # upcoming build phase.
            configurePhase = ''
              # NPM writes cache directories etc to $HOME.
              export HOME=$TMP
            '';

            # Compiling phase
            buildPhase = ''
              rustup default stable
              just build
            '';
            installPhase = ''
              mv out $out
            '';
          };

          devenv.shells.default = {
            name = "recipe-parser-wasm";

            packages = with pkgs; [
              just
              wasm-pack
              nodejs_20
            ] ++ lib.optionals stdenv.isDarwin [
              libiconv
              darwin.apple_sdk_11_0.frameworks.Cocoa
              darwin.apple_sdk_11_0.frameworks.CoreServices
              darwin.apple_sdk_11_0.frameworks.Security
            ];

            enterShell = ''
              just --list
            '';
          };
        };
    };
}
