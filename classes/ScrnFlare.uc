class ScrnFlare extends Flare;


function bool HandlePickupQuery(inventory Item)
{
	if (Item.Class == class'Flare') {
		NumCopies++;
		Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
		Item.PlaySound(Item.PickupSound,,2.0);
		Item.SetRespawn();
		return true;
	}
	return super.HandlePickupQuery(Item);
}

defaultproperties
{
	Charge=30  // up from 10
	ItemName="Flare SE"
}