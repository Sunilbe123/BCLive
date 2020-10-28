tableextension 50075 WhseWorksheetName extends "Whse. Worksheet Name"
{
    //Version MITL13601
    fields
    {
        // Add changes to table fields here
        field(50000; "Direct Posting"; Boolean)
        {
            Caption = 'Direct Posting';
            Description='MITL13601';
        }
    }

    var
        myInt: Integer;
}