page 50098 PickCreationCalc
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Tasks;
    SourceTable = "Sales & Receivables Setup";
    Description = 'mitl_6532';
    CaptionML = ENU = 'Pick Creation Calc', ENG = 'Pick Creation Calc';
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(PickCreationCalc; PickCreationCalc)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    CaptionML = ENU = 'Pick Creation Calculation', ENG = 'Pick Creation Calculation';
                    Description = 'mitl_6532';

                }
            }
        }
    }
}