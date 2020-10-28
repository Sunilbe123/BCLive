pageextension 50076 ItemCharges extends "Item Charges"
{
    //MITL2147 - Added a field "Charge Type" as per the specification document.
    layout
    {
        // Add changes to page layout here
        addafter("No.")
        {
            field("Type"; "Type")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL2147';
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