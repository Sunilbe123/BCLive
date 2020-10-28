//MITL-2146++
page 50040 "Activity Tracking Lines"
{
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Activity Tracking Lines";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';

                }
                field("Activity No."; "Activity No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';

                }
                field("Order No."; "Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';

                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';

                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';

                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';

                }
                field("Device ID"; "Device ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';

                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("End Time"; "End Time")
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
            action(ActionName)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';

                trigger OnAction();
                begin

                end;
            }
        }
    }
}
//MITL-2146--