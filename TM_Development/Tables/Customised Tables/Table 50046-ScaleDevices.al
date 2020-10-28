table 50046 "Scale Devices"
{
    //Version MITL2219
    Caption = 'Scale Devices';
    fields
    {
        field(1; "Device ID"; Code[100])
        {
            CaptionML = ENU = 'Device ID', ENG = 'Device ID';
            Description = 'MITL2219';
        }
        field(2; "Device MAC Address"; Code[20])
        {
            CaptionML = ENU = 'Device MAC Address', ENG = 'Device MAC Address';
            Description = 'MITL2219';
        }
        field(3; "Device Name"; Text[80])
        {
            CaptionML = ENU = 'Device Name', ENG = 'Device Name';
            Description = 'MITL2219';
        }
        field(4; "Device Enabled"; Boolean)
        {
            CaptionML = ENU = 'Device Enabled', ENG = 'Device Enabled';
            Description = 'MITL2219';
        }
        field(5; "Disable Scale Integration"; Boolean)
        {
            CaptionML = ENU = 'Disable Scale Integration', ENG = 'Disable Scale Integration';
            Description = 'MITL2219';
        }
    }

    keys
    {
        key(PK; "Device ID")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

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