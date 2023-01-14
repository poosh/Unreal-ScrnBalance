class ScrnRocket extends rocket;

var float SelfDmgMult;
var int MaxSelfDmg;

auto state Flying
{
	function BlowUp(vector HitLocation, RingExplosion r)
	{
		local int OldHealth;
		local Pawn Player;
		local int DamageMade;

		if (Instigator != none && Instigator.bIsPlayer && Instigator.Health > 0) {
			Player = Instigator;
			OldHealth = Player.Health;
			// a hack to prevent instigator from dying due to explosion
			Player.Health = 999;
		}

		super.BlowUp(HitLocation, r);

		if (Player != none) {
			DamageMade = 999 - Player.Health;
			DamageMade = clamp(DamageMade * SelfDmgMult, 0, MaxSelfDmg);
			if (DamageMade >= OldHealth) {
				// kill the player
				Player.Health = OldHealth;
				Player.TakeDamage(1000, Player, HitLocation, (Player.Location - HitLocation) * MomentumTransfer, 'exploded');
			}
			else {
				// apply the adjusted damage
				Player.Health = OldHealth - DamageMade;
			}
		}
	}
}


defaultproperties
{
	SelfDmgMult=0.5
	MaxSelfDmg=49
}