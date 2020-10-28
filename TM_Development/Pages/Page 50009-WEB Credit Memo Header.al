page 50009 "WEB Credit Memo Header"
{
    PageType = Card;
    SourceTable = "WEB Credit Header";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Credit Memo Date"; "Credit Memo Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Credit Memo ID"; "Credit Memo ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Store; Store)
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
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Adjustment Refund Amount"; "Adjustment Refund Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Adjustment Fee Amount"; "Adjustment Fee Amount")
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
                field("Shipment ID"; "Shipment ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Dimension Code"; "Dimension Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Customer Order No."; "Customer Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            part("WEB Credit Memo Lines"; "WEB Credit Memo Lines")
            {
                SubPageLink = "Order ID" = FIELD("Order ID");
            }
        }
    }

    actions
    {
    }
}

