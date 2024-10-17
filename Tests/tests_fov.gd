extends "res://addons/gut/test.gd"

var player = null
var sectarian = null

func setup():
    # Create a new player node
    player = Node2D.new()
    player.add_to_group("player")

    # Create a new sectarian node and add the script to it
    sectarian = Node2D.new()
    var script = load("res://path/to/sectarian.gd")
    sectarian.set_script(script)

    # Add the nodes to the scene
    get_tree().get_root().add_child(player)
    get_tree().get_root().add_child(sectarian)

func teardown():
    # Remove the nodes from the scene
    get_tree().get_root().remove_child(player)
    get_tree().get_root().remove_child(sectarian)

    # Free the nodes
    player.queue_free()
    sectarian.queue_free()

func test_is_player_in_range():
    # Test when the player is not in range
    player.global_position = Vector2(1000, 1000)
    assert_false(sectarian.is_player_in_range(player), "Player should not be in range")

    # Test when the player is in range
    player.global_position = Vector2(0, 0)
    assert_true(sectarian.is_player_in_range(player), "Player should be in range")