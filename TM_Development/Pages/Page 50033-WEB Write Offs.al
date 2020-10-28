page 50033 "WEB Write Offs"
{
    //MITL2221
    PageType = List;
    SourceTable = "Web Write Offs";
    ApplicationArea = All;
    UsageCategory = Tasks;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(SKU; SKU)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2221';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2221';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2221';
                }
                field("Written Off"; "Written Off")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2221';
                }
            }
        }
    }

    actions
    {
    }
}

