extends Node2D

func _ready():
	# 创建一个旋转的星星
	var star = ShapeDrawer.create_shape(
		Vector2(400, 300),              # 位置
		ShapeInstance.ShapeType.STAR,   # 形状
		60.0,                           # 大小
		Color.GOLD                      # 颜色
	)
	
	# 添加无限旋转动画
	star.rotate_by(TAU, 2.0).set_loops(-1)
