@tool
extends EditorPlugin

# Godot Shape Drawer 插件入口
# 负责插件的生命周期管理

const AUTOLOAD_NAME = "ShapeDrawer"
const AUTOLOAD_PATH = "res://addons/magic_circle/shape_drawer.gd"

func _enter_tree():
	# 添加自动加载单例
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	print("✓ ShapeDrawer插件已启用")
	print("  使用 ShapeDrawer.create_shape() 创建形状")
	print("  查看文档了解更多功能")

func _exit_tree():
	# 移除自动加载单例
	remove_autoload_singleton(AUTOLOAD_NAME)
	print("✓ ShapeDrawer插件已禁用")

func _get_plugin_name():
	return "Shape Drawer"

func _get_plugin_icon():
	# 可以返回自定义图标
	return null
