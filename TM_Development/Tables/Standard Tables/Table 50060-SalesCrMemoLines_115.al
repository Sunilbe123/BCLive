tableextension 50060 SalesCrMemoLines extends "Sales Cr.Memo Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Cut Size"; Boolean)
        {
            Caption = 'Cut Size';
        }

    }

    var
        myInt: Integer;
}