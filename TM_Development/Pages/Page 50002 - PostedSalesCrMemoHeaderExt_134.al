pageextension 50002 PostedSalesCrMemoHeaderExt extends "Posted Sales Credit Memo"
{
    //Version MITL3836
    layout
    {
        // Add changes to page layout here
        //MITL3836 ++
        addafter("No.")
        {
            field(WebIncrementID; WebIncrementID)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL3836';
            }
        }
        //MITL3836 **
    }

    actions
    {
        // Add changes to page actions here
        //MITL3836 ++
        addafter(Print)
        {
            action("Print Credit Memos")
            {
                CaptionML = ENU = 'Print Credit Memos', ENG = 'Print Credit Memos';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Print;
                trigger OnAction();
                var
                    SalesCrMemoRep: Report "StandardSalesCredit Memo";
                    SalesCrMemoHead: Record "Sales Cr.Memo Header";
                begin
                    Clear(SalesCrMemoRep);
                    SalesCrMemoHead.Reset;
                    SalesCrMemoHead.SetRange("No.", Rec."No.");
                    SalesCrMemoRep.SetTableView(SalesCrMemoHead);
                    SalesCrMemoRep.RunModal;
                end;
            }
        }
        //MITL3836 **
    }

    var
        myInt: Integer;
}