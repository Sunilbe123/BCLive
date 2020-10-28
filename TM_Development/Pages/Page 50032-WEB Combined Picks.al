page 50032 "WEB Combined Picks"
{
    PageType = List;
    SourceTable = "WEB Combined Picks";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order No."; "Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order Line No."; "Order Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Pick No."; "Pick No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(SKU; SKU)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Pick")
            {

                trigger OnAction()
                begin
                    //WEBIndexHandling.WarehouseMultiPicks(Rec);
                end;
            }
        }
    }

    var
        WEBIndexHandling: Codeunit "WEB Index Handling";
}

