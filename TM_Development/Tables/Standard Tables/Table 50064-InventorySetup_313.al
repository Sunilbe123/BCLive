tableextension 50064 InventorySetup extends "Inventory Setup"
{
    //version MITL2219
    //MITL2219 - Added new fields for Scale Integration Requirement
    fields
    {
        // Add changes to table fields here
        field(50000; "Weight Tolerence Percentage"; Decimal)
        {
            Description = 'MITL2219';
            CaptionML = ENU = 'Weight Tolerence Percentage', ENG = 'Weight Tolerence Percentage';
        }
    }

    var
        myInt: Integer;
}