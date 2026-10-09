# Afterlight: 2100 - Game Design (source of truth)

## 1. Pitch
A minimal crafting game like Dawn of Crafting, set in the year 2100. You are a young man in your
family's repair workshop. You combine items to discover recipes, level up crafting skills, and send
a small robot out to gather materials from the ruins and wild zones of a rebuilt world.

Platform: Android first, iOS later. Engine: Godot 4.

## 2. Characters
| Character | Role |
|---|---|
| Player (young man) | Crafts everything. Has Energy and one skill per crafting category |
| Father (Master Fabricator) | Guides Tool Crafting, Fabrication, Processing. Gives hints at skill milestones |
| Mother (Master of Food and Fabric) | Guides Ceramics, Food Prep, Cooking, Tailoring (later phases) |
| Robot (name TBD, WALL-E style) | Gathers materials while you craft. Controlled by Task Chips |

Father and Mother only appear as short hint messages in Phase 1.

## 3. The Craft Page (the only gameplay screen)
Top to bottom, portrait:
1. Status bar: Energy bar, current skill level, discovered recipes counter, Recipe Book button.
2. Hand gather strip: tap Rubble, Plastic Rod, Cable Strand (unlimited, free).
3. Robot panel: robot status, selected chip, "Collect" button, bag count.
4. Craft table: 1 Tool slot + 3 Ingredient slots (each slot holds one item type and a quantity),
   result preview, Craft and Clear buttons, one-line message.
5. Inventory grid with filter chips (All, Material, Part, Tool) and a search field.
6. Recipe Book: slide-up panel on the same page.

## 4. Core rules
1. **Discovery:** put items in the slots and press Craft. Order does not matter. Match = the
   ingredient multiset (item and quantity) equals a recipe's inputs exactly. No match = "Nothing
   happens", nothing is lost.
2. **Skill gate:** if the combination matches a recipe but the skill is too low, show
   "Needs Tool Crafting 35" and do not mark it discovered or consume anything.
3. **Tool slot:** a recipe may need a tool family at a minimum tier (hammer tier 1+). The tool must
   be in the tool slot (or the best owned one is auto-selected). Each use costs 1 durability.
   A broken tool disappears. Tools used as ingredients (upgrades) are consumed.
4. **Energy:** max 100, regenerates 1 per 6 seconds, also offline up to the max. Crafting costs the
   recipe's energy. Hand gathering is free. (Food restores energy in later phases.)
5. **Skill:** one skill per category (Phase 1: Tool Crafting, 0 to 120). XP per craft =
   ceil(energy / 5); the first time a recipe is made, XP x3. Level = floor(XP / 10).
6. **Father hints:** when skill reaches a milestone, show a hint message (table in section 8).
7. **Robot chips:** five chips. A chip unlocks when you own any tool of its family.
   Tier of the best owned tool decides which items can be found.

| Chip | Tool family | Finds |
|---|---|---|
| Scavenge | Axe | Metal, plastics, wire, electronics, glass, machine parts, overgrowth wood, relics |
| Quarry | Digger | Earth, stone, fuel and chemicals, ores, crystals, rare earth |
| Harvest | Grabber | Fruit, vegetables, grains, nuts, herbs, fungi and algae |
| Fishing | Rod | Fish and seafood, water and aquatic |
| Wildlife | Lance | Creatures, nests and hives |

8. **Robot trips:** one trip every 60 seconds (configurable) while a chip is selected and the tool
   has durability. A trip returns 3 + floor(chipSkill / 25) items and costs 1 tool durability.
   Chip skill = completed trips (max 100). Item chance weights by item tier: tier1=6, tier2=4,
   tier3=2, tier4=1, limited to tiers at or below the tool tier. The robot bag holds 30 items;
   Collect moves them to inventory. The robot wakes after the first Scrap Cutter is crafted.
9. **Tool tiers:** Scrap (1), Standard (2), Advanced (3), Elite (4). Durability 15 / 30 / 60 / 120.
   Craft energy 15 / 20 / 30 / 45. Master tools are tier 5.
10. **No inventory limit in Phase 1.** Stack size 999.

## 5. The nine crafting categories
| # | Category | Replaces (Dawn of Crafting) | Status |
|---|---|---|---|
| 1 | Tool Crafting | Tool Crafting | **Phase 1, fully specified** |
| 2 | Fabrication | Wood Working | Later |
| 3 | Processing | Skinning | Later |
| 4 | Ceramics and Glass | Pottery | Later |
| 5 | Food Prep | Meal Preparation | Later |
| 6 | Cooking | Cooking | Later |
| 7 | Tailoring | Tailoring | Later |
| 8 | Construction (home, storage, city) | Construction | Later |
| 9 | Robot Programming | Painting | Later (Phase 1 has a simple chip picker) |

## 6. Gatherable items (270)
All in data/items.json (type "gather") and data/gatherable_items.csv.

| Chip | Items | Groups |
|---|---|---|
| Scavenge | 86 | Metal 12, Plastic & Rubber 10, Wire & Cable 6, Electronics 16, Glass & Ceramic 6, Machine Part 10, Overgrowth Wood 20, Relic 6 |
| Harvest | 68 | Fruit 16, Vegetable 16, Grain & Legume 6, Nut & Seed 10, Herb & Flower 12, Fungi & Algae 8 |
| Quarry | 50 | Earth 10, Stone 8, Fuel & Chemical 6, Ore 14, Crystal & Gem 8, Rare Earth 4 |
| Wildlife | 40 | Creature 28 (including machine creatures), Nest & Hive 12 |
| Fishing | 26 | Fish & Seafood 20, Water & Aquatic 6 |

By tier: tier 1 = 61, tier 2 = 98, tier 3 = 72, tier 4 = 39.
Start by hand: Rubble, Plastic Rod, Cable Strand.
Only Tool Crafting uses gatherables in Phase 1. The rest are for later categories, so Phase 1
players can collect and see them in the inventory.

## 7. Category 1: Tool Crafting
Content: data/recipes_tool_crafting.json (37 recipes: 7 parts, 28 tools, 2 master tools).
- Parts: Sharp Shard, Blade Head, Braided Cable, Hook, Sharp Alloy, Smooth Rod, Rubber Cord.
- Seven tool families x four tiers: Axe, Hammer, Cutter, Lance, Digger, Rod, Grabber.
- Each tier's tools need the previous tier's Hammer (Scrap tools need none, except Scrap Digger which
  needs a Cutter).
- Upgrade recipes (for example Standard Digger) consume the lower tool.
- Master tools: Tactical Tool (skill 100), Tactical Bright Tool (skill 120).

## 8. Father's hints (Tool Crafting)
| Skill | Hint |
|---|---|
| 0 | Two pieces of rubble struck together make a sharper edge |
| 10 | A good blade needs a firm handle |
| 30 | A cutter can smooth a plastic rod |
| 35 | Twisted cable holds better than a single strand |
| 55 | A better hammer makes better tools |
| 70 | Rubber cord lasts longer than cable |

## 9. First 10 minutes (must be possible without developer tools)
1. Tap Rubble x4, Plastic Rod x2, Cable Strand x4.
2. Rubble + Rubble = Sharp Shard (first discovery).
3. Sharp Shard + Cable Strand + Plastic Rod = Scrap Axe.
4. Make Scrap Hammer, then Scrap Cutter. The robot wakes and Scavenge becomes available.
5. Make Braided Cable. The robot brings Metal Scrap, Alloy Scrap, Rubber Strip.
6. Make Scrap Digger (Metal Scrap + Plastic Rod, Cutter), then Hook and Sharp Alloy.
7. Reach skill 35 and craft the Standard Hammer.

## 10. Later phases (do not build yet)
Phase 2: Fabrication, Processing, home and storage limits, Construction and the city.
Phase 3: Ceramics, Food Prep, Cooking, Tailoring, Robot Programming.
Phase 4: Girls, courtship, marriage, children and their jobs. Keep it family-friendly.
