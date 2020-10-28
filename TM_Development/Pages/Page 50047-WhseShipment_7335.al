pageextension 50047 WarehouseShipment extends "Warehouse Shipment"
{
    layout
    {
        // Add changes to page layout here
        addafter("Sorting Method")
        {
            field("Latest Dispatch Date"; "Latest Dispatch Date")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
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