page 50003 "WEB Order Bill-To"
{
    PageType = List;
    SourceTable = "WEB Customer Bill-To";
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
                field("Bill-To First Name"; "Bill-To First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Bill-To Last Name"; "Bill-To Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Bill-To Company"; "Bill-To Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Bill-To Street 1"; "Bill-To Street 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Bill-To Street 2"; "Bill-To Street 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Bill-To Street 3"; "Bill-To Street 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Bill-To City"; "Bill-To City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Bill-To Postcode"; "Bill-To Postcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Bill-To Country"; "Bill-To Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Bill-To Telephone"; "Bill-To Telephone")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Bill-To Mobile"; "Bill-To Mobile")
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

