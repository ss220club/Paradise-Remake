// Fur recipes
/obj/item/stack/sheet/fur/New(loc, amount=null)
	recipes = GLOB.fur_recipes
	..()

GLOBAL_LIST_INIT(fur_recipes, list(
	new /datum/stack_recipe_list("fur clothings", list(
		new /datum/stack_recipe("fur cap", /obj/item/clothing/head/furcap, 2),
		new /datum/stack_recipe("fur cape", /obj/item/clothing/suit/furcape, 3),
		new /datum/stack_recipe("fur coat", /obj/item/clothing/suit/furcoat, 3),
		new /datum/stack_recipe("fur gloves", /obj/item/clothing/gloves/furgloves, 3),
		new /datum/stack_recipe("fur boots", /obj/item/clothing/shoes/furboots, 2),
	)),
	null,
	new /datum/stack_recipe_list("fur carpets", list(
		new /datum/stack_recipe("red carpet", /obj/structure/fluff/carpet, 4),
		new /datum/stack_recipe("blue carpet", /obj/structure/fluff/carpet/blue, 4),
		new /datum/stack_recipe("yellow carpet", /obj/structure/fluff/carpet/yellow, 4),
		new /datum/stack_recipe("green carpet", /obj/structure/fluff/carpet/green, 4),
		null,
		new /datum/stack_recipe("small red carpet", /obj/structure/fluff/carpet/small, 3),
		new /datum/stack_recipe("small yellow carpet", /obj/structure/fluff/carpet/small/yellow, 3),
		new /datum/stack_recipe("small white carpet", /obj/structure/fluff/carpet/small/white, 3),
	)),
))
