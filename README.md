# HYPERFIGHT
2D one-hit fighting game, made with Godot 3.2 and GodotSteam.

## Building
**Please read README.txt in resources/font/raw for more information about downloading the default fonts, as they are not included!**
### With Steam integration 
Use GodotSteam for Godot 3.2 (https://github.com/Gramps/GodotSteam) and follow the instructions.

### Without Steam integration
You can use normal Godot 3.2. You will also need to:
- Set "steam_enabled" to false in scripts/global.gd
- Enable Steam as a Singleton in Project -> Project Settings -> AutoLoad

**Note:** Building without Steam integration will disable online multiplayer.

## Tips
- Any builds with the same version number ("VERSION" in scripts/global.gd) will see the same lobbies, so use a custom version number to prevent conflicts.
