# Changelog

All notable changes to Tank Bar Helper will be documented in this file.

## [v1.1.0] - 2025-08-25

### Added
- **Threat Indicator** - Real-time threat tracking with color-coded visual feedback (#1)
  - Horizontal threat bar below main health/shield bars
  - Shows threat percentage (0-100%)
  - Dynamic color coding (Blue: tanking, Orange: high threat, Yellow: medium, Red: low)
  - Pulsing animations when threat is unstable
  
- **Off-tank Health Bars** - Automatic detection and display of other tanks (#2)
  - Shows smaller health and shield bars for off-tanks
  - Displays tank name and health percentage
  - Color changes based on off-tank health level
  - Can be toggled on/off in settings
  
- **Boss Ability Prediction** - Integration with DBM/BigWigs (#3)
  - Shows incoming tank buster abilities with countdown timer
  - Displays expected damage amount
  - Color-coded warnings based on time and damage severity
  - Database of common tank buster abilities
  
- **Interface Options Integration**
  - Added to WoW system menu (ESC → Options → Addons)
  - Native settings panel with all configuration options
  - Real-time updates without reload

### Changed
- Improved configuration panel with more options
- Enhanced visual feedback for low health situations

### Fixed
- Text display properly shows below bars
- Skull animation only affects icon, not bars

## [v1.0.0] - 2025-08-24

### Added
- Initial release
- Core health and absorb tracking
- Percentage markers at 10%, 20%, and 30%
- Smooth animations
- Damage projection based on 5-second history
- Configuration system with slash commands
- Visual effects (glow, pulse, skull warning)