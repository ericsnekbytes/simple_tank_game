extends Control

#var player_node = null
var endgame_stats = []
# ....
var fetch_game_stats_func = null


#func set_player(node):
	#player_node = node


func toggle_game_stats():
	if is_visible():
		# Already visible, player wants to hide stats
		hide()
	else:
		# Not yet visible, fetch and show stats
		fetch_and_show_stats()


func fetch_and_show_stats():
	var stats = fetch_game_stats_func.call()
	populate_game_stats(stats)
	show()


func init_player(node):
	node.died.connect(sync_stats)
	node.score_changed.connect(sync_stats)


func sync_stats():
	if is_visible():
		fetch_and_show_stats()


func populate_game_stats(stat_data):
	var headers = stat_data['headers']
	var player_data = stat_data['player_data']

	# Build a 2D array of player stats (do any post-processing
	# here, like [TODO] sorting, highlighting)
	var game_stats = []
	for player_id in player_data:
		var player_row = player_data[player_id]
		game_stats.append(player_row)

	var table_area = $MarginContainer/HBoxContainer/TableArea
	var table = $MarginContainer/HBoxContainer/TableArea/Table
	#var header = $EngameStats/TableArea/Table/HeaderRow
	#var info_row = $EngameStats/TableArea/Table/InfoRow

	# Remove all but header and top row
	for i in range(max(0, table.get_child_count() - 2)):
		table.get_child(2).hide()
		table.remove_child(table.get_child(2))

	# Populate headers
	var header_row = table.get_child(0)
	for i in range(headers.size()):
		var hdr = headers[i]

		if i == 0:
			# Remove all but first cell
			for k in range(max(0, header_row.get_child_count() - 1)):
				header_row.remove_child(header_row.get_child(1))

			var lbl = header_row.get_child(0).get_node("Label")
			lbl.set_text("")
			if hdr:
				lbl.set_text(hdr)
		else:
			var new_cell = header_row.get_child(0).duplicate()
			header_row.add_child(new_cell)
			var label = new_cell.get_node("Label")
			label.set_text("")
			if hdr != null:
				label.set_text("%s" % hdr)

	# Populate player stats
	for i in range(game_stats.size()):
		var player_stats = game_stats[i]

		if i != 0:
			# The first row is a template we duplicate for subsequent rows,
			# it already exists so we skip creation for that index here
			var new_row = table.get_child(1).duplicate()
			table.add_child(new_row)

		var row = table.get_child(i + 1)
		for ii in range(max(0, row.get_child_count() - 1)):
			# Remove all but first cell
			row.remove_child(row.get_child(1))

		# For each column, make cell if needed and populate
		for j in range(header_row.get_child_count()):
			var cell_val = player_stats[j]

			# First cell is a template cell for the row, populate it
			if j == 0:
				# Remove all but first cell
				for k in range(max(0, row.get_child_count() - 1)):
					row.remove_child(row.get_child(1))

				var cell = row.get_child(j)

				var label = cell.get_node("Label")
				label.set_text("")
				if cell_val != null:
					label.set_text("%s" % cell_val)
			else:  # We need to make a cell for subsequent columns
				var new_cell = row.get_child(0).duplicate()
				row.add_child(new_cell)

				var label = new_cell.get_node("Label")
				label.set_text("")
				if cell_val != null:
					label.set_text("%s" % cell_val)

		## Fetch and populate first cell, then add new cells for the rest
		#row.get_child(0).get_node("Label").set_text("%s" % pname)
		#if not row:
			#continue
		#for val in [points, deaths]:
			#var new_cell = row.get_child(0).duplicate()
			#row.add_child(new_cell)
			#var label = new_cell.get_node("Label")
			#label.set_text("")
			#if val != null:
				#label.set_text("%s" % val)

		#var cell = row.get_child(0)
		#var label = .get_node("Label")

	table_area.size.y = 40 * table.get_child_count()
