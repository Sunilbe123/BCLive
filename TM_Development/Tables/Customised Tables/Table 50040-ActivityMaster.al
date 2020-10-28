table 50040 "Activity Master"
{
    //Versionm MITL13989
    CaptionML = ENU = 'Activity Master', ENG = 'Activity Master';
    DrillDownPageId = "Activity Master";
    LookupPageId = "Activity Master";
    fields
    {
        field(1; "Activity Code"; Code[20])
        {
            CaptionML = ENU = 'Activity Code', ENG = 'Activity Code';
            Description = 'MITL13989';
        }
        field(2; "Description"; Text[100])
        {
            CaptionML = ENU = 'Description', ENG = 'Description';
            Description = 'MITL13989';
        }
        field(3; "Activity Barcode"; Code[20])
        {
            CaptionML = ENU = 'Activity Barcode', ENG = 'Activity Barcode';
            Description = 'MITL13989';
        }
        field(4; "Activity Type"; Option)
        {
            CaptionML = ENU = 'Activity Type', ENG = 'Activity Type';
            Description = 'MITL13989';
            OptionMembers = ,"Start of day","End of day";
            OptionCaptionML = ENU = ' ,Start of day,End of day', ENG = ' ,Start of day,End of day';
            trigger OnValidate()
            var
            // myInt: Integer;
            begin
                //MITL13989 ++
                IF "Activity Type" IN ["Activity Type"::"End of day", "Activity Type"::"Start of day"] THEN BEGIN
                    SETFILTER("Activity Type", '%1', "Activity Type");
                    IF FINDFIRST THEN
                        ERROR('Only one Start/End activity can exist in the activity master');
                END ELSE
                    EXIT;
                //MITL13989 **
            end;
        }
    }

    keys
    {
        key(PK; "Activity Code")
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