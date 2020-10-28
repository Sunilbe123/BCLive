pageextension 50074 ValueEntries extends "Value Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter("Item No.")
        {
            field("Reason Code"; "Reason Code")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL14137';
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