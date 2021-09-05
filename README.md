# UntitledLirikGame
Game for lirik

All pull requests must be approved by starstorm

## Setup

Pull the code. It will be missing the following files.

```
default_env.tres
icon.png
icon.png.import
project.godot
```

You can get them by generating new project in Godot in any folder. After setting up a new project, take the files above and paste them into the `Untitled Game` folder. Once you do that you should be able to access the scenes in the project without any of the import paths being broken. 

## Other Important Info

### Set up Input Map

You need to setup input map in project to keep actions (keybinds) consistent. Heres how:

Open the project and click *Project* -> *Project Settings...* and then go to *Input Map*. Create the 5 actions with the names below.

```
move_left
move_right
move_up
move_down
side_swipe_attack
```

Once you create the actions, go the right of each action and click the Plus symbol to add and event. It does not matter what keybind you use, all that matters is that the name of the action is consistent.