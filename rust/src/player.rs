use godot::classes::{
    AnimatedSprite2D, Area2D, Camera2D, CanvasItem, CharacterBody2D, ClassDb, Control, Engine,
    ICharacterBody2D, Input, PhysicsRayQueryParameters2D, Sprite2D, Time,
};
use godot::prelude::*;

use crate::pickup::Pickup;
use crate::timekeeper::Timekeeper;

#[derive(GodotClass)]
#[class(base=CharacterBody2D)]
pub struct Player {
    aim_target_hit: Option<(Vector2, Gd<Node>)>,
    is_dashing: Option<Vector2>,
    is_walking: bool,
    sprite_facing_right: bool,
    sprite_facing_front: bool,
    squash_distance_traveled: real,
    squash_distance_traveled_last: real,
    real_last_hurt_time: f32,

    #[export]
    camera_distance: real,

    #[export]
    camera_zoom_min: Vector2,
    #[export]
    camera_zoom_max: Vector2,
    #[export]
    camera_zoom_speed_clench: real,
    #[export]
    camera_zoom_speed_release: real,

    #[export]
    link_timer: Option<Gd<Control>>,
    #[export]
    held_item: Option<Gd<Pickup>>,

    blast: OnReady<Gd<PackedScene>>,
    camera: OnReady<Gd<Camera2D>>,
    sprite: OnReady<Gd<AnimatedSprite2D>>,
    interact_area: OnReady<Gd<Area2D>>,

    base: Base<CharacterBody2D>,
}

#[godot_api]
impl Player {
    const ACCELERATION: real = 3600.0;
    const DECELERATION: real = 3600.0;
    const BASE_SPEED: real = 800.0;

    #[signal]
    fn squash_and_stretch();

    #[func]
    fn hurt(&mut self) {
        self.decrease_timer_by(2.0);
    }

    #[func]
    fn is_dashing(&self) -> bool {
        self.is_dashing.is_some()
    }

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

    fn aim_dir(&self) -> Vector2 {
        let mouse_position = self
            .to_gd()
            .upcast::<CanvasItem>()
            .get_global_mouse_position();
        (mouse_position - self.base().get_global_position()).normalized()
    }

    fn decrease_timer_by(&mut self, dec_by: f32) {
        {
            let mut bm = self.base_mut();
            let old_mod = bm.get_self_modulate() + Color::WHITE;
            bm.set_self_modulate(old_mod);
        }
        self.link_timer
            .as_mut()
            .unwrap()
            .call("remove_time", &[dec_by.to_variant()]);
    }

    fn _manually_spawn_ghost(&self) -> Gd<AnimatedSprite2D> {
        let transform = self.base().get_global_transform();
        let texture = self
            .sprite
            .get_sprite_frames()
            .unwrap()
            .get_frame_texture(&self.sprite.get_animation(), self.sprite.get_frame());
        let ghost = ClassDb::singleton()
            .class_call_static(
                "Ghost",
                "make_ghost",
                &[transform.to_variant(), texture.to_variant()],
            )
            .to::<Gd<AnimatedSprite2D>>();
        self.base().get_tree().get_root().unwrap().add_child(&ghost);
        ghost
    }

    fn aim_calculations(&mut self) {
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

        let dir = self.aim_dir() * 2048.0;

        let aim_hit = dss.intersect_ray(
            &PhysicsRayQueryParameters2D::create(global_pos, global_pos + dir).unwrap(),
        );
        if let Some(position) = aim_hit.get("position") {
            self.aim_target_hit = Some((position.to(), aim_hit.at("collider").to()))
        } else {
            self.aim_target_hit = None;
        }
    }

    fn item_actions(&mut self, _delta: f64) {
        let input = Input::singleton();
        let chi = self.held_item.as_ref().map(|x| x.clone());
        if let Some(mut held_item) = chi {
            if input.is_action_just_pressed("attack") {
                if held_item.bind_mut().interact() {
                    self.decrease_timer_by(2.0);
                    // TODO: decrease level time by 1 seconds
                }
            } else if input.is_action_just_pressed("use_item") {
                drop(self.held_item.take());
                held_item.reparent(&self.base().get_parent().unwrap());
                let mut bind = held_item.bind_mut();
                bind.throw(self.aim_dir());
                let mut bind_base = bind.base_mut();
                bind_base.set_visible(true);

                self.decrease_timer_by(2.0);

                // let mut blast_particle = self.blast.instantiate().unwrap().cast::<Node2D>();
                // let mut bm = self.base_mut();
                // bm.add_sibling(&blast_particle);
                // blast_particle.set_z_index(400);
                // blast_particle.set_global_position(bm.get_global_position());
                // blast_particle.request_ready();
            }
        } else {
            if input.is_action_just_pressed("use_item") {
                let pickup = self
                    .interact_area
                    .get_overlapping_bodies()
                    .iter_shared()
                    .find_map(|node| node.try_cast::<Pickup>().ok());

                if let Some(mut pickup) = pickup {
                    // pickup
                    //     .bind_mut()
                    //     .base_mut()
                    //     .add_collision_exception_with(&self.to_gd());
                    pickup.reparent(&self.to_gd());
                    {
                        let mut bind = pickup.bind_mut();
                        bind.equip();
                        let mut bind_base = bind.base_mut();
                        bind_base.set_visible(false);
                        bind_base.set_position(Vector2::ZERO);
                    }
                    self.held_item = Some(pickup.clone());
                    self.decrease_timer_by(1.0);
                }
            }
        }
    }

