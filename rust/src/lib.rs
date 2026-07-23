use godot::classes::Engine;
use godot::prelude::*;

use crate::timekeeper::Timekeeper;

pub mod pickup;
pub mod player;
pub mod timekeeper;

struct CrabJamExtension;

pub fn move_toward_f32(from: f32, to: f32, delta: f32) -> f32 {
    if (to - from).abs() <= delta {
        to
    } else {
        from + (to - from).signum() * delta
    }
}

#[gdextension]
unsafe impl ExtensionLibrary for CrabJamExtension {
    fn on_main_loop_frame() {
        if Engine::singleton().is_editor_hint() {
            return;
        }

        Timekeeper::singleton().bind_mut()._internal_update();
    }
}
