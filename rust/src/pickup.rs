use godot::classes::{IRigidBody2D, RigidBody2D};
use godot::prelude::*;

#[derive(GodotClass)]
#[class(base=RigidBody2D)]
pub struct Pickup {
    #[var]
    pub is_held: bool,
    base: Base<RigidBody2D>,
}

#[godot_api]
impl Pickup {}

#[godot_api]
impl IRigidBody2D for Pickup {
    fn init(base: Base<RigidBody2D>) -> Self {
        // let mut based = base.tox_init_gd();
        Self {
            base,
            is_held: false,
        }
    }
}
