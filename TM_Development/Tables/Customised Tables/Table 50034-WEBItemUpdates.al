table 50034 "WEB Item Updates"
{
    CaptionML = ENU = 'WEB Item Updates', ENG = 'WEB Item Updates';

    fields
    {
        field(1; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', ENG = 'Line No.';
            AutoIncrement = true;
        }
        field(2; SKU; Code[20])
        {
            CaptionML = ENU = 'SKU', ENG = 'SKU';
        }
        field(3; "Reason for Update"; Text[30])
        {
            CaptionML = ENU = 'Reason for Update', ENG = 'Reason for Update';
        }
        field(4; Completed; Boolean)
        {
            CaptionML = ENU = 'Completed', ENG = 'Completed';
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

