pageextension 50090 PurchaseOrderListExt extends "Purchase Order List"
{
    layout
    {
        // Add changes to page layout here
        addafter("Due Date")
        {
            field(Receive; Receive)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            //MITL.MF.5405++
            field("Container No."; "Container No.")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("PO Status"; "PO Status")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            //MITL.MF.5405 --
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}