//! Test suite for the Web and headless browsers.

#![cfg(target_arch = "wasm32")]

extern crate wasm_bindgen_test;
use recipe_parser_wasm::parse;
use wasm_bindgen_test::*;

// wasm_bindgen_test_configure!(run_in_browser);

#[wasm_bindgen_test]
fn parser_ok() {
    let recipe_str = r#">> source: https://www.youtube.com/watch?v=4aqx69E9T4A
    >> tags: vegan, protein

    Soak {red lentils}(100 gr) overnight. Normally you don't need to soak red lentils but soaking makes them more digestible.

    Drain the red lentils.

    Add the red lentils to the &{blender} with {water}(250 ml), {salt} and {pepper}.

    Blend for at least t{2 minutes}.

    Transfer to a pot and cook until it becomes a think paste.

    Transfer to a mold and let it cool until set."#;
    let result = parse(recipe_str);
    assert_eq!(result.is_ok(), true);
}

#[wasm_bindgen_test]
fn parser_err() {
    let recipe_str = r#"this is an {invalid recipe"#;
    let result = parse(recipe_str);
    assert_eq!(result.is_err(), true);
}
