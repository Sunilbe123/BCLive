table 50031 "WEB Combined Picks"
{
    CaptionML = ENU = 'WEB Combined Picks', ENG = 'WEB Combined Picks';

    fields
    {
        field(1; "Order No."; Code[20])
        {
            CaptionML = ENU = 'Order No.', ENG = 'Order No.';
        }
        field(2; "Pick No."; Code[20])
        {
            CaptionML = ENU = 'Pick No.', ENG = 'Pick No.';
        }
        field(3; Quantity; Decimal)
        {
            CaptionML = ENU = 'Quantity', ENG = 'Quantity';
        }
        field(4; SKU; Code[20])
        {
            CaptionML = ENU = 'SKU', ENG = 'SKU';
        }
        field(5; Created; Boolean)
        {
            CaptionML = ENU = 'Created', ENG = 'Created';
        }
        field(6; "Order Line No."; Integer)
        {
            CaptionML = ENU = 'Order Line No.', ENG = 'Order Line No.';
        }
    }

    keys
    {
        key(Key1; "Order No.", "Order Line No.", "Pick No.", SKU)
        {
        }
        key(key2; Created)
        {

        }
    }

    fieldgroups
    {
    }
}

