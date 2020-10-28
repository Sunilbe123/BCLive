pageextension 50081 PurchasingAgentRolecenter extends "Purchasing Agent Role Center"
{
    //MITL2202 - AJ 29.04.2019 - Added 'Delete Invoiced Purch. Orders' to the Role Center.
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        //MITL2202 ++
        //Report Added in Role Center to delete Invoiced Purch. Orders
        addafter("Order Plan&ning")
        {
            action(DeleteInvoicedPurchOrders)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Delete Invoiced Purch. Orders', ENG = 'Delete Invoiced Purch. Orders';
                Image = DeleteXML;
                Promoted = true;
                RunObject = Report "Delete Invoiced Purch. Orders";
            }
        }
        //MITL2202 **
    }

    var
        myInt: Integer;
}