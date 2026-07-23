use godot::classes::{Engine, Window};
use godot::global::move_toward;
use godot::prelude::*;

#[derive(GodotClass)]
#[class(no_init, base=RefCounted)]
pub struct TimekeeperFlags {
    /// Is the player moving right now?
    #[var]
    pub player_moving: bool,
    /// Is the player in the middle of a dash right now?
    #[var]
    pub player_dashing: bool,
    /// The last time the player used an action (i.e. fire weapon, pick up item, etc.)
    #[var]
    pub last_player_action_time: f64,
    /// The last time the player dashed
    #[var]
    pub last_player_dash_time: f64,
    /// The last time the player took any damage
    #[var]
    pub last_player_hurt_time: f64,
}

#[derive(GodotClass)]
#[class(singleton)]
pub struct Timekeeper {
    /// used for interpolation logic
    target_timescale: f64,
    /// used
    current_timescale: f64,
    /// time that makes sense
    dilated_time: f64,
    flags: Gd<TimekeeperFlags>,
    /// used when someone does silly things. save for later.
    is_hacked: bool,

    base: Base<Object>,
}

#[godot_api]
impl IObject for Timekeeper {
    fn init(base: Base<Object>) -> Self {
        Self {
            target_timescale: 0.25,
            current_timescale: 0.25,
            base,
            flags: Gd::from_object(TimekeeperFlags {
                player_moving: false,
                player_dashing: false,
                last_player_action_time: -1000.0,
                last_player_dash_time: -1000.0,
                last_player_hurt_time: -1000.0,
            }),
            is_hacked: false,
            dilated_time: 0.0,
        }
    }
}

#[godot_api]
impl Timekeeper {
    #[func]
    /// Game time (in seconds) as affected by time dilation.
    pub fn get_time() -> f64 {
        Timekeeper::singleton().bind().dilated_time
    }

    fn shared_window_getter() -> Option<Gd<Window>> {
        Engine::singleton()
            .get_main_loop()
            .and_then(|ml| ml.try_cast::<SceneTree>().ok())
            .and_then(|st| st.get_root())
    }

    fn global_process_delta() -> Option<f64> {
        Self::shared_window_getter().map(|window| window.get_process_delta_time())
    }

    fn global_physics_delta() -> Option<f64> {
        Self::shared_window_getter().map(|window| window.get_physics_process_delta_time())
    }

    #[func]
    /// Returns the engine's `process()` delta time, unchanged by time dilation
    pub fn real_process_delta() -> f64 {
        Self::global_process_delta().unwrap_or(0.0) / Engine::singleton().get_time_scale()
    }

    #[func]
    /// Returns the engine's `physics_process()` delta time, unchanged by time dilation
    pub fn real_physics_delta() -> f64 {
        Self::global_physics_delta().unwrap_or(0.0) / Engine::singleton().get_time_scale()
    }

    #[func]
    /// Returns a reference to the Timekeeper's gameplay flags.
    pub fn time_flags() -> Gd<TimekeeperFlags> {
        Timekeeper::singleton().bind().flags.clone()
    }

    #[func]
    /// Returns the current timescale. You don't need to use this for physics/world calculations,
    /// only for gameplay mechanics or effects that rely on knowing what the current timescale is.
    pub fn timescale() -> f64 {
        Timekeeper::singleton().bind().current_timescale
    }

    #[func]
    /// Returns the timescale target. You shouldn't need this.
    pub fn timescale_target() -> f64 {
        Timekeeper::singleton().bind().target_timescale
    }

    #[func]
    /// Messes up the internal time tracker a little bit. Just for funsies.
    pub fn hack_jump_timescale_to(new_timescale: f64) {
        let mut this = Timekeeper::singleton();
        let mut this = this.bind_mut();
        this.is_hacked = true;
        this.target_timescale = new_timescale;
        this.current_timescale = (this.current_timescale + new_timescale) / 2.0;
    }

    pub(crate) fn _internal_update(&mut self) {
        let time = self.dilated_time;
        let flags = self.flags.bind();

        let real_proc_delta = Self::real_process_delta();

        if flags.player_dashing {
            self.is_hacked = false;
            self.current_timescale = 0.125;
        } else {
            let mut calculated_target: f64 = if flags.player_moving { 1.0 } else { 0.25 };

            {
                let dash_diff = (0.5 - (time - flags.last_player_dash_time) * 4.0).clamp(0.0, 1.0);
                calculated_target += dash_diff;
                // godot_print!("dd = {dash_diff}");
            }

            self.target_timescale = calculated_target.min(1.0);
            // if self.is_hacked {
            // } else {
            //     self.target_timescale = calculated_target;
            // }

            // this math is kinda Wrong but idrc

            self.current_timescale = move_toward(
                self.current_timescale,
                self.target_timescale,
                if self.is_hacked {
                    real_proc_delta * 2.0
                } else {
                    real_proc_delta * 4.0
                },
            );
        }

        if self.current_timescale == self.target_timescale {
            self.is_hacked = false;
        }

        Engine::singleton().set_time_scale(self.current_timescale as f64);
        // godot_print!("delta = {real_proc_delta}, ts = {}", self.current_timescale);
        self.dilated_time += self.current_timescale * real_proc_delta;
    }
}
