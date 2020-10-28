pageextension 50039 SalesOrder extends "Sales Order"
{
    layout
    {
        // Add changes to page layout here
        addafter("Salesperson Code")
        {
            field("Customer Credit Limit"; "Customer Credit Limit")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }
        addafter("Prepayment %")
        {
            group(WebData)
            {
                field(WebIncrementID; WebIncrementID) { }
                field(WebOrderID; WebOrderID) { }
                field("Web Shipment Increment Id"; "Web Shipment Increment Id") { }
                field("Web Shipment Carrier"; "Web Shipment Carrier") { }
                field("Web Invoice Increment Id"; "Web Invoice Increment Id") { }

            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}