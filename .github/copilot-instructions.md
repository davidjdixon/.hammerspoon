# Copilot Instructions

## Architecture

- [init.lua](init.lua) bootstraps Hammerspoon, exposes the global `hsm` namespace, and loads modules listed in the `modules` array; add/remove modules here to control startup order.
- Each module is required as `modules.<name>`, stored in `hsm[name]`, then configured by merging `config.<name>` into `mod.config`, so avoid side effects before `start()` runs.
- `hs_reload()` unbinds hotkeys via [bindings.lua](bindings.lua) before stopping modules and reloading, so call it after edits instead of Hammerspoon’s GUI reload button when modules create watchers.

## Configuration

- Keep user-specific values in [config.lua](config.lua) (git-tracked here but can be templated from [config-example.lua](config-example.lua)); `config.global.paths` already maps `$HOME`, `$TMPDIR`, and `.hammerspoon/icons`.
- Module configs mirror their file names (`config.zoom`, `config.darkmode`, etc.); add a table there before referencing `hsm.config` inside a new module to avoid nil errors.
- Paths should be composed through `utils.file.toPath()` to stay portable on macOS; `hsm.config.paths.icons` is the canonical location for Finder icon assets.

## Module Lifecycle Pattern

- Each module exports a table with optional `start()`/`stop()` and internal helpers; Hammerspoon automatically wires logging via `hs.logger.new(modName, LOGLEVEL)` in [init.lua](init.lua#L7-L39).
- Watchers, timers, or hotkeys created in `start()` must be stopped or cleared in `stop()` (see [modules/location.lua](modules/location.lua#L73-L111) for the reference pattern storing watcher handles on `m`).
- When adding module-level config defaults, set `m.config = {}` and rely on `configModule()` to merge overrides so tests don’t depend on user machines.

## Key Modules

- Zoom workflow ([modules/zoom.lua](modules/zoom.lua)) listens to `Zoom.spoon` status transitions and invokes macOS Shortcuts defined at `config.zoom.shortcut.{start|stop}`; always update the config when renaming Shortcuts to avoid silent failures.
- Camera watcher ([modules/camera.lua](modules/camera.lua)) toggles the same focus Shortcuts whenever any camera reports `isInUse()`; strings are currently hard-coded, so keep them in sync with `config.zoom.shortcut`.
- Dark mode tooling ([modules/darkmode.lua](modules/darkmode.lua)) re-applies Finder toolbar icons using `/usr/local/bin/fileicon`; ensure new icon variants follow `icons/toolbar/icon_<name>_{light|dark}.icns`.
- Location automations ([modules/location.lua](modules/location.lua)) watch Wi-Fi SSID and power source to mute/unmute via `hs.audiodevice`; extend behavior by adding flags under `config.location.ssid['Network Name']`.
- Spotify media keys ([modules/spotify.lua](modules/spotify.lua)) bind raw F10–F12 keys; avoid double-binding by unbinding any Apple system-level volume shortcuts.

## Hotkeys & Reload

- Global key remaps live in [bindings.lua](bindings.lua); register new bindings by appending to `globalBindings`, but remember to store the `hs.hotkey` handle in `active_hotkeys` for clean reloads.
- Modules that create their own hotkeys should follow the Spotify pattern of keeping handles in a local table and deleting them inside `stop()` to prevent orphaned shortcuts after `hs_reload()`.

## Utilities & Assets

- Use [utils/app.lua](utils/app.lua) for AppleScript `tell` and user notifications, [utils/file.lua](utils/file.lua) for filesystem helpers, and [utils/string.lua](utils/string.lua) for parsing; these utilities assume macOS paths and `hs.*` availability.
- Finder toolbar icons are stored under [icons/toolbar](icons/toolbar); provide both `light` and `dark` `.icns` files so `modules/darkmode` can toggle seamlessly.

## External Dependencies

- Requires Hammerspoon with `hs.ipc`, `hs.shortcuts`, `hs.camera`, `hs.location`, and `hs.wifi`; install the bundled [spoons/Zoom.spoon](spoons/Zoom.spoon) to keep the Zoom module functional.
- Dark mode automation depends on Ji4n1ng’s OpenInTerminal/OpenInEditor Lite apps pinned to the Finder toolbar and the `fileicon` CLI; camera/Zoom automation assumes Shortcuts named in `config.zoom.shortcut`.

## Developer Workflow

- Reload after changes with `hs_reload()` from the Hammerspoon console or bind it to a hotkey for faster iteration; this ensures bindings and watchers are stopped before reloading.
- Use `hsm.log.<level>()` from the console for module debugging—the logger respects `LOGLEVEL` near the top of [init.lua](init.lua#L1-L6).
- When extending automation, prefer composing new helpers under `utils/` first, then pulling them into modules so logic stays testable outside watcher callbacks.
