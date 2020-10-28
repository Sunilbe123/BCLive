table 50020 "WEB Index"
{
    // version RM 17082015,R4451,R4501,230

    // RM - 17082015
    // Added Test field and "Table No." to key
    // 
    // R4451 - RM - 21.01.2016
    // Added Checked fielf after checking with Bilal
    // 
    // R4501 - RM - 29.01.2016
    // Added key Table No.,Key Field 1,Key Field 2,Key Field 3
    // MITL-SP  Case_230  06/08/18  New FIled "Order Created' Added

    CaptionML = ENU = 'WEB Index', ENG = 'WEB Index';
    DrillDownPageID = "WEB Index Monitoring ADMIN";
    LookupPageID = "WEB Index Monitoring ADMIN";

    fields
    {
        field(1; "Line no."; Integer)
        {
            CaptionML = ENU = 'Line no.', ENG = 'Line no.';
            AutoIncrement = true;
        }
        field(2; "Table No."; Integer)
        {
            CaptionML = ENU = 'Table No.', ENG = 'Table No.';
        }
        field(3; "Key Field 1"; Text[100])
        {
            CaptionML = ENU = 'Key Field 1', ENG = 'Key Field 1';
        }
        field(4; "Key Field 2"; Text[100])
        {
            CaptionML = ENU = 'Key Field 2', ENG = 'Key Field 2';
        }
        field(5; "Key Field 3"; Text[100])
        {
            CaptionML = ENU = 'Key Field 3', ENG = 'Key Field 3';
        }
        field(6; "Key Field 4"; Text[100])
        {
            CaptionML = ENU = 'Key Field 4', ENG = 'Key Field 4';
        }
        field(7; "Key Field 5"; Text[100])
        {
            CaptionML = ENU = 'Key Field 5', ENG = 'Key Field 5';
        }
        field(8; Status; Option)
        {
            CaptionML = ENU = 'Status', ENG = 'Status';
            OptionMembers = " ",Complete,Error,Ignored,"Awaiting Data Request";
        }
        field(9; Error; Text[250])
        {
            CaptionML = ENU = 'Error', ENG = 'Error';
        }
        field(10; "Table Name"; Text[80])
        {
            CaptionML = ENU = 'Table Name', ENG = 'Table Name';
        }
        field(11; Test; Boolean)
        {
            CaptionML = ENU = 'Test', ENG = 'Test';
        }
        field(12; "DateTime Inserted"; DateTime)
        {
            CaptionML = ENU = 'DateTime Inserted', ENG = 'DateTime Inserted';
        }
        field(13; "Order ID"; Code[20])
        {
            CaptionML = ENU = 'Order ID', ENG = 'Order ID';
        }
        field(14; Checked; Boolean)
        {
            CaptionML = ENU = 'Checked', ENG = 'Checked';
            Description = 'R4451';
        }
        field(50000; "Order Created"; Boolean)
        {
            CaptionML = ENU = 'Order Created', ENG = 'Order Created';
            Description = 'MITL-SP-230';
        }
        field(50010; "Pick Processed"; Boolean)
        {
            Description = 'MITL.VS.6702.FailedShip.20200819';
            CaptionML = ENG = 'Pick Processed', ENU = 'Pick Processed';
        }
    }

    keys
    {
        key(Key1; "Line no.")
        {
        }
        key(Key2; "Table No.")
        {
        }
        key(Key3; Test)
        {
        }
        key(Key4; "Table No.", "Key Field 1", "Key Field 2", "Key Field 3")
        {
        }
        key(key5; Status, "Table No.", "Line no.")
        {

        }
    }


    fieldgroups
    {
    }

    var
        WebFunctions: Codeunit "WEB Functions";

    procedure ShowWebDocument()
    begin
        WebFunctions.ShowWebDocument(Rec); //RM 05.11.2015
    end;


}

