page 50090 "Scale Devices"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Scale Devices";

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
                    Description = 'MITL2219';
                }
                field("Device MAC Address"; "Device MAC Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2219';
                }
                field("Device Name"; "Device Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2219';
                }
                field("Device Enabled"; "Device Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2219';
                }
                field("Disable Scale Integration"; "Disable Scale Integration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2219';
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