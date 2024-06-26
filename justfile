build:
    wasm-pack build --target bundler --out-dir out --out-name recipe-parser
    npm --prefix out pkg set type='module'
    npm --prefix out pkg set main='recipe-parser.js'

nix_build:
    nix build .#recipe-parser-wasm --json