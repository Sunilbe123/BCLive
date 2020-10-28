page 50091 "Scale Weight Capture"
{
    //version MITL2219
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Scale Weight Capture";
    Caption = 'Scale Weight Capture';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Device Id"; "Device Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2219';
                }

                field("Pallet Weight"; "Pallet Weight")
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
        // area(Processing)
        // {
        //     action(ActionName)
        //     {
        //         ApplicationArea = All;

        //         trigger OnAction()
        //         begin

        //         end;
        //     }
        // }
    }

    var
    // myInt: Integer;
}