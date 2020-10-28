pageextension 50083 InventorySetup extends "Inventory Setup"
{
    //version MITL2219
    //MITL2219 - new field added for Scale integration
    layout
    {
        // Add changes to page layout here
        addafter("Prevent Negative Inventory")
        {
            field("Weight Tolerence Percentage"; "Weight Tolerence Percentage")
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