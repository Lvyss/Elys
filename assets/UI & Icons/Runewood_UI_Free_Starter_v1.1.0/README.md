# Runewood UI — Free Starter Pack v1.1.0

A fantasy game interface starter: 17 transparent PNG files, plus an interactive browser preview. The free pack is useful on its own and is designed as the foundation for a possible future expansion.

## Included artwork

- Two panels: menu and dialogue.
- Wide and square buttons, each with matching normal and pressed states.
- An inventory slot, health track and separate red health fill.
- Eight icons: heart, coin, sword, shield, potion, backpack, settings and close.

The full-size files are in `assets/`; ready-to-use smaller copies with the same file names are in `game_256/` (longest side 256 px) and `game_128/` (128 px); open `index.html` in a modern browser to explore the included artwork. The sample text, layout, health slider and interaction logic are examples. Inventory slots have an opaque dark interior. The PNGs have transparent exteriors and are provided at their original derivative resolutions; use proportional scaling. Nine-slice behavior has not been tested. There are no animations, fonts or engine-specific prefabs.

## Placement

The preview places the health fill inside the track at 8% left and 12% top, at 84% of track width and 75% of track height; its visible width is clipped against the fill artwork bounds to represent health. It uses square-button icons at 60% of the button canvas and inventory icons at 56% of the slot canvas. These are starting points, not universal engine settings. Inspect text size, touch targets and appearance in your game. The preview uses 72-pixel square controls; small icons can lose detail below this size.

## Source and processing

Artwork was generated with ChatGPT in Chrome. Transparent derivative PNGs were cleaned by removing pixels with alpha at or below 5 and adding a transparent margin. Button states were aligned, and the pressed faces were composited onto the normal-state frames to reduce frame movement. Generated source files and detailed provenance remain in the creator's asset library. AI-generated artwork is included.

## License

MIT License; see `LICENSE.txt` for the full terms. You may use and adapt the assets in personal and commercial projects under that license.

## Changelog

- 1.1.0: Added `game_256/` and `game_128/` with all 17 PNGs resized for in-game use (same names, transparent). The full-size `assets/` and the preview are unchanged.
- 1.0.0: Initial free starter pack. Local browser-preview checks cover responsive layout and the supplied controls. Physical-device and game-engine integration have not been tested.
