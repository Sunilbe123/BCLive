tableextension 50084 SalesLineDiscountExt extends "Sales Line Discount"
{
    fields
    {
        // Add changes to table fields here
        field(50000; WebSite; Text[100])
        {
            Description = 'INS1.1';
        }
        field(50001; WebSiteID; Integer)
        {
            Description = 'INS1.1';
        }
    }
    
    var
        myInt: Integer;
}