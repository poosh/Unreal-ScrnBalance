class ScrnEightball extends Eightball;

var()   class<rocket> SeekingProjectileClass;


function bool HandlePickupQuery(inventory Item)
{
	if (Item.Class == class'Eightball') {
		class'ScrnUBalanceMut'.static.HandleDuplicateWeaponPickup(self, Weapon(Item));
		return true;
	}
	return super.HandlePickupQuery(Item);
}

// instant fire - no pre-loading
function Fire( float Value )
{
	//bFireMem = false;
	//bAltFireMem = false;
	bPointing = true;
	CheckVisibility();
	LockedTarget = none;  // no seeking rockets on normal fire
	if (AmmoType.UseAmmo(1)) {
		bFireLoad = true;  // fire rocket
		RocketsLoaded = 1;
		GoToState('FireRockets');
	}
}

// Finish a firing sequence
function Finish()
{
	local Pawn PawnOwner;

	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	PawnOwner = Pawn(Owner);
	if ( PlayerPawn(Owner) == None )
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		{
			PawnOwner.StopFiring();
			PawnOwner.SwitchToBestWeapon();
			if ( bChangeWeapon )
				GotoState('DownWeapon');
		}
		// else if ( (PawnOwner.bFire != 0) && (FRand() < RefireRate) )
		// 	Global.Fire(0);
		else if ( (PawnOwner.bAltFire != 0) && (FRand() < AltRefireRate) )
			Global.AltFire(0);
		else
		{
			PawnOwner.StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if ( ((AmmoType != None) && (AmmoType.AmmoAmount<=0)) || (PawnOwner.Weapon != self) )
		GotoState('Idle');
	// else if ( PawnOwner.bFire!=0 )
	// 	Global.Fire(0);
	else if ( PawnOwner.bAltFire!=0 )
		Global.AltFire(0);
	else
		GotoState('Idle');
}

state AltFiring
{
	function BeginState()
	{
		RocketsLoaded = 1;
		bFireLoad = true;  // fire rockets instead of grenades
	}

	function Fire(float F)
	{
		bFireLoad = false;  // launch grenades
		GoToState('FireRockets');
	}
}

// C&P to replace hardcoded projectile classes with class properties
state FireRockets
{
	function BeginState()
	{
		local vector FireLocation, StartLoc, X,Y,Z;
		local rotator FireRot;
		local rocket r;
		local grenade g;
		local float Angle;
		local pawn BestTarget;
		local int DupRockets;

		Angle = 0;
		DupRockets = RocketsLoaded - 1;
		if (DupRockets < 0) DupRockets = 0;
		if ( PlayerPawn(Owner) != None )
		{
			PlayerPawn(Owner).shakeview(ShakeTime, ShakeMag*RocketsLoaded, ShakeVert); //shake player view
			PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(650, 450, 190));
		}
		else
			bTightWad = ( FRand() * 4 < Pawn(Owner).skill );

		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		StartLoc = Owner.Location + CalcDrawOffset();
		FireLocation = StartLoc + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		if ( bFireLoad )
			AdjustedAim = pawn(owner).AdjustAim(ProjectileSpeed, FireLocation, AimError, True, bWarnTarget);
		else
			AdjustedAim = pawn(owner).AdjustToss(AltProjectileSpeed, FireLocation, AimError, True, bAltWarnTarget);

		GetAxes(AdjustedAim,X,Y,Z);
		PlayAnim( 'Fire', 0.6, 0.05);
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		if ( FiringSpeed > 0 )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		if ( (LockedTarget!=None) || !bFireLoad )
		{
			BestTarget = Pawn(CheckTarget());
			if ( (LockedTarget!=None) && (LockedTarget != BestTarget) )
			{
				LockedTarget = None;
				bLockedOn=False;
			}
		}
		else
			BestTarget = None;
		bPointing = true;
		FireRot = AdjustedAim;
		RocketRad = 4;
		if (bTightWad || !bFireLoad) RocketRad=7;
		While ( RocketsLoaded > 0 )
		{
			Firelocation = StartLoc - Sin(Angle)*Y*RocketRad + (Cos(Angle)*RocketRad - 10.78)*Z + X * (10 + 8 * FRand());
			if (bFireLoad)
			{
				if ( Angle > 0 && !bTightWad )
				{
					if ( Angle < 3 )
						FireRot = rotator(X-Y*(Angle/16.f));
					else if ( Angle > 3.5 )
						FireRot = rotator(X+Y*((Angle-3.f)/16.f));
					else FireRot = AdjustedAim;
				}
				if ( LockedTarget!=None )
				{
					r = Spawn(SeekingProjectileClass,, '', FireLocation,FireRot);
					r.Seeking = LockedTarget;
					r.NumExtraRockets = DupRockets;
				}
				else
				{
					r = rocket(Spawn(ProjectileClass,, '', FireLocation,FireRot));
					r.NumExtraRockets = DupRockets;
					if (RocketsLoaded>5 && bTightWad) r.bRing=True;
				}
				if ( Angle > 0 )
					r.Velocity *= (0.9 + 0.2 * FRand());
			}
			else
			{
				g = Grenade(Spawn(AltProjectileClass,, '', FireLocation,AdjustedAim));
				g.WarnTarget = ScriptedPawn(BestTarget);
				g.NumExtraGrenades = DupRockets;
				Owner.PlaySound(AltFireSound, SLOT_None, 3.0*Pawn(Owner).SoundDampening);
			}

			Angle += 1.0484; //2*3.1415/6;
			RocketsLoaded--;
		}
		bTightWad=False;
		//bFireMem = false;
		//bAltFireMem = false;
	}
}

defaultproperties
{
	ProjectileClass=class'ScrnRocket'
	AltProjectileClass=class'Grenade'
	SeekingProjectileClass=class'SeekingRocket'

	PickupMessage="You got the Eightball SE gun"
	ItemName="Eightball SE"
	RefireRate=0
}