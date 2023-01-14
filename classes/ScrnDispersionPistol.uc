class ScrnDispersionPistol extends DispersionPistol;

var float AmpCharge;
var float dmAmpCharge;

var() float RechargeDelayCooldown, RechargeDelay, RechargeDelay2;

struct SPowerLevel {
	var name ShootAnim;
	var float ShootAnimRate;
	var int AmmoPerShot;
	var int Damage;
	var class<DispersionAmmo> ProjClass;
};
var SPowerLevel PowerLevels[5];

function bool HandlePickupQuery(inventory Item)
{
	if (Item.Class == class'DispersionPistol') {
		class'ScrnUBalanceMut'.static.HandleDuplicateWeaponPickup(self, Weapon(Item));
		return true;
	}
	return super.HandlePickupQuery(Item);
}

function Timer()
{
	if (AmmoType.AddAmmo(1)) {
		if (AmmoType.AmmoAmount < AmmoType.default.MaxAmmo)
			SetTimer(RechargeDelay, false);
		else
			SetTimer(RechargeDelay2, false);
	}
}

function PlayFiring()
{
	AmmoType.GoToState('');
	SetTimer(RechargeDelayCooldown, false);

	Owner.PlaySound(AltFireSound, SLOT_None, 1.8*Pawn(Owner).SoundDampening,,,1.2);
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);

	PlayAnim(PowerLevels[PowerLevel].ShootAnim, PowerLevels[PowerLevel].ShootAnimRate, 0.2);
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;
	local DispersionAmmo da;
	local float Mult;
	local int pl;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);

	if (Amp != none) {
		if (Level.Game.bDeathMatch) {
			Mult = Amp.UseCharge(dmAmpCharge);
		}
		else {
			Mult = Amp.UseCharge(AmpCharge);
		}
	}
	else {
		Mult=1.0;
	}

	if (AmmoType.AmmoAmount < 10) {
		pl = 0;
		if (AmmoType.AmmoAmount < 1 && Level.Game.bDeathMatch) {
			// never run out of ammo in DM
			AmmoType.AmmoAmount = 1;
		}

	}
	else {
		pl = PowerLevel;
	}

	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, (3.5*FRand() - 1 < pl));

	// 1 ammo is already used in Fire()
	if (PowerLevels[pl].AmmoPerShot <= 1 || AmmoType.UseAmmo(PowerLevels[pl].AmmoPerShot - 1)) {
		da = spawn(PowerLevels[pl].ProjClass,,, Start,AdjustedAim);
	}
	if (da != None && Mult > 1.0) {
		da.InitSplash(Mult);
	}
	return da;
}

state AltFiring
{
	function Timer()
	{
		// do not recharge while charging
		SetTimer(RechargeDelayCooldown, false);
	}

}

state ShootLoad
{
	function BeginState()
	{
		local DispersionAmmo d;
		local Vector Start, X,Y,Z;
		local float Mult;

		if (Amp!=None) Mult = Amp.UseCharge(ChargeSize*50+50);
		else Mult=1.0;

		Owner.PlaySound(AltFireSound, SLOT_Misc, 1.8*Pawn(Owner).SoundDampening);
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag*ChargeSize, ShakeVert);

		PlayAnim(PowerLevels[PowerLevel].ShootAnim, 0.2, 0.05);
		Pawn(Owner).PlayRecoil(FiringSpeed);

		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		AdjustedAim = pawn(owner).AdjustAim(AltProjectileSpeed, Start, AimError, True, True);
		d = DispersionAmmo(Spawn(AltProjectileClass,,, Start,AdjustedAim));
		if ( d != None )
		{
			d.bAltFire = ChargeSize > 0.3;
			d.DrawScale = 0.5 + fmax(ChargeSize*0.6, 0.5);
			d.InitSplash(d.DrawScale * Mult * 1.1);
		}
		SetTimer(RechargeDelayCooldown, false);
	}

Begin:
	FinishAnim();
	Finish();
}

defaultproperties
{
	PickupMessage="You got the Dispersion Pistol SE"
	ItemName="Dispersion Pistol SE"
	AmpCharge=50
	dmAmpCharge=80
	RechargeDelayCooldown=3.0
	RechargeDelay=1.0
	RechargeDelay2=2.0
	PowerLevels(0)=(ShootAnim="Shoot1",ShootAnimRate=0.4,AmmoPerShot=1,Damage=15,ProjClass=class'DispersionAmmo')
	PowerLevels(1)=(ShootAnim="Shoot2",ShootAnimRate=0.4,AmmoPerShot=2,Damage=28,ProjClass=class'DAmmo2')
	PowerLevels(2)=(ShootAnim="Shoot3",ShootAnimRate=0.4,AmmoPerShot=3,Damage=39,ProjClass=class'DAmmo3')
	PowerLevels(3)=(ShootAnim="Shoot4",ShootAnimRate=0.4,AmmoPerShot=4,Damage=48,ProjClass=class'DAmmo4')
	PowerLevels(4)=(ShootAnim="Shoot5",ShootAnimRate=0.4,AmmoPerShot=5,Damage=55,ProjClass=class'DAmmo5')
}