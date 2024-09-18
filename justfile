build:
    wasm-pack build --target bundler --out-dir out --out-name recipe-parser
    npm --prefix out pkg set type='module'
    npm --prefix out pkg set main='recipe-parser.js'
    npm --prefix out pkg set name=@reciperium/recipe-parser-wasm
    npm --prefix out pkg set publishConfig.access=public

build-nix:
    nix build .#recipe-parser-wasm --json