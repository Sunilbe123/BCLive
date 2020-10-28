pageextension 50064 WhseMovements extends "Warehouse Movements"
{
    layout
    {
        // Add changes to page layout here
        addafter("Assignment Date")
        {
            field("Movement Type"; "Movement Type")
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