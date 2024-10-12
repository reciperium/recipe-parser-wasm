{
  description = "Frontend app for reciperium";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    gitignore.url = "github:hercules-ci/gitignore.nix";
    gitignore.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      gitignore,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          packages.recipe-parser-wasm = pkgs.rustPlatform.buildRustPackage {
            name = "recipe-parser-wasm";
            src = gitignore.lib.gitignoreSource ./.;
            cargoLock = {
              lockFile = ./Cargo.lock;
            };
            doCheck = false;

            # used at build time
            nativeBuildInputs = with pkgs; [
              just
              wasm-pack
              wasm-bindgen-cli
              nodejs_20
              llvmPackages.bintools
              binaryen
            ];


            configurePhase = ''
              # NPM writes cache directories etc to $HOME.
              export HOME=$TMP
            '';

            buildPhase = ''
              just build
            '';

            installPhase = ''
              mv out $out
            '';
          };

          devShells.default = pkgs.mkShell {
            name = "recipe-parser-wasm";
            buildInputs =
              with pkgs;
              [
                just
                wasm-pack
                nodejs_20
              ]
              ++ lib.optionals stdenv.isDarwin [
                libiconv
                darwin.apple_sdk_11_0.frameworks.Cocoa
                darwin.apple_sdk_11_0.frameworks.CoreServices
                darwin.apple_sdk_11_0.frameworks.Security
              ];
            shellHook = ''
              just --list
            '';
          };

        };
    };
}
