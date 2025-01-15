// MARK: Trees
/obj/structure/flora/tree/desert/joshua
	name = "yucca palm"
	icon = 'modular_ss220/objects/icons/flora/desert_tree.dmi'
	icon_state = "joshua1"

/obj/structure/flora/tree/desert/joshua/Initialize(mapload)
	. = ..()
	icon_state = "joshua[rand(1, 8)]"

/obj/structure/flora/tree/desert/dead
	name = "dead tree"
	icon = 'modular_ss220/objects/icons/flora/desert_tree.dmi'
	icon_state = "dead1"

/obj/structure/flora/tree/desert/dead/Initialize(mapload)
	. = ..()
	icon_state = "dead[rand(1, 6)]"

/obj/structure/flora/tree/desert/big
	name = "long dead tree"
	icon = 'modular_ss220/objects/icons/flora/desert_tree_big.dmi'
	icon_state = "dead_tree1"

/obj/structure/flora/tree/desert/big/Initialize(mapload)
	. = ..()
	icon_state = "dead_tree[rand(1, 4)]"

/obj/structure/flora/tree/desert/medpine
	icon = 'modular_ss220/objects/icons/flora/desert_tree.dmi'
	icon_state = "medpine"

/obj/structure/flora/tree/desert/african
	icon = 'modular_ss220/objects/icons/flora/desert_tree.dmi'
	icon_state = "african"

// MARK: Cactuses
/obj/structure/flora/tree/cactus
	name = "cactus"
	icon = 'modular_ss220/objects/icons/flora/cactus.dmi'
	icon_state = "cactus1"
	pixel_x = 0

/obj/structure/flora/tree/cactus/Initialize(mapload)
	. = ..()
	icon_state = "cactus[rand(1, 2)]"
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/structure/flora/tree/cactus/little
	icon_state = "little_cactus1"
	density = FALSE
	layer = BELOW_OBJ_LAYER

/obj/structure/flora/tree/cactus/little/Initialize(mapload)
	. = ..()
	icon_state = "little_cactus[rand(1, 6)]"

/obj/structure/flora/tree/cactus/circle
	icon_state = "circle_cactus1"
	density = FALSE
	layer = BELOW_OBJ_LAYER

/obj/structure/flora/tree/cactus/circle/Initialize(mapload)
	. = ..()
	icon_state = "circle_cactus[rand(1, 6)]"

/obj/structure/flora/tree/cactus/flat
	icon_state = "flat_cactus1"
	density = FALSE
	layer = BELOW_OBJ_LAYER

/obj/structure/flora/tree/cactus/flat/Initialize(mapload)
	. = ..()
	icon_state = "flat_cactus[rand(1, 3)]"
