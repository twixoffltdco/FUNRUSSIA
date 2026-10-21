FUN RUSSIA — PVZ GUI + DOT DUEL COMMAND PATCH

FILES
- filterscripts/FunRussia_PVZ.pwn: standalone PVZ point visuals, enter/exit pickups, reward GUI shell.
- Integration/FR_OpenMarketplaceRewards_bridge.pwn.txt: public bridge snippet for the gamemode.
- Integration/EuroSystem.pwn and EuroSystem_GUI.pwn: EuroSystem sources with duel commands dot-only (if using these exact sources, compare with your current copy before replacing).
- include_patch/*original: untouched references from your uploaded mod.

PVZ INSTALL
1) Compile filterscripts/FunRussia_PVZ.pwn with your server's SA-MP/open.mp includes.
2) Add FunRussia_PVZ to filterscripts in server.cfg.
3) Replace your include/marketplace.inc with include_patch/marketplace.inc.patched (keep a backup first), then recompile the gamemode so the public FR_OpenMarketplaceRewards bridge is exported. Alternatively, add the snippet from Integration/FR_OpenMarketplaceRewards_bridge.pwn.txt to the gamemode source after marketplace.inc is included.
4) The filterscript cannot call a stock function inside another AMX directly; without recompiling the gamemode with the bridge, the custom GUI opens but the actual marketplace reward inventory will not open.

DOT COMMANDS
- .pvz — help message for PVZ points.
- .reward — open the custom reward GUI shell.
- .duel ID [rounds 1-3] [stake] — challenge a player (EuroSystem integration).
- .duelaccept — accept.
- .duelno — decline/cancel.

IMPORTANT
- No .amx files are included because Pawn compiler isn't available in this environment; compile locally and test on a test server first.
- The coordinates come from the supplied pvz.inc. Some coordinates are CRMP-specific and should be tested on your exact map.
- Reward item lists are not duplicated in the FS: the actual reward contents must remain sourced from marketplace.inc/database.
