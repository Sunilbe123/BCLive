table 50009 "WEB Customer"
{
    // version RM 19082015,R4359

    // R4359 - RM - 18.12.2015
    // Added key Email
    CaptionML = ENU = 'WEB Customer', ENG = 'WEB Customer';

    DrillDownPageID = "WEB Customer List";
    LookupPageID = "WEB Customer List";

    fields
    {
        field(1; Email; Text[100])
        {
            CaptionML = ENU = 'Email', ENG = 'Email';
        }
        field(2; "Customer ID"; Text[100])
        {
            CaptionML = ENU = 'Customer ID', ENG = 'Customer ID';
        }
        field(3; "Customer Group"; Text[100])
        {
            CaptionML = ENU = 'Customer Group', ENG = 'Customer Group';
        }
        field(4; "IP address"; Text[100])
        {
            CaptionML = ENU = 'IP address', ENG = 'IP address';
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
        field(50000; Receipted; DateTime)
        {
            CaptionML = ENU = 'Receipted', ENG = 'Receipted';
        }
        field(50001; "Dimension Code"; Code[20])
        {
            CaptionML = ENU = 'Dimension Code', ENG = 'Dimension Code';
            Description = 'Business Channel Dimension';
        }
        //MITL_MF_5480++
        field(50002; "Wholesale Customer"; Boolean)
        {
            CaptionML = ENU = 'Wholesale Customer', ENG = 'Wholesale Customer';

        }
        //MITL_MF_5480--
    }

    keys
    {
        key(Key1; "Customer ID", Email, "LineType", "Date Time")
        {
        }
        key(Key2; Email)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        //Email := LOWERCASE(Email);
        "Index No." := WF.InsertIndex(50009, "Customer ID", Email, FORMAT("LineType"), FORMAT("Date Time"), '', '0');
        Receipted := CURRENTDATETIME;
    end;

    var
        WF: Codeunit "WEB Functions";
}

