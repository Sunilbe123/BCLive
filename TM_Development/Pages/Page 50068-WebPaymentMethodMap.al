page 50065 WebPaymentMethodMapping
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Payment Method Template MAP";
    DelayedInsert = true;
    CaptionML = ENU = 'Web Payment Method Mappings', ENG = 'Web Payment Method Mappings';
    layout
    {
        area(Content)
        {
            repeater("Payment Method")
            {
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Sales Pmt. Jnl Template Name"; "Sales Pmt. Jnl Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Sales Pmt. Jnl Batch Name"; "Sales Pmt. Jnl Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Create No Payment"; "Create No Payment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    var
        myInt: Integer;
}