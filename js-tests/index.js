import { parse } from "@reciperium/recipe-lang-wasm";

let recipe = `>> source: https://www.youtube.com/watch?v=4aqx69E9T4A
>> tags: vegan, protein

Soak {red lentils}(100 gr) overnight. Normally you don't need to soak red lentils but soaking makes them more digestible.

Drain the red lentils.

Add the red lentils to the &{blender} with {water}(250 ml), {salt} and {pepper}.

Blend for at least t{2 minutes}.

Transfer to a pot and cook until it becomes a think paste.

Transfer to a mold and let it cool until set.
`

let invalidRecipe = `this is an {invalid recipe`
console.log(parse(recipe));
console.log(parse(invalidRecipe));
