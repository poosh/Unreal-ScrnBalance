class ScrnUpgrade extends VoiceBox;

var bool bSilent;
var bool bUpgraded;


function bool ReplaceCustomWeapon(class<Weapon> OldWClass, class<Weapon> NewWClass, out Weapon OldWeap, out Weapon NewWeap)
{
	local int AmmoAmount;

	OldWeap = Weapon(Instigator.FindInventoryType(OldWClass));
	if (OldWeap == none)
		return false;

	NewWeap = Spawn(NewWClass,,, Instigator.Location);
	if (NewWeap == none)
		return false;

	NewWeap.AmmoType = OldWeap.AmmoType;
	if (OldWeap.AmmoType != none) {
		AmmoAmount = OldWeap.AmmoType.AmmoAmount;
	}
	Instigator.DeleteInventory(OldWeap);
	NewWeap.SpawnCopy(Instigator);

	if (AmmoAmount > 0 && NewWeap.AmmoType != none) {
		NewWeap.AmmoType.AmmoAmount = min(AmmoAmount, NewWeap.AmmoType.MaxAmmo);
	}

	if ( Instigator.Weapon == None ) {
		Instigator.SwitchToBestWeapon();
	}
	return true;
}

function bool ReplaceDispertionPistol()
{
	local bool bResult;
	local Weapon OldWeap, NewWeap;
	local DispersionPistol OldPistol, NewPistol;
	local Inventory Inv;
	local int c;

	if (ReplaceCustomWeapon(class'DispersionPistol', class'ScrnDispersionPistol', OldWeap, NewWeap)) {
		OldPistol = DispersionPistol(OldWeap);
		NewPistol = DispersionPistol(NewWeap);
		if (OldPistol.PowerLevel > 0) {
			NewPistol.PowerLevel = OldPistol.PowerLevel;
		}
		OldWeap.Destroy();
		bResult = true;
	}

	// make sure there are no duplicates (spawned via game's defaultinventory)
	Inv = Instigator.Inventory;
	while (Inv != none && ++c < 1000) {
		NewPistol = DispersionPistol(Inv);
		Inv = Inv.Inventory;
		if (NewPistol == none)
			continue;

		if (OldPistol == none) {
			// first one
			OldPistol = NewPistol;
		}
		else if (OldPistol.class == class'DispersionPistol' && NewPistol.IsA('ScrnDispersionPistol')) {
			// ScrN version has higher precedence
			NewPistol.PowerLevel = max(OldPistol.PowerLevel, NewPistol.PowerLevel);
			Instigator.DeleteInventory(OldPistol);
			OldPistol.Destroy();
			OldPistol = none;
			Inv = Instigator.Inventory; // restart from the beginning
		}
		else {
			OldPistol.PowerLevel = max(OldPistol.PowerLevel, NewPistol.PowerLevel);
			Instigator.DeleteInventory(NewPistol);
			NewPistol.Destroy();
		}
	}

	return bResult;
}

function bool ReplaceWeapon(class<Weapon> OldWClass, class<Weapon> NewWClass)
{
	local Weapon OldWeap, NewWeap;

	if (!ReplaceCustomWeapon(OldWClass, NewWClass, OldWeap, NewWeap))
		return false;
	OldWeap.Destroy();
	return true;
}

function bool ReplacePickup(class<Pickup> OldClass, class<Pickup> NewClass, optional bool bNoCharge)
{
	local Pickup OldPickup, NewPickup;

	OldPickup = Pickup(Instigator.FindInventoryType(OldClass));
	if (OldPickup == none)
		return false;

	NewPickup = Spawn(NewClass,,, Instigator.Location);
	if (NewPickup == none)
		return false;

	Instigator.DeleteInventory(OldPickup);
	NewPickup.GiveTo(Instigator);
	if (!bNoCharge) {
		NewPickup.Charge = OldPickup.Charge;
	}
	NewPickup.NumCopies = OldPickup.NumCopies;
	OldPickup.Destroy();
	return true;
}


function PickupFunction(Pawn Other)
{
	local ScrnUBalanceMut ScrnMut;

	if (Other != none) {
		Instigator = Other;  // just to be sure
	}
	if (Instigator == none) {
		log("Cannot apply ScrN upgrade - Instigator not set!");
		return;
	}

	ScrnMut = class'ScrnUBalanceMut'.static.FindMe(Level, true);
	if(ScrnMut == none) {
		msg("Cannot spawn ScrnUBalanceMut!");
		return;
	}
	if (ScrnMut.bPistol)
		ReplaceDispertionPistol();
	if (ScrnMut.bAutoMag)
		ReplaceWeapon(class'AutoMag', class'ScrnAutomag');
	if (ScrnMut.bStinger)
		ReplaceWeapon(class'Stinger', class'ScrnStinger');
	if (ScrnMut.bASMD)
		ReplaceWeapon(class'ASMD', class'ScrnASMD');
	if (ScrnMut.bEightball)
		ReplaceWeapon(class'Eightball', class'ScrnEightball');
	if (ScrnMut.bMinigun)
		ReplaceWeapon(class'Minigun', class'ScrnMinigun');

	if (ScrnMut.bFlare)
		ReplacePickup(class'Flare', class'ScrnFlare', true);

	msg(PickupMessage);
	bUpgraded = true;
}

function msg(String s)
{
	if (bSilent)
		return;

	log(s);
	Instigator.ClientMessage(PickupMessage, 'Pickup');
}

function bool HandlePickupQuery(inventory Item)
{
	if (Owner != none) {
		GotoState('DelayedUpgrade', 'Begin');
	}
	return super.HandlePickupQuery(Item);
}

auto state Pickup
{
	function BeginState()
	{
		if (Level.NetMode != NM_Standalone) {
			Destroy();
			return;
		}
		super.BeginState();
	}
}

state DelayedUpgrade
{
Begin:
	sleep(0.1);
	bSilent = bUpgraded;
	PickupFunction(Pawn(Owner));
	bSilent = false;
	GotoState('Idle2');
}


defaultproperties
{
	PickupMessage="The game has been upgraded to ScrN Balance"
	bDisplayableInv=false
	bActivatable=false
	RespawnTime=0
}