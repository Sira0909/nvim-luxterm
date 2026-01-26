# Luxterm UI Redesign

**Date:** 2026-01-25
**Status:** Approved
**Goal:** Modernize Luxterm manager UI with Lazygit-inspired terminal-native aesthetic

## Overview

Replace the current bordered-box session list with a sleek, row-based panel layout. Add structured preview metadata, contextual status bar, and theme-aware color system.

## Design Goals

1. **Reduce friction** - Fewer keystrokes to switch sessions
2. **Improve clarity** - Visual hierarchy differentiates sessions at a glance
3. **Modern aesthetic** - Lazygit-style terminal-native look
4. **Theme integration** - Auto-adapt to current colorscheme
5. **Persistence-ready** - Data structures support future session serialization

## Layout Structure

```
┌─ Sessions ─────────────────┬─ Preview ──────────────────────┐
│                            │                                │
│  ● node         2m  [1]    │  ~/projects/my-app             │
│  ○ idle        15m  [2]    │  Process: node (npm run dev)   │
│  ◐ vim          5m  [3]    │  Last cmd: npm run dev         │
│                            │  ─────────────────────────────  │
│                            │  Ready on http://localhost:3000 │
│                            │  ...                           │
│                            │                                │
├────────────────────────────┴────────────────────────────────┤
│ [n]ew  [d]elete  [r]ename  [p]review  [1-9] jump   [Esc]    │
└─────────────────────────────────────────────────────────────┘
```

### Key Layout Changes

- Sessions are **rows**, not bordered boxes
- Status bar replaces inline shortcuts footer
- Preview has structured header before terminal output
- Selection is highlighted row background, not box border

## Session List Item Design

### Row Format

```
● process-name    time  [n]
│ │               │     │
│ │               │     └── Hotkey (dimmed, right-aligned)
│ │               └── Time since active (dimmed)
│ └── Session name OR running process
└── Status icon (colored)
```

### Status Icons & Colors

| State | Icon | Color Source | Meaning |
|-------|------|--------------|---------|
| Running + Active | `●` | `DiagnosticOk` (green) | Process running, recently used |
| Running + Stale | `◐` | `DiagnosticWarn` (yellow) | Process running, idle >5min |
| Stopped | `○` | `Comment` (gray) | No process, shell idle |
| Error | `✕` | `DiagnosticError` (red) | Process exited with error |

### Display Name Logic

- If process running → show process name (e.g., `node`, `vim`, `python`)
- If shell idle → show session name or CWD basename
- Truncate to ~15 chars with ellipsis if needed

### Selection & Activity

- Selected row: `Visual` background highlight across full width
- Sessions inactive >30min: dimmed text (blend toward `Comment`)

## Preview Pane Design

### Structured Header

```
┌─ Preview ──────────────────────────────────┐
│                                            │
│  ~/projects/my-app                         │  ← CWD (bold)
│  node (npm run dev)                        │  ← Process + command
│  $ npm run dev                             │  ← Last command (dimmed)
│                                            │
│  ──────────────────────────────────────    │  ← Separator
│                                            │
│  > my-app@1.0.0 dev                        │  ← Terminal output
│  ...                                       │
│                                            │
└────────────────────────────────────────────┘
```

### Metadata Lines

| Line | Content | Color Source |
|------|---------|--------------|
| CWD | Working directory (`~` for home) | `Directory` or `Title` |
| Process | Running process + full command | `Normal` |
| Last cmd | Most recent command with `$` prefix | `Comment` |

### Terminal Output

- Thin horizontal separator divides metadata from output
- Show last ~15 lines (configurable)
- Skip empty lines, strip ANSI escapes
- `Normal` foreground, no syntax highlighting

### Empty States

- No session selected: centered "Select a session" in `Comment`
- No output: show metadata header, then "No recent output"

## Status Bar

### Layout

```
│ [n]ew  [d]elete  [r]ename  [p]review  [1-9] jump  [Esc]    │
```

### Styling

- Keys in brackets: `Special` or `Keyword` highlight
- Labels: `Comment` highlight
- Background matches panel border

### Contextual Hints

| Context | Hints |
|---------|-------|
| Normal | `[n]ew [d]elete [r]ename [p]review [1-9] jump [Esc]` |
| No sessions | `[n]ew session [Esc] close` |
| Renaming | `[Enter] confirm [Esc] cancel` |
| Delete confirm | `[y]es [n]o` |

## Keyboard Navigation

| Key | Action |
|-----|--------|
| `j` / `k` / `↓` / `↑` | Navigate list |
| `1-9` | Jump directly to session |
| `Enter` | Open selected session |
| `n` | New session |
| `d` | Delete selected |
| `r` | Rename selected |
| `p` | Toggle preview panel |
| `Esc` | Close manager |

## Configuration

```lua
require("luxterm").setup({
  ui = {
    -- Preview panel behavior
    preview = "always",  -- "always" | "toggle" | "adaptive"

    -- Panel proportions
    split_ratio = 0.35,  -- 35% list, 65% preview

    -- Overall size
    width = 0.7,
    height = 0.6,

    -- Activity thresholds (seconds)
    stale_timeout = 300,   -- 5 min until "stale"
    fade_timeout = 1800,   -- 30 min until dimmed
  },
})
```

### Preview Modes

| Mode | Behavior |
|------|----------|
| `"always"` | Preview always visible |
| `"toggle"` | List only, `p` shows/hides preview |
| `"adaptive"` | Preview if 2+ sessions |

### Backward Compatibility

- Existing options continue to work
- `ui` table optional, sensible defaults applied
- Existing presets updated for new layout

## Theme Integration

All highlights link to standard Neovim groups:

```lua
vim.api.nvim_set_hl(0, "LuxtermStatusActive", { link = "DiagnosticOk" })
vim.api.nvim_set_hl(0, "LuxtermStatusStale", { link = "DiagnosticWarn" })
vim.api.nvim_set_hl(0, "LuxtermSelected", { link = "Visual" })
vim.api.nvim_set_hl(0, "LuxtermDimmed", { link = "Comment" })
vim.api.nvim_set_hl(0, "LuxtermDirectory", { link = "Directory" })
vim.api.nvim_set_hl(0, "LuxtermKey", { link = "Special" })
```

No hardcoded hex colors.

## Persistence Readiness

### Session Data Structure

```lua
session = {
  -- Existing
  id = "uuid",
  name = "my-session",
  bufnr = 42,  -- Runtime only, not persisted

  -- New serializable fields
  cwd = "/Users/joe/projects/app",
  shell = "/bin/zsh",
  created_at = 1706000000,
  last_active_at = 1706001234,
  last_command = "npm run dev",
  command_history = {"git status", "npm install", "npm run dev"},
  env = {NODE_ENV = "development"},
  scroll_position = 150,
}
```

### Serialization Plan

| Field | Persisted | Restored |
|-------|-----------|----------|
| `id`, `name`, `cwd`, `shell` | Yes | Directly |
| `created_at`, `last_active_at` | Yes | Directly |
| `command_history`, `last_command` | Yes | Directly |
| `bufnr`, terminal job | No | Recreated |
| Terminal buffer content | Optional | If configured |

### File Location

`data/luxterm/sessions.json` (follows LuxVim data isolation)

## Implementation Scope

### Files to Modify

| File | Changes |
|------|---------|
| `ui/session_list.lua` | Rewrite - row-based items, new highlights |
| `ui/preview_pane.lua` | Structured header, separator, smarter output |
| `ui/floating_window.lua` | Status bar panel, layout updates |
| `ui/highlights.lua` | Highlight group linking |
| `config.lua` | New `ui` options |
| `session_manager.lua` | `get_cwd()`, `get_process()`, `get_last_command()`, `get_last_active_time()` |
| `core.lua` | Preview toggle, refresh logic |

### New Functionality

1. **Process detection** - `nvim_get_proc` on terminal job PID
2. **CWD tracking** - Parse prompt or `OSC 7` escape sequences
3. **Command history** - Track commands or parse buffer
4. **Activity timestamps** - Last interaction time per session

### Technical Notes

- CWD detection may need shell integration hook
- Process detection uses `nvim_get_proc` on job PID
- Command history requires input interception or buffer parsing

### Out of Scope

- Fuzzy search within manager
- Session grouping/folders
- Actual persistence implementation (future feature)
