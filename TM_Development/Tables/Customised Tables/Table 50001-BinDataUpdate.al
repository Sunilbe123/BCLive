table 50001 "Bin Data Update"
{
    // version MITL1884

    CaptionML = ENU = 'Bin Data Check', ENG = 'Bin Data Check';
    Description = 'MITL1884-This table will keep the Bin data for all the items';
    DrillDownPageID = "Bin Data List";
    LookupPageID = "Bin Data List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            CaptionML = ENU = 'Entry No.', ENG = 'Entry No.';
            Description = 'MITL1884';
            NotBlank = true;
            Editable = false;
        }
        field(2; "Item No."; Code[20])
        {
            CaptionML = ENU = 'Item No.', ENG = 'Item No.';
            Description = 'MITL1884';
            Editable = false;
            NotBlank = true;

        }
        field(3; "Total Stock In Picking Bins"; Decimal)
        {
            CaptionML = ENU = 'Total Stock In Picking Bins', ENG = 'Total Stock In Picking Bins';
            Description = 'MITL1884';
            Editable = false;
        }

        field(4; "Total Stock In Put-Away Bins"; Decimal)
        {
            CaptionML = ENU = 'Total Stock In Put-Away Bins', ENG = 'Total Stock In Put-Away Bins';
            Description = 'MITL1884';
            Editable = false;

        }
        field(5; "Available Stock"; Decimal)
        {
            CaptionML = ENU = 'Available Stock', ENG = 'Available Stock';
            Description = 'MITL1884';
            Editable = false;
        }
        field(6; "Modified DateTime"; DateTime)
        {
            CaptionML = ENU = 'Modified DateTime', ENG = 'Modified DateTime';
            Description = 'MITL1884';
            Editable = false;
        }
        field(7; "Magento Update"; Boolean)
        {
            CaptionML = ENU = 'Magento Update', ENG = 'Magento Update';
            Description = 'MITL1884';
            Editable = true;
        }

    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }


}