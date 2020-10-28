table 50013 "WEB Customer Ship-To"
{
    // version R4359

    // R4359 - RM - 18.12.2015
    // Added key Customer Email
    CaptionML = ENU = 'WEB Customer Ship-To', ENG = 'WEB Customer Ship-To';

    fields
    {
        field(1; "Customer ID"; Code[10])
        {
            CaptionML = ENU = 'Customer ID', ENG = 'Customer ID';
        }
        field(2; "Customer Email"; Text[100])
        {
            CaptionML = ENU = 'Customer Email', ENG = 'Customer Email';
        }
        field(3; "Ship-To First Name"; Text[100])
        {
            CaptionML = ENU = 'Ship-To First Name', ENG = 'Ship-To First Name';
        }
        field(4; "Ship-To Last Name"; Text[100])
        {
            CaptionML = ENU = 'Ship-To Last Name', ENG = 'Ship-To Last Name';
        }
        field(5; "Ship-To Company"; Text[100])
        {
            CaptionML = ENU = 'Ship-To Company', ENG = 'Ship-To Company';
        }
        field(6; "Ship-To Street 1"; Text[100])
        {
            CaptionML = ENU = 'Ship-To Street 1', ENG = 'Ship-To Street 1';
        }
        field(7; "Ship-To Street 2"; Text[100])
        {
            CaptionML = ENU = 'Ship-To Street 2', ENG = 'Ship-To Street 2';
        }
        field(8; "Ship-To Street 3"; Text[100])
        {
            CaptionML = ENU = 'Ship-To Street 3', ENG = 'Ship-To Street 3';
        }
        field(9; "Ship-To City"; Text[100])
        {
            CaptionML = ENU = 'Ship-To City', ENG = 'Ship-To City';
        }
        field(10; "Ship-To Postcode"; Text[100])
        {
            CaptionML = ENU = 'Ship-To Postcode', ENG = 'Ship-To Postcode';
        }
        field(11; "Ship-To Country"; Text[100])
        {
            CaptionML = ENU = 'Ship-To Country', ENG = 'Ship-To Country';
        }
        field(12; "Ship-To Telephone"; Text[100])
        {
            CaptionML = ENU = 'Ship-To Telephone', ENG = 'Ship-To Telephone';
        }
        field(13; "Ship-To Mobile"; Text[100])
        {
            CaptionML = ENU = 'Ship-To Mobile', ENG = 'Ship-To Mobile';
        }
        field(14; "Order ID"; Code[20])
        {
            CaptionML = ENU = 'Order ID', ENG = 'Order ID';
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
    }

    keys
    {
        key(Key1; "Customer ID", "Customer Email", "Order ID", "LineType", "Date Time")
        {
        }
        key(Key2; "Customer Email")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Index No." := WF.InsertIndex(50013, "Customer ID", "Customer Email", "Order ID", FORMAT("LineType"), FORMAT("Date Time"), "Order ID");
        Receipted := CURRENTDATETIME;
    end;

    var
        WF: Codeunit "WEB Functions";
}

