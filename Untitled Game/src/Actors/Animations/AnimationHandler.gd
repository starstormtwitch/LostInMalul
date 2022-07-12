extends Node


class_name AnimationHandler
# Interface to call different animations. Made so that we can call animatins
# for enemies and player, who now use different animtion tree types. 
# Implement all function in inhereting classes

func die():
	pass 

func hurt():
	pass

