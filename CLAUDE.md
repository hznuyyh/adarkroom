# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Dark Room — a minimalist text adventure browser game. Pure vanilla JavaScript (no build step, no bundler, no modules/bundler). Scripts are loaded via `<script>` tags in `index.html` in a specific dependency order. Licensed under MPL-2.0.

## Development

**Start dev server:** `yarn start` (runs `dev-server.js`, serves static files on port 8080 via Express)

No build step, no test suite, no linter configured. Open `http://localhost:8080` in a browser to play.

**Update translation template:** `yarn run update_pot` (requires pyBabel, extracts translatable strings from `script/` into `lang/adarkroom.pot`)

**Translation tool:** `python tools/po2js.py` — converts `.po` files to the JS format used by `lang/`

## Architecture

### Module System

Each game location is a global singleton object (e.g. `Room`, `Outside`, `Path`, `Ship`, `Space`, `Fabricator`) with a standard interface:
- `init()` — sets up state, registers the tab via `Header.addLocation()`, creates the DOM panel
- `onArrival(diff)` — called by `Engine.travelTo()` when the player navigates to this location
- `panel` — jQuery DOM element for this location's view

Navigation uses `Engine.travelTo(module)` which slides a horizontal `#locationSlider` via CSS `left` animation.

### Load Order (matters — defined in `index.html`)

1. jQuery + libs (`lib/`)
2. `lang/langs.js` + language-specific strings
3. `Button.js` → `audioLibrary.js` → `audio.js` → **`engine.js`** → **`state_manager.js`** → `header.js` → `notifications.js` → **`events.js`**
4. Game modules: `room.js` → `outside.js` → `world.js` → `path.js` → `ship.js` → `space.js` → `fabricator.js` → `prestige.js` → `scoring.js`
5. Event data modules: `events/global.js`, `events/room.js`, `events/outside.js`, `events/encounters.js`, `events/setpieces.js`, `events/marketing.js`, `events/executioner.js`
6. `localization.js` (last)

### State Management (`state_manager.js` / `$SM`)

Central game state stored in the global `State` object, persisted to `localStorage`. Key categories:
- `features` — unlocked features/locations
- `stores` — inventory items
- `game` — gameplay state (buildings, workers, world map, etc.)
- `character` — perks, player stats
- `income` — recurring resource income sources

State changes fire `stateUpdate` events via `$.Dispatch('stateUpdate')`, which modules subscribe to for reactivity.

### Event System (`events.js` / `Events`)

Random events use a scene-based system. Each event has `scenes` (keyed by name), and scenes can be combat or story. Combat scenes define `health`, `damage`, `hit`, `attackDelay`, `loot`, and `buttons`. Event data is defined in `script/events/*.js` files as arrays attached to `Events.Global`, `Events.Room`, `Events.Outside`, `Events.Encounters`, `Events.Setpieces`, `Events.Marketing`, `Events.Executioner`.

### Pub/Sub

`$.Dispatch(id)` creates jQuery Callbacks-based topics on `Engine.topics`. Modules subscribe to `stateUpdate` to react to state changes.

### Game Flow

Room (fire stoking, crafting) → Outside (gathering, building, workers) → Path/World (procedural map exploration with combat) → Ship → Space (endgame). The world map in `world.js` is a 60×60 grid (RADIUS 30) using character-based tiles.

### Localization

Strings wrapped in `_()` calls. Language files live in `lang/<locale>/strings.js`. `lang/langs.js` defines available languages. CSS overrides in `lang/main.css`.
