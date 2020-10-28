pageextension 50055 CustomerStatiscs extends "Customer Statistics FactBox"
{
    layout
    {
        // Add changes to page layout here
        addafter("Credit Limit (LCY)")
        {
            field("Available Balance"; AvailableBalance)//SP.W&F
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Released Orders Value"; ReleasedOrdersValue)//SP.W&F
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

    trigger OnAfterGetRecord()
    begin
        //MITL064
        ReleasedOrdersValue := 0;
        AvailableBalance := 0;
        SalesHdr.RESET;
        SalesHdr.SETFILTER("Sell-to Customer No.", Rec."No.");
        SalesHdr.SETFILTER("Document Type", '%1', SalesHdr."Document Type"::Order);
        SalesHdr.SETFILTER(Status, '<>%1', SalesHdr.Status::Open);
        IF SalesHdr.FINDSET THEN
            REPEAT
                SalesLines.RESET;
                SalesLines.SETRANGE("Document Type", SalesHdr."Document Type");
                SalesLines.SETRANGE("Document No.", SalesHdr."No.");
                IF SalesLines.FINDSET THEN
                    REPEAT
                        IF SalesLines."Outstanding Quantity" > 0 THEN BEGIN
                            //SalesLines.CALCFIELDS("Amount Including VAT");
                            IF SalesLines."Amount Including VAT" > 0 THEN
                                ReleasedOrdersValue += (SalesLines."Amount Including VAT" / SalesLines.Quantity * SalesLines."Outstanding Quantity");
                        END;
                    UNTIL SalesLines.NEXT = 0;
            //SalesHdr.CALCFIELDS("Amount Including VAT");
            //ReleasedOrdersValue += SalesHdr."Amount Including VAT";
            UNTIL SalesHdr.NEXT = 0;
        AvailableBalance := "Credit Limit (LCY)" - "Balance (LCY)" - ReleasedOrdersValue;
        IF AvailableBalance < 0 THEN
            AvailableBalance := 0;
        //MITL064

    end;

    trigger OnAfterGetCurrRecord()
    begin

    end;

    var
        myInt: Integer;
        AvailableBalance: Decimal;
        ReleasedOrdersValue: Decimal;
        SalesHdr: Record "Sales Header";
        SalesLines: Record "Sales Line";
}