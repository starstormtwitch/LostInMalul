extends BlendTreeAnimationHandler


class_name Level2BlendTreeAnimationHandler

func _init(animationTree: AnimationTree).(animationTree):
	_animationTree = animationTree

func punch1():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 0)
	_animationTree.set("parameters/Combo1/current", 0)


func punch2():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 0)
	_animationTree.set("parameters/Combo1/current", 1)


func kick1():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 1)
	_animationTree.set("parameters/Combo2/current", 0)


func shoryuken():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 1)
	_animationTree.set("parameters/Combo2/current", 2)


func startHadouken():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 2)
	_animationTree.set("parameters/Special/current", 0)


func chargeHadouken():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 2)
	_animationTree.set("parameters/Special/current", 1)


func releaseHadouken():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 2)
	_animationTree.set("parameters/Special/current", 2)

