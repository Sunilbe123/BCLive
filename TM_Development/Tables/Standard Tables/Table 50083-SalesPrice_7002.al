tableextension 50083 SalesPriceExt extends "Sales Price"
{
    fields
    {
        // Add changes to table fields here
        field(50000; WebSyncFlag; Code[1])
        {
            Description = 'INS1.1';
        }
        field(50001; WebSite; Text[100])
        {
            Description = 'INS1.1';
        }
        field(50002; WebSiteID; Integer)
        {
            Description = 'INS1.1';
        }
    }

    var
        myInt: Integer;
}