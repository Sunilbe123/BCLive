page 50025 "WEB User  - Order Header"
{
    PageType = Card;
    SourceTable = "WEB Order Header";


    layout
    {
        area(content)
        {
            group(General)
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
                field("Combined Pick"; "Combined Pick")
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
            part("WEB Order Lines"; 50001)
            {
                SubPageLink = "Order ID" = FIELD("Order ID");
            }
        }
    }

    actions
    {
    }
}

