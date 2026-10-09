# Afterlight: 2100 - Implementation Plan (Phase 1)

Goal of Phase 1: a playable Tool Crafting game on Android. One page, 270 gatherable items,
37 recipes, energy, skill, discovery, durability, robot gathering, save and load.

## 1. Tech decisions
- Godot 4.x, GDScript, portrait. Android first; iOS export later (needs a Mac, Xcode and an Apple
  developer account). Avoid platform-specific plugins.
- Content in JSON. Saves in user://save.json (versioned).

## 2. Folder layout
project.godot | AGENTS.md | README.md
docs/GAME_DESIGN.md  IMPLEMENTATION_PLAN.md  ANTIGRAVITY_PROMPTS.md  DECISIONS.md
data/items.json  recipes_tool_crafting.json  gatherable_items.csv  config.json
scenes/main.tscn  craft_page.tscn
scripts/ (autoloads) data_store.gd  inventory.gd  energy.gd  skills.gd  robot.gd  save_game.gd
scripts/ crafting_system.gd  gather_system.gd  ui/*.gd
assets/items/<item_id>.png (placeholder if missing)  tests/manual_checklist.md

## 3. Data contracts
items.json entry (gather): { id, name, type:"gather", group, chip, tool_family, tier, hand }
items.json entry (part):   { id, name, type:"part" }
items.json entry (tool):   { id, name, type:"tool", family, tier, durability }
recipes_*.json entry:      { id, output, output_qty, inputs:[{item,qty}], tool:{family,min_tier}|null,
                             skill, skill_req, energy }
config.json: energy max/regen, trip seconds, bag size, weights per tier, xp rules (all tunable).

Matching: build a dictionary {item_id: total_qty} from the slots and compare with each recipe's
inputs. Equal = match. Pre-index recipes by a sorted signature for speed.

## 4. Build order and gates
| Task | Build | Gate (must pass before the next task) |
|---|---|---|
| 0 | Inspect repo, no edits | Report reviewed |
| 1 | Project skeleton, DataStore loader and validation | 307 items, 37 recipes load; a bad ID gives a clear error |
| 2 | Inventory and a debug panel | Add, remove, count work; debug panel can be hidden |
| 3 | Craft Page layout (static) | Fits a small phone and a tall phone; safe areas respected |
| 4 | CraftingSystem, discovery, tool slot, durability, energy, skill | All rule tests pass; failures never change inventory |
| 5 | Hand gathering and inventory filters | First 10 minutes path works up to Scrap Axe |
| 6 | Recipe Book and Father hints | Undiscovered show ???; hints appear once per milestone |
| 7 | Robot and chips | Wakes after Scrap Cutter; trips, bag, collect, tier gating work |
| 8 | Save and load | Round trip identical; corrupt save does not crash |
| 9 | Android debug build on a real phone | Installs, runs, saves and loads on the device |
| 10 | Balance pass | Fresh save reaches Standard Hammer in about 20 min and Elite Hammer in about 2 hours |

## 5. Test list for Task 4 (CraftingSystem)
- Valid recipe, swapped order, extra quantity (rubble x3 does not match rubble x2).
- Unknown combination: nothing consumed.
- Skill too low: message, nothing consumed, not discovered.
- Missing tool or tool tier too low: message, nothing consumed.
- Not enough energy: message, nothing consumed.
- Tool durability goes down by 1; at 0 the tool is removed.
- Upgrade recipe consumes the lower tool.
- First craft gives 3x XP; discovery counter increases once.

## 6. Definition of done for Phase 1
- All 37 recipes craftable from a fresh save with no developer tools.
- All 270 gatherable items obtainable (the data validator confirms reachability).
- Runs on a real Android phone; saves survive closing the app.
- No crashes in a 30 minute session.

## 7. Risks and how we handle them
- Too many items: only Tool Crafting recipes use them now; icons load by ID with a placeholder.
- Balance: all numbers live in config.json so tuning never needs code changes.
- Scope creep: family, city and other categories are blocked by AGENTS.md until Phase 1 is done.
