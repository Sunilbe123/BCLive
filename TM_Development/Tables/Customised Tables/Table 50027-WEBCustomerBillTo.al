table 50027 "WEB Customer Bill-To"
{
    // version R4359

    // R4359 - RM - 18.12.2015
    // Added key Customer Email
    CaptionML = ENU = 'WEB Customer Bill-To', ENG = 'WEB Customer Bill-To';

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
        field(3; "Bill-To First Name"; Text[100])
        {
            CaptionML = ENU = 'Bill-To First Name', ENG = 'Bill-To First Name';
        }
        field(4; "Bill-To Last Name"; Text[100])
        {
            CaptionML = ENU = 'Bill-To Last Name', ENG = 'Bill-To Last Name';
        }
        field(5; "Bill-To Company"; Text[100])
        {
            CaptionML = ENU = 'Bill-To Company', ENG = 'Bill-To Company';
        }
        field(6; "Bill-To Street 1"; Text[100])
        {
            CaptionML = ENU = 'Bill-To Street 1', ENG = 'Bill-To Street 1';
        }
        field(7; "Bill-To Street 2"; Text[100])
        {
            CaptionML = ENU = 'Bill-To Street 2', ENG = 'Bill-To Street 2';
        }
        field(8; "Bill-To Street 3"; Text[100])
        {
            CaptionML = ENU = 'Bill-To Street 3', ENG = 'Bill-To Street 3';
        }
        field(9; "Bill-To City"; Text[100])
        {
            CaptionML = ENU = 'Bill-To City', ENG = 'Bill-To City';
        }
        field(10; "Bill-To Postcode"; Text[100])
        {
            CaptionML = ENU = 'Bill-To Postcode', ENG = 'Bill-To Postcode';
        }
        field(11; "Bill-To Country"; Text[100])
        {
            CaptionML = ENU = 'Bill-To Country', ENG = 'Bill-To Country';
        }
        field(12; "Bill-To Telephone"; Text[100])
        {
            CaptionML = ENU = 'Bill-To Telephone', ENG = 'Bill-To Telephone';
        }
        field(13; "Bill-To Mobile"; Text[100])
        {
            CaptionML = ENU = 'Bill-To Mobile', ENG = 'Bill-To Mobile';
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
        key(Key3; "Index No.")
        {
            Description = 'MITL.AJ.20200603 Indexing correction';
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Index No." := WF.InsertIndex(50027, "Customer ID", "Customer Email", "Order ID", FORMAT("LineType"), FORMAT("Date Time"), "Order ID");
        Receipted := CURRENTDATETIME;
    end;

    var
        WF: Codeunit "WEB Functions";
}

