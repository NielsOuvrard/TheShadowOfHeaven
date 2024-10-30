# Contributing Guidelines

Thank you for considering contributing to the project.
This document outlines the guidelines for contributing to the project, including the types of assets accepted, and the quality standards to follow.

All our arts are in pixel art style, and we have specific requirements for each type of asset.

## Sprite Design Rules

1. **Maintain Consistent Dimensions**  
   Ensure all sprites share consistent dimensions (width and height) for similar types (e.g., all characters of the same type should be 64x64 pixels). This simplifies programming and reduces the risk of misalignment.

2. **Arrange Sprites Left to Right in Sheets**  
   When creating sprite sheets, arrange sprites from left to right and, if necessary, from top to bottom. This order is crucial for animations, as it aligns with how the game engine processes frames.

3. **Do Not Duplicate Sprites**  
   Avoid placing identical sprites multiple times within a sheet. If a repeated animation frame is needed, programmers can reference the same frame to save memory and space.

4. **Center Sprites Horizontally (X-axis)**  
   Align sprites in the center along the X-axis to ensure characters, objects, and animations are balanced and consistent in gameplay.

5. **Align Sprites at the Bottom for Characters (Y-axis)**  
   For characters, align them to the bottom of the frame on the Y-axis. This alignment helps in making sure that characters appear to stand on the ground correctly within the game world.

6. **Consistent Pivot Point (or Anchor)**  
   Keep the pivot point (or anchor point) consistent across all frames. Usually, it is set at the center-bottom of the sprite for characters or at the center for round objects or items.

7. **Transparent Background**  
   Make sure that the background of each sprite is fully transparent. This avoids any visible artifacts in the game and makes the sprite blend well with the game environment.

8. **Naming Convention**  
   Use a clear and consistent naming convention, in PascalCase, in english, for all sprites. This makes it easier for developers to identify and reference the sprites in the game code.
   For example, `Doors.png`, `Demon.png`, `Items.png`, etc.

9. **Consistent Color Palette**  
   Keep a consistent color palette across all sprites. This avoids visual discrepancies and maintains a uniform style throughout the game.

10. **Use png Format for Sprites**  
    Save sprites in the PNG format to preserve transparency and quality. This format is widely supported and is ideal for game development.

## Additional Information

1. **If needed, provide a `.txt` data file**  
   If additional information is needed (e.g., pivot points, timing for each frame, order of each frame), provide a `.txt` file with clear documentation for each sprite or animation sequence.

2. **Use Sprite Sheets for Animations**
   For animations, use sprite sheets instead of individual frames. This optimizes memory usage and improves performance during gameplay.

## In our case

1. **Character, Background Sprites**

   - Dimensions: 16x16 pixels
   - Pivot Point: Center-bottom

2. **Item Sprites**
   - Dimensions: 16x16 pixels
   - Pivot Point: Center
