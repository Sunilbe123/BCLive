tableextension 50052 PurchaseLine extends "Purchase Line"
{
    fields
    {
        // Add changes to table fields here
        field(50001; Size; Text[30])
        {
            CaptionML = ENU = 'Size', ENG = 'Size';
            Description = 'MITL1600';
            Editable = false;
        }
    }

    var
        myInt: Integer;
}