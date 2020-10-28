page 50006 "WEB Shipment Header"
{
    PageType = Card;
    SourceTable = "WEB Shipment Header";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shipment ID"; "Shipment ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Store; Store)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shipping Method"; "Shipping Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shipping Description"; "Shipping Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Customer ID"; "Customer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Weight; Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Type"; "LineType")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("DateTime"; "Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Customer Email"; "Customer Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            part("WEB Shipment Lines"; "WEB Shipment Lines")
            {
                SubPageLink = "Order ID" = FIELD("Shipment ID");
            }
        }
    }

    actions
    {
    }
}

