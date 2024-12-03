/datum/modpack/dunes_map
	name = "Дюны"
	desc = "Особая карта использованная для ивента. Возможно используется в качестве гейта."
	author = "grombila, furior, aylong, dj-34"

/datum/modpack/dunes_map/pre_initialize()
	. = ..()

/datum/modpack/dunes_map/initialize()
	. = ..()

#define DESERT_SOUNDS_START list('modular_ss220/dunes_map/sound/music/welcometohell.ogg')

#define DESERT_SOUNDS list('modular_ss220/dunes_map/sound/music/desert1.ogg',\
	'modular_ss220/dunes_map/sound/music/desert2.ogg',\
	'modular_ss220/dunes_map/sound/music/desert3.ogg',\
	'modular_ss220/dunes_map/sound/music/desert4.ogg',\
	'modular_ss220/dunes_map/sound/music/desert5.ogg',\
	'modular_ss220/dunes_map/sound/music/desert6.ogg',\
	'modular_ss220/dunes_map/sound/music/desert7.ogg',\
	'modular_ss220/dunes_map/sound/music/desert8.ogg',\
	'modular_ss220/dunes_map/sound/music/desert9.ogg')

#define DESERT_SOUNDS_ROCK list('modular_ss220/dunes_map/sound/music/rock1.ogg',\
	'modular_ss220/dunes_map/sound/music/rock2.ogg',\
	'modular_ss220/dunes_map/sound/music/rock3.ogg')

#define DESERT_SOUNDS_VAULT list('modular_ss220/dunes_map/sound/music/vault1.ogg',\
	'modular_ss220/dunes_map/sound/music/vault2.ogg',\
	'modular_ss220/dunes_map/sound/music/vault3.ogg',\
	'modular_ss220/dunes_map/sound/music/vault4.ogg',\
	'modular_ss220/dunes_map/sound/music/vault5.ogg',\
	'modular_ss220/dunes_map/sound/music/vault6.ogg',\
	'modular_ss220/dunes_map/sound/music/vault7.ogg')

#define DESERT_SOUNDS_SECRET list('modular_ss220/dunes_map/sound/music/whatdowefound.ogg')

#define CC_IS_UNDER_ATTACK list('modular_ss220/dunes_map/sound/music/cc_attack.ogg',\
	'modular_ss220/dunes_map/sound/music/cc_attack2.ogg',\
	'modular_ss220/dunes_map/sound/music/cc_ship.ogg',\
	'modular_ss220/dunes_map/sound/music/cc_ship2.ogg')

/datum/modpack/dunes_map/post_initialize()
	. = ..()
