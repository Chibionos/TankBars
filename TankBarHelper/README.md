# Tank Bar Helper

A clean and satisfying World of Warcraft addon for tanks that displays health and absorb shields in a vertical bar format with percentage markers.

## Features

- **Vertical Health Bar**: Clean vertical display of your health
- **Absorb Shield Tracking**: Visual representation of all absorb shields with numbers
- **Percentage Markers**: Visual markers at 10%, 20%, and 30% health thresholds
- **Empty Absorb Indicator**: Shows when you have no absorb shields active
- **Smooth Animations**: Satisfying smooth transitions for health and shield changes
- **Low Health Warning**: Pulsing red glow when health drops below 30%
- **Damage Pulse Effect**: Visual feedback when taking damage
- **Fully Customizable**: Adjust size, colors, position, and effects

## Installation

1. Download the `TankBarHelper` folder
2. Copy it to your WoW addons directory:
   - **Retail**: `World of Warcraft\_retail_\Interface\AddOns\`
   - **Classic**: `World of Warcraft\_classic_\Interface\AddOns\`
3. Restart WoW or type `/reload` if already in-game
4. The addon will appear automatically when you log in

## Usage

### Basic Commands

- `/tbh` or `/tankbar` - Show help menu
- `/tbh config` - Open configuration panel
- `/tbh lock` - Lock the frame position
- `/tbh unlock` - Unlock to move the frame (drag with mouse)
- `/tbh reset` - Reset all settings to default

### Quick Settings

- `/tbh scale [0.5-2.0]` - Adjust overall scale
- `/tbh width [20-100]` - Set bar width
- `/tbh height [100-500]` - Set bar height
- `/tbh numbers on/off` - Toggle number display
- `/tbh smooth on/off` - Toggle smooth animations
- `/tbh glow on/off` - Toggle low health glow
- `/tbh pulse on/off` - Toggle damage pulse effect
- `/tbh empty on/off` - Toggle empty absorb indicator

## Configuration Panel

Type `/tbh config` to open the graphical configuration panel where you can:

- Adjust all visual settings with sliders
- Change colors for health, absorb, and background
- Toggle various effects and features
- Lock/unlock frame position

## Positioning

1. Type `/tbh unlock` to enable positioning mode
2. Click and drag the bar to your desired location
3. Type `/tbh lock` when satisfied with the position

## Visual Indicators

- **Green Bar**: Your current health
- **Blue Overlay**: Active absorb shields
- **Yellow Markers**: 20% and 30% health thresholds
- **Red Marker**: Critical 10% health threshold
- **Red Glow**: Activates below 30% health
- **Gray Shield**: Shows when no absorb is active

## Tips for Tanks

- Position the bar near your character or focus target for easy monitoring
- The percentage markers help you quickly identify when to use defensive cooldowns
- The empty absorb indicator helps you know when shields have expired
- Adjust the size to your preference - larger for visibility or smaller for less clutter

## Troubleshooting

- If the addon doesn't appear, check that it's enabled in the AddOns menu at character select
- Use `/tbh reset` if settings become corrupted
- The frame saves position per character

## Version History

### v1.0.0
- Initial release
- Core health and absorb tracking
- Percentage markers
- Configuration system
- Visual effects and animations

## Author

Created by DarthChibi

## Support

For issues or suggestions, please contact the author in-game or through the addon's repository.