pageextension 50079 PurchaseOrder extends "Purchase Order"
{
    layout
    {
        // Add changes to page layout here
        addafter("Ship-to Post Code")
        {
            field("PO Status"; "PO Status")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL2184';
            }
            field("Container No."; "Container No.")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL2184';
            }
            field(TimeUpdated; TimeUpdated)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL2184';
            }
        }
        /*
        addbefore("Attached Documents")
        {
            part(CaptureUI;"CDC Client Addin - Purch.")
            {
                SubPageView=SORTING("Document Type","No.")
                            WHERE("Document Type"=CONST(Order));
                SubPageLink="No."=FIELD("No.");
                
            }
        }   
        */
        modify(PayToOptions)
        {
            Editable = false;
            Description = 'MITLP58.AJ.17MAR2020';
        }
    }

    actions
    {
        // Add changes to page actions here
        // addafter(Receipts)
        // {
        //     action(CreatePostedPurchaseReceipt)
        //     {
        //         ApplicationArea = All;
        //         RunObject = report PurchaseEntryCorrection;
        //         Image = List;
        //         Promoted = true;
        //         PromotedCategory = Process;
        //         PromotedOnly = true;
        //         PromotedIsBig = true;

        //         trigger OnAction()
        //         begin

        //         end;
        //     }
        // }

    }

    var
        myInt: Integer;
}