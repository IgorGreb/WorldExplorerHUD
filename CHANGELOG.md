# Changelog

## 0.7.0
- **Settings panel** (Game Menu → Options → AddOns → World Explorer HUD, or `/we`), built on `Settings.RegisterCanvasLayoutCategory` with a fallback for older clients. All slash commands still work.
- **Minimap button** via LibDataBroker + LibDBIcon (built-in fallback button when LibDBIcon is not available). Left-click: Explorer's Journal, right-click: settings, Shift-click: show/hide HUD.
- **Explorer's Journal** (`/we journal`): every zone grouped by continent with progress bars, account/character scope, "hide unvisited", click a zone to open it on the world map.
- **Discovery toasts** for new areas, secrets and fully explored zones (with zone progress). Toasts, sound and chat messages can be toggled separately.
- **Share custom pins** (`/we share`): export/import as a single checksummed string; Shift+Right-Click deletes a custom pin on the map.
- Pin names are sanitized (no UI escape codes).
- Tooling: luacheck, offline test suite, GitHub Actions CI and BigWigs packager releases.

## 0.6.0
- Map pins rendered through HereBeDragons-Pins (proper map layer, zoom scaling, only on their own zone map).
- New minimap pins for undiscovered points; the tracked target floats on the minimap edge.
- Distances use real zone sizes from HereBeDragons.

## 0.5.0
- Zones are identified by uiMapID (works with any client language); old saved data is migrated.
- Exploration percentage counts only database discovery points; quest totals only where real quest IDs exist.
- Unmarking a point in character scope no longer erases other characters' progress; tracking a secret finishes automatically.
