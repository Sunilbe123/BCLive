pageextension 50061 WhseWorksheetNames extends "Whse. Worksheet Names"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("Direct Posting"; "Direct Posting")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                CaptionML = ENU = 'For Auto Movement Creation', ENG = 'For Auto Movement Creation';
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