class ScrnMinigun extends Minigun;

var() int spMaxAmmo;

event TravelPostAccept()
{
	super.TravelPostAccept();
	CheckMaxAmmo();
}

function GiveAmmo( Pawn Other )
{
	super.GiveAmmo(Other);
	CheckMaxAmmo();
}

function CheckMaxAmmo()
{
	if (AmmoType != none && !Level.Game.bDeathMatch) {
		AmmoType.MaxAmmo = max(AmmoType.MaxAmmo, spMaxAmmo);
	}
}

function bool HandlePickupQuery(inventory Item)
{
	if (Item.Class == class'Minigun') {
		class'ScrnUBalanceMut'.static.HandleDuplicateWeaponPickup(self, Weapon(Item));
		return true;
	}
	return super.HandlePickupQuery(Item);
}

defaultproperties
{
	spMaxAmmo=300  // up from 200
	PickupMessage="You got the Minigun SE"
	ItemName="Minigun SE"
}