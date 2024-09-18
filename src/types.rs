#![allow(non_snake_case)]
use std::collections::HashMap;

use recipe_parser::Token;
use serde::Serialize;
use tsify::Tsify;

#[derive(Debug, Clone, Eq, PartialEq, Serialize, Tsify)]
#[tsify(into_wasm_abi)]
pub struct Ingredient {
    pub name: String,
    #[tsify(optional)]
    pub quantity: Option<String>,
    #[tsify(optional)]
    pub unit: Option<String>,
}

#[derive(Debug, Clone, Eq, PartialEq, Serialize, Tsify)]
#[tsify(into_wasm_abi)]
pub struct Timer {
    pub duration: String,
}

#[derive(Debug, Clone, Eq, PartialEq, Serialize, Tsify)]
#[tsify(into_wasm_abi)]
pub struct Material {
    pub name: String,
}

#[derive(Debug, Clone, Eq, PartialEq, Serialize, Tsify)]
#[tsify(into_wasm_abi)]
pub struct Recipe<'a> {
    #[tsify(optional)]
    pub name: Option<String>,
    #[tsify(type = "Map<string, string>")]
    #[tsify(optional)]
    pub metadata: HashMap<String, String>,
    pub ingredients: Vec<Ingredient>,
    pub recipes_refs: Vec<Ingredient>,
    pub timers: Vec<Timer>,
    pub materials: Vec<Material>,
    #[tsify(optional)]
    pub backstory: Option<String>,
    pub instructions: String,
    pub tokens: Vec<Token<'a>>,
}

impl<'a> From<Vec<Token<'a>>> for Recipe<'a> {
    fn from(value: Vec<Token<'a>>) -> Self {
        let mut metadata = HashMap::new();

        let mut ingredients = Vec::new();
        let mut recipes_refs = Vec::new();
        let mut timers = Vec::new();
        let mut materials = Vec::new();
        let mut backstory = String::new();
        let mut instructions = String::new();

        for token in &value {
            match token {
                Token::Backstory(_) => (),
                _ => {
                    instructions.push_str(&token.to_string());
                }
            }
            match token {
                Token::Metadata { key, value } => {
                    metadata.insert(key.to_string(), value.to_string());
                }
                Token::Ingredient {
                    name,
                    quantity,
                    unit,
                } => {
                    let i = Ingredient {
                        name: name.to_string(),
                        quantity: quantity.map(|v| v.to_string()),
                        unit: unit.map(|v| v.to_string()),
                    };
                    ingredients.push(i);
                }
                Token::RecipeRef {
                    name,
                    quantity,
                    unit,
                } => {
                    let i = Ingredient {
                        name: name.to_string(),
                        quantity: quantity.map(|v| v.to_string()),
                        unit: unit.map(|v| v.to_string()),
                    };
                    recipes_refs.push(i);
                }

                Token::Timer(t) => timers.push(Timer {
                    duration: t.to_string(),
                }),
                Token::Material(material) => materials.push(Material {
                    name: material.to_string(),
                }),
                Token::Backstory(bs) => backstory.push_str(bs),
                _ => {}
            };
        }
        let name = metadata.get("name").cloned();

        Self {
            name,
            ingredients,
            timers,
            materials,
            metadata,
            recipes_refs,
            backstory: {
                if backstory.is_empty() {
                    None
                } else {
                    Some(backstory)
                }
            },
            instructions: instructions,
            tokens: value,
        }
    }
}
