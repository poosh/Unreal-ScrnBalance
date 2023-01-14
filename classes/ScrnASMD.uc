class ScrnASMD extends ASMD;

var() int spMaxAmmo;
var float HeadshotMult;

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
	if (Item.Class == class'ASMD') {
		class'ScrnUBalanceMut'.static.HandleDuplicateWeaponPickup(self, Weapon(Item));
		return true;
	}
	return super.HandlePickupQuery(Item);
}

// C&P to add headshot detection
function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local vector SmokeLocation,DVector;
	local rotator SmokeRotation;
	local float NumPoints,Mult;
	local class<RingExplosion> rc;
	local RingExplosion r;
	local ZoneInfo HitZone;
	local byte HitCount;
	local name DamType;
	local Pawn Victim;

	DamType = MyDamageType;
	if (Other==None)
	{
		HitNormal = -X;
		HitLocation = Owner.Location + X*10000.0;
	}

	if (Amp!=None) Mult = Amp.UseCharge(100);
	else Mult=1.0;
	SmokeLocation = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * 3.3 * Y + FireOffset.Z * Z * 3.0;

	/* Check if were passing through warp zones */
	while ( HitCount++<5 )
	{
		DVector = HitLocation - SmokeLocation;
		NumPoints = VSize(DVector)/70.0;
		SmokeRotation = rotator(HitLocation-SmokeLocation);
		SmokeLocation += DVector/NumPoints;
		if (NumPoints>15) NumPoints=15;
		if ( NumPoints>1.0 ) SpawnEffect(DVector, NumPoints, SmokeRotation, SmokeLocation);

		if ( Other==None )
			Break;
		HitZone = Level.GetLocZone(HitLocation+HitNormal).Zone;
		if ( WarpZoneInfo(HitZone)==None || WarpZoneInfo(HitZone).OtherSideActor==None )
			Break;
		SmokeLocation = HitLocation;
		WarpZoneInfo(HitZone).UnWarp(SmokeLocation,X,SmokeRotation);
		WarpZoneInfo(HitZone).OtherSideActor.Warp(SmokeLocation,X,SmokeRotation);
		Z = SmokeLocation+X*8000;
		Other = Trace(HitLocation,HitNormal,Z,SmokeLocation,True); // We dont use owner pawn trace here because we could hit ourselves.
		while ( Other!=None && Other.bIsPawn && !Pawn(Other).AdjustHitLocation(HitLocation, Z - SmokeLocation) )
		{
			SmokeLocation = HitLocation;
			Other = Other.Trace(HitLocation,HitNormal,Z,SmokeLocation,True);
		}
	}

	Victim = Pawn(Other);

	if (Victim == none && TazerProj(Other) != none)
	{
		AmmoType.UseAmmo(2);
		Other.Instigator = Pawn(Owner);
		TazerProj(Other).SuperExplosion();
	}
	else
	{
		if (Victim != none && !Level.Game.bDeathMatch && Victim.IsHeadShot(HitLocation, X)) {
			Mult *= HeadshotMult;
			DamType = 'decapitated';
		}

		if (Mult>1.5)
			rc = class'RingExplosion3';
		else
			rc = class'RingExplosion';

		r = Spawn(rc,,, HitLocation+HitNormal*8,rotator(HitNormal));
		if ( r != None )
			r.PlaySound(r.ExploSound,,6);
	}

	if ( Other!=None )
		Other.TakeDamage(HitDamage*Mult, Pawn(Owner), HitLocation, 50000.0*X, DamType);
}

defaultproperties
{
	spMaxAmmo=80  // up from 50
	HeadshotMult=2.0
	PickupMessage="You got the ASMD SE"
	ItemName="ASMD SE"
}