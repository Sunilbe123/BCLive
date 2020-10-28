page 50011 "WEB Mapping"
{
    PageType = List;
    SourceTable = "WEB Mapping";
    UsageCategory = Tasks;
    CaptionML = ENU = 'WEB Payment Mapping', ENG = 'WEB Payment Mapping';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Magento Payment Method Code"; "Magento Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Dynamics NAV Payment Method Co"; "Dynamics NAV Payment Method Co")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Online Payment"; "Online Payment")
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

