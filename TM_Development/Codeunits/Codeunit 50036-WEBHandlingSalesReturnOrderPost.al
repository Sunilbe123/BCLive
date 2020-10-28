codeunit 50036 "WEB Handling Sales Return Post"
{
    TableNo = "Sales Header";
    trigger OnRun()
    var
        SalesHeaderL: Record "Sales Header";
    begin
        if Rec."Document Type" <> rec."Document Type"::"Return Order" then
            exit;

        if not CheckWhseRequired(Rec) then
            exit;

        SalesHeaderL := Rec;

        CreateWhseRcpt(SalesHeaderL);
    end;

    local procedure CheckDocStatus(var SalesHeaderP: Record "Sales Header")
    var
        ReleaseSalesDocL: Codeunit "Release Sales Document";
    begin
        if SalesHeaderP.Status = SalesHeaderP.Status::Open then begin
            Clear(ReleaseSalesDocL);
            ReleaseSalesDocL.PerformManualRelease(SalesHeaderP);
        end;
    end;

    local procedure CreateWhseRcpt(var SalesHeaderP: Record "Sales Header")
    var
        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
    begin
        // Checking Document Status & releasing the same
        CheckDocStatus(SalesHeaderP);

        // Creating the Warehouse Receipt
        GetSourceDocInbound.CreateFromSalesReturnOrderHideDialog(SalesHeaderP);

        // Post Warehouse receipt
        PostWhseRcpt(SalesHeaderP);
    end;

    local procedure PostWhseRcpt(var SalesHeaderP: Record "Sales Header")
    var
        WhseRcptPostL: Codeunit "Whse.-Post Receipt";
        WhseRcptLineL: Record "Warehouse Receipt Line";
    begin
        // Checking if receiving bin is missing and if not exist then updating from Location
        CheckAndUpdateReceivingBin(SalesHeaderP);

        // Checking Sales Return Order Outstanding Quantity & Warehouse Receipt Line Quantity
        CheckAndUpdateQty(SalesHeaderP);

        // Posting the Warehouse receipt
        WhseRcptLineL.Reset();
        WhseRcptLineL.SetRange("Source Type", Database::"Sales Line");
        WhseRcptLineL.SetRange("Source Document", WhseRcptLineL."Source Document"::"Sales Return Order");
        WhseRcptLineL.SetRange("Source Subtype", SalesHeaderP."Document Type");
        WhseRcptLineL.SetRange("Source No.", SalesHeaderP."No.");
        if WhseRcptLineL.FindFirst() then begin
            WhseRcptPostL.Run(WhseRcptLineL);
        end;
    end;

    local procedure CheckAndUpdateQty(var SalesHeaderP: Record "Sales Header")
    var
        SaleLineL: Record "Sales Line";
        WhseRcptLineL: Record "Warehouse Receipt Line";
    begin
        SaleLineL.Reset();
        SaleLineL.SetRange("Document Type", SalesHeaderP."Document Type");
        SaleLineL.SetRange("Document No.", SalesHeaderP."No.");
        SaleLineL.SetRange(Type, SaleLineL.Type::Item);// MITL.SM.5442.20200512
        SaleLineL.SetFilter("Outstanding Quantity", '<>0');
        if SaleLineL.FindSet() then
            repeat
                WhseRcptLineL.Reset();
                WhseRcptLineL.SetRange("Source Type", Database::"Sales Line");
                WhseRcptLineL.SetRange("Source Document", WhseRcptLineL."Source Document"::"Sales Return Order");
                WhseRcptLineL.SetRange("Source Subtype", SaleLineL."Document Type");
                WhseRcptLineL.SetRange("Source No.", SaleLineL."Document No.");
                WhseRcptLineL.SetRange("Source Line No.", SaleLineL."Line No.");// MITL.SM.5442.20200512
                WhseRcptLineL.SetFilter("Qty. Received", '0');
                if WhseRcptLineL.FindFirst() then begin
                    if SaleLineL."Outstanding Qty. (Base)" <> WhseRcptLineL."Qty. Outstanding (Base)" then begin
                        WhseRcptLineL.Validate(Quantity, SaleLineL."Outstanding Quantity");
                        WhseRcptLineL.Modify(true);
                    end;
                end;
            until SaleLineL.Next() = 0;
    end;

    local procedure CheckAndUpdateReceivingBin(var SalesHeaderP: Record "Sales Header")
    var
        SaleLineL: Record "Sales Line";
        WhseRcptLineL: Record "Warehouse Receipt Line";
        LocL: Record Location;
    begin
        SaleLineL.Reset();
        SaleLineL.SetRange("Document Type", SalesHeaderP."Document Type");
        SaleLineL.SetRange("Document No.", SalesHeaderP."No.");
        SaleLineL.SetRange(Type, SaleLineL.Type::Item);// MITL.SM.5442.20200512
        SaleLineL.SetFilter("Outstanding Quantity", '<>0');
        if SaleLineL.FindSet() then
            repeat
                LocL.Reset();
                LocL.Get(SaleLineL."Location Code");
                WhseRcptLineL.Reset();
                WhseRcptLineL.SetRange("Source Type", Database::"Sales Line");
                WhseRcptLineL.SetRange("Source Document", WhseRcptLineL."Source Document"::"Sales Return Order");
                WhseRcptLineL.SetRange("Source Subtype", SaleLineL."Document Type");
                WhseRcptLineL.SetRange("Source No.", SaleLineL."Document No.");
                WhseRcptLineL.SetRange("Source Line No.", SaleLineL."Line No.");// MITL.SM.5442.20200512
                WhseRcptLineL.SetFilter("Qty. Received", '0');
                WhseRcptLineL.SetFilter("Bin Code", '');
                if WhseRcptLineL.FindFirst() then begin
                    WhseRcptLineL.Validate("Bin Code", LocL."Receipt Bin Code");
                    WhseRcptLineL.Modify(true);
                end;
            until SaleLineL.Next() = 0;
    end;

    local procedure CheckWhseRequired(var SalesHeaderP: Record "Sales Header") WhseReqR: Boolean
    var
        LocL: Record Location;
        SalesLineL: Record "Sales Line";
    begin
        WhseReqR := false;
        SalesLineL.Reset();
        SalesLineL.SetRange("Document Type", SalesHeaderP."Document Type");
        SalesLineL.SetRange("Document No.", SalesHeaderP."No.");
        SalesLineL.SetFilter("Location Code", '<>%1', '');
        if SalesLineL.FindFirst() then begin
            LocL.Reset();
            LocL.SetRange(Code, SalesLineL."Location Code");
            LocL.SetRange("Require Put-away", true); //MITL.AJ.21APR2020
            LocL.SetFilter("Receipt Bin Code", '<>%1', '');
            if LocL.FindFirst() then
                WhseReqR := true;
        end;
    end;

    var
        myInt: Integer;
}