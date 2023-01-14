# Unreal-ScrnBalance
ScrN Balance mutator for **Unreal Gold v227i+**.
Modifies weapons and items for the singleplayer campaign to achieve better balance and improve QoL.

# Summary
- **Dispersion Pistol**: more consistent upgrades and faster recharge rate.
- **AutoMag**: manual reload option; slight damage nerf.
- **Stinger**: damage buff and total ammo increase.
- **ASMD**: primary fire can score headshots; total ammo increase.
- **Eightball**: primary fire QoL improvement and Quake-style rocket jumping.
- **Minigun**: total ammo increase.
- **Flare**: longer duration.

# Weapons
## Dispersion Pistol
Unlike Quake2's Blaster, which is useful only for lighting dark areas and shooting boxes, Unreal's Dispersion Pistol is supposed to be an actual gun to use in fights, and thanks to its upgrade system, remain useful during the entire game. Unfortunately, it does not work that way, especially on higher difficulties.

The original upgrade mechanics are inconsistent. For instance, lv3 has the highest DPS (even better than lv5) while lv4 has the worst DPS (even worse than lv1). Total Damage (by spending all ammo from full to 0) drops down at levels 2 and 3, improving only at lv5. Dispersion Pistol upgrades feel weak because their are - until lv5, some of the "upgraded" stats are worse than at lv1.

ScrN Balance improves the upgrade system to make Dispersion Pistol better at every level.

### Original Pistol Upgrade Stats
| Level | Damage | Ammo/Shot | DPA | Cooldown | DPS | Total Ammo | Total Damage |
|-------|--------|-----------|-----|----------|-----|------------|--------------|
| 1     | 15     | 1         | 15  | 0.25     | 60  | 50         | 750          |
| 2     | 25     | 3         | 8   | 0.33     | 75  | 60         | 560          |
| 3     | 40     | 5         | 8   | 0.5      | 80  | 70         | 595          |
| 4     | 55     | 6         | 9   | 1.0      | 55  | 80         | 780          |
| 5     | 75     | 7         | 11  | 1.0      | 75  | 90         | 990          |

### Modified Pistol Upgrade Stats
| Level | Damage | Ammo/Shot | DPA | Cooldown | DPS | Total Ammo | Total Damage |
|-------|--------|-----------|-----|----------|-----|------------|--------------|
| 1     | 15     | 1         | 15  | 0.25     | 60  | 50         | 750          |
| 2     | 28     | 2         | 14  | 0.25     | 112 | 60         | 848          |
| 3     | 39     | 3         | 13  | 0.25     | 156 | 70         | 924          |
| 4     | 48     | 4         | 12  | 0.25     | 192 | 80         | 984          |
| 5     | 55     | 5         | 11  | 0.25     | 220 | 90         | 1010         |

### Recharge Rate
The original Dispersion Pistol recharges way too slowly. Maybe you didn't notice it because the ammo amount is enough to break boxes and barrels for loot, and you don't use it elsewhere. The original recharge rate is 1.1 seconds per ammo for the first 10 rounds, then approximately +1 extra second for every ten rounds. For instance, at 20 ammo, it takes ~2s to recharge one ammo, ~5s to recharge above 50, or ~8s per ammo at lv5 to charge >80. Going from 80 to 90 takes ~1.5 minutes.

The modified charge rate is much faster and simplier:
- 1s per ammo for standard charge (up to 50)
- 2s per ammo for upgraded charge (>50)
- Dispersion Pistol does not recharge while charging (AltFire)
- Dispersion Pistol starts recharging 3 seconds after the last shot.

## AutoMag
### Manual Reload
AutoMag reloads every 20 rounds, and there is no way to force the process. For instance, if you kill an enemy with 15 rounds, there are two options:
- waste the remaining 5 rounds (by shooting into nowhere) to trigger the reload
- keep 5 rounds in the magazine, making reload in the middle of the next fight.

ScrN Balance introduces new console command: `reload` to manually trigger the reload process. You can bind it to a key, e.g.: `set input r reload`.
Another option to trigger the reload without an extra key/command is **AltFire+Fire combo**: *pressing the Fire key (LMB) while holding the AltFire (RMB).* By doing it fast, you can trigger reload before firing any round, i.e., without wasting any ammo.

### Lower Damage
The original AutoMag damage (17) is too high comparing to Stinger (14) or ASMD (35). AutoMag does a hitscan (instant) damage while Stinger shots projectiles. The latter are harder to hit, hence, projectiles should do more damage for balance reasons. ASMD primary fire also is a hitscan, but it fires much slower and has 4x less ammo. For instance, on Unreal difficulty, you can kill only 6 Skaarj Scounts with full ASMD ammo, while AutoMag allows up to 12 kills.

ScrN Balance reduces AutoMag damage down to **15**.

## Stinger
Stinger projectile damage increased to **16** (up from 14). Alternate fire shoots 6 rounds (up from 5), dealing **96** damage at 100% hit (up from 70), making it a good shotgun alternative until Flak Cannon is found (or to save Flak ammo after that). The original Stinger was next to useless due to AutoMag's being better in any aspect.

*(Singleplayer-only)* Total ammo count increased to **240** (up from 200)

## ASMD
The primary fire mode of the modified ASMD can score **headshots** and decapitate enemies like Rifle or Razorjack. ASMD headshots do double damage (70).
Total ammo count increased to **80** (up from 50).
Both ASMD changes apply only to *singleplayer*. In deathmatch (if anybody still plays it), the modified ASMD acts the same as the original.

## Eightball
- Primary acts like a proper rocket launcher from Quake or UT2004+. Pressing fire (LMB) instantly fires a rocket - there are no more annoying delays due to firing on button release. Thanks to that, you can do **rocket-jumps** with Eightball now.
- Alternate fire (RMB) loads multiple **rockets** now - like in UT2004+.
- However, it is still possible to launch **grenades** by **AltFire+Fire combo**: *pressing the Fire key (LMB) while holding the AltFire (RMB).*

## Minigun
*(Singleplayer-only)* Total ammo count increased to **300** (up from 200)

# Items
## Flare
Flare duration increased to **30** seconds (up from 10).

## VoiceBox
Since VoiceBox is useless in *singleplayer* (enemies do not react to that), it has been replaced with an extra **Amplifier**.