use godot::classes::{CharacterBody2D, ICharacterBody2D, Input};
use godot::prelude::*;

#[derive(GodotClass)]
#[class(base=CharacterBody2D)]
struct Player {
    base: Base<CharacterBody2D>,
}

#[godot_api]
impl Player {
    const ACCELERATION: real = 1800.0;
    const DECELERATION: real = 1800.0;
    const BASE_SPEED: real = 800.0;
}

#[godot_api]
impl ICharacterBody2D for Player {
    fn init(base: Base<CharacterBody2D>) -> Self {
        Self { base }
    }

    fn physics_process(&mut self, delta: f64) {
        let input = Input::singleton();
        // let jump = input.is_action_pressed("jump");

        // Handle jump.
        // if jump {
        // if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        // 	velocity.y = JUMP_VELOCITY
        // }

        let horz = input.get_axis("move_left", "move_right");
        let vert = input.get_axis("move_forward", "move_backward");

        let dir = Vector2::new(horz, vert);
        let dir_length = dir.length();

        let current_velocity = self.base().get_velocity();

        // FIXME: replace with time-dilated delta
        let real_delta = delta as f32;

        let new_vel = if dir_length >= 0.1 {
            let target_vel = dir * Self::BASE_SPEED / dir_length;
            current_velocity.move_toward(target_vel, Self::ACCELERATION * real_delta)
        } else {
            current_velocity.move_toward(Vector2::ZERO, Self::DECELERATION * real_delta)
        };
        self.base_mut().set_velocity(new_vel);

        self.base_mut().move_and_slide();
    }
}
