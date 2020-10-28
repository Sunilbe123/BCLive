pageextension 50046 WhsePickSubform extends "Whse. Pick Subform"
{
    //version MITL2219
    //MITL2219 - new field added for Scale integration
    layout
    {
        // Add changes to page layout here
        addafter("Qty. per Unit of Measure")
        {
            field("Product Type"; "Product Type")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }

        addafter("Due Date")
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
            field("Picking Bin"; "Picking Bin")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL.AJ.12MAR2020';
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