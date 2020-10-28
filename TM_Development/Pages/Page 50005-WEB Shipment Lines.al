page 50005 "WEB Shipment Lines"
{
    PageType = ListPart;
    SourceTable = "WEB Shipment Lines";


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
                field("Line No"; "Line No")
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
                field("Shipment ID"; "Shipment ID")
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

