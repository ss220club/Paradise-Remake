/area/shuttle/elevator
	name = "Snowdwin elevator"
	icon_state = "shuttle"

/obj/machinery/computer/shuttle/elevator
	name = "elevator console"
	shuttleId = "elevator"
	possible_destinations = "elevator_up;elevator_down"
	resistance_flags = INDESTRUCTIBLE
	flags = NODECONSTRUCT
	circuit = /obj/item/circuitboard/shuttle/elevator

/obj/item/circuitboard/shuttle/elevator
	board_name = "Elevator"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle/elevator
