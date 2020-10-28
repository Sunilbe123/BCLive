page 50096 ActiveSessionCustom
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Active Session";
    Caption = 'Active Sessions';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Session ID"; "Session ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Client Type"; "Client Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Server Instance ID"; "Server Instance ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Login Datetime"; "Login Datetime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Database Name"; "Database Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Client Computer Name"; "Client Computer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action("Stop Sesison")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Caption = 'Stop Session';
                Image = Delete;
                PromotedCategory = Category4;
                Promoted = true;
                trigger OnAction();
                begin
                    StopSession("Session ID");
                end;
            }
        }
    }
}