use godot::classes::{IRigidBody2D, RigidBody2D};
use godot::prelude::*;

#[derive(GodotClass)]
#[class(base=RigidBody2D)]
pub struct Pickup {
    base: Base<RigidBody2D>,
}

#[godot_api]
impl Pickup {
    pub fn equip(&mut self) {
        self.base_mut().set_freeze_enabled(true);
    }

    #[func(virtual)]
    /// Returns true if the action did anything.
    pub fn interact(&mut self) -> bool {
        false
    }

    #[func(virtual)]
    pub fn throw(&mut self, direction: Vector2) {
        self.base_mut().set_freeze_enabled(false);
        self.base_mut().set_linear_velocity(direction * 2048.0);
        self.base_mut().set_angular_velocity(64.0);
    }
}

#[godot_api]
impl IRigidBody2D for Pickup {
    fn init(base: Base<RigidBody2D>) -> Self {
        let mut based = base.to_init_gd();
        based.set_gravity_scale(0.0);
        Self { base }
    }
}
