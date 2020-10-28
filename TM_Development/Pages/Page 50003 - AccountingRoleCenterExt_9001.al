pageextension 50003 AccountingManagerRoleCenterExt extends "Accounting Manager Role Center"
{
    //Version MITL4598 - Added delete Inv. Purchase order action
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        //MITL4598 ++
        //Report Added in Role Center to delete Invoiced Purch. Orders


        addafter("P&ost Inventory Cost to G/L")
        {
            action(DeleteInvoicedPurchOrders)
            {
                ApplicationArea = All;
                ToolTip = 'Action';
                CaptionML = ENU = 'Delete Invoiced Purch. Orders', ENG = 'Delete Invoiced Purch. Orders';
                Image = DeleteXML;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Report "Delete Invoiced Purch. Orders";
            }
        }
        //MITL4598 **
    }

    var
        myInt: Integer;
}