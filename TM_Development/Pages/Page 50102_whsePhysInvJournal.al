pageextension 50102 WhsePhysInvJournal extends "Whse. Phys. Invt. Journal"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("Calculate &Inventory")
        {
            //MITL.MF.5409 Added action for calculating Inventory with odd/even bin flag ++
            action("Calculate Inventory with odd/Even flag")
            {
                Image = CalculateInventory;
                Promoted = true;
                PromotedIsBig = true;
                trigger
                OnAction()
                var
                    BinContent: Record "Bin Content";
                    WhseCalcInventory: Report "Whse. Calculate Inventory 1";
                begin
                    BinContent.SETRANGE("Location Code", "Location Code");
                    WhseCalcInventory.SetWhseJnlLine(Rec);
                    WhseCalcInventory.SETTABLEVIEW(BinContent);
                    WhseCalcInventory.SetProposalMode(TRUE);
                    WhseCalcInventory.RUNMODAL;
                    CLEAR(WhseCalcInventory);
                end;
            }
            //MITL.MF.5409 --
        }
    }

    var
        myInt: Integer;


}