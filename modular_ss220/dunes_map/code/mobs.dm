// Спавнеры депредов
/obj/structure/spawner/desert_depretarors
	name = "спавнер депредов"
	desc = "страшное описание."
	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"

	faction = list("depredators")
	max_mobs = 2
	max_integrity = 300
	density = FALSE
	invisibility = 101
	mob_types = list(/mob/living/simple_animal/hostile/duna)

	spawn_time = 480 SECONDS

/obj/structure/spawner/desert_depretarors/range
	mob_types = list(/mob/living/simple_animal/hostile/duna/range)

/obj/structure/spawner/desert_depretarors/altar
	name = "пульсирующий маяк"
	desc = "Спиральный монолит из черного камня. В его высокотехнологичных вкраплениях, слово по жилам, протекает невиданная ранее энергия - продукт симбиоза блюспейса и редспейса. Кажется, он используется депредаторами как маяк навигации."
	icon = 'modular_ss220/dunes_map/icons/marker_normal.dmi'
	icon_state = "marker_depred"
	density = TRUE
	invisibility = 0
	spawn_time = 30 SECONDS
	layer = ABOVE_MOB_LAYER

	light_power = 2
	light_range = 3
	light_color = COLOR_VIOLET

/obj/structure/spawner/desert_depretarors/altar/range
	mob_types = list(/mob/living/simple_animal/hostile/duna/range)


// Снаряды депредов
/obj/item/projectile/beam/depredator
	name = "depredator beam"
	icon_state = "purple_laser"
	damage = 10

/obj/item/projectile/beam/depredator_laser
	name = "depredator laser"
	icon_state = "sniperlaser"
	damage = 9
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = COLOR_PURPLE

/obj/effect/projectile/muzzle/depredator
	icon_state = "muzzle_hcult"

/obj/effect/projectile/tracer/depredator
	name = "depredator beam"
	icon_state = "hcult"

/obj/effect/projectile/impact/depredator
	name = "depredator impact"
	icon_state = "impact_hcult"

/obj/item/projectile/beam/depredator/hitscan
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

// Депреды
/mob/living/simple_animal/hostile/duna
	var/list/alert_sounds
	var/alert_cooldown = 3 SECONDS
	var/alert_cooldown_time
	name = "депредатор"
	desc = "Высокое злобное существо, пришедшее из неизведанных глубин космоса. Тварь представляет из себя жуткое переплетение темно-фиолетовой плоти и бугристых пучков мышц. Они постоянно пульсируют, неустанно перегоняя под кожей бледные зеленоватые отсветы. Что бы это ни было - оно отвратительно."
	icon = 'modular_ss220/dunes_map/icons/mobs.dmi'
	icon_state = "osminogmeele"
	icon_living = "osminogmeele"
	icon_dead = "osminogmeele"
	maxbodytemp = INFINITY
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mob_size = MOB_SIZE_LARGE
	sentience_type = SENTIENCE_OTHER
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = 3500
	check_friendly_fire = TRUE
	a_intent = INTENT_HARM
	loot = list(/obj/effect/decal/cleanable/blood/gibs/xeno/down)
	faction = list("depredators")
	turns_per_move = 3
	move_to_delay = 2.8
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 150
	health = 150
	see_in_dark = 8
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 20
	attacktext = "разрывает"
	attack_sound = 'modular_ss220/mobs/sound/creatures/zombie_attack.ogg'
	rapid_melee = 2
	footstep_type = FOOTSTEP_MOB_SHOE
	alert_cooldown = 10 SECONDS
	alert_sounds = list(
		'modular_ss220/dunes_map/sound/mobs/dep1.ogg',
		'modular_ss220/dunes_map/sound/mobs/dep2.ogg',
		'modular_ss220/dunes_map/sound/mobs/dep3.ogg',
		'modular_ss220/dunes_map/sound/mobs/dep4.ogg',
		'modular_ss220/dunes_map/sound/mobs/dep5.ogg',
		'modular_ss220/dunes_map/sound/mobs/dep6.ogg',
	)
	layer = 4.49

/mob/living/simple_animal/hostile/duna/Initialize(mapload)
	. = ..()
	add_language("Sol Common")
	default_language = GLOB.all_languages["Sol Common"]

	speed = pick(-1.2, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5)

	var/list/meele_type= list("gold", "silver", "platinum")
	icon_state = "osminogmeele_[pick(meele_type)]"


/mob/living/simple_animal/hostile/duna/Aggro()
	if(!alert_sounds)
		return
	if(world.time > alert_cooldown_time)
		playsound(src, pick(alert_sounds), 200, ignore_walls = FALSE)
		alert_cooldown_time = world.time + alert_cooldown

/mob/living/simple_animal/hostile/duna/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/kazamon)


/mob/living/simple_animal/hostile/duna/range
	icon_state = "osminogrange_gold"
	var/list/range_type= list("gold", "silver", "platinum")
	projectiletype = /obj/item/projectile/beam/depredator/hitscan
	projectilesound = 'modular_ss220/aesthetics_sounds/sound/mobs/vortigaunt/attack_shoot4.ogg'
	ranged_cooldown_time = 2.5 SECONDS
	ranged = TRUE
	maxHealth = 120
	health = 120
	rapid = 2
	rapid_fire_delay = 1 SECONDS
	harm_intent_damage = 15
	melee_damage_lower = 10
	melee_damage_upper = 10
	retreat_distance = 8
	minimum_distance = 10
	aggro_vision_range = 10
	vision_range = 10

/mob/living/simple_animal/hostile/duna/range/Initialize(mapload)
	. = ..()

	var/list/range_type= list("gold", "silver", "platinum")
	icon_state = "osminogrange_[pick(range_type)]"

/mob/living/simple_animal/hostile/duna_tower
	name = "сторожевой маяк"
	desc = "Спиральный монолит из черного камня. В его высокотехнологичных вкраплениях, слово по жилам, протекает невиданная ранее энергия - продукт симбиоза блюспейса и редспейса. Кажется, он используется депредаторами как защитная установка."
	icon = 'modular_ss220/dunes_map/icons/marker_normal.dmi'
	icon_state = "marker_depred_range"
	icon_living = "marker_depred_range"
	icon_dead = "marker_depred_range"
	mob_biotypes = MOB_PLANT
	sentience_type = SENTIENCE_OTHER
	move_resist = INFINITY
	mob_size = MOB_SIZE_LARGE
	del_on_death = TRUE
	dodging = FALSE
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = 3500
	check_friendly_fire = TRUE
	a_intent = INTENT_HARM
	faction = list("depredators")
	turns_per_move = 0
	move_to_delay = 2.8
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 300
	health = 300
	see_in_dark = 8
	ranged_cooldown_time = 5 SECONDS
	ranged = TRUE
	rapid = 3
	rapid_fire_delay = 0.5 SECONDS
	harm_intent_damage = 0
	melee_damage_lower = 3
	melee_damage_upper = 5
	retreat_distance = 0
	minimum_distance = 20
	aggro_vision_range = 11
	vision_range = 15
	wander = FALSE
	stop_automated_movement = TRUE
	projectiletype = /obj/item/projectile/beam/depredator_laser
	projectilesound = 'sound/weapons/resonator_blast.ogg'
	anchored = TRUE

	light_power = 2
	light_range = 3
	light_color = COLOR_VIOLET

// Крокодил
/obj/structure/spawner/gator
	name = "спавнер аллигаторов"
	desc = "они умирают от бури."
	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"

	faction = list("hostile")
	max_mobs = 1
	max_integrity = 300
	density = FALSE
	invisibility = 101
	mob_types = list(/mob/living/simple_animal/hostile/lizard/gator/desert)

	spawn_time = 120 SECONDS
