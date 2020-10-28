tableextension 50068 RegisteredWhseActivityLine extends "Registered Whse. Activity Line"
{
    //version MITL2219
    //MITL2219 - new field added for Scale integration
    fields
    {
        // Add changes to table fields here
        field(50000; "Measured Weight"; Decimal)
        {
            Description = 'MITL2219';
            CaptionML = ENU = 'Measured Weight', ENG = 'Measured Weight';
            Editable = false;
        }
        field(50001; "Weight Difference"; Decimal)
        {
            Description = 'MITL2219';
            CaptionML = ENU = 'Weight Difference', ENG = 'Weight Difference';
            Editable = false;
        }
    }

    var
        myInt: Integer;
}