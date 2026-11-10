# Engine and editor addons

Use the standard (non-.NET) **Godot 4.7.2** editor and matching export templates.
The project feature version is 4.7; `.godot-version` records the tested patch
release. Export templates must match the editor exactly.

## Vendored addons

| Addon | Bundled version | Upstream/revision |
| --- | --- | --- |
| Aseprite Wizard | 9.8.0 | [viniciusgerevini/godot-aseprite-wizard](https://github.com/viniciusgerevini/godot-aseprite-wizard), tag [`v9.8.0-4`](https://github.com/viniciusgerevini/godot-aseprite-wizard/releases/tag/v9.8.0-4), commit `dd7d4e21eb665385c74b47378f7e3020d7037339` |
| SignalVisualizer | 1.7.0 | Existing MiniGameDev bundle; upstream repository and revision have not been verified |
| Scene Manager | 1.0.1 | Existing GlassBrick bundle; upstream repository and revision have not been verified |

Aseprite Wizard is copied from upstream's `addons/AsepriteWizard` directory.
Its MIT license is retained as `addons/AsepriteWizard/LICENSE`. Keep its supplied
`.uid` files: they belong to the upstream release. Do not commit the editor's
`.godot` cache or unrelated asset import rewrites when refreshing the addon.

SignalVisualizer and Scene Manager remain at their original bundled versions.
Their authors and versions come from their `plugin.cfg` files; no update or
security clearance is implied. Verify their source and licensing before replacing
them with another release.

## Aseprite source imports

Install Aseprite separately and configure its command under **Editor > Editor
Settings > Aseprite > General > Command Path**. The Aseprite Wizard UI is available
under **Project > Tools > Aseprite Wizard**.

The existing skunk `.aseprite.import` entry uses the new
`aseprite_wizard.plugin.spriteframes` importer and namespaced options introduced
since the previous bundled version. Its source UID and import output path are
preserved. Other animal sources intentionally keep their existing **No Import**
selection. Do not silently change an actively imported source to **No Import** to
work around a missing Aseprite executable.

The game scenes use committed PNG sprite sheets. Rendering and playing those
scenes does not validate fresh `.aseprite` conversion. Before merging an addon
upgrade, reimport the skunk source with a working Aseprite installation and check
the resulting frames and animation timing. The editor will report an import error
when that executable is unavailable; that requires installing/configuring the
tool, not editing the importer selection.

## Upgrade checks

Run these commands with the pinned editor after installing matching templates:

```sh
godot --headless --editor --path . --quit
godot --headless --path . --quit-after 180
godot --headless --path . res://scenes/level_01.tscn --quit-after 180
mkdir -p output/windows output/html
godot --headless --path . --export-release "Windows Desktop"
godot --headless --path . --export-release "Web"
```

Inspect the command output as well as exit status: Godot can exit successfully
while reporting import errors. Run the native build on Windows and serve the web
build over HTTP for a browser check of the menu, start transition, movement,
eating, pause/settings, and sound. Export success alone is not a full playtest.

### Validation recorded for the 4.7.2 / 9.8.0 update

- Official editor and export-template downloads were checked against upstream
  `SHA512-SUMS.txt`.
- Godot 4.7.2 loaded the updated addon without script parse errors. Main menu and
  level headless smoke runs exited successfully; existing SignalVisualizer
  shutdown/resource warnings were observed.
- Web and Windows release exports completed. Chromium loaded the web build with
  WebGL 2, rendered the menu, started a level, and accepted movement/eat input,
  without browser page or console errors.
- Fresh Aseprite conversion and native Windows execution remain unverified in
  this Linux environment. Complete them before merging. Audio, controller input,
  and the full gameplay loop also need a manual playtest.
