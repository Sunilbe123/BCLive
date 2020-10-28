page 50028 "WEB Reconciliation"
{
    PageType = List;
    SourceTable = "WEB Daily Reconciliation";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Type"; "WEB Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(ID; ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Value"; "WEB Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Date"; "WEB Date")
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

