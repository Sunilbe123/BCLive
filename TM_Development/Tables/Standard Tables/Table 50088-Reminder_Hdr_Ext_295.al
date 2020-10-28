tableextension 50088 "Reminder Header Ext" extends "Reminder Header"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Issue Reminder"; Boolean)
        {
            CaptionML = ENU = 'Issue Reminder', ENG = 'Issue Reminder';//MITL.SP.W&F
        }
    }

    var
        myInt: Integer;
}