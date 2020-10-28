pageextension 50112 SalespersonPurchaserExt extends "Salesperson/Purchaser Card"
{
    layout
    {
        addafter("E-Mail")
        {
            field("Line Manager"; "Line Manager")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL.7446.VS';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
    //Add global variables here
}