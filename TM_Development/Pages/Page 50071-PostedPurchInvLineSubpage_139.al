pageextension 50071 PostedPurchInvLineSubpage extends "Posted Purch. Invoice Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("Variant Code")
        {
            field(Size; Size)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL1600';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}