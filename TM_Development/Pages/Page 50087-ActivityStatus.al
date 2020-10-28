page 50087 "Activity Status"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Activity Status";
    Caption = 'Activity Status';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Device ID"; "Device ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                }
                field("Mobile User ID"; "Mobile User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                }
                field("Activity Code"; "Activity Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                }
                field("Activity Description"; "Activity Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                }
                field("End Time"; "End Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                }
                field("Activity Time Taken"; "Activity Time Taken")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}