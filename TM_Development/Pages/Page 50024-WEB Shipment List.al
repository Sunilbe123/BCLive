page 50024 "WEB Shipment List"
{
    PageType = List;
    SourceTable = "WEB Shipment Header";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
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
                field("Discount Code"; "Discount Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Subtotal; Subtotal)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shipping & Handling"; "Shipping & Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(VAT; VAT)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Grand Total"; "Grand Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Customer Comments"; "Customer Comments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Payment Method"; "Payment Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Customer ID"; "Customer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Customer Email"; "Customer Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Tracking Carrier"; "Tracking Carrier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Tracking Number"; "Tracking Number")
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
                field("Index No."; "Index No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order Exists"; "Order Exists")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shipment Count"; "Shipment Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    actions
    {
    }
}

