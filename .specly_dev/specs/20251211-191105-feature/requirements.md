# Requirements Document

## Introduction

This Hammerspoon automation suite orchestrates Zoom focus mode management, Spotify volume shortcuts, Finder toolbar icon theming, camera-driven focus toggles, and location-aware audio settings. The core bootstrap in [`init.lua`](init.lua) loads modules from [`modules/`](modules/:0) with shared configuration from [`config.lua`](config.lua), binds hotkeys via [`bindings.lua`](bindings.lua), and exposes logging through `hsm.log`. The goal is to strengthen flexibility for adding new automations while ensuring every module surfaces failures promptly in the Hammerspoon console.

## Requirements

### Requirement 1: Modular lifecycle contract

**User Story:** As a maintainer, I want a consistent module lifecycle contract so that I can add or update automation modules without destabilising the system.

#### Acceptance Criteria

1. WHEN [`init.lua`](init.lua) loads a module AND the `require('modules.<name>')` call fails THEN the system SHALL log an error with the module name via `hsm.log.e` AND SHALL continue loading remaining modules.
2. WHEN [`init.lua`](init.lua) assigns configuration to a module THEN the system SHALL merge values from `config.<moduleName>` into the module’s `config` table without overwriting existing defaults declared in the module.
3. WHEN any module exposes `start` or `stop` functions THEN the system SHALL invoke them via protected calls (pcall) AND SHALL log structured errors that include the module name, entry point, and error message.

### Requirement 2: Runtime automation resilience

**User Story:** As an automation user, I want runtime watchers and callbacks to recover gracefully so that my workflows remain stable even when dependencies misbehave.

#### Acceptance Criteria

1. WHEN a watcher callback in [`modules/camera.lua`](modules/camera.lua), [`modules/location.lua`](modules/location.lua), or similar automation raises an error THEN the system SHALL catch the exception, log it with watcher context, and attempt one automatic restart of the watcher.
2. WHEN an external dependency such as `hs.shortcuts`, `hs.spotify`, or `hs.application` reports a failure during module execution THEN the system SHALL emit a Hammerspoon console alert identifying the dependency, the attempted action, and suggested remediation.
3. IF a module exceeds a configurable failure threshold within a rolling time window THEN the system SHALL expose a console command (e.g. `hs_reload_module('<name>')`) that restarts that module’s lifecycle without requiring a full config reload.

### Requirement 3: Observability and configuration transparency

**User Story:** As a power user, I want clear visibility into automation status and configurable behaviours so that I can extend the system with confidence.

#### Acceptance Criteria

1. WHEN the automation suite finishes initialisation THEN the system SHALL log a summary listing loaded modules, active watchers, and resolved configuration paths (e.g. icons, temp directories) using `hsm.log`.
2. IF a configuration value referenced in [`config.lua`](config.lua) is missing or invalid THEN the system SHALL log a warning identifying the configuration key and explain the fallback behaviour applied.
3. WHEN a new module is registered in the `modules` table THEN the system SHALL require that it declare metadata (name, description, configurable options, default bindings) so that documentation and discovery remain consistent.