    fn dash_action(&mut self, delta: f64) {
        let input = Input::singleton();
        let velocity = self.base().get_velocity();
        if self.is_dashing.is_none() && input.is_action_just_pressed("dash") {
            // TODO: decrease level time by 2 seconds
            let dash_dir = self.aim_dir();
            self.is_dashing = Some(dash_dir);
            Timekeeper::time_flags().bind_mut().player_dashing = true;
            self.base_mut().set_velocity(
                /* negate this for curveball (broken) */ dash_dir * 1024.0,
            );
            self.decrease_timer_by(2.0);
        }

        if let Some(dash_dir) = self.is_dashing {
            // let velocity = self.base().get_velocity();

            let mut ghost = self.sprite.call("_frame_ghost", &[]).to::<Gd<Sprite2D>>();
            ghost.set_self_modulate(Color::AQUA.with_alpha(0.2));
            ghost.apply_scale(Vector2::new(0.9, 0.75));

            // // true if we're moving the right direction
            // let is_curveball = velocity.dot(dash_dir) >= 0.0 || velocity.length_squared() < 32.0;

            // let vel_scale = if is_curveball && velocity.length_squared() < 32.0 {
            //     4096.0 / 0.25
            // } else {
            //     8.0
            // };
            // if is_curveball {
            //     delta as f32 * 4096.0 / 0.0125
            // } else {
            //     delta as f32 * 4096.0 * 16.0
            // }

            self.base_mut().set_velocity(dash_dir * 4096.0 * 4.0);

            // self.base_mut().set_velocity(velocity.move_toward(
            //     dash_dir * (velocity.length() * (1.0 + 16.0 * delta as f32)).min(4096.0 * 80.0),
            //     delta as f32 * 4096.0 * 128.0,
            // ));
        }

        let collision = self
            .base_mut()
            .move_and_collide_ex(velocity * delta as f32)
            .test_only(true)
            .done();
        if let Some(collision) = collision
            && let Some(collider) = collision.get_collider()
            && let Some(dash_dir) = self.is_dashing
        {
            self.is_dashing = None;

            let mut time_flags = Timekeeper::time_flags();
            let mut time_flags = time_flags.bind_mut();

            time_flags.last_player_dash_time = Timekeeper::get_time();
            time_flags.player_dashing = false;
            let bounce = dash_dir * -1024.0;
            self.base_mut().set_velocity(bounce);

            let mut ghost = self.sprite.call("_frame_ghost", &[]).to::<Gd<Sprite2D>>();
            ghost.set_self_modulate(Color::AQUA.with_alpha(0.3));
            ghost.apply_scale(Vector2::new(1.1, 1.1));

            godot_print!("hit the wall: {collider:?}, angle = {bounce}");
        }
    }

    fn basic_movement(&mut self, delta: f64) {
        let input = Input::singleton();

        let horz = input.get_axis("move_left", "move_right");
        let vert = input.get_axis("move_forward", "move_backward");

        let dir = Vector2::new(horz, vert);
        let dir_length = dir.length();

        let current_velocity = self.base().get_velocity();

        let new_vel;
        if dir_length >= 0.1 {
            let target_vel = dir * Self::BASE_SPEED / dir_length;

            self.is_walking = true;
            if dir.x > 0.0 {
                self.sprite_facing_right = true;
            } else if dir.x < 0.0 {
                self.sprite_facing_right = false;
            }

            if dir.y > 0.0 {
                self.sprite_facing_front = true;
            } else if dir.y < 0.0 {
                self.sprite_facing_front = false;
            }

            Timekeeper::time_flags().bind_mut().player_moving = true;
            new_vel =
                current_velocity.move_toward(target_vel, Self::ACCELERATION as f32 * delta as f32);

            self.squash_distance_traveled += new_vel.length() * delta as f32;
        } else {
            Timekeeper::time_flags().bind_mut().player_moving = false;
            self.is_walking = false;
            self.squash_distance_traveled = 0.0;
            self.squash_distance_traveled_last = f32::NEG_INFINITY;

            new_vel =
                current_velocity.move_toward(Vector2::ZERO, Self::DECELERATION * delta as f32);
        }

        self.base_mut().set_velocity(new_vel);
    }

