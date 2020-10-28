table 50007 "Scanner Scans"
{
    CaptionML = ENU = 'Scanner Scans', ENG = 'Scanner Scans';

    fields
    {
        field(1; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', ENG = 'Line No.';
            AutoIncrement = true;
        }
        field(2; "Item No."; Code[50])
        {
            CaptionML = ENU = 'Item No.', ENG = 'Item No.';
        }
        field(3; Emailed; Boolean)
        {
            CaptionML = ENU = 'Emailed', ENG = 'Emailed';
        }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
    }

    var
    // myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}