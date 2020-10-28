page 50043 "Order Status"
{
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Pick Creation Status";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Visible = false;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Visible = false;
                }
                field("Source Subtype"; "Source Subtype")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Visible = false;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Source Line No."; "Source Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Visible = false;
                }
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Pick No."; "Pick No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Editable = false;
                }
                field(Whse_Movement_No; Whse_Movement_No)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Editable = false;
                }

                field("No Stock Items 1"; "No Stock Items 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Visible = false;
                }
                field("No Stock Items 2"; "No Stock Items 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Visible = false;
                }
                field("No Stock Items 3"; "No Stock Items 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Visible = false;
                }
                field("Web Order No."; "Web Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Creation Date Time"; "Creation Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Last modified Date Time"; "Last modified Date Time")
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

