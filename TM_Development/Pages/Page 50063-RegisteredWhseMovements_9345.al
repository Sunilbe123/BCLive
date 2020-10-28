pageextension 50063 RegWhseMovements extends "Registered Whse. Movements"
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