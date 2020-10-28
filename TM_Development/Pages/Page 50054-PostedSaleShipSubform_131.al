pageextension 50054 PostedSaleShipSubform extends "Posted Sales Shpt. Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter(Correction)
        {
            field(WebOrderItemID; WebOrderItemID)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
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