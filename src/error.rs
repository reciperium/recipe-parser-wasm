#![allow(non_snake_case)]

use std::{error::Error, fmt::Display};

use serde::Serialize;
use tsify::Tsify;

#[derive(Debug, Clone, Serialize, Tsify)]
#[tsify(into_wasm_abi)]
pub struct WasmParserError {
    message: String,
    offset: usize,
}

impl WasmParserError {
    pub fn new(message: String, offset: usize) -> Self {
        Self { message, offset }
    }
}

impl Display for WasmParserError {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "Error: {} at offset {}", self.message, self.offset)
    }
}

impl Error for WasmParserError {}
