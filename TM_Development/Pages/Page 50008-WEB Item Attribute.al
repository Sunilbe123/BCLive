page 50008 "WEB Item Attribute"
{
    AutoSplitKey = true;
    PageType = Card;
    SourceTable = "WEB Item Attribute";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Sku; Sku)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Attibute; Attibute)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Attribute Value"; "Attribute Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Line No."; "Line No.")
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
            }
        }
    }

    actions
    {
    }
}

