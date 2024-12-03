//DUMMIES

/obj/item/projectile/beam/depredator/dummy
	damage = 0

/obj/item/projectile/beam/laser/heavylaser/dummy
	damage = 0

/obj/item/projectile/beam/depredator/dummy/hitscan
	color = LIGHT_COLOR_PURPLE
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/depredator
	tracer_type = /obj/effect/projectile/tracer/depredator
	impact_type = /obj/effect/projectile/impact/depredator
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_range = 0.75
	hitscan_light_color_override = LIGHT_COLOR_PURPLE
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = LIGHT_COLOR_PURPLE
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = LIGHT_COLOR_PURPLE

/obj/machinery/power/emitter/dummy_depred
	name = "depredator turret"
	desc = "скрытный депредатор незаметно стрелять трурль спецэффекты 220"
	projectile_type = /obj/item/projectile/beam/depredator/dummy/hitscan
	projectile_sound = 'modular_ss220/aesthetics_sounds/sound/mobs/vortigaunt/attack_shoot4.ogg'

/obj/machinery/power/emitter/dummy_depred/Initialize(mapload)
	. = ..()
	invisibility = 101
	active = 1
	powered = TRUE
	active_power_consumption = 0
	state = 2
	fire_delay = 150
	maximum_fire_delay = 700
	minimum_fire_delay = 20

/obj/machinery/power/emitter/dummy_laser
	name = "turret"
	desc = "незаметный стрелять лазер эффекты взрыв кино сс220"
	projectile_type = /obj/item/projectile/beam/laser/heavylaser/dummy
	projectile_sound = 'sound/weapons/lasercannonfire.ogg'
	invisibility = 101
	powered = TRUE
	active = 1
	active_power_consumption = 0
	state = 2
	fire_delay = 150
	maximum_fire_delay = 500
	minimum_fire_delay = 40

/obj/machinery/power/emitter/dummy_laser/Initialize(mapload)
	. = ..()
	invisibility = 101
	active = 1
	powered = TRUE
	active_power_consumption = 0
	state = 2
	fire_delay = 150
	maximum_fire_delay = 100
	minimum_fire_delay = 50

/obj/machinery/porta_turret/syndicate/dummy
	name = "система защиты АКН"
	icon_state = "target_prism"
	icon_state_initial = "target_prism"
	icon_state_active = "target_prism"
	icon_state_destroyed = "destroyed_target_prism"
	faction = list("neutral")
	lethal = TRUE
	name = "Heavy Defence Turret"
	max_integrity = 120
	projectile = /obj/item/projectile/beam/laser/heavylaser
	eprojectile = /obj/item/projectile/beam/laser/heavylaser
	shot_sound = 'sound/weapons/lasercannonfire.ogg'
	eshot_sound = 'sound/weapons/lasercannonfire.ogg'
	reqpower = FALSE

/mob/living/carbon/human/dummy/target
	name = ""
	desc = ""
	alpha = 0
	opacity = TRUE
	density = TRUE
	faction = "syndicate"
