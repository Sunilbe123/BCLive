table 50004 "Activity Tracking Audit"
{
    //version MITL2146(CASE227)
    //MITL2146 - New table created to capture the Nav activities which is happening from Handheld device for Audit purpose.
    CaptionML = ENU = 'Activity Tracking Audit', ENG = 'Activity Tracking Audit';

    fields
    {
        field(1; "Activity No."; Code[20])
        {
            CaptionML = ENU = 'Activity No.', ENG = 'Activity No.';
            Description = 'MITL2146';
        }
        field(2; "Activity Type"; Text[50])
        {
            CaptionML = ENU = 'Activity Type', ENG = 'Activity Type';
            Description = 'MITL2146';
        }
        field(3; "User Id"; Code[100])
        {
            CaptionML = ENU = 'User Id', ENG = 'User Id';
            Description = 'MITL2146';
            Editable = false;
        }
        field(4; "Device Id"; Code[100])
        {
            CaptionML = ENU = 'Device Id', ENG = 'Device Id';
            Description = 'MITL2146';
            Editable = false;
        }
        field(5; "Status"; Option)
        {
            CaptionML = ENU = 'Status', ENG = 'Status';
            Description = 'MITL2146';
            OptionMembers = Started,Finished;
            OptionCaptionML = ENU = 'Started,Finished', ENG = 'Started,Finished';
            Editable = false;
        }
        field(6; "Start DateTime"; DateTime)
        {
            CaptionML = ENU = 'Start DateTime', ENG = 'Start DateTime';
            Description = 'MITL2146';
            Editable = false;
        }
        field(7; "Finish DateTime"; DateTime)
        {
            CaptionML = ENU = 'Finish DateTime', ENG = 'Finish DateTime';
            Description = 'MITL2146';
            Editable = false;
        }
        field(8; "Location Code"; Code[10])
        {
            CaptionML = ENU = 'Location Code', ENG = 'Location Code';
            Description = 'MITL2146';
        }
        field(9; "Pick Order No."; Code[20])
        {
            CaptionML = ENU = 'Pick Order No.', ENG = 'Pick Order No.';
            Description = 'MITL2146';
        }
    }

    keys
    {
        key(PK; "Activity No.")
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