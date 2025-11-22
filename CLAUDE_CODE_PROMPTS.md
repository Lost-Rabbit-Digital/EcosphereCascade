# Claude Code Prompts for Ecosphere Cascade Implementation

This document contains specific Claude Code prompts to implement the game design document for the $3 Steam release. Prompts are organized by development priority and should be executed in order.

---

## Phase 1: Architecture Refactor (Week 1)

### Prompt 1.1: Analyze Current Architecture and Create Refactor Plan
```
Analyze the current architecture of Ecosphere Cascade, focusing on main.gd which contains 475 lines of mixed concerns. Create a detailed refactoring plan that:

1. Identifies all responsibilities currently in main.gd
2. Proposes a clean architecture with separation of concerns
3. Suggests the following systems:
   - GameManager (game state, level loading, transitions)
   - ScoreManager (scoring, combos, persistence)
   - AudioManager (centralized audio control)
   - LevelData (level definitions as resources)
   - UI manager for scene transitions
4. Create a diagram showing the new architecture
5. Provide a step-by-step migration plan that won't break existing functionality

Do NOT implement yet, just create the plan and get my approval first.
```

### Prompt 1.2: Create Core Manager Scripts
```
Based on the approved refactoring plan, create the following manager scripts in the scripts/ directory:

1. game_manager.gd - Singleton for game state management
   - Level progression tracking
   - Current level state
   - Scene transition handling
   - Pause/resume functionality

2. score_manager.gd - Singleton for scoring system
   - Score calculation with combo multipliers
   - High score tracking per level
   - Save/load scores to user:// directory as JSON
   - 3-star rating calculation based on score thresholds

3. audio_manager.gd - Singleton for audio control
   - Centralized audio playback
   - Volume control from settings
   - Music/SFX toggle state
   - Sound pooling for frequently played effects

4. level_data.gd - Resource class for level definitions
   - Seed peg positions
   - Obstacle positions and types
   - Star score thresholds
   - Background theme
   - Difficulty metadata

Ensure all managers use proper Godot autoload/singleton pattern. Include comprehensive comments explaining each method.
```

### Prompt 1.3: Refactor main.gd to Use New Architecture
```
Refactor main.gd (the main game scene script) to use the new manager systems:

1. Remove all scoring logic - delegate to ScoreManager
2. Remove all audio setup - delegate to AudioManager
3. Remove level generation logic - load from LevelData resources
4. Keep only game-specific logic:
   - Shooting mechanics
   - Trajectory prediction
   - Physics interactions
   - Visual updates (background transformation)
5. Reduce main.gd to under 250 lines

Ensure the game still functions identically after refactoring. Test that:
- Shooting still works
- Scoring and combos still work
- Audio still plays
- Level can be reset with R key
```

### Prompt 1.4: Create Level Data Resources
```
Create a level data resource system:

1. Create res://resources/levels/ directory
2. Create LevelData.gd as a custom Resource class with:
   - export var level_name: String
   - export var level_number: int
   - export var seed_peg_positions: Array[Vector2]
   - export var rock_positions: Array[Vector2]
   - export var vertical_rock_positions: Array[Vector2]
   - export var star_thresholds: Vector3i (1-star, 2-star, 3-star scores)
   - export var shots_allowed: int = 10
   - export var background_theme: String = "default"

3. Create tutorial_level_01.tres as the first level resource
4. Update main.gd to load and apply level data from resources
5. Create a level loader that instantiates obstacles from the level data

This will make creating 12 levels much easier.
```

---

## Phase 2: Level System Implementation (Weeks 2-3)

### Prompt 2.1: Create Level Selection Screen
```
Create a level selection screen (res://scenes/LevelSelectMenu.tscn):

1. Grid layout showing levels 1-12
2. Each level shows:
   - Level number
   - Lock icon if not unlocked
   - Star rating (0-3 stars) if completed
   - High score if completed
3. Clicking unlocked level loads that level
4. Back button returns to main menu
5. Responsive layout that looks good at 1920x1080

Style should match the existing main menu aesthetic. Use Godot Control nodes for layout.
```

### Prompt 2.2: Implement Level Progression System
```
Implement level unlock progression in GameManager:

1. Track which levels are unlocked (save to user://save_data.json)
2. Level 1 is always unlocked
3. Beating a level unlocks the next level
4. Create save/load system using JSON:
   - unlocked_levels: Array[int]
   - level_scores: Dictionary (level_id -> high_score)
   - level_stars: Dictionary (level_id -> stars)
5. Auto-save after each level completion
6. Add "Continue" option to main menu that goes to highest unlocked level

Ensure save data persists between game sessions.
```

### Prompt 2.3: Design 12 Level Layouts
```
Create 12 level data resources (tutorial + 11 progression levels):

**Guidelines:**
- Levels 1-2: Tutorial (few obstacles, easy shots, low star thresholds)
- Levels 3-5: Easy (moderate obstacles, some bounces required)
- Levels 6-9: Medium (tight spaces, rotating obstacles, combo emphasis)
- Levels 10-12: Hard (many obstacles, precise shots needed, high skill)

For each level, define:
1. Seed peg positions (10 pegs per level)
2. Rock obstacle positions (increase from 5 to 30 across levels)
3. Vertical rock positions (increase from 5 to 20)
4. Star thresholds based on testing
5. Save as level_01.tres through level_12.tres

Be creative with layouts - create satisfying shot opportunities and challenging configurations.
```

### Prompt 2.4: Create Level Complete Screen
```
Create a level complete screen (res://scenes/LevelCompleteScreen.tscn):

1. Display after winning a level:
   - "Level Complete!" header
   - Final score with animation counting up
   - Stars earned (1-3) with satisfying reveal animation
   - High score indicator if beaten
   - Buttons: "Next Level", "Retry", "Level Select"

2. Add celebration effects:
   - Particle effects (confetti/flowers)
   - Victory sound effect
   - Star award sounds (one per star)

3. Update GameManager to show this screen on level completion
4. Trigger save data update with new score/stars

Make it feel rewarding and encourage progression to next level.
```

---

## Phase 3: Visual & Audio Polish (Week 4)

### Prompt 3.1: Implement Hit Effects and Score Popups
```
Add satisfying visual feedback for hitting pegs and obstacles:

1. When water drop hits a seed peg:
   - Glow effect around the peg (use modulate or shader)
   - Particle burst (water splash + sparkles)
   - Score popup showing points earned (floating text that rises and fades)
   - Combo multiplier shown if combo > 1

2. When hitting rocks:
   - Impact particles (rock dust)
   - Screen shake (subtle, 2-3 pixels)
   - Erosion visual feedback

3. When hitting vertical rocks:
   - Spin faster temporarily
   - Impact sound with pitch variation
   - Small particle effect

Use Godot's built-in particle systems and tweens for performance. Keep effects lightweight for low-end hardware.
```

### Prompt 3.2: Implement Tree Growth and Combo Animations
```
Improve tree growth and combo visual feedback:

1. Tree Growth Animation:
   - Instead of instant appearance, tween the tree scale from 0 to 1 over 0.5 seconds
   - Add green particle sparkles during growth
   - Play growth sound effect
   - Slight bounce at end of animation (scale 1.1 -> 1.0)

2. Combo Visual Feedback:
   - Screen flash on high combos (3+)
   - Combo counter gets bigger/more colorful with higher combos
   - Particle trail following water drop during combo chains
   - Rainbow effect across screen on 5+ combo

3. Background transformation should be more gradual:
   - Smooth interpolation as each tree grows
   - Add ambient particles (butterflies, pollen) as environment improves

Make it feel magical and rewarding to restore the environment.
```

### Prompt 3.3: Add Missing Sound Effects
```
Implement all missing sound effects (you may need to find free/CC0 sounds or generate them):

1. Shooting sound:
   - Water "whoosh" when firing crossbow
   - Slightly different pitch each time for variety

2. Impact sounds:
   - Water drop hitting peg (soft splash)
   - Water drop hitting rock (harder impact)
   - Water drop hitting vertical rock (metallic clink)

3. UI sounds:
   - Button hover (subtle tick)
   - Button click (satisfying click)
   - Level unlock sound
   - Star award sound (3 variations for each star)

4. Tree growth sound:
   - Magical chime or nature sound

5. Level complete jingle (5-7 seconds, upbeat)

Integrate with AudioManager. Ensure all sounds respect volume settings. Provide recommendations for where to find appropriate CC0 audio if needed.
```

### Prompt 3.4: Implement Pause Menu
```
Create a pause menu that appears when pressing ESC:

1. Dim/blur the game background
2. Show pause menu with buttons:
   - Resume
   - Restart Level
   - Settings (quick access to audio controls)
   - Level Select
   - Main Menu

3. Pause game physics and timers when active
4. ESC toggles pause on/off
5. Menu should be centered and styled consistently

Ensure pausing works correctly:
- Water drops freeze in place
- Timers stop
- Audio can still be adjusted
- Resume continues exactly where left off
```

---

## Phase 4: UI Improvements (Week 5)

### Prompt 4.1: Improve In-Game UI Layout
```
Redesign the in-game UI for better clarity and visual appeal:

1. Top-left corner:
   - Level number and name
   - Current score (larger, more prominent)
   - High score indicator (smaller, below)

2. Top-right corner:
   - Stars earned so far (0-3 filled stars)
   - Next star threshold

3. Left side:
   - Visual water drop icons for shots remaining (not just text)
   - Deduct icons as shots are used
   - Warning animation when <4 shots left

4. Top-center:
   - Combo counter (only visible during combo)
   - Larger, more animated

5. Bottom-left:
   - Menu/pause button

Use themed UI sprites and make everything readable at 1080p. Consider adding a subtle background panel for better contrast.
```

### Prompt 4.2: Polish Main Menu and Settings
```
Improve the main menu and settings screens:

1. Main Menu enhancements:
   - Add game logo/title art at top
   - Animated background (subtle particle effects)
   - "Continue" button that goes to highest unlocked level
   - Show total game completion percentage
   - Credits button (can be simple)

2. Settings Menu improvements:
   - Clearer labels for all controls
   - Volume sliders (not just toggles) for Music and SFX
   - Fullscreen toggle
   - Test buttons to preview volume levels
   - Apply/Save button that persists settings

3. How to Play improvements:
   - Show controller diagram
   - Explain combo system clearly
   - Explain star rating system
   - Maybe add a simple interactive tutorial

Make everything use consistent fonts, colors, and spacing.
```

### Prompt 4.3: Add Transition Effects Between Scenes
```
Add smooth transitions between all scenes to improve polish:

1. Fade to black transition (0.3 seconds) when changing scenes
2. Use ColorRect with AnimationPlayer
3. Create a singleton SceneTransition manager with methods:
   - change_scene_with_fade(scene_path: String)
   - fade_out() -> await signal
   - fade_in() -> await signal

4. Apply to all scene changes:
   - Main menu -> Level select
   - Level select -> Game
   - Game -> Level complete
   - Pause menu -> Level select/Main menu

Transitions should feel snappy but not jarring. Add loading indicator if needed for larger scenes.
```

### Prompt 4.4: Implement Game Over Screen Improvements
```
Improve the game over/loss screen to be more polished:

1. Replace the current simple label with a proper scene
2. Show:
   - "Out of Shots!" or "Level Failed" message
   - Final score
   - How close to next star threshold
   - Best shot of the attempt (highest single shot score)

3. Options:
   - Retry Level (prominent)
   - Level Select
   - Main Menu

4. Add "encouragement" messages:
   - "Almost there! Try again?"
   - "So close to the next star!"
   - Random tips about game mechanics

Make failure feel less punishing and encourage another attempt.
```

---

## Phase 5: Optional Polish Features (Week 6)

### Prompt 5.1: Implement Bucket Bonus System
```
Implement the bucket bonus system from playtesting feedback:

1. Add 5 buckets at bottom of screen (just above screen edge):
   - Far left/right: 10,000 points (green)
   - Mid left/right: 50,000 points (blue)
   - Center: 100,000 points (gold)

2. When water drop falls below screen:
   - Detect which bucket it lands in
   - Award bonus points with flashy animation
   - Particle effects shooting from bucket
   - Sound effect pitched based on bucket value

3. Make buckets visible but not distracting:
   - Semi-transparent when not active
   - Glow/pulse when ball is approaching
   - Celebration animation when ball lands

4. Show "Bucket Bonus!" popup with points awarded

This adds luck-based rewards and excitement to missed shots.
```

### Prompt 5.2: Implement Free Ball Mechanics
```
Add free ball reward mechanics:

1. 50% chance for free shot on total miss:
   - If water drop hits zero pegs
   - Show "Lucky Break!" message
   - Restore one shot
   - Play encouraging sound effect

2. Free shot for 25,000+ point single shot:
   - Track points earned per shot
   - If single shot exceeds threshold
   - Show "Amazing Shot! Bonus Ball!" message
   - Add one shot to remaining count
   - Celebratory particle effects

3. Visual indicators:
   - Flash the shots remaining counter
   - Special particle effect around crossbow
   - Distinct sound effect

This rewards skillful play and softens punishment for mistakes.
```

### Prompt 5.3: Add Longshot Bonus
```
Implement bonus points for impressive long-distance shots:

1. Track water drop travel distance:
   - Calculate horizontal distance traveled from launch point
   - If > 70% of screen width (1344 pixels)
   - Award "Longshot Bonus!" (5000 points)

2. Visual feedback:
   - Show trajectory trail in special color for longshots
   - "Longshot!" popup when bonus awarded
   - Additional particles on impact

3. Track longshot stats:
   - Show total longshots on level complete screen
   - Consider special achievement for many longshots

This encourages creative shot angles and exploration.
```

### Prompt 5.4: Add Floating Score Accumulation
```
Implement satisfying score accumulation at end of each shot:

1. When water drop expires/leaves screen:
   - Collect all points earned during that shot
   - Display "Shot Score" in center of screen
   - Show breakdown:
     - Base peg points
     - Combo multiplier bonus
     - Bucket bonus (if applicable)
     - Special bonuses
   - Total shot score in large text

2. Animate score transfer to main score:
   - Tween score from center to top-left
   - Count up main score with number animation
   - Satisfying sound effect

3. Brief pause (0.5 seconds) to let player appreciate the score

This is a core part of Peggle-like satisfaction and should feel very rewarding.
```

---

## Phase 6: Save System & Persistence (Days 1-3)

### Prompt 6.1: Implement Comprehensive Save System
```
Create a robust save/load system using JSON:

1. Save data structure in res://scripts/save_data.gd:
```gdscript
class_name SaveData

var unlocked_levels: Array[int] = [1]  # Level 1 always unlocked
var level_high_scores: Dictionary = {}  # level_id -> int
var level_stars: Dictionary = {}  # level_id -> int (0-3)
var total_score: int = 0
var settings: Dictionary = {
    "music_volume": 0.8,
    "sfx_volume": 0.8,
    "fullscreen": false
}
var stats: Dictionary = {
    "total_shots_fired": 0,
    "total_trees_grown": 0,
    "total_combos": 0,
    "max_combo": 0,
    "total_playtime": 0.0
}
```

2. Save to user://save_data.json
3. Auto-save after each level completion
4. Manual save when settings change
5. Load on game start
6. Handle corrupted save files gracefully (reset to defaults)

Include error handling and backup saves.
```

### Prompt 6.2: Add Statistics Tracking
```
Implement stat tracking throughout the game:

1. Track during gameplay:
   - Total shots fired (increment on each shot)
   - Total trees grown (increment per seed peg hit)
   - Total combos achieved
   - Highest combo reached
   - Total playtime (track in GameManager._process)

2. Save stats with save data
3. Create a stats screen accessible from main menu:
   - Display all tracked statistics
   - Interesting facts ("You've grown X trees!")
   - Completion percentage
   - Total stars earned

4. Consider adding more interesting stats:
   - Most used shot angle
   - Favorite level (most replayed)
   - Longest shot distance

This gives players a sense of progression and accomplishment.
```

---

## Phase 7: Testing & Bug Fixes (Week 7)

### Prompt 7.1: Create Debug Tools
```
Create debug tools for easier testing and balancing:

1. Debug menu (toggle with F12):
   - Unlock all levels
   - Set score to specific value
   - Add shots
   - Skip to any level
   - Reset save data
   - Show performance stats (FPS, memory)
   - Toggle collision debug draw

2. Cheat codes for testing:
   - Ctrl+W: Win current level
   - Ctrl+S: Add 5 shots
   - Ctrl+L: Load next level
   - Ctrl+R: Reset save data

3. Level editor features (if time permits):
   - Click to place seed pegs
   - Click to place obstacles
   - Save layout to level resource
   - Test layout immediately

Debug features should be disabled in release builds.
```

### Prompt 7.2: Performance Optimization Pass
```
Optimize the game for low-end hardware (target: 60 FPS on 3-year-old laptops):

1. Profile the game to find bottlenecks:
   - Use Godot's built-in profiler
   - Identify expensive _process calls
   - Check for memory leaks

2. Common optimizations:
   - Object pooling for frequently spawned nodes (particles, score popups)
   - Limit active particle systems
   - Use CanvasItem.hide() for off-screen elements
   - Optimize trajectory line calculation (fewer points)
   - Cache frequently accessed nodes

3. Settings for low-end hardware:
   - Particle quality setting (high/medium/low)
   - Reduce visual effects option
   - FPS limiter option

4. Test on lower-spec hardware if possible

Ensure the game runs smoothly on target hardware.
```

### Prompt 7.3: Bug Fixing and Edge Case Handling
```
Identify and fix bugs and edge cases:

1. Test edge cases:
   - What if water drop gets stuck?
   - What if player spams shoot button?
   - What if save file is corrupted?
   - What if player resizes window mid-game?
   - What if player pauses during animations?

2. Known issues to address:
   - Water drops sometimes get stuck in geometry
   - Combo timer edge cases
   - Score overflow on very high combos
   - Audio overlap/crackling on many simultaneous sounds

3. Add timeout for stuck water drops:
   - If drop velocity < threshold for 2 seconds
   - Auto-remove and continue game
   - Show "Ball Stuck - Removed" message

4. Input validation:
   - Prevent double-clicks
   - Debounce menu buttons
   - Handle rapid scene transitions

Create a testing checklist and systematically verify each system.
```

### Prompt 7.4: Balance Testing and Difficulty Tuning
```
Test and balance the 12 levels for appropriate difficulty curve:

1. Playtest each level multiple times:
   - Track completion rate
   - Track average score
   - Track shots used
   - Note frustrating moments

2. Adjust based on data:
   - If level too hard: reduce obstacles or add easier seed pegs
   - If level too easy: tighten peg spacing or add obstacles
   - Ensure star thresholds feel achievable but challenging

3. Combo balance:
   - Ensure levels allow for combos (pegs not too far apart)
   - Combo timeout of 3 seconds feels right?
   - Combo multiplier too powerful/weak?

4. Shot count balance:
   - 10 shots per level appropriate?
   - Some levels need more/fewer?

5. Bucket bonuses:
   - Are bonuses too generous?
   - Do they encourage skillful shots or random luck?

Get external playtesters if possible. Iterate based on feedback.
```

---

## Phase 8: Steam Preparation (Days 1-2)

### Prompt 8.1: Create Steam Store Assets
```
I need to create Steam store page assets. Please help me:

1. List all required assets for Steam store page:
   - Capsule images (sizes needed)
   - Header image
   - Screenshots (how many, what to show)
   - Trailer/gameplay video (optional but recommended)
   - Game logo

2. Screenshot guidance:
   - Which levels/moments to capture
   - How to compose exciting screenshots
   - UI elements to show/hide

3. Marketing copy suggestions:
   - Short description (hook potential players)
   - Long description (detailed feature list)
   - Key features bullet points
   - Tags for Steam store

4. Create a STEAM_ASSETS_CHECKLIST.md with all requirements

Note: I'll need to create actual assets myself or hire an artist, but guide me on specifications and best practices.
```

### Prompt 8.2: Prepare Build Pipeline
```
Set up the Godot export pipeline for Steam release:

1. Configure export presets:
   - Windows 64-bit (primary)
   - Linux 64-bit (if supporting)
   - Proper executable names
   - Icon setup
   - Embedded PCK

2. Create build script (build.sh or build.bat):
   - Automated export for all platforms
   - Version numbering
   - Compression settings
   - Output to builds/ directory

3. Create release checklist:
   - Disable debug features
   - Remove console prints
   - Verify all levels included
   - Test exported build thoroughly
   - Verify save system works in exported build

4. Prepare for Steam integration:
   - Steamworks SDK placeholder (for future)
   - Achievement system hooks (for future updates)

Ensure exported builds work identically to editor version.
```

---

## Quality of Life Improvements (Ongoing)

### Prompt QOL.1: Add Accessibility Features
```
Implement basic accessibility features:

1. Colorblind support:
   - Option for colorblind-friendly palette
   - Don't rely solely on color for important info
   - Consider colorblind testing tools

2. Text scaling:
   - Option to increase UI text size
   - Ensure all text remains readable

3. Audio accessibility:
   - Separate volume for music vs SFX
   - Visual indicators for audio cues
   - Subtitles/captions for any voiced content

4. Input accessibility:
   - Adjustable aiming sensitivity
   - Option to pause mid-shot
   - Key rebinding (if time permits)

5. Difficulty accessibility:
   - "Relaxed mode" with unlimited shots
   - Option to skip difficult levels

Even small accessibility improvements can expand your audience significantly.
```

### Prompt QOL.2: Add Keyboard Shortcuts and Quality Improvements
```
Add convenient keyboard shortcuts and small quality improvements:

1. Keyboard shortcuts:
   - ESC: Pause/back
   - Space: Shoot (alternative to click)
   - R: Restart level (already implemented)
   - 1-3: Quick restart with different camera angles?
   - Tab: Show high scores overlay
   - F11: Toggle fullscreen

2. Quality improvements:
   - Show trajectory line while paused
   - Zoom in/out with mouse wheel (subtle)
   - Double-click to quick-restart
   - "Next level" auto-advances after 3 seconds (with option to disable)
   - Show remaining shots needed to unlock next star

3. Tooltips:
   - Hover over UI elements to show helpful tips
   - Explain what each obstacle does
   - First-time player hints

These small touches make the game feel more polished and player-friendly.
```

---

## Code Quality & Maintenance Prompts

### Prompt CODE.1: Add Comprehensive Code Documentation
```
Add comprehensive documentation to all scripts:

1. File headers with:
   - Purpose of the script
   - Main responsibilities
   - Key dependencies

2. Function documentation:
   - What the function does
   - Parameters and their types
   - Return value
   - Side effects

3. Complex logic comments:
   - Explain "why" not "what"
   - Document tricky algorithms
   - Note performance considerations

4. Create ARCHITECTURE.md:
   - Explain the overall code structure
   - Document the singleton pattern usage
   - Explain the scene hierarchy
   - Data flow diagrams

Good documentation helps with maintenance and future updates.
```

### Prompt CODE.2: Set Up Unit Tests
```
Create basic unit tests for core systems (if time permits):

1. Test ScoreManager:
   - Combo calculation
   - Score thresholds
   - Save/load functionality

2. Test SaveData:
   - Serialization/deserialization
   - Corrupted data handling
   - Migration from old save versions

3. Test LevelData:
   - Validation of level configurations
   - Ensure all required data present

4. Use GUT (Godot Unit Testing) framework
5. Create test suite in tests/ directory
6. Add to build pipeline (run tests before export)

Unit tests catch regressions and make refactoring safer.
```

---

## Final Polish Pass

### Prompt FINAL.1: Complete Final Polish Pass
```
Do a complete final polish pass before release:

1. Playthrough test:
   - Play all 12 levels start to finish
   - Verify progression works correctly
   - Check all UI transitions
   - Test all menu options

2. Audio polish:
   - Verify no audio cutting/crackling
   - Check volume balance between music and SFX
   - Ensure audio respects settings

3. Visual polish:
   - Verify all animations smooth
   - Check for visual glitches
   - Ensure consistent art style
   - Verify particles don't overlap weirdly

4. Text polish:
   - Proofread all text for typos
   - Ensure consistent capitalization
   - Check for grammar issues
   - Verify text fits in all UI elements

5. Create final pre-launch checklist

Ship only when you're proud of the quality!
```

---

## Usage Instructions

1. **Execute prompts in order** - Each phase builds on previous work
2. **Test thoroughly** after each prompt before moving to the next
3. **Adjust based on results** - If something doesn't work well, iterate
4. **Skip optional features** if time-constrained - Focus on core quality
5. **Get feedback early** - Playtest with others during Phase 3-4
6. **Don't rush** - Quality over speed for a $3 game with good reviews

## Estimated Time per Phase

- Phase 1 (Architecture): ~40 hours
- Phase 2 (Levels): ~60 hours
- Phase 3 (Polish): ~30 hours
- Phase 4 (UI): ~30 hours
- Phase 5 (Optional): ~30 hours
- Phase 6 (Save): ~15 hours
- Phase 7 (Testing): ~35 hours
- Phase 8 (Steam): ~10 hours

**Total: ~250 hours (6-7 weeks at 40 hours/week)**

## Notes on Using These Prompts with Claude Code

- Each prompt is designed to be self-contained and actionable
- Claude Code should be able to implement each prompt with minimal clarification
- Always review generated code before committing
- Test thoroughly after each major change
- Don't hesitate to ask Claude to revise or improve solutions
- Use version control - commit after each successful prompt implementation

Good luck with development! 🌳
