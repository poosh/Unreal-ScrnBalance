class ScrnStinger extends Stinger;

var() int ProjPerAltFire;
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
	if (Item.Class == class'Stinger') {
		class'ScrnUBalanceMut'.static.HandleDuplicateWeaponPickup(self, Weapon(Item));
		return true;
	}
	return super.HandlePickupQuery(Item);
}

state AltFiring
{
	function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
	{
		local Projectile S;
		local int i;
		local vector Start,X,Y,Z;
		local Rotator StartRot, AltRotation;

		S = Global.ProjectileFire(ProjClass, ProjSpeed, bWarn);
		StartRot = S.Rotation;
		Start = S.Location;
		GetAxes(StartRot,X,Y,Z);
		for (i = 1; i< ProjPerAltFire && AmmoType.UseAmmo(1); i++) {
			AltRotation = rotator(X+Y*(FRand()*0.26-0.13)+Z*(FRand()*0.26-0.13));
			S = Spawn(AltProjectileClass,,, Start - 2 * VRand(), AltRotation);
		}
		if ( StingerProjectile(S)!=None )
			StingerProjectile(S).bLighting = True;
		Return S;
	}

Begin:
	FinishAnim();
	PlayAnim('Still');
	Sleep(1.0);
	Finish();
}

defaultproperties
{
	spMaxAmmo=240  // up from 200
	ProjPerAltFire=6  // up from 5
	ProjectileClass=Class'ScrnStingerProjectile'
	AltProjectileClass=Class'ScrnStingerProjectile'
	PickupMessage="You got the Stinger SE"
	ItemName="Stinger SE"
}