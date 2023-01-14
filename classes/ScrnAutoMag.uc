class ScrnAutoMag extends AutoMag;

function bool HandlePickupQuery(inventory Item)
{
	if (Item.Class == class'AutoMag') {
		class'ScrnUBalanceMut'.static.HandleDuplicateWeaponPickup(self, Weapon(Item));
		return true;
	}
	return super.HandlePickupQuery(Item);
}

exec function Reload()
{
	// single-player only (to avoid bothering with replication crap)
	if (Level.NetMode != NM_Standalone)
		return;

	if (ClipCount > 0 && AmmoType.AmmoAmount > (20 - ClipCount)) {
		GotoState('NewClip');
	}
}

state AltFiring
{
	function Fire( float Value )
	{
		global.Reload();
	}
}

state NewClip
{
	function Reload() { }
}

defaultproperties
{
	hitdamage=15  // down from 17
	PickupMessage="You got the AutoMag SE"
	ItemName="AutoMag SE"
}