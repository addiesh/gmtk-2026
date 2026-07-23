use godot::prelude::*;

pub mod pickup;
pub mod player;

struct CrabJamExtension;

#[gdextension]
unsafe impl ExtensionLibrary for CrabJamExtension {}
