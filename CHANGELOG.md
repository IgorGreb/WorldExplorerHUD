# Changelog

## 0.7.2
- **Fixed:** hovering the HUD widget (and `/we quests`) could throw a Lua error ("attempt to compare string with number"). The addon saved a quest's XP reward as its title; quest titles are now read from the game client, and the bad entries already saved are cleaned up automatically.
- **Fixed:** a custom pin with the same name as a map discovery point (added with `/we addpin` or imported) could mark that discovery point as explored. Such pins now get a " *" suffix (e.g. "Goldshire *"); existing ones are renamed once.
- Tooltip label now reads "Other Areas (not in database)" instead of showing a stray "%".
- Ukrainian text fixes (Stromgarde secret descriptions).
- Saved data schema 3: upgraded automatically on first login, nothing to do.
- Supported game client: English. The addon interface is available in English and Ukrainian (`/we lang`).

## 0.7.1
- Added LICENSE (All Rights Reserved; bundled libraries keep their own licenses).
- Packaged builds now include the license file.
- Documentation: CurseForge description (English + Ukrainian).

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
