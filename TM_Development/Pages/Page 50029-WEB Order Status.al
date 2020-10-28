page 50029 "WEB Order Status"
{
    PageType = List;
    SourceTable = "WEB Order Status";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Status; Status)
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

