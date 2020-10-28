table 50042 "Scale Weight Capture"
{
    //version MITL225
    CaptionML = ENU = 'Scale Weight Capture', ENG = 'Scale Weight Capture';

    fields
    {
        field(1; "Device Id"; Code[100])
        {
            CaptionML = ENU = 'Device Id', ENG = 'Device Id';
            Description = 'MITL225';
        }
        field(2; "Pallet Weight"; Decimal)
        {
            CaptionML = ENU = 'Pallet Weight', ENG = 'Pallet Weight';
            Description = 'MITL225';
        }
    }

    keys
    {
        key(PK; "Device Id")
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