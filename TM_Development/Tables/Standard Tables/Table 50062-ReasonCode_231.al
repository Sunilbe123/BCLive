tableextension 50062 ReasonCode extends "Reason Code"
{ //MITL2148 - New field added for selecting "Gen. Bus. Posting Group" per reason code.
    fields
    {
        // Add changes to table fields here
        field(50000; "Gen. Bus. Posting Group"; Code[10])
        {
            CaptionML = ENU = 'Gen. Bus. Posting Group', ENG = 'Gen. Bus. Posting Group';
            Description = 'MITL2148';
            TableRelation = "Gen. Business Posting Group";
        }
    }

    var
        myInt: Integer;
}