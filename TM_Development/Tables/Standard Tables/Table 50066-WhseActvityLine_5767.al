tableextension 50066 WhseActivityLine extends "Warehouse Activity Line"
{
    //Version MITL2219,MITL13605
    //MITL2219 - Added new fields for Scale Integration Requirement
    fields
    {
        // Add changes to table fields here

        field(50000; "Measured Weight"; Decimal)
        {
            Description = 'MITL2219';
            CaptionML = ENU = 'Measured Weight', ENG = 'Measured Weight';
            Editable = false;
        }
        field(50001; "Weight Difference"; Decimal)
        {
            Description = 'MITL2219';
            CaptionML = ENU = 'Weight Difference', ENG = 'Weight Difference';
            Editable = false;
        }
        field(50002; "Product Type"; Option)
        {
            Description = 'MITL13605';
            CaptionML = ENU = 'Product Type', ENG = 'Product Type';
            OptionMembers = " ",Accessories,Tiles;
        }

        field(50003; "Picking Bin"; Code[20])
        {
            Description = 'MITL.AJ.12MAR2020';
            CaptionML = ENU = 'Picking Bin', ENG = 'Picking Bin';
        }
    }

    var
    // myInt: Integer;
}