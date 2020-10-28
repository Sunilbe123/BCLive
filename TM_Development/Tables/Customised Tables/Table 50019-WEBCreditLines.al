table 50019 "WEB Credit Lines"
{
    // version MITL14041
    CaptionML = ENU = 'WEB Credit Lines', ENG = 'WEB Credit Lines';


    fields
    {
        field(1; Sku; Text[100])
        {
            CaptionML = ENU = 'Sku', ENG = 'Sku';
        }
        field(2; Name; Text[100])
        {
            CaptionML = ENU = 'Name', ENG = 'Name';
        }
        field(3; Size; Text[100])
        {
            CaptionML = ENU = 'Size', ENG = 'Size';
        }
        field(4; QTY; Text[100])
        {
            CaptionML = ENU = 'QTY', ENG = 'QTY';
        }
        field(5; "Product Options"; Text[100])
        {
            CaptionML = ENU = 'Product Options', ENG = 'Product Options';
        }
        field(6; "Calculator Settings"; Text[100])
        {
            CaptionML = ENU = 'Calculator Settings', ENG = 'Calculator Settings';
        }
        field(7; "Order ID"; Text[100])
        {
            CaptionML = ENU = 'Order ID', ENG = 'Order ID';
        }
        field(8; "Line No"; Integer)
        {
            CaptionML = ENU = 'Line No', ENG = 'Line No';
        }

        field(9; Subtotal; Decimal)
        {
            CaptionML = ENU = 'Subtotal', ENG = 'Subtotal';
        }
        field(10; "Shipping & Handling"; Decimal)
        {
            CaptionML = ENU = 'Shipping & Handling', ENG = 'Shipping & Handling';
        }
        field(11; "Discount Amount"; Decimal)
        {
            CaptionML = ENU = 'Discount Amount', ENG = 'Discount Amount';
        }
        field(12; VAT; Decimal)
        {
            CaptionML = ENU = 'VAT', ENG = 'VAT';
        }
        field(13; "LineType"; Option)
        {
            CaptionML = ENU = 'Type', ENG = 'Type';
            OptionMembers = Insert,Modify,Delete;
        }
        field(14; "Date Time"; DateTime)
        {
            CaptionML = ENU = 'DateTime', ENG = 'DateTime';
        }
        field(15; "Unit Price"; Decimal)
        {
            CaptionML = ENU = 'Unit Price', ENG = 'Unit Price';
        }
        field(16; "Credit Memo ID"; Text[100])
        {
            CaptionML = ENU = 'Credit Memo ID', ENG = 'Credit Memo ID';
        }
        field(17; "Index No."; Code[20])
        {
            CaptionML = ENU = 'Index No.', ENG = 'Index No.';
        }
        field(18; Receipted2; DateTime)
        {
            CaptionML = ENU = 'Receipted2', ENG = 'Receipted2';
        }
        field(50000; "Location Code"; Code[10])
        {
            CaptionML = ENU = 'Location', ENG = 'Location';
            Description = 'MITL14041';
        }
        field(50001; "Dimension Code"; Code[20])
        {
            CaptionML = ENU = 'Dimension Code', ENG = 'Dimension Code';
            Description = 'Business Channel Dimension';
        }
    }

    keys
    {
        key(Key1; "Order ID", "LineType", "Date Time", "Line No")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Receipted2 := CURRENTDATETIME;
    end;
}

