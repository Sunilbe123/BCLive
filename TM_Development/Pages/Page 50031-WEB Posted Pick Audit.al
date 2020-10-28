page 50031 "WEB Posted Pick Audit"
{
    PageType = List;
    SourceTable = "Posted Pick Audit";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Sales Order No."; "Sales Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(USERID; USERID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Sell-To Customer No."; "Sell-To Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(WebIncrementID; WebIncrementID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Start DateTime"; "Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Magento Complete"; "Magento Complete")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Start; Start)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("End DateTime"; "End DateTime")
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

