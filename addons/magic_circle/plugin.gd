@tool
extends EditorPlugin

## Magic Circle v2.0 — Plugin Entry
## Manim-inspired 2D shape drawing and animation plugin for Godot 4.
##
## This plugin provides a library of classes:
##   MagicScene, MagicMobject, CircleMobject, StarMobject, etc.
##   MagicAnimation, TransformAnimation, FadeInAnimation, etc.
##
## No autoload singleton is needed — users extend MagicScene directly.
## Enable the plugin in Project Settings > Plugins, then:
##   1. Create a new scene with a root node extending MagicScene
##   2. Override construct() to build your content
##   3. Use add(), play(), wait() to orchestrate animations

func _enter_tree() -> void:
	print("✓ Magic Circle v2.0-alpha — Manim-inspired animation plugin enabled")
	print("   Create a scene with root node of type: MagicScene")
	print("   Override construct() and use: add(), play(), wait()")

func _exit_tree() -> void:
	print("✓ Magic Circle plugin disabled")

func _get_plugin_name() -> String:
	return "Magic Circle"

func _get_plugin_icon() -> Texture2D:
	return null