/mob/living/simple_animal/hostile/lizard/gator/desert
	del_on_death = TRUE
	butcher_results = null
	minbodytemp = INFINITY
	icon_state = "gator"
	icon_living = "gator"
	icon_dead = "gator_dead"

// ТАНЯ

/mob/living/simple_animal/hostile/retaliate/tanya_cc
	name = "Дельта 8-1-7"
	desc = "Боевой юнит-андроид проекта ''Delta 8-1-7'', идеально подходящий для выполнения любых поставленных задач. Судя по глазам, этот экземпляр находится на боевом дежурстве и действует автономно."
	icon =  'modular_ss220/dunes_map/icons/tanya_cc.dmi'
	icon_state = "tanya_cc"
	icon_living = "tanya_cc"
	icon_dead = "tanya_cc"
	faction = list("neutral")
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_OTHER
	turns_per_move = 3
	speed = -0.5
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 150
	health = 150
	harm_intent_damage = 15
	melee_damage_lower = 20
	melee_damage_upper = 25
	minbodytemp = 0
	maxbodytemp = 3500
	a_intent = INTENT_HARM
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = TRUE
	loot = list(/obj/effect/gibspawner/robot)
	dodging = TRUE
	rapid_melee = 2
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	footstep_type = FOOTSTEP_MOB_SHOE
	ranged = TRUE
	ranged_cooldown_time = 15
	rapid = 3
	retreat_distance = 8
	minimum_distance = 8
	casingtype = /obj/item/ammo_casing/a556
	projectilesound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	wander = FALSE

/mob/living/simple_animal/hostile/retaliate/tanya_cc/Initialize(mapload)
	. = ..()
	add_language("Galactic Common")
	default_language = GLOB.all_languages["Galactic Common"]

/mob/living/simple_animal/hostile/retaliate/tanya_cc/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/cerys)

/mob/living/simple_animal/hostile/retaliate/tanya_death   // Не от tanya_cc т.к. баллистические снаряды перезаписывают энергетические - разделить их никак нельзя
	name = "Дельта 8-1-7"
	desc = "Боевой юнит-андроид проекта ''Delta 8-1-7'', облаченный в тяжелую штурмовую броню. Судя по глазам, этот экземпляр находится на боевом дежурстве и действует автономно."
	icon =  'modular_ss220/dunes_map/icons/tanya_cc.dmi'
	icon_state = "tanya_cc_death"
	icon_living = "tanya_cc_death"
	icon_dead = "tanya_cc_death"
	faction = list("neutral")
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_OTHER
	turns_per_move = 3
	speed = -0.5
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	harm_intent_damage = 15
	melee_damage_lower = 20
	melee_damage_upper = 25
	minbodytemp = 0
	maxbodytemp = 3500
	a_intent = INTENT_HARM
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = TRUE
	loot = list(/obj/effect/gibspawner/robot)
	dodging = TRUE
	rapid_melee = 2
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	footstep_type = FOOTSTEP_MOB_SHOE
	ranged = TRUE
	ranged_cooldown_time = 15
	rapid = 1
	wander = FALSE
	maxHealth = 300
	health = 300
	retreat_distance = 8
	minimum_distance = 8
	projectiletype = /obj/item/projectile/beam/pulse
	projectilesound = 'sound/weapons/emitter2.ogg'

/mob/living/simple_animal/hostile/retaliate/tanya_death/Initialize(mapload)
	. = ..()
	add_language("Galactic Common")
	default_language = GLOB.all_languages["Galactic Common"]

/mob/living/simple_animal/hostile/retaliate/tanya_death/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/cerys)

// Скорпиончики

/mob/living/simple_animal/hostile/poison/giant_scorpio
	name = "гигантский скорпион"
	desc = "Огромная восьмилапая тварь, закованная в хитиновый панцырь. Этот выглядит особенно защищенным. Остерегайтесь его сильных клешней и смертоносного жала на хвосте!"
	icon = 'modular_ss220/dunes_map/icons/scorpio.dmi'
	icon_state = "yellow_scorpion"
	icon_living = "yellow_scorpion"
	icon_dead = "yellow_scorpion"
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	footstep_type = FOOTSTEP_MOB_CLAW
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	loot = list(/obj/effect/decal/cleanable/blood/gibs/xeno)
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 20
	minbodytemp = 0
	maxbodytemp = 600
	faction = list("scorpio")
	pass_flags = PASSTABLE
	move_to_delay = 6
	del_on_death = TRUE
	attacktext = "strikes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	gold_core_spawnable = HOSTILE_SPAWN
	var/venom_per_bite = 0
	unsuitable_atmos_damage = 0


/mob/living/simple_animal/hostile/poison/giant_scorpio/AttackingTarget()
	. = ..()
	if(. && venom_per_bite > 0 && iscarbon(target) && (!client || a_intent == INTENT_HARM))
		var/mob/living/carbon/C = target
		var/inject_target = pick("chest", "head")
		if(C.can_inject(null, FALSE, inject_target, FALSE))
			C.reagents.add_reagent("toxin", venom_per_bite)

/*
/mob/living/simple_animal/hostile/poison/giant_scorpio/AttackingTarget()
	. = ..()
	flick("scorpion_attack",src)
*/

/mob/living/simple_animal/hostile/poison/giant_scorpio/poison
	desc = "Огромная восьмилапая тварь, закованная в хитиновый панцырь. Этот кажется особенно ядовитым. Остерегайтесь его сильных клешней и смертоносного жала на хвосте!"
	icon_state = "scorpion"
	icon_living = "scorpion"
	icon_dead = "scorpion"
	maxHealth = 120
	health = 120
	maxbodytemp = 600
	venom_per_bite = 20
	melee_damage_lower = 10
	melee_damage_upper = 20
	move_to_delay = 5


/obj/structure/spawner/scorpio
	name = "вход в тоннель"
	desc = "Вам кажется, что на вас пялится 8 светящихся глаз."
	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"

	faction = list("scorpio")
	max_mobs = 2
	max_integrity = 500
	density = FALSE
	mob_types = list(/mob/living/simple_animal/hostile/poison/giant_scorpio)
	spawn_time = 120 SECONDS

/obj/structure/spawner/scorpio/poison
	mob_types = list(/mob/living/simple_animal/hostile/poison/giant_scorpio/poison)

/mob/living/simple_animal/hostile/poison_snake/scorpio_mini
	name = "скорпион"
	desc = "Небольшое проворливое членистоногое обитающие в засушливом климате. Для охоты и защиты использует жало с сильным нейропаралитическим ядом."
	icon = 'modular_ss220/dunes_map/icons/scorpio.dmi'
	icon_state = "y_scorpion_mini"
	icon_living = "y_scorpion_mini"
	icon_dead = "y_scorpion_mini"
	speak_emote = list("chitters")
	faction = list("scorpio")
	del_on_death = TRUE
	loot = list(/obj/effect/decal/cleanable/spiderling_remains)
	minbodytemp = 0
	maxbodytemp = INFINITY
	unsuitable_atmos_damage = 0

/mob/living/simple_animal/hostile/poison_snake/scorpio_mini/purpl
	icon_state = "scorpion_mini"
	icon_living = "scorpion_mini"
	icon_dead = "scorpion_mini"

/mob/living/simple_animal/cow/desert
	name = "Пустынная корова"
	desc = "Особо стойкая порода коров, способная выдерживать адские температуры."
	minbodytemp = 0
	maxbodytemp = INFINITY
	var/milk_capacity

/mob/living/simple_animal/hostile/raider_kidan
	name = "raider"
	desc = "Кидан-рейдер. Только не опять... Этот вооружен кинетическим топором. Массивный и устрашающий противник."
	icon = 'modular_ss220/dunes_map/icons/kidan.dmi'
	icon_state = "raider6"
	icon_living = "raider6"
	icon_dead = "raiderdead"
	mob_biotypes =  MOB_ORGANIC | MOB_HUMANOID
	sentience_type = SENTIENCE_OTHER
	speak_chance = 1
	speak_emote = list("жужжит", "стрекочет", "пищит","киданит")
	turns_per_move = 5
	speed = 0.5
	move_to_delay = 2.8
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	maxHealth = 250
	health = 250
	obj_damage = 10
	harm_intent_damage = 15
	melee_damage_lower = 15
	melee_damage_upper = 35
	del_on_death = FALSE
	dodging = TRUE
	attack_sound = 'sound/weapons/genhit1.ogg'
	attacktext = list("рубит", "крушит", "дробит", "разрубает")
	faction = list("kidan")
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = 3500
	wander = FALSE

/mob/living/simple_animal/hostile/raider_kidan/Initialize(mapload)
	. = ..()
	add_language("Kidan")
	default_language = GLOB.all_languages["Kidan"]

/mob/living/simple_animal/hostile/raider_kidan/add_tts_component()
	AddComponent(/datum/component/tts_component, /datum/tts_seed/silero/awilo)

/mob/living/simple_animal/hostile/raider_kidan/spear
	desc = "Кидан-рейдер. Только не опять... Этот вооружен киданским копьем. Крайне быстрый и юркий противник"
	icon_state = "raider5"
	icon_living = "raider5"
	speed = -0.2
	maxHealth = 180
	health = 180
	obj_damage = 2
	harm_intent_damage = 5
	melee_damage_lower = 13
	melee_damage_upper = 18
	rapid_melee = 2
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attacktext = list("укалывает", "протыкает", "ударяет", "вонзает")

/mob/living/simple_animal/hostile/raider_kidan/gun
	desc = "Кидан-рейдер. Только не опять... Этот вооружен мощной винтовкой."
	icon_state = "raider1"
	icon_living = "raider1"
	obj_damage = 2
	melee_damage_lower = 8
	melee_damage_upper = 8
	maxHealth = 220
	health = 220
	ranged = TRUE
	check_friendly_fire = TRUE
	dodging = TRUE
	retreat_distance = 8
	minimum_distance = 8
	casingtype = /obj/item/ammo_casing/s310
	projectilesound = 'modular_ss220/objects/sound/weapons/gunshots/shot_heavy.ogg'
	attack_sound = 'sound/weapons/genhit1.ogg'
	attacktext = "ударяет"

/mob/living/simple_animal/hostile/raider_kidan/gun/shotgun
	desc = "Кидан-рейдер. Только не опять... Этот вооружен обрезом дробовика."
	icon_state = "raider2"
	icon_living = "raider2"
	casingtype = /obj/item/ammo_casing/shotgun
	projectilesound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'

/mob/living/simple_animal/hostile/raider_kidan/gun/rifle
	desc = "Кидан-рейдер. Только не опять... Этот вооружен импровизированной винтовкой."
	icon_state = "raider4"
	icon_living = "raider4"
	casingtype = /obj/item/ammo_casing/a556
	projectilesound = 'sound/weapons/gunshots/gunshot_smg.ogg'

/mob/living/simple_animal/hostile/raider_kidan/laser
	desc = "Кидан-рейдер. Только не опять... Этот вооружен энерговинтовкой."
	icon_state = "raider3"
	icon_living = "raider3"
	obj_damage = 2
	melee_damage_lower = 8
	melee_damage_upper = 8
	maxHealth = 220
	health = 220
	ranged = TRUE
	check_friendly_fire = TRUE
	dodging = TRUE
	retreat_distance = 8
	minimum_distance = 8
	rapid = 2
	projectiletype = /obj/item/projectile/beam/laser
	projectilesound = 'sound/weapons/laser.ogg'
	attacktext = "ударяет"
