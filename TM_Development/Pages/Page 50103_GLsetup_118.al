//MITL.MF.5419 Added field Purchase Invoice Line Description
pageextension 50103 GLSetup extends "General Ledger Setup"
{
    layout
    {
        addafter("Show Amounts")
        {
            field("Purchase Invoice Line Description Update"; PurchaseInvoiceDescriptionUpdate)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
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