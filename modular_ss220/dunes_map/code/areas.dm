/area/awaymission/arrakis
	name = "\improper Пустыня"
	icon_state = "away"
	requires_power = FALSE
	has_gravity = TRUE
	always_unpowered = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	there_can_be_many = TRUE
	nad_allowed = TRUE
	min_ambience_cooldown = 3 MINUTES
	max_ambience_cooldown = 3 MINUTES

/area/awaymission/arrakis/outside_building
	name = "\improper Пустыня - Ангары"
	icon_state = "awaycontent18"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	requires_power = TRUE
	always_unpowered = FALSE
	ambientsounds = RUINS_SOUNDS
	min_ambience_cooldown = 5 MINUTES
	max_ambience_cooldown = 5 MINUTES

/area/awaymission/arrakis/outside_building/raider_base
	name = "\improper Пустыня - База рейдеров"
	icon_state = "awaycontent14"

/area/awaymission/arrakis/outside_building/abandoned_house
	name = "\improper Пустыня - Заброшенный дом"
	icon_state = "awaycontent13"

/area/awaymission/arrakis/outside_building/mining_storage_outpost
	name = "\improper Пустыня - Шахтёрский аванпост"
	icon_state = "awaycontent28"

/area/awaymission/arrakis/outside_building/hermit_shack
	name = "\improper Пустыня - Хижина отшельника"
	icon_state = "awaycontent30"

/area/awaymission/arrakis/outside
	name = "\improper Пустыня - Дюны"
	icon_state = "syndie-outside"
	ambientsounds = DESERT_SOUNDS

/area/awaymission/arrakis/outside/outside1
	name = "\improper Пустыня - Прибытие"
	icon_state = "awaycontent1"
	ambientsounds = DESERT_SOUNDS_START
	min_ambience_cooldown = 5 MINUTES
	max_ambience_cooldown = 5 MINUTES

/area/awaymission/arrakis/outside/outside2
	name = "\improper Пустыня - Дюны"
	icon_state = "awaycontent2"

/area/awaymission/arrakis/outside/outside3
	name = "\improper Пустыня - Дюны"
	icon_state = "awaycontent3"

/area/awaymission/arrakis/outside/outside4
	name = "\improper Пустыня - Дюны"
	icon_state = "awaycontent4"

/area/awaymission/arrakis/outside/outside5
	name = "\improper Пустыня - Дюны"
	icon_state = "awaycontent5"

/area/awaymission/arrakis/outside/outside6
	name = "\improper Пустыня - Дюны"
	icon_state = "awaycontent6"

/area/awaymission/arrakis/outside/outside7
	name = "\improper Пустыня - Дюны"
	icon_state = "awaycontent7"

/area/awaymission/arrakis/outside/mining_town
	name = "\improper Пустыня - Шахтёрский городок"
	icon_state = "awaycontent8"

/area/awaymission/arrakis/outside/shuttle
	name = "\improper Пустыня - Шаттл"
	icon_state = "unknown"

/area/awaymission/arrakis/outside/syndi_shuttle
	name = "\improper Пустыня - Шаттл Синдиката"
	icon_state = "unknown"

/area/awaymission/arrakis/cave
	name = "\improper Пустыня - Скалы"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	icon_state = "space_near"
	ambientsounds = DESERT_SOUNDS_ROCK

/area/awaymission/arrakis/cave/cave
	name = "\improper Пустыня - Пещера"

/area/awaymission/arrakis/cave/cave1
	name = "\improper Пустыня - Здание"
	requires_power = TRUE
	always_unpowered = FALSE

/area/awaymission/arrakis/cave/cave2
	name = "\improper Пустыня - Храм"
	requires_power = FALSE
	always_unpowered = FALSE

/area/awaymission/arrakis/bunker
	name = "\improper Пустыня - Вход в бункер"
	icon = 'modular_ss220/dunes_map/icons/areas.dmi'
	icon_state = "desert_entry"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = TRUE
	always_unpowered = FALSE
	ambientsounds = DESERT_SOUNDS_VAULT

/area/awaymission/arrakis/bunker/hallway
	name = "\improper Бункер - Холл"
	icon_state = "desert_hall"

/area/awaymission/arrakis/bunker/brig
	name = "\improper Бункер - Охрана"
	icon_state = "desert_brig"

/area/awaymission/arrakis/bunker/brig/bsa
	name = "\improper Бункер - ???"
	requires_power = FALSE

/area/awaymission/arrakis/bunker/engie
	name = "\improper Бункер - Инженерия"
	icon_state = "desert_engie"

/area/awaymission/arrakis/bunker/hydro
	name = "\improper Бункер - Гидропоника"
	icon_state = "desert_hydro"

/area/awaymission/arrakis/bunker/rnd
	name = "\improper Бункер - Отдел исследований"
	icon_state = "desert_science"

/area/awaymission/arrakis/bunker/medbay
	name = "\improper Бункер - Больница"
	icon_state = "desert_medbay"

/area/awaymission/arrakis/bunker/kitchen
	name = "\improper Бункер - Кухня"
	icon_state = "desert_kitchen"

/area/awaymission/arrakis/bunker/bar
	name = "\improper Бункер - Бар"
	icon_state = "desert_bar"

/area/awaymission/arrakis/bunker/clowns
	name = "\improper Бункер - Театр"
	icon_state = "desert_theatre"

/area/awaymission/arrakis/bunker/janitor
	name = "\improper Бункер - Уборщик"
	icon_state = "desert_janitor"

/area/awaymission/arrakis/bunker/bridge
	name = "\improper Бункер - Мостик"
	icon_state = "desert_bridge"

/area/awaymission/arrakis/bunker/dorms
	name = "\improper Бункер - Дормы"
	icon = 'icons/turf/areas.dmi'
	icon_state = "dorms"

/area/awaymission/arrakis/bunker/cryo
	name = "\improper Бункер - Крио"
	icon = 'icons/turf/areas.dmi'
	icon_state = "Sleep"
	lightswitch = FALSE

/area/awaymission/arrakis/bunker/cryo/second

/area/awaymission/arrakis/bunker/bedrooms
	name = "\improper Бункер - Спальни"
	icon = 'icons/turf/areas.dmi'
	icon_state = "dorms"

/area/awaymission/arrakis/bunker/storage
	name = "\improper Бункер - Хранилище"
	icon = 'icons/turf/areas.dmi'
	icon_state = "dorms"

/area/awaymission/arrakis/bunker/tanya_cyborg_blyat_lab
	name = "\improper Бункер - ???"
	icon = 'icons/turf/areas.dmi'
	icon_state = "purple"
	ambientsounds = DESERT_SOUNDS_SECRET

/area/awaymission/arrakis/bunker/normandy_mi_v_shkafu_pryachemsya
	name = "\improper Бункер - Офис Центрального Командования"
	icon = 'icons/turf/areas.dmi'
	icon_state = "green"

/area/centcom/ss220
	name = "\improper ЦК"
	icon_state = "centcom"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	nad_allowed = TRUE
	ambientsounds = CC_IS_UNDER_ATTACK
	min_ambience_cooldown = 3 MINUTES
	max_ambience_cooldown = 3 MINUTES
