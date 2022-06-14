extends AnimationHandler


class_name NodeStateMachineAnimationHandler

var _animationTree: AnimationTree

func _init(animationTree: AnimationTree):
	_animationTree = animationTree

func die():
	_animationTree.get("parameters/playback").travel("die")

func hurt():
	_animationTree.get("parameters/playback").travel("Hurt")

