table 50025 "WEB Log"
{
    CaptionML = ENU = 'WEB Log', ENG = 'WEB Log';

    fields
    {
        field(1; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', ENG = 'Line No.';
            AutoIncrement = true;
        }
        field(2; Note; Text[250])
        {
            CaptionML = ENU = 'Note', ENG = 'Note';
        }
        field(3; "Order ID"; Code[20])
        {
            CaptionML = ENU = 'Order ID', ENG = 'Order ID';
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

