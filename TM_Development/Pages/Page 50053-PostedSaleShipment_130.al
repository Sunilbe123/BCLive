pageextension 50053 PostedSaleShipment extends "Posted Sales Shipment"
{
    layout
    {
        // Add changes to page layout here
        addafter(Shipping)
        {
            group("Web Data")
            {
                field(WebIncrementID; WebIncrementID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(WebOrderID; WebOrderID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Web Shipment Increment Id"; "Web Shipment Increment Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Web Shipment Carrier"; "Web Shipment Carrier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }

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