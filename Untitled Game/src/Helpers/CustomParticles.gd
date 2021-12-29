extends Particles2D

class_name CustomParticles

func flipSide(flip: bool):
	if flip:
		self.scale = Vector2(-1, 1)
	else:
		self.scale = Vector2(1, 1)
