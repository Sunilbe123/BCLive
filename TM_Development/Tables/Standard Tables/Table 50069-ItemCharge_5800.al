tableextension 50069 ItemCharge extends "Item Charge"
{
    //MITL2147- Added a field "Charge Type" as per the specification document.
    fields
    {
        // Add changes to table fields here
        field(50000; "Type"; Option)
        {
            CaptionML = ENU = 'Type', ENG = 'Type';
            Description = 'MITL2147';
            OptionMembers = " ",Duty,Freight,Insurance,Other;
            OptionCaptionML = ENU = '" ",Duty,Freight,Insurance,Other', ENG = '" ",Duty,Freight,Insurance,Other';
        }
    }

    var
        myInt: Integer;
}