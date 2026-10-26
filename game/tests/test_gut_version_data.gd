extends GutTest
## Guards the vendored GUT's own version data against the engine it runs on (#452).
##
## Every GUT run ends by asking res://addons/gut/versions.json which GUT release
## suits the running Godot, and prints "GUT <x> is now available!" when the
## answer differs from the installed GUT. The data shipped in a GUT release tag
## can cap below the engine this project targets — 9.7.0 and 9.7.1 both cap at
## Godot 4.7.999 — and then the answer is the placeholder 0.0.0, so every run on
## 4.8 advertised a release that does not exist. The fix is to vendor upstream's
## published data (bitwes/Gut main, which raises 9.7.x to 4.99). Re-vendoring a
## release tag over it brings the bogus notice back, and this test is what says so.
##
## Only the vendored file is read, never the user:// cache GUT's editor panel
## downloads, so the verdict is the same on every machine and in CI. That is the
## local half of what the end-of-run notice consults; the cache can only differ
## on a machine where someone has opened the GUT editor panel.


func _recommended_gut_for_running_engine() -> String:
	var detector: Node = GutUtils.UpdateDetector.new()
	detector.local_data.parse_file(detector.LOCAL_FILE_PATH)
	var recommended: String = detector.local_data.get_gut_version_for_godot_version(
		GutUtils.godot_version_string()
	)
	detector.free()
	return recommended


func test_vendored_version_data_recommends_the_installed_gut_for_this_engine() -> void:
	var installed: String = GutUtils.version_numbers.gut_version
	var recommended: String = _recommended_gut_for_running_engine()
	assert_eq(
		recommended,
		installed,
		(
			(
				"res://addons/gut/versions.json recommends GUT %s for Godot %s but %s is"
				+ " installed, so every run ends with a 'GUT %s is now available!' notice."
				+ " 0.0.0 means the data caps below this engine: take addons/gut/versions.json"
				+ " from bitwes/Gut main at a named SHA (see godot-tooling-updates)."
				+ " Any other version means a newer GUT really exists: bump GUT."
			)
			% [recommended, GutUtils.godot_version_string(), installed, recommended]
		)
	)
