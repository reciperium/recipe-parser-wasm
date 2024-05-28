mod utils;
mod types;
mod error;

use core::str;
use error::WasmParserError;

use types::Recipe;
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub fn parse(i: &str) -> Result<JsValue, JsValue> {
    recipe_parser::parse(i)
        .map(|v| Recipe::from(v))
        .map(|v| serde_wasm_bindgen::to_value(&v).unwrap())
        .map_err(|e| WasmParserError::new(e.to_string(), e.offset()))
        .map_err(|e| serde_wasm_bindgen::to_value(&e).unwrap())
}
