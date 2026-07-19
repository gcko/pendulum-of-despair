class_name ZoneResolver
extends RefCounted
## Resolves an overworld tile coordinate to an encounter zone_id using an
## ordered rect table (first match wins). Zone priority in overlap bands
## is encoded by list order — geography.md § Region Boundaries: "in
## overlap zones, the Thornmere region takes priority".
##
## Table entries: {"zone_id": String, "rects": [[x1, y1, x2, y2], ...]}
## with an optional "flag" key gating the entry on EventFlags (used for
## act-gated zones such as the Act III Pallor Wastes approach).
## Rect bounds are inclusive tile coordinates.


## Returns the zone_id of the first entry whose rect contains [param tile],
## or "" when no entry matches (unclassified tile).
static func resolve(tile: Vector2i, zone_map: Array) -> String:
	for entry: Variant in zone_map:
		if not entry is Dictionary:
			continue
		var entry_dict: Dictionary = entry as Dictionary
		var flag: String = entry_dict.get("flag", "")
		if not flag.is_empty() and not EventFlags.check_required_flags(flag):
			continue
		for rect: Variant in entry_dict.get("rects", []):
			if (
				rect is Array
				and (rect as Array).size() == 4
				and _rect_contains(rect as Array, tile)
			):
				return entry_dict.get("zone_id", "")
	return ""


## Find the encounter entry whose [param id_key] equals [param zone_id].
## Returns {} when absent — callers must not fall back to entries[0].
static func find_entry(zone_id: String, entries: Array, id_key: String) -> Dictionary:
	for entry: Variant in entries:
		if entry is Dictionary and (entry as Dictionary).get(id_key, "") == zone_id:
			return entry as Dictionary
	return {}


## Build the encounter setup for a freshly loaded map from its
## encounters-file content: the entry list, the id key that selects
## entries ("zone_id" for zone maps, "floor_id" for floors maps), and
## the initially active config (floor_id-meta match, falling back to
## the first entry for legacy floor configs). use_zones tells the
## caller whether a per-tile zone map may apply — floors maps must not
## get one, since floor_id entries can never match resolved zone ids.
static func build_encounter_setup(encounters: Dictionary, floor_id: String) -> Dictionary:
	var setup: Dictionary = {"entries": [], "id_key": "floor_id", "config": {}, "use_zones": false}
	if encounters.is_empty():
		return setup
	var use_zones: bool = encounters.has("zones") and not encounters.has("floors")
	var entries: Array = encounters.get("floors", encounters.get("zones", []))
	setup.use_zones = use_zones
	setup.entries = entries
	setup.id_key = "zone_id" if use_zones else "floor_id"
	setup.config = find_entry(floor_id, entries, setup.id_key)
	if setup.config.is_empty() and not floor_id.is_empty() and not entries.is_empty():
		if entries[0] is Dictionary:
			setup.config = entries[0]
	return setup


static func _rect_contains(rect: Array, tile: Vector2i) -> bool:
	return (
		tile.x >= int(rect[0])
		and tile.y >= int(rect[1])
		and tile.x <= int(rect[2])
		and tile.y <= int(rect[3])
	)
