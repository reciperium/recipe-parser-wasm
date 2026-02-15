build:
    wasm-pack build --target bundler --out-dir out --out-name recipe-parser
    npm --prefix out pkg set name=@reciperium/recipe-parser-wasm
    npm --prefix out pkg set publishConfig.access=public
    npm --prefix out pkg set --json publishConfig.provenance=true

build-nix:
    nix build .#recipe-parser-wasm --json

test:
    wasm-pack test --node
