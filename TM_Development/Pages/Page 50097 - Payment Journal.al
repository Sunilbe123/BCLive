pageextension 50097 "Payment Journal Ext" extends "Payment Journal"
{
    layout
    {
        // Add changes to page layout here
        addafter("Amount (LCY)")
        {
            field("Due Date"; "Due Date")
            {
                Description = 'MITL.VS.7616';
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }
    }

    actions
    {
        // Add changes to page actions 
        modify(SuggestVendorPayments)
        {
            Visible = false;
        }
        addafter(SuggestVendorPayments)
        {
            action(SuggestVendorPayment)
            {
                Caption = 'Suggest Vendor Payment';
                Image = SuggestVendorPayments;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Ellipsis = true;
                ToolTip = 'Create payment suggestions as lines in the payment journal.';
                ApplicationArea = All;
                trigger OnAction()
                var
                    SuggestVendorPayments: report 50013;
                begin
                    CLEAR(SuggestVendorPayments);
                    SuggestVendorPayments.SetGenJnlLine(Rec);
                    SuggestVendorPayments.RUNMODAL;
                end;
            }
        }
    }

    var
        myInt: Integer;
}