page 50004 "WEB Order Ship-To"
{
    PageType = List;
    SourceTable = "WEB Customer Ship-To";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer ID"; "Customer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Customer Email"; "Customer Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Ship-To First Name"; "Ship-To First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Ship-To Last Name"; "Ship-To Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Ship-To Company"; "Ship-To Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Ship-To Street 1"; "Ship-To Street 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Ship-To Street 2"; "Ship-To Street 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Ship-To Street 3"; "Ship-To Street 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Ship-To City"; "Ship-To City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Ship-To Postcode"; "Ship-To Postcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Ship-To Country"; "Ship-To Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Ship-To Telephone"; "Ship-To Telephone")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Ship-To Mobile"; "Ship-To Mobile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order ID"; "Order ID")
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

