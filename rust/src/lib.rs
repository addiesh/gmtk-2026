use godot::prelude::*;

mod player;

struct CrabJamExtension;

#[gdextension]
unsafe impl ExtensionLibrary for CrabJamExtension {}
