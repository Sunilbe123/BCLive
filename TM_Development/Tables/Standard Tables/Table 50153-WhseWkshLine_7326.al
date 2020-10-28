tableextension 50153 WhseWkshLine extends "Whse. Worksheet Line"
{
    //version MITL13601
    fields
    {
        // Add changes to table fields here
        field(50000; "Movement Type"; Option)
        {
            Description = 'MITL13601';
            CaptionML = ENU = 'Movement Type', ENG = 'Movement Type';
            OptionMembers = " ","Order Cancellation","Bin Replenishment";
        }
    }

    var
        myInt: Integer;
}