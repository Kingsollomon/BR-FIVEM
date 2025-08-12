# Qbox Battle Royale - v1.0.0 (Generated)

## Summary
This is a Qbox / QB-compatible Battle Royale mode resource designed to work with **Qbox** (via QB bridge), **ox_inventory**, and **ox_lib**. It provides a lobby, teleport-on-start, shrinking safe zone, loot crates, basic pickup and weapon giving and round end detection. It is a functional starting point and is intentionally simple to be easy to adapt.

## Installation
1. Upload the folder `qbox_battleroyale_v1` to your server resources directory.
2. Ensure `qb-core`, `ox_inventory` and `ox_lib` (or equivalent) are installed and started before this resource.
3. Add `start qbox_battleroyale_v1` to your `server.cfg` **after** qb-core and ox_inventory.
4. Configure `config.lua` to match your server (admins, centers, loot table).
5. On the server console run: `ensure qbox_battleroyale_v1` then in console `br_start` to start lobby.
6. For admin commands in-game you can use `/br_start` or `/br_stop`. Join via `/br_join` (if manual join enabled).

