extends AnimationHandler


class_name BlendTreeAnimationHandler

var _animationTree: AnimationTree


func _init(animationTree: AnimationTree):
	_animationTree = animationTree


func die():
	_animationTree.set("parameters/Main/current", 2)


func hurt():
	_animationTree.set("parameters/Main/current", 1)


func idle():
	_animationTree.set("parameters/Main/current", 0)
	_animationTree.set("parameters/Movement/current", 0)


func walk():
	_animationTree.set("parameters/Main/current", 0)
	_animationTree.set("parameters/Movement/current", 1)


func punch1():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 0)
	_animationTree.set("parameters/Combo1/current", 0)


func punch2():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 0)
	_animationTree.set("parameters/Combo1/current", 1)


func headbutt():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 0)
	_animationTree.set("parameters/Combo1/current", 2)


func kick1():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 1)
	_animationTree.set("parameters/Combo2/current", 0)


func kick2():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 1)
	_animationTree.set("parameters/Combo2/current", 1)


func shoryuken():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 1)
	_animationTree.set("parameters/Combo2/current", 2)


func chargeHadouken():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 2)
	_animationTree.set("parameters/Special/current", 0)


func releaseHadouken():
	_animationTree.set("parameters/Main/current", 3)
	_animationTree.set("parameters/Attack/current", 2)
	_animationTree.set("parameters/Special/current", 1)
	
