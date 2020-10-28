table 50017 "WEB Item Attribute"
{
    CaptionML = ENU = 'WEB Item Attribute', ENG = 'WEB Item Attribute';

    fields
    {
        field(1; Sku; Code[20])
        {
            CaptionML = ENU = 'Sku', ENG = 'Sku';
        }
        field(2; Attibute; Text[30])
        {
            CaptionML = ENU = 'Attibute', ENG = 'Attibute';
        }
        field(3; "Attribute Value"; Text[250])
        {
            CaptionML = ENU = 'Attribute Value', ENG = 'Attribute Value';
        }
        field(4; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', ENG = 'Line No.';
        }
        field(5; "LineType"; Option)
        {
            CaptionML = ENU = 'Type', ENG = 'Type';
            OptionMembers = Insert,Modify,Delete;
        }
        field(6; "Date Time"; DateTime)
        {
            CaptionML = ENU = 'DateTime', ENG = 'DateTime';
        }
        field(7; "Index No."; Code[20])
        {
            CaptionML = ENU = 'Index No.', ENG = 'Index No.';
        }
        field(8; Receipted; DateTime)
        {
            CaptionML = ENU = 'Receipted', ENG = 'Receipted';
        }
    }

    keys
    {
        key(Key1; Sku, Attibute, "LineType", "Date Time", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Index No." := WF.InsertIndex(50017, Sku, Attibute, FORMAT("LineType"), FORMAT("Date Time"), '', '0');
        Receipted := CURRENTDATETIME;
    end;

    var
        WF: Codeunit "WEB Functions";
}

