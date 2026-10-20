EuroSystem / FunTrial / AccessGate — patched package

Changes included:
- Added Udmut ruble balance in EuroSystem (database column accounts.udmurt_rub).
- Added /udmurt and /udr menu with conversion routes; the fictional Udmut ruble is pegged to 1 RUB (there is no real-world market rate for this fictional currency). Cash RUB <-> Udmut ruble exchange uses 20% commission; cross-currency conversions use live rates already fetched by the script and 50% commission; player transfers also use 50%.
- Added player-to-player Udmut-ruble transfers with a 50% fee.
- Added purchase of a permanent AccessGate key for 500,000 Udmut rubles, followed by separate activation in the Udmut currency menu. Permanent codes are stored as fun_codes rows with days=0.
- Added key activation entry to the Funcoin menu and duration choices 15, 20, 30, 40, 90, 100, 200 days.
- AccessGate now treats a 0-day code as permanent (date 31.12.9999). Existing active keys/access are not automatically replaced.
- Viewer spending on streamer troll actions/full control is credited to the streamer as FC compensation.
- Removed duplicate legacy OnPlayerCommandText invocation in Full Control and tightened session-expiry comparison.

IMPORTANT:
- These are source edits, not compiler-verified. No Pawn compiler or your Black Russia gamemode was provided, so the arbitrary command bridge in Full Control may still require adapting to the command processor used by your exact server (e.g. Pawn.CMD).
- Test on a copy first and back up the database. EuroSystem automatically adds accounts.udmurt_rub.
- For Russian text, source keeps its original SA-MP CP1251 byte conventions; this does not guarantee compatibility with every modified 16.94 client build.
- AccessGate already contains its own trial manager. Do not load both AccessGate and the old independent FunTrial filterscript at the same time: they both set virtual worlds and enforce separate timers. The included FunTrial.pwn is the original source for reference; if AccessGate is your active trial manager, remove FunTrial from server.cfg filterscripts. The separate old FunTrial file has not been rewritten.
