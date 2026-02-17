# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Slay the Spire-inspired card game built with **Godot 4.4** using GDScript and the **GL Compatibility** renderer. The project name is "kss" (kanjo-slay-the-spire).

## Development Commands

```bash
# Run the game (requires Godot 4.4+ in PATH)
godot --path /mnt/c/workspace/kanjo-slay-the-spire

# Run a specific scene
godot --path /mnt/c/workspace/kanjo-slay-the-spire res://path/to/scene.tscn

# Export (once export presets are configured)
godot --headless --path /mnt/c/workspace/kanjo-slay-the-spire --export-release "<preset>" output_path
```

## Conventions

- Line endings: LF (enforced via `.gitattributes`)
- Charset: UTF-8 (enforced via `.editorconfig`)
- GDScript files use `.gd` extension; scenes use `.tscn`; resources use `.tres`
- The `.godot/` directory is gitignored (generated cache/imports)
