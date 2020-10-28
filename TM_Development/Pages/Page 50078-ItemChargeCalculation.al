page 50078 ItemChargeCalculation
{
    //MITL2147 - Created new page as per the requirement document.

    CaptionML = ENU = 'Item Charge Calculation', ENG = 'Item Charge Calculation';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = ItemChgCalculation;
    SourceTableView = SORTING("Item No.", "Item Charge");

    layout
    {
        area(Content)
        {
            repeater(Group_)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2147';
                }
                field("Calculation Method"; "Calculation Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2147';
                }
                field("Item Charge"; "Item Charge")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2147';
                }
                field("Calculation Value"; "Calculation Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2147';
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
        myInt: Integer;
}