tableextension 50058 SalesInvoiceLines extends "Sales Invoice Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Cut Size"; Boolean)
        {
        }
        field(50001; "Cut Size To-Do"; Boolean)
        {
        }
        field(50021; WebOrderItemID; Text[30])
        {
            Description = 'R1518';
        }
    }

    var
        myInt: Integer;
}