page 50001 "WEB Order Lines"
{
    PageType = ListPart;
    SourceTable = "WEB Order Lines";


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
                field("Product Options"; Rec."Product Options")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Calculator Settings"; Rec."Calculator Settings")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order ID"; Rec."Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Subtotal; Subtotal)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shipping & Handling"; Rec."Shipping & Handling")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(VAT; VAT)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("DateTime"; Rec."Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Type"; Rec."LineType")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Cut Size"; Rec."Cut Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Cut Sample Location"; Rec."Cut Sample Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Dimension Code"; Rec."Dimension Code")
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

