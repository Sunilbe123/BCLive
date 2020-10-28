pageextension 50075 ReasonCodes extends "Reason Codes"
{ //MITL2148 - added "Gen. Bus. Posting Group" field on the page.
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL2148';
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