pageextension 50060 WhseMovementCard extends "Warehouse Movement"

{
    layout
    {
        // Add changes to page layout here
        addafter("Sorting Method")
        {
            field("Movement Type"; "Movement Type")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Editable = false;
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