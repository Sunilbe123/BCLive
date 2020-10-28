table 50023 "WEB Requests"
{
    CaptionML = ENU = 'WEB Requests', ENG = 'WEB Requests';
    DrillDownPageID = "WEB Requests";
    LookupPageID = "WEB Requests";

    fields
    {
        field(1; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', ENG = 'Line No.';
            AutoIncrement = true;
        }
        field(2; "Table"; Integer)
        {
            CaptionML = ENU = 'Table', ENG = 'Table';
        }
        field(3; "Table Name"; Text[30])
        {
            CaptionML = ENU = 'Table Name', ENG = 'Table Name';
        }
        field(4; ID; Code[80])
        {
            CaptionML = ENU = 'ID', ENG = 'ID';
        }
        field(5; "Magento Completed"; Boolean)
        {
            CaptionML = ENU = 'Magento Completed', ENG = 'Magento Completed';
        }
        field(6; "Index No."; Integer)
        {
            CaptionML = ENU = 'Index No.', ENG = 'Index No.';
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

