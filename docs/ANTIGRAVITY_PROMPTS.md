# Antigravity prompts (copy one per conversation)

How to use: put AGENTS.md, docs/ and data/ in the repo first. One task per conversation.
Approve the plan, run the game yourself, check the gate in docs/IMPLEMENTATION_PLAN.md, commit,
then move on. If something is wrong, ask for a fix to that task only.

## Prompt 0: Inspect (no edits)
```
You are the lead Godot 4 engineer for Afterlight: 2100. Read AGENTS.md, docs/GAME_DESIGN.md and
docs/IMPLEMENTATION_PLAN.md. Do NOT edit any file.
Report: 1) current repo state and whether it is a valid Godot 4 project, 2) the exact files you
will create for Task 1, 3) contradictions or missing decisions in the docs, 4) risks for an
Android-first portrait game. Wait for my approval.
```

## Task 1: Skeleton and data loader
```
Read AGENTS.md and docs/. Implement ONLY Task 1:
1) A Godot 4 portrait project (1080x1920 base, stretch mode canvas_items) with scenes/main.tscn.
2) A DataStore autoload that loads data/items.json, data/recipes_tool_crafting.json and
   data/config.json and validates: unique IDs; every recipe output and input exists; recipes have
   1-3 input entries; tool families are valid; gather items have chip, tool_family and tier 1-4.
   Errors must name the file and the bad ID.
3) A temporary debug scene that prints counts: expected 270 gather items, 37 crafted items,
   37 recipes, and lists items per chip.
No UI, inventory, or crafting yet. Run the project. Report the real output.
```

## Task 2: Inventory and debug panel
```
Read AGENTS.md and docs/. Implement ONLY Task 2:
1) An Inventory autoload: add, remove, count, has, with stack limit from config (999) and
   change signals.
2) A debug panel (toggle with a small button) listing items with +1/+10/-1 and a
   "give all hand materials x20" button. It must be easy to hide for release builds.
3) Unit-style checks for add, remove below zero (must refuse), and has.
No crafting, gathering UI, or save yet. Report real results.
```

## Task 3: Craft Page layout (static)
```
Read AGENTS.md and docs/GAME_DESIGN.md section 3. Build scenes/craft_page.tscn as the main screen:
status bar, hand gather strip, robot panel, craft table (1 tool slot + 3 ingredient slots, result
preview, Craft, Clear, message line), inventory grid with filter chips and search, Recipe Book
button. Layout only; buttons can log to the console. Use safe-area margins, large touch targets,
portrait. Test mentally and with the editor at 360x800 and 430x932 and report any overflow.
If docs/mockups/craft_page.png exists, match its layout. No game logic.
```

## Task 4: CraftingSystem and rules
```
Read AGENTS.md and docs/GAME_DESIGN.md section 4. Implement ONLY Task 4:
CraftingSystem.try_craft(slots, tool_id) as the single place for recipe rules: multiset match with
quantities; skill gate; tool family and min tier; energy; consume exact inputs; add output;
durability -1 and removal at 0; upgrade recipes consume the lower tool; XP rules and discovery.
Add Energy (with regen using timestamps) and Skills autoloads reading config.json.
Wire the Craft button to it. Every failure returns a reason and changes nothing.
Run every test listed in docs/IMPLEMENTATION_PLAN.md section 5 and report real results.
```

## Task 5: Hand gathering and inventory filters
```
Read AGENTS.md and docs/. Implement ONLY Task 5: tapping Rubble, Plastic Rod, Cable Strand on the
gather strip adds 1 each (free, no cooldown). Inventory grid filters (All, Material, Part, Tool)
and search work. Tapping an inventory item puts it in the first free ingredient slot (or increases
the quantity if already there); tapping a slot removes one. Tools can be dragged or tapped into
the tool slot. Verify the "first 10 minutes" path in docs/GAME_DESIGN.md up to Scrap Axe.
```

## Task 6: Recipe Book and Father hints
```
Read AGENTS.md and docs/. Implement ONLY Task 6: a slide-up Recipe Book on the Craft Page.
Discovered recipes show inputs, tool, skill and output; undiscovered show "???" with number of
inputs and required skill. Tapping a discovered recipe fills the slots if the items are owned.
Show discovered X/37 in the status bar. Add Father hint messages at skill milestones from
GAME_DESIGN section 8, shown once each. No robot yet.
```

## Task 7: Robot and chips
```
Read AGENTS.md and docs/GAME_DESIGN.md section 4 (robot rules). Implement ONLY Task 7:
a Robot autoload with five chips; a chip unlocks when the player owns a tool of its family;
the robot wakes after the first Scrap Cutter. Trips use timestamps (config trip_seconds), return
3 + floor(chipSkill/25) items drawn from items of that chip with tier <= best owned tool tier,
using the tier weights in config; cost 1 durability on the tool; bag holds 30; Collect moves items
to inventory; collecting twice must not duplicate items. Add a "fast mode" config (5 s trips)
for testing. Report the drawn items for 20 trips with each tool tier.
```

## Task 8: Save and load
```
Read AGENTS.md and docs/. Implement ONLY Task 8: SaveGame writing user://save.json with a version
field: inventory, tool durabilities, energy value and timestamp, skills XP, discovered recipes,
robot state (chip skills, bag, last trip time, selected chip), hints shown. Autosave after every
craft, gather and collect. Missing file starts a new game. A corrupt file is backed up as
save.json.bak and a new game starts with a visible message. Test: play, close, reopen, state
identical; delete file; corrupt file. No cloud saves.
```

## Task 9: Android build
```
Read AGENTS.md. Implement ONLY Task 9: set up the Godot Android export (debug) and give exact
steps for JDK, Android SDK, export templates, and keystore. Build a debug APK if the environment
allows; otherwise list exact manual steps. State clearly what was tested on a real device and what
was not. Check safe areas on a phone with gesture navigation.
```

## Task 10: Balance pass (data only)
```
Read AGENTS.md and docs/IMPLEMENTATION_PLAN.md. Play from a fresh save without debug tools and
report time to Standard Hammer (target about 20 min) and Elite Hammer (target about 2 hours).
Adjust only data/config.json values (energy regen, trip seconds, weights, xp). Report before and
after numbers and any blocked step.
```