    fn animation(&mut self) {
        let fb = if self.sprite_facing_front { "f" } else { "b" };
        let rl = if self.sprite_facing_right { "r" } else { "l" };
        let moving = if self.is_walking { "walk" } else { "idle" };
        let equip = match &self.held_item {
            Some(_) => "_hammer",
            None => "",
        };

        if self.real_last_hurt_time + 100.0 > (Time::singleton().get_ticks_msec() as f32 / 1000.0) {
            self.sprite.set_animation(&format!("hurt_{fb}{rl}{equip}"));
        } else if self.is_dashing.is_some() {
            self.sprite.set_animation(&format!("walk_{fb}{rl}{equip}"));
        } else {
            let anim_string = format!("{moving}_{fb}{rl}{equip}");
            self.sprite.set_animation(&anim_string);
        }
        if !self.sprite.is_playing() {
            self.sprite.play();
        }
        // if self.is_walking {
        // if self.squash_distance_traveled >= self.squash_distance_traveled_last + 128.0 {
        //     self.squash_distance_traveled_last = self.squash_distance_traveled;
        //     self.signals().squash_and_stretch().emit();
        // }
        // }
    }
}

#[godot_api]
impl ICharacterBody2D for Player {
    fn init(base: Base<CharacterBody2D>) -> Self {
        Self {
            base,
            camera: OnReady::from_node("Camera2D"),
            sprite: OnReady::from_node("Sprite"),
            interact_area: OnReady::from_node("InteractArea"),
            camera_distance: 256.0,
            held_item: None,
            link_timer: None,
            aim_target_hit: None,
            camera_zoom_min: Vector2::ONE * 0.9,
            camera_zoom_max: Vector2::ONE * 1.1,
            camera_zoom_speed_clench: 16.0,
            camera_zoom_speed_release: 1.0,
            is_dashing: None,
            is_walking: false,
            sprite_facing_right: true,
            sprite_facing_front: true,
            squash_distance_traveled: 0.0,
            blast: OnReady::from_loaded("res://particles/blast.tscn"),
            squash_distance_traveled_last: f32::NEG_INFINITY,
            real_last_hurt_time: f32::NEG_INFINITY,
        }
    }

    fn process(&mut self, _delta: f64) {
        let Some(vp) = self.base().get_viewport() else {
            return;
        };
        let vp_size = vp.get_visible_rect().size;
        let mouse_position = ((vp.get_mouse_position() / vp_size) * 2.0 - Vector2::new(0.5, 0.5))
            .limit_length(Some(1.0));

        let real_delta = Timekeeper::real_process_delta();

        // camera offset code
        {
            let offset = self.camera.get_offset();

            let target = mouse_position
                * self.camera_distance.lerp(
                    self.camera_distance * 1.5,
                    Timekeeper::timescale().clamp(0.25, 1.25) as f32,
                );
            self.camera.set_offset(
                offset
                    .move_toward(target, real_delta as f32 * 8.0 * offset.distance_to(target))
                    .round(),
            );
        }

        // camera zoom code
        if false {
            let zoom = self.camera.get_zoom();

            let target = self.camera_zoom_min.lerp(
                self.camera_zoom_max,
                Timekeeper::timescale().clamp(0.25, 1.25) as f32,
            );

            let zoom_speed = if target.length_squared() > zoom.length_squared() {
                self.camera_zoom_speed_clench
            } else {
                self.camera_zoom_speed_release
            };

            self.camera.set_zoom(zoom.move_toward(
                target,
                real_delta as f32 * zoom_speed * zoom.distance_squared_to(target),
            ));
        }

        let aim_dir = self.aim_dir();

        if let Some(held_item) = &mut self.held_item {
            held_item.set_rotation(aim_dir.angle());
            held_item.set_position(aim_dir * 48.0);
        }

        // self.base_mut().queue_redraw();
    }

    fn draw(&mut self) {
        if let Some((_aim_target, _)) = self.aim_target_hit {

            // let aim_target = self.base().to_local(aim_target);
            // self.base_mut()
            //     .draw_line_ex(Vector2::ZERO, aim_target, Color::DEEP_PINK)
            //     .width(4.0)
            //     .done();
        }
    }

    fn physics_process(&mut self, delta: f64) {
        self.aim_calculations();
        if self.is_dashing.is_none() {
            self.basic_movement(delta);
        } else {
            self.is_walking = false;
        }
        self.dash_action(delta);
        self.item_actions(delta);
        self.animation();
        self.base_mut().move_and_slide();
    }
}
