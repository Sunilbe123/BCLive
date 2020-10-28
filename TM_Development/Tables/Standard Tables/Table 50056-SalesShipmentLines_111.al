tableextension 50056 SalesShipmentLines extends "Sales Shipment Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Cut Size"; Boolean)
        {
            Caption = 'Cut Size';
        }
        field(50001; "Cut Size To-Do"; Boolean)
        {
            Caption = 'Cut Size To-Do';
        }
        field(50021; WebOrderItemID; Text[30])
        {
            Description = 'INS1.1';
            Caption = 'WebOrderItemID';
        }
    }

    var
        myInt: Integer;
}