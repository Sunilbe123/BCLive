pageextension 50099 "Job Queue Entries Ext" extends "Job Queue Entry Card"
{
    layout
    {
        // Add changes to page layout here
        addafter(Status)
        {
            field("Cronitor Function"; "Cronitor Function")
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