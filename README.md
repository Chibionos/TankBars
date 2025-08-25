# Tank Bar Helper

[![GitHub release](https://img.shields.io/github/v/release/Chibionos/TankBars)](https://github.com/Chibionos/TankBars/releases)
[![CurseForge](https://img.shields.io/badge/CurseForge-Download-orange)](https://www.curseforge.com/wow/addons/tank-bar-helper)
[![License](https://img.shields.io/github/license/Chibionos/TankBars)](LICENSE)

A clean and satisfying World of Warcraft addon for tanks that displays health and absorb shields in a vertical bar format with advanced tank-specific features.

## Features

### Core Features
- **Vertical Health Bar**: Clean vertical display of your health
- **Absorb Shield Tracking**: Visual representation of all absorb shields with numbers
- **Percentage Markers**: Visual markers at 10%, 20%, and 30% health thresholds
- **Damage Projection**: Shows predicted incoming damage based on recent history
- **Smooth Animations**: Satisfying smooth transitions for health and shield changes

### Advanced Tank Features
- **Threat Indicator**: Real-time threat monitoring with color-coded bar
- **Off-Tank Display**: Automatic detection and display of other tanks in your group
- **Boss Ability Prediction**: Integration with DBM/BigWigs for incoming damage warnings
- **Low Health Warning**: Pulsing red glow and skull icon when health drops below threshold

## Installation

### CurseForge Client (Recommended)
1. Search for "Tank Bar Helper" in the CurseForge client
2. Click Install

### Manual Installation
1. Download the latest release from [Releases](https://github.com/Chibionos/TankBars/releases)
2. Extract the `TankBarHelper` folder
3. Copy it to your WoW addons directory:
   - **Retail**: `World of Warcraft\_retail_\Interface\AddOns\`
   - **Classic**: `World of Warcraft\_classic_\Interface\AddOns\`
4. Restart WoW or type `/reload` if already in-game

## Configuration

### Interface Options
Access the configuration through:
- **System Menu**: ESC → Options → Addons → Tank Bar Helper
- **Slash Command**: `/tbh config`

### Quick Commands
- `/tbh` or `/tankbar` - Show help menu
- `/tbh lock` - Lock the frame position
- `/tbh unlock` - Unlock to move the frame
- `/tbh reset` - Reset all settings to default

## Screenshots

![Tank Bar Helper Main Display](screenshots/main.png)
*Main health and shield bars with threat indicator*

![Boss Ability Warning](screenshots/boss-ability.png)
*Boss ability prediction with damage warning*

## Development

### Building from Source
```bash
git clone https://github.com/Chibionos/TankBars.git
cd TankBars
# The TankBarHelper folder contains the addon
```

### Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

### Release Process
This addon uses GitHub Actions for automated releases to:
- GitHub Releases
- CurseForge
- Wago.io (optional)

Releases are triggered by pushing version tags (e.g., `v1.1.0`).

## Support

For issues, suggestions, or questions:
- [Open an issue](https://github.com/Chibionos/TankBars/issues)
- Contact in-game: DarthChibi

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the WoW addon community for inspiration
- BigWigsMods for the packaging tools
- All contributors and testers

## Version History

See [CHANGELOG.md](CHANGELOG.md) for a detailed version history.