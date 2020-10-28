table 50041 "Activity Status"
{
    //version MITL13989
    CaptionML = ENU = 'Activity Status', ENG = 'Activity Status';
    DrillDownPageId = "Activity Status";
    LookupPageId = "Activity Status";
    fields
    {
        field(1; "Device ID"; Code[100])
        {
            CaptionML = ENU = 'Device ID', ENG = 'Device ID';
            Description = 'MITL13989';
        }
        field(2; "Mobile User ID"; Code[50])
        {
            CaptionML = ENU = 'Mobile User ID', ENG = 'Mobile User ID';
            Description = 'MITL13989';
        }
        field(3; "Location Code"; Code[10])
        {
            CaptionML = ENU = 'Location Code', ENG = 'Location Code';
            Description = 'MITL13989';
        }
        field(4; "Activity Code"; Code[20])
        {
            CaptionML = ENU = 'Activity Code', ENG = 'Activity Code';
            Description = 'MITL13989';
            TableRelation = "Activity Master"."Activity Code";
        }
        field(5; "Activity Description"; Text[50])
        {
            CaptionML = ENU = 'Activity Description', ENG = 'Activity Description';
            Description = 'MITL13989';
            TableRelation = "Activity Master".Description WHERE ("Activity Code" = FIELD ("Activity Code"));
        }
        field(6; "Status"; Option)
        {
            CaptionML = ENU = 'Status', ENG = 'Status';
            Description = 'MITL13989';
            OptionMembers = ,Inprogress,Completed;
            OptionCaptionML = ENU = ' ,Inprogress,Completed', ENG = ' ,Inprogress,Completed';
        }
        field(7; "Start Date"; Date)
        {
            CaptionML = ENU = 'Start Date', ENG = 'Start Date';
            Description = 'MITL13989';
        }
        field(8; "Start Time"; DateTime)
        {
            CaptionML = ENU = 'Start Time', ENG = 'Start Time';
            Description = 'MITL13989';
        }
        field(9; "End Date"; Date)
        {
            CaptionML = ENU = 'End Date', ENG = 'End Date';
            Description = 'MITL13989';
        }
        field(10; "End Time"; DateTime)
        {
            CaptionML = ENU = 'End Time', ENG = 'End Time';
            Description = 'MITL13989';
            trigger OnValidate()
            var
            // myInt: Integer;
            begin
                "Activity Time Taken" := "End Time" - "Start Time"; //MITL13989
            end;
        }
        field(11; "Activity Time Taken"; Duration)
        {
            CaptionML = ENU = 'Activity Time Taken', ENG = 'Activity Time Taken';
            Description = 'MITL13989';
        }
        field(12; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', ENG = 'Line No.';
            Description = 'MITL13989';
        }
    }

    keys
    {
        key(PK; "Device ID", "Mobile User ID", "Line No.", "Start Date")
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