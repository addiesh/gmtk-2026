use godot::classes::{
    Camera2D, CanvasItem, CharacterBody2D, ICharacterBody2D, Input, PhysicsRayQueryParameters2D,
    Sprite2D,
};
use godot::prelude::*;

use crate::pickup::PickupBase;

#[derive(GodotClass)]
#[class(base=CharacterBody2D)]
pub struct Player {
    aim_target_hit: Option<(Vector2, Gd<Node>)>,
    #[export]
    camera_distance: real,
    #[export]
    held_item: Option<Gd<PickupBase>>,
    camera: OnReady<Gd<Camera2D>>,
    sprite: OnReady<Gd<Sprite2D>>,
    base: Base<CharacterBody2D>,
}

#[godot_api]
impl Player {
    const ACCELERATION: real = 1800.0;
    const DECELERATION: real = 1800.0;
    const BASE_SPEED: real = 800.0;

    #[func]
    fn has_aim_endpoint(&self) -> bool {
        self.aim_target_hit.is_some()
    }

    #[func]
    fn aim_endpoint(&self) -> Vector2 {
        self.aim_target_hit
            .as_ref()
            .map(|x| x.0)
            .unwrap_or_default()
    }

    fn aim_calculations(&mut self) {
        let mouse_position = self
            .to_gd()
            .upcast::<CanvasItem>()
            .get_global_mouse_position();

        let Some(mut dss) = self
            .base()
            .get_world_2d()
            .map(|world| world.get_direct_space_state())
            .flatten()
        else {
            godot_warn!("player has no world/space state!");
            return;
        };

        let global_pos = self.base().get_global_position();

        let dir = (mouse_position - global_pos) * 2048.0;

        let aim_hit = dss.intersect_ray(
            &PhysicsRayQueryParameters2D::create(global_pos, global_pos + dir).unwrap(),
        );
        if let Some(position) = aim_hit.get("position") {
            self.aim_target_hit = Some((position.to(), aim_hit.at("collider").to()))
        } else {
            self.aim_target_hit = None;
        }
    }

    fn calculate_movement(&mut self, delta: f64) {
        let input = Input::singleton();

        let horz = input.get_axis("move_left", "move_right");
        let vert = input.get_axis("move_forward", "move_backward");

        let dir = Vector2::new(horz, vert);
        let dir_length = dir.length();

        let current_velocity = self.base().get_velocity();

        // FIXME: replace with time-dilated delta
        let real_delta = delta as f32;

        let new_vel = if dir_length >= 0.1 {
            let target_vel = dir * Self::BASE_SPEED / dir_length;
            if target_vel.x > 0.5 {
                self.sprite.set_flip_h(false);
            } else if target_vel.x < -0.5 {
                self.sprite.set_flip_h(true);
            }
            current_velocity.move_toward(target_vel, Self::ACCELERATION as f32 * real_delta)
        } else {
            current_velocity.move_toward(Vector2::ZERO, Self::DECELERATION * real_delta)
        };
        self.base_mut().set_velocity(new_vel);

        self.base_mut().move_and_slide();
    }
}

#[godot_api]
impl ICharacterBody2D for Player {
    fn init(base: Base<CharacterBody2D>) -> Self {
        Self {
            base,
            camera: OnReady::from_node("Camera2D"),
            sprite: OnReady::from_node("Sprite"),
            camera_distance: 256.0,
            held_item: None,
            aim_target_hit: None,
        }
    }

    fn process(&mut self, delta: f64) {
        let Some(vp) = self.base().get_viewport() else {
            return;
        };
        let vp_size = vp.get_visible_rect().size;
        let mouse_position = ((vp.get_mouse_position() / vp_size) * 2.0 - Vector2::new(0.5, 0.5))
            .limit_length(Some(1.0));

        let offset = self.camera.get_offset();

        let target = mouse_position * self.camera_distance;

        let diff = offset.distance_to(target);

        self.camera
            .set_offset(offset.move_toward(target, delta as f32 * 8.0 * diff));
    }

    fn draw(&mut self) {
        if let Some((aim_target, _)) = self.aim_target_hit {
            let aim_target = self.base().to_local(aim_target);
            self.base_mut()
                .draw_line_ex(Vector2::ZERO, aim_target, Color::DEEP_PINK)
                .width(4.0)
                .done();
        }
    }

    fn physics_process(&mut self, delta: f64) {
        self.aim_calculations();
        self.calculate_movement(delta);
        self.base_mut().queue_redraw();
    }
}
