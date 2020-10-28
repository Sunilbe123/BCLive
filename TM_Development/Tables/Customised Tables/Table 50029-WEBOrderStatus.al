table 50029 "WEB Order Status"
{
    CaptionML = ENU = 'WEB Order Status', ENG = 'WEB Order Status';

    fields
    {
        field(1; "Order ID"; Code[20])
        {
            CaptionML = ENU = 'Order ID', ENG = 'Order ID';
        }
        field(2; Status; Code[30])
        {
            CaptionML = ENU = 'Status', ENG = 'Status';
        }
    }

    keys
    {
        key(Key1; "Order ID")
        {
        }
    }

    fieldgroups
    {
    }
}

