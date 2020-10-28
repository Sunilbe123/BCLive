codeunit 50029 RegisterUnhandledPicks
{
    trigger OnRun()
    begin
        WhseActivityHeader.Reset();
        WhseActivityHeader.SetCurrentKey("Source Document", "Source No.", "Location Code");
        WhseActivityHeader.SetRange(Type, WhseActivityHeader.Type::Pick);
        WhseActivityHeader.SetRange("Source Document", WhseActivityHeader."Source Document"::"Sales Order");
        WhseActivityHeader.SetRange("Source No.", SalesHeaderG."No.");
        If WhseActivityHeader.Findset() then
            repeat
                WhseActivLine.SetCurrentKey("Activity Type", "No.", "Shelf No."); // MITL.SM.20200503 Indexing correction
                WhseActivLine.Reset();
                WhseActivLine.SetRange("Activity Type", WhseActivLine."Activity Type"::Pick);
                WhseActivLine.SetRange("No.", WhseActivityHeader."No.");
                IF WhseActivLine.FindSet() THEN BEGIN
                    WhseActivityRegister.ShowHideDialog(true);
                    IF WhseActivityRegister.RUN(WhseActivLine) THEN;
                    CLEAR(WhseActivityRegister);
                END;
            until WhseActivityHeader.Next() = 0;

    end;

    procedure SetSalesOrder(var SalesHeaderP: Record "Sales Header")
    var
    begin
        SalesHeaderG.copy(SalesHeaderP);
    end;

    var
        WhseActivityHeader: Record "Warehouse Activity Header";
        SalesHeaderG: Record "Sales Header";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
        WhseActivLine: Record "Warehouse Activity Line";

}