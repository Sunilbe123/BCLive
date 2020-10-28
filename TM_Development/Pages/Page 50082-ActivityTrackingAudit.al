page 50082 "Activity Tracking Audit"
{
    //MITL2146- New page created for audit of NAV activities perfomed from Handheld device.
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Activity Tracking Audit";
    CaptionML = ENU = 'Activity Tracking Audit', ENG = 'Activity Tracking Audit';
    Editable = false;

    layout
    {
        area(Content)
        {
            Repeater(Details)
            {
                field("Activity No."; "Activity No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2146';
                }
                field("Activity Type"; "Activity Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2146';
                }
                field("User Id"; "User Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2146';
                }
                field("Device Id"; "Device Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2146';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2146';
                }
                field("Start DateTime"; "Start DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2146';
                }
                field("Finish DateTime"; "Finish DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2146';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2146';
                }
                field("Pick Order No."; "Pick Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2146';
                }
            }
        }
    }

    // actions
    // {
    //     area(Processing)
    //     {
    //         action(ActionName)
    //         {
    //             ApplicationArea = All;

    //             trigger OnAction()
    //             begin

    //             end;
    //         }
    //     }
    // }

    var
        myInt: Integer;
}