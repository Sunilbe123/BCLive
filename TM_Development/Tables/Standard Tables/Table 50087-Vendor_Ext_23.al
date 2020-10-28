tableextension 50087 "Vendor Ext" extends Vendor
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Vend. Bank Acc. Modified"; Boolean)
        {
            CaptionML = ENU = 'Vend. Bank Acc. Modified', ENG = 'Vend. Bank Acc. Modified';//MITL.SP.W&F
        }
    }

    var
        myInt: Integer;
}