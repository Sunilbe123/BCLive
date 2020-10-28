page 50013 "WEB Requests"
{
    PageType = List;
    SourceTable = "WEB Requests";
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
                field(Table; Table)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(ID; ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Magento Completed"; "Magento Completed")
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

