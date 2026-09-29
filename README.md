# Evil Dungeon Game (working title)

Turn-based roguelike deckbuilder on a tile grid. Team project for UAA CSCE A401, Fall 2026.
Godot 4.7, GDScript.

## Where things go

| Folder | What goes in it |
|---|---|
| `addons/` | Third-party editor plugins |
| `assets/` | Raw art, audio and fonts only. No scripts. |
| `autoload/` | Singletons (run state, save manager, content database) |
| `data/` | `.tres` content only: `cards/`, `enemies/`, `relics/`, `rooms/`, `tilesets/` |
| `entities/` | Things that stand on the board (player, enemies, objects), scene + script together |
| `scenes/` | Screens and UI pieces (menus, levels, card), scene + script together |
| `scripts/` | Code that has no scene: Resource classes (e.g. `CardData`, card effects), combat and run logic |

Rules of thumb:

- A script that belongs to a scene lives **next to that scene**.
- Any other script goes in `scripts/`.
- Adding a new card, enemy or relic should only add files under `data/` (plus art in `assets/`).
- Move or rename files in Godot's FileSystem dock, not in Explorer, so references update.

## Workflow

1. `git switch main` and `git pull`
2. `git switch -c feature/<short-name>`
3. Keep the change small and focused on one feature.
4. Run `gdlint scenes scripts entities autoload` (install with `pip install "gdtoolkit==4.*"`).
5. Push and open a pull request into `main`. Fill in the template, including the FR number.
6. Merge after one teammate approves. Never commit directly to `main`.
