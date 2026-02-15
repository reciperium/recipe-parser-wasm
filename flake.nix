{
  description = "Frontend app for reciperium";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    gitignore.url = "github:hercules-ci/gitignore.nix";
    gitignore.inputs.nixpkgs.follows = "nixpkgs";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          pkgs,
          inputs',
          ...
        }:
        let
          nodejs = pkgs.nodejs_24;
          fenix = inputs'.fenix.packages;
          rustChannel = "stable";
          rustToolchain = (
            fenix.combine [
              fenix.${rustChannel}.toolchain

              # https://doc.rust-lang.org/rustc/platform-support.html
              # For more targets add:
              # fenix.targets.aarch64-linux-android."${rustChannel}".rust-std
              # fenix.targets.x86_64-linux-android."${rustChannel}".rust-std
            ]
          );

        in
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
              nodejs
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
            packages =
              with pkgs;
              [
                just
                wasm-pack
                nodejs
                rustToolchain
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
