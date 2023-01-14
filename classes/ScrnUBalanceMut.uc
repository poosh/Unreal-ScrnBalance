class ScrnUBalanceMut extends Mutator
	config(ScrnUBalance);

var globalconfig bool bPistol;
var globalconfig bool bAutoMag;
var globalconfig bool bStinger;
var globalconfig bool bASMD;
var globalconfig bool bEightBall;
var globalconfig bool bMinigun;
var globalconfig bool bFlare;

static function ScrnUBalanceMut FindMe(LevelInfo Level, optional bool bCreate)
{
	local Mutator mut;
	local ScrnUBalanceMut ScrnMut;

	for (mut = Level.Game.BaseMutator; mut != none && ScrnMut == none; mut = mut.NextMutator) {
		ScrnMut = ScrnUBalanceMut(mut);
	}

	if (ScrnMut == none && bCreate) {
		log("Creating ScrN Balance mutator");
		Level.Game.BaseMutator.AddMutator(Level.Game.Spawn(class'ScrnUBalanceMut'));
		return FindMe(Level, false);
	}

	return ScrnMut;
}

function PostBeginPlay()
{
	if (bPistol) {
		Level.Game.DefaultWeapon = class'ScrnDispersionPistol';
	}
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (!Other.IsA('Inventory')) {
		return true;
	}

	if (Other.IsA('Weapon')) {
		if (Other.class == class'DispersionPistol') {
			if (bPistol) {
				ReplaceWith(Other, string(class'ScrnDispersionPistol'));
				return false;
			}
		}
		else if (Other.class == class'AutoMag') {
			if (bAutoMag) {
				ReplaceWith(Other, string(class'ScrnAutoMag'));
				return false;
			}
		}
		else if (Other.class == class'Stinger') {
			if (bStinger) {
				ReplaceWith(Other, string(class'ScrnStinger'));
				return false;
			}
		}
		else if (Other.class == class'ASMD') {
			if (bASMD) {
				ReplaceWith(Other, string(class'ScrnASMD'));
				return false;
			}
		}
		else if (Other.class == class'EightBall') {
			if (bEightBall) {
				ReplaceWith(Other, string(class'ScrnEightBall'));
				return false;
			}
		}
		else if (Other.class == class'Minigun') {
			if (bMinigun) {
				ReplaceWith(Other, string(class'ScrnMinigun'));
				return false;
			}
		}
	}
	else if (Other.IsA('Pickup')) {
		if (Other.class == class'Flare') {
			if (bFlare) {
				// flares stay longer
				ReplaceWith(Other, string(class'ScrnFlare'));
				return false;
			}
		}
		else if (Other.class == class'VoiceBox') {
			// Voice Box does nothing in single player. Replace it with something useful.
			if (!Level.Game.bDeathMatch) {
				ReplaceWith(Other, string(class'Amplifier'));
				return false;
			}
		}
	}
	return true;
}

static function HandleDuplicateWeaponPickup(Weapon MyWeapon, Weapon Dup)
{
	local int OldAmmo;
	local Pawn P;

	if (Dup.bWeaponStay && (!Dup.bHeldItem || Dup.bTossedOut))
		return ;
	P = Pawn(MyWeapon.Owner);
	if ( MyWeapon.AmmoType != None ) {
		OldAmmo = MyWeapon.AmmoType.AmmoAmount;
		if (MyWeapon.AmmoType.AddAmmo(Dup.PickupAmmoCount) && (OldAmmo == 0)
				&& (P.Weapon != MyWeapon) && !P.bNeverSwitchOnPickup )
			MyWeapon.WeaponSet(P);
	}
	P.ClientMessage(Dup.PickupMessage, 'Pickup');
	Dup.PlaySound(Dup.PickupSound);
	Dup.SetRespawn();
}


defaultproperties
{
	bPistol=true
	bAutoMag=true
	bStinger=true
	bASMD=true
	bEightBall=true
	bMinigun=true
	bFlare=true
}