table 50011 "WEB Order Lines"
{
    //SM_Business Channel - New field created in Web Order Header and Line for passing the value of Business Channel from Magento to NAV Dimensions.
    CaptionML = ENU = 'WEB Order Lines', ENG = 'WEB Order Lines';
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
        field(6; "Calculator Settings"; Text[250])
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
        field(16; "Item No. Exists"; Boolean)
        {
            CaptionML = ENU = 'Item No. Exists', ENG = 'Item No. Exists';
            CalcFormula = Exist (Item WHERE ("No." = FIELD (Sku)));
            FieldClass = FlowField;
        }
        field(17; Receipted; DateTime)
        {
            CaptionML = ENU = 'Receipted', ENG = 'Receipted';
        }
        field(18; "Cut Size"; Boolean)
        {
            CaptionML = ENU = 'Cut Size', ENG = 'Cut Size';
            Description = 'RM 11122015';
        }
        field(19; "Cut Sample Location"; Code[20])
        {
            CaptionML = ENU = 'Cut Sample Location', ENG = 'Cut Sample Location';
        }
        field(20; "Location Code"; Code[20])
        {
            CaptionML = ENU = 'Location Code', ENG = 'Location Code';
        }
        field(50000; "Dimension Code"; Code[20])
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
        Receipted := CURRENTDATETIME;
    end;
}

