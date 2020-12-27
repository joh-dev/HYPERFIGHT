# HYPERFIGHT
2D one-hit fighting game, made with Godot 3.2 and GodotSteam.

## Building
### With Steam integration 
Use GodotSteam for Godot 3.2 (https://github.com/Gramps/GodotSteam) and follow the instructions.

### Without Steam integration
You can use normal Godot 3.2. You will also need to:
- Set "steam_enabled" to false in scripts/global.gd
- Enable Steam as a Singleton in Project -> Project Settings -> AutoLoad

**Note:** Building without Steam integration will disable online multiplayer.
