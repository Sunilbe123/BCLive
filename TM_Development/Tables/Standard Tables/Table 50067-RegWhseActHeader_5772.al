tableextension 50067 RegWhseActivityHead extends "Registered Whse. Activity Hdr."
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Movement Type"; Option)
        {
            Description = 'MITL13601';
            OptionMembers = "","Order Cancellation","Bin Replenishment";
        }
    }

    var
        myInt: Integer;
}