# Afterlight: 2100 - Agent Rules

Read this file and docs/GAME_DESIGN.md before every task.

## Project
- Mobile crafting game in the style of Dawn of Crafting, set in the year 2100. Android first, iOS later.
- Engine: Godot 4.x, GDScript. Portrait, touch-first. No Android-only or iOS-only plugins.
- ONE gameplay page (the Craft Page). Everything happens on it. No extra screens or tabs in Phase 1.
- Scope right now: Category 1 (Tool Crafting), gathering, energy, skills, discovery, robot gathering.
- Out of scope until asked: family, marriage, kids, city, home, storage limits, cooking, tailoring,
  pottery, other crafting categories, monetization, multiplayer, cloud saves.

## Source of truth
- docs/GAME_DESIGN.md = rules. docs/IMPLEMENTATION_PLAN.md = build order and gates.
- data/items.json, data/recipes_tool_crafting.json = content. Do not rename IDs.
- data/gatherable_items.csv = readable copy of the 270 gatherable items (do not edit by hand in code).

## Engineering rules
- Data-driven: no item names or recipes in code. All content comes from /data JSON.
- Only CraftingSystem.try_craft() knows recipe rules. UI never re-implements them.
- Validate all data at load. Fail with file name and the bad ID.
- Keep tuning numbers (energy, durability, timers, weights) in data or one config file.
- Small changes only. No new dependencies. Do not rewrite unrelated files.
- Never claim a test or build passed unless it was actually run. If Godot cannot run in your
  environment, say so and give exact manual steps.
- No secrets in the repo.

## Workflow for every task
1. Read the docs. 2. State scope and the files you will touch. 3. Implement only the task.
4. Run checks. 5. Report: files changed, real test results, known issues.
6. Record any design change in docs/DECISIONS.md.

## UI rules
- Large tap targets, readable on small phones, safe-area margins for notches and gesture bars.
- Every disabled control shows a reason. No dead buttons.
