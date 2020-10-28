pageextension 50000 PostedSalesInvoiceExt extends "Posted Sales Invoices"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        modify(Print)
        {
            Visible = false;
        }

        addafter(Navigate)
        {
            action("Print Invoice")
            {
                CaptionML = ENU = 'Print Invoice', ENG = 'Print Invoice';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Print;
                trigger OnAction();
                var
                    SIPrint: Report StandardSalesInvoiceCustom;
                    SIHead: Record "Sales Invoice Header";
                begin
                    Clear(SIPrint);
                    SIHead.Reset;
                    SIHead.SetRange("No.", Rec."No.");
                    SIPrint.SetTableView(SIHead);
                    SIPrint.RunModal;
                end;
            }
            //MITL.AK.3585 --
        }
        // Add changes to page actions here
    }

    var
        myInt: Integer;

}