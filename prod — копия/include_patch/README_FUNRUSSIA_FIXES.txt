Fun Russia — PVZ + EuroSystem GUI/Duels fixes

FILES
- FunRussia_PVZ_WORK_FIXED.pwn: updated PVZ filterscript source.
- EuroSystem_GUI_FIXED.pwn: EuroSystem GUI source with the FRDuelArenaInterior compile fix and duel damage fallback.
- marketplace.inc.patched: marketplace include with the public bridges needed for PVZ rewards and delivery payment.
- pvz_bridge_snippet.inc.txt: bridge code only, if you need to merge it manually.
- pvz.inc.original: original PVZ include for reference.

PVZ CHANGES
- Changed pickup type from 23 to 1 so the entrance, exit, boss, and reward pickups are active pickups.
- Changed teleport ordering: interior/world are set before position; player is placed slightly above the ground and camera is reset. This targets the falling-under-map bug when leaving/entering PVZ.
- Added a female actor at the PVZ counter (skin 31), a visible label, and an active pickup at the job start point.
- Added entrance map icons for all nine PVZ locations and a per-player map icon for the current delivery checkpoint.
- Reward/boss pickups are not blocked by the teleport cooldown. Added a diagnostic message if the rewards bridge is missing.
- Existing currency is preserved; delivery still uses the existing cash function through FR_PVZ_Pay.

DUEL CHANGES
- Added a duel-only OnPlayerGiveDamage fallback: it checks whether health/armour actually decreased and only applies damage manually when it did not. It does not alter damage outside duels.
- The source also retains the fix for the undefined FRDuelArenaInterior identifier.

INSTALL
1. Back up the currently installed files.
2. Replace the PVZ filterscript source with FunRussia_PVZ_WORK_FIXED.pwn and compile it with your Pawn compiler.
3. Replace/merge marketplace.inc with marketplace.inc.patched in the MAIN GAMEMODE source, then recompile the gamemode. This is required for .reward and the existing-cash payment bridge to work. If you cannot recompile the gamemode, the reward GUI bridge cannot be made functional from this standalone filterscript alone.
4. Compile EuroSystem_GUI_FIXED.pwn as a filterscript only if that is the EuroSystem source you currently use. Do not run two copies of the same EuroSystem filterscript at once.
5. Install the resulting AMX files, restart the server, and test on a test server first.

IMPORTANT
- This package contains source files, not verified AMX binaries.
- Pawn compiler was not available in the build environment, so the files have not been compiled here. Test compilation and in-game behavior before deploying to production.
- The female actor model is standard skin 31; if your CRMP map uses a custom skin pack and model 12 looks different, change the actor model ID to a female model supported by that pack.
- The truck delivery is an adaptation; the supplied original pvz.inc was a hand-carry cargo job, not a truck job.
