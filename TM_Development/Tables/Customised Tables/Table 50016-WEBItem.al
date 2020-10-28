table 50016 "WEB Item"
{
    CaptionML = ENU = 'WEB Item', ENG = 'WEB Item';
    DrillDownPageID = "WEB Item List";
    LookupPageID = "WEB Item List";

    fields
    {
        field(1; Name; Text[100])
        {
            CaptionML = ENU = 'Name', ENG = 'Name';
        }
        field(2; SKU; Code[20])
        {
            CaptionML = ENU = 'SKU', ENG = 'SKU';
        }
        field(3; "Manufacturer SKU"; Text[100])
        {
            CaptionML = ENU = 'Manufacturer SKU', ENG = 'Manufacturer SKU';
        }
        field(4; Barcode; Text[30])
        {
            CaptionML = ENU = 'Barcode', ENG = 'Barcode';
        }
        field(5; Weight; Decimal)
        {
            CaptionML = ENU = 'Weight', ENG = 'Weight';
        }
        field(6; "Sample Cut Weight"; Decimal)
        {
            CaptionML = ENU = 'Sample Cut Weight', ENG = 'Sample Cut Weight';
        }
        field(7; Status; Text[250])
        {
            CaptionML = ENU = 'Status', ENG = 'Status';
        }
        field(8; Supplier; Text[250])
        {
            CaptionML = ENU = 'Supplier', ENG = 'Supplier';
        }
        field(9; Colour; Text[250])
        {
            CaptionML = ENU = 'Colour', ENG = 'Colour';
        }
        field(10; Price; Decimal)
        {
            CaptionML = ENU = 'Price', ENG = 'Price';
        }
        field(11; Description; Text[250])
        {
            CaptionML = ENU = 'Description', ENG = 'Description';
        }
        field(12; "Short Description"; Text[250])
        {
            CaptionML = ENU = 'Short Description', ENG = 'Short Description';
        }
        field(13; Inventory; Decimal)
        {
            CaptionML = ENU = 'Inventory', ENG = 'Inventory';
        }
        field(14; "Qty. On Sales Order"; Decimal)
        {
            CaptionML = ENU = 'Qty. On Sales Order', ENG = 'Qty. On Sales Order';
        }
        field(15; "LineType"; Option)
        {
            CaptionML = ENU = 'Type', ENG = 'Type';
            OptionMembers = Insert,Modify,Delete;
        }
        field(16; "Date Time"; DateTime)
        {
            CaptionML = ENU = 'DateTime', ENG = 'DateTime';
        }
        field(17; "Index No."; Code[20])
        {
            CaptionML = ENU = 'Index No.', ENG = 'Index No.';
        }
        field(18; Receipted; DateTime)
        {
            CaptionML = ENU = 'Receipted', ENG = 'Receipted';
        }
        field(19; "Qty Per SQM"; Decimal)
        {
            CaptionML = ENU = 'Qty Per SQM', ENG = 'Qty Per SQM';
        }
        field(20; Height; Decimal)
        {
            CaptionML = ENU = 'Height', ENG = 'Height';
        }
        field(21; Width; Decimal)
        {
            CaptionML = ENU = 'Width', ENG = 'Width';
        }
        field(22; "Vendor Number"; Text[50])
        {
            CaptionML = ENU = 'Vendor Number', ENG = 'Vendor Number';
        }
        field(23; "Item Created At"; DateTime)
        {
            CaptionML = ENU = 'Item Created At', ENG = 'Item Created At';
        }
    }

    keys
    {
        key(Key1; SKU, "LineType", "Date Time")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Index No." := WF.InsertIndex(50016, SKU, FORMAT("LineType"), FORMAT("Date Time"), '', '', '0');
        Receipted := CURRENTDATETIME;
    end;

    var
        WF: Codeunit "WEB Functions";
}

