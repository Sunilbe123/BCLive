pageextension 50084 RegisteredPickSubform extends "Registered Pick Subform"
{
    //Version MITL2219
    //MITL2219 - new field added for Scale integration
    layout
    {
        // Add changes to page layout here
        addafter("Unit of Measure Code")
        {
            field("Measured Weight"; "Measured Weight")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL2219';
            }
            field("Weight Difference"; "Weight Difference")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL2219';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}