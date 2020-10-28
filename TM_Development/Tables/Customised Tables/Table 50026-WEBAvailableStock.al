table 50026 "WEB Available Stock"
{
    CaptionML = ENU = 'WEB Available Stock', ENG = 'WEB Available Stock';

    fields
    {
        field(1; SKU; Code[20])
        {
            CaptionML = ENU = 'SKU', ENG = 'SKU';
        }
        field(2; "Available Quantity"; Decimal)
        {
            CaptionML = ENU = 'Available Quantity', ENG = 'Available Quantity';
        }
        field(3; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', ENG = 'Line No.';
            AutoIncrement = true;
        }
        field(4; "Average Cost"; Decimal)
        {
            CaptionML = ENU = 'Average Cost', ENG = 'Average Cost';
        }
    }

    keys
    {
        key(Key1; SKU, "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

