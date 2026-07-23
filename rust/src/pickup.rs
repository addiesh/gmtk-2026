use godot::classes::{IRigidBody2D, RigidBody2D, Texture2D};
use godot::prelude::*;

#[derive(GodotClass)]
#[class(base=RigidBody2D)]
pub struct PickupBase {
    #[var]
    overworld_sprite: Gd<Texture2D>,
    base: Base<RigidBody2D>,
}

#[godot_api]
impl PickupBase {}

#[godot_api]
impl IRigidBody2D for PickupBase {
    fn init(base: Base<RigidBody2D>) -> Self {
        base.to_init_gd().set_gravity_scale(0.0);
        Self {
            base,
            overworld_sprite: load("res://icon.svg"),
        }
    }

    fn draw(&mut self) {
        let sprite = self.overworld_sprite.clone();
        self.base_mut()
            .draw_texture(&sprite, sprite.get_size() / -2.0);
    }
}
