page 50010 "WEB Credit Memo Lines"
{
    // version MITL14041

    PageType = ListPart;
    SourceTable = "WEB Credit Lines";


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Sku; Sku)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Size; Size)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(QTY; QTY)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Product Options"; "Product Options")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Calculator Settings"; "Calculator Settings")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Line No"; "Line No")
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
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Credit Memo ID"; "Credit Memo ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Dimension Code"; "Dimension Code")
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

