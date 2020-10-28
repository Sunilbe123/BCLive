pageextension 50062 RegisteredMovemen extends "Registered Movement"
{
    layout
    {
        // Add changes to page layout here
        addafter("No. Printed")
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