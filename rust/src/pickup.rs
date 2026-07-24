use godot::classes::{IRigidBody2D, RigidBody2D};
use godot::prelude::*;

#[derive(GodotClass)]
#[class(base=RigidBody2D)]
pub struct Pickup {
    base: Base<RigidBody2D>,
}

#[godot_api]
impl Pickup {
    #[func(virtual)]
    pub fn equip(&mut self) {}

    #[func(virtual)]
    /// Returns true if the action did anything.
    pub fn interact(&mut self) -> bool {
        false
    }

    #[func(virtual)]
    pub fn throw(&mut self, _direction: Vector2) {
        godot_error!("TODO: implement throw function");
    }
}

#[godot_api]
impl IRigidBody2D for Pickup {
    fn init(base: Base<RigidBody2D>) -> Self {
        // let mut based = base.to_init_gd();
        Self { base }
    }
}
