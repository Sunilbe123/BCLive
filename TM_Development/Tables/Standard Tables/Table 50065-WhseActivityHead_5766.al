tableextension 50065 WhseActivityHeader extends "Warehouse Activity Header"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Movement Type"; Option)
        {
            Description = 'MITL13601';
            OptionMembers = " ","Order Cancellation","Bin Replenishment";
            CaptionML = ENU = 'Movement Type', ENG = 'Movement Type';
        }
        field(50001; "Latest Dispatch Date"; Date)
        {
            Description = 'MITL332';
            CaptionML = ENU = 'Latest Dispatch Date', ENG = 'Latest Dispatch Date';
        }

    }

    var
    // myInt: Integer;
}