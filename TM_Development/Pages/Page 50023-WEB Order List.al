page 50023 "WEB Order List"
{
    // version MITL332

    PageType = List;
    SourceTable = "WEB Order Header";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order Date"; "Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order ID"; "Order ID")
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
                field("Latest Dispatch Date"; "Latest Dispatch Date")
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

