table 50015 "WEB Shipment Lines"
{
    CaptionML = ENU = 'WEB Shipment Lines', ENG = 'WEB Shipment Lines';

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
        field(15; "Shipment ID"; Text[100])
        {
            CaptionML = ENU = 'Shipment ID', ENG = 'Shipment ID';
        }
        field(16; Receipted; DateTime)
        {
            CaptionML = ENU = 'Receipted', ENG = 'Receipted';
        }
    }

    keys
    {
        key(Key1; "Order ID", "LineType", "Date Time", "Line No")
        {
        }
        key(Key2; "Shipment ID", "LineType")
        {
            Description = 'MITL.AJ.20200603 Indexing correction';
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

