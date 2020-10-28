table 50032 "Web Write Offs"
{
    //MITL2221
    CaptionML = ENU = 'Web Write Offs', ENG = 'Web Write Offs';
    fields
    {
        field(1; SKU; Code[20])
        {
            CaptionML = ENU = 'SKU', ENG = 'SKU';
            Description = 'MITL2221';
        }
        field(2; Quantity; Decimal)
        {
            CaptionML = ENU = 'Quantity', ENG = 'Quantity';
            Description = 'MITL2221';
        }
        field(3; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', ENG = 'Line No.';
            AutoIncrement = true;
            Description = 'MITL2221';
        }
        field(4; "Written Off"; Boolean)
        {
            CaptionML = ENU = 'Written Off', ENG = 'Written Off';
            Description = 'MITL2221';
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {

        }
    }

    fieldgroups
    {
    }
}


