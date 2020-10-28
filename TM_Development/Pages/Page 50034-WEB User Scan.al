page 50034 "WEB User Scan"
{
    PageType = List;
    SourceTable = "WEB User Scan";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Start Scan"; "Start Scan")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("End Time"; "End Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order No"; "Order No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Login Time"; "Login Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Logout Time"; "Logout Time")
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

