codeunit 50020 "Whse._Create Source Document"
{
    // version NAVW17.10,CASE13605


    trigger OnRun()
    begin
    end;

    var
        WhseMgt: Codeunit "Whse. Management";

    procedure FromSalesLine2ShptLine(WhseShptHeader: Record "Warehouse Shipment Header"; SalesLine: Record "Sales Line"): Boolean
    var
        AsmHeader: Record "Assembly Header";
        TotalOutstandingWhseShptQty: Decimal;
        TotalOutstandingWhseShptQtyBase: Decimal;
        ATOWhseShptLineQty: Decimal;
        ATOWhseShptLineQtyBase: Decimal;
    begin
        SalesLine.CALCFIELDS("Whse. Outstanding Qty.", "ATO Whse. Outstanding Qty.",
          "Whse. Outstanding Qty. (Base)", "ATO Whse. Outstd. Qty. (Base)");
        TotalOutstandingWhseShptQty := ABS(SalesLine."Outstanding Quantity") - SalesLine."Whse. Outstanding Qty.";
        TotalOutstandingWhseShptQtyBase := ABS(SalesLine."Outstanding Qty. (Base)") - SalesLine."Whse. Outstanding Qty. (Base)";
        IF SalesLine.AsmToOrderExists(AsmHeader) THEN BEGIN
            ATOWhseShptLineQty := AsmHeader."Remaining Quantity" - SalesLine."ATO Whse. Outstanding Qty.";
            ATOWhseShptLineQtyBase := AsmHeader."Remaining Quantity (Base)" - SalesLine."ATO Whse. Outstd. Qty. (Base)";
            IF ATOWhseShptLineQtyBase > 0 THEN BEGIN
                IF NOT CreateShptLineFromSalesLine(WhseShptHeader, SalesLine, ATOWhseShptLineQty, ATOWhseShptLineQtyBase, TRUE) THEN
                    EXIT(FALSE);
                TotalOutstandingWhseShptQty -= ATOWhseShptLineQty;
                TotalOutstandingWhseShptQtyBase -= ATOWhseShptLineQtyBase;
            END;
        END;
        IF TotalOutstandingWhseShptQtyBase > 0 THEN
            EXIT(CreateShptLineFromSalesLine(WhseShptHeader, SalesLine, TotalOutstandingWhseShptQty, TotalOutstandingWhseShptQtyBase, FALSE));
        EXIT(TRUE);
    end;

    local procedure CreateShptLineFromSalesLine(WhseShptHeader: Record "Warehouse Shipment Header"; SalesLine: Record "Sales Line"; WhseShptLineQty: Decimal; WhseShptLineQtyBase: Decimal; AssembleToOrder: Boolean): Boolean
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        SalesHeader: Record "Sales Header";
        WebOrderHeaderRecL: Record "WEB Order Header";
        ItemRecL: Record Item;
    begin
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");

        WITH WhseShptLine DO BEGIN
            RESET;
            "No." := WhseShptHeader."No.";
            SETRANGE("No.", "No.");
            LOCKTABLE;
            IF FINDLAST THEN;

            INIT;
            SetIgnoreErrors;
            "Line No." := "Line No." + 10000;
            "Source Type" := DATABASE::"Sales Line";
            "Source Subtype" := SalesLine."Document Type";
            "Source No." := SalesLine."Document No.";
            "Source Line No." := SalesLine."Line No.";
            "Source Document" := WhseMgt.GetSourceDocument("Source Type", "Source Subtype");
            "Location Code" := SalesLine."Location Code";
            "Item No." := SalesLine."No.";
            // MITL ++
            WebOrderHeaderRecL.RESET;
            WebOrderHeaderRecL.SETRANGE("Order ID", SalesLine."Document No.");
            IF WebOrderHeaderRecL.FINDLAST THEN
                "Combined Pick" := WebOrderHeaderRecL."Combined Pick";

            ItemRecL.RESET;
            IF ItemRecL.GET(SalesLine."No.") THEN
                "Product Type" := ItemRecL."Product Type";
            // MITL --
            "Variant Code" := SalesLine."Variant Code";
            SalesLine.TESTFIELD("Unit of Measure Code");
            "Unit of Measure Code" := SalesLine."Unit of Measure Code";
            "Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
            Description := SalesLine.Description;
            "Description 2" := SalesLine."Description 2";
            SetQtysOnShptLine(WhseShptLine, WhseShptLineQty, WhseShptLineQtyBase);
            "Assemble to Order" := AssembleToOrder;
            IF SalesLine."Document Type" = SalesLine."Document Type"::Order THEN
                "Due Date" := SalesLine."Planned Shipment Date";
            IF SalesLine."Document Type" = SalesLine."Document Type"::"Return Order" THEN
                "Due Date" := WORKDATE;
            IF WhseShptHeader."Shipment Date" = 0D THEN
                "Shipment Date" := SalesLine."Shipment Date"
            ELSE
                "Shipment Date" := WhseShptHeader."Shipment Date";
            "Destination Type" := "Destination Type"::Customer;
            "Destination No." := SalesLine."Sell-to Customer No.";
            "Shipping Advice" := SalesHeader."Shipping Advice";
            IF "Location Code" = WhseShptHeader."Location Code" THEN
                "Bin Code" := WhseShptHeader."Bin Code";
            IF "Bin Code" = '' THEN
                "Bin Code" := SalesLine."Bin Code";
            UpdateShptLine(WhseShptLine, WhseShptHeader);
            CreateShptLine(WhseShptLine);
            EXIT(NOT HasErrorOccured);
        END;
    end;

    procedure SalesLine2ReceiptLine(WhseReceiptHeader: Record "Warehouse Receipt Header"; SalesLine: Record "Sales Line"): Boolean
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        WITH WhseReceiptLine DO BEGIN
            RESET;
            "No." := WhseReceiptHeader."No.";
            SETRANGE("No.", "No.");
            LOCKTABLE;
            IF FINDLAST THEN;

            INIT;
            SetIgnoreErrors;
            "Line No." := "Line No." + 10000;
            "Source Type" := DATABASE::"Sales Line";
            "Source Subtype" := SalesLine."Document Type";
            "Source No." := SalesLine."Document No.";
            "Source Line No." := SalesLine."Line No.";
            "Source Document" := WhseMgt.GetSourceDocument("Source Type", "Source Subtype");
            "Location Code" := SalesLine."Location Code";
            "Item No." := SalesLine."No.";
            "Variant Code" := SalesLine."Variant Code";
            SalesLine.TESTFIELD("Unit of Measure Code");
            "Unit of Measure Code" := SalesLine."Unit of Measure Code";
            "Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
            Description := SalesLine.Description;
            "Description 2" := SalesLine."Description 2";
            CASE SalesLine."Document Type" OF
                SalesLine."Document Type"::Order:
                    BEGIN
                        VALIDATE("Qty. Received", ABS(SalesLine."Quantity Shipped"));
                        "Due Date" := SalesLine."Planned Shipment Date";
                    END;
                SalesLine."Document Type"::"Return Order":
                    BEGIN
                        VALIDATE("Qty. Received", ABS(SalesLine."Return Qty. Received"));
                        "Due Date" := WORKDATE;
                    END;
            END;
            SetQtysOnRcptLine(WhseReceiptLine, ABS(SalesLine.Quantity), ABS(SalesLine."Quantity (Base)"));
            "Starting Date" := SalesLine."Shipment Date";
            IF "Location Code" = WhseReceiptHeader."Location Code" THEN
                "Bin Code" := WhseReceiptHeader."Bin Code";
            IF "Bin Code" = '' THEN
                "Bin Code" := SalesLine."Bin Code";
            UpdateReceiptLine(WhseReceiptLine, WhseReceiptHeader);
            CreateReceiptLine(WhseReceiptLine);
            EXIT(NOT HasErrorOccured);
        END;
    end;

    procedure FromServiceLine2ShptLine(WhseShptHeader: Record "Warehouse Shipment Header"; ServiceLine: Record "Service Line"): Boolean
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.GET(ServiceLine."Document Type", ServiceLine."Document No.");

        WITH WhseShptLine DO BEGIN
            RESET;
            "No." := WhseShptHeader."No.";
            SETRANGE("No.", "No.");
            LOCKTABLE;
            IF FINDLAST THEN;

            INIT;
            SetIgnoreErrors;
            "Line No." := "Line No." + 10000;
            "Source Type" := DATABASE::"Service Line";
            "Source Subtype" := ServiceLine."Document Type";
            "Source No." := ServiceLine."Document No.";
            "Source Line No." := ServiceLine."Line No.";
            "Source Document" := WhseMgt.GetSourceDocument("Source Type", "Source Subtype");
            "Location Code" := ServiceLine."Location Code";
            "Item No." := ServiceLine."No.";
            "Variant Code" := ServiceLine."Variant Code";
            ServiceLine.TESTFIELD("Unit of Measure Code");
            "Unit of Measure Code" := ServiceLine."Unit of Measure Code";
            "Qty. per Unit of Measure" := ServiceLine."Qty. per Unit of Measure";
            Description := ServiceLine.Description;
            "Description 2" := ServiceLine."Description 2";
            SetQtysOnShptLine(WhseShptLine, ABS(ServiceLine."Outstanding Quantity"), ABS(ServiceLine."Outstanding Qty. (Base)"));
            IF ServiceLine."Document Type" = ServiceLine."Document Type"::Order THEN
                "Due Date" := ServiceLine.GetDueDate;
            IF WhseShptHeader."Shipment Date" = 0D THEN
                "Shipment Date" := ServiceLine.GetShipmentDate
            ELSE
                "Shipment Date" := WhseShptHeader."Shipment Date";
            "Destination Type" := "Destination Type"::Customer;
            "Destination No." := ServiceLine."Bill-to Customer No.";
            "Shipping Advice" := ServiceHeader."Shipping Advice";
            IF "Location Code" = WhseShptHeader."Location Code" THEN
                "Bin Code" := WhseShptHeader."Bin Code";
            IF "Bin Code" = '' THEN
                "Bin Code" := ServiceLine."Bin Code";
            UpdateShptLine(WhseShptLine, WhseShptHeader);
            CreateShptLine(WhseShptLine);
            EXIT(NOT HasErrorOccured);
        END;
    end;

    procedure FromPurchLine2ShptLine(WhseShptHeader: Record "Warehouse Shipment Header"; PurchLine: Record "Purchase Line"): Boolean
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        WITH WhseShptLine DO BEGIN
            RESET;
            "No." := WhseShptHeader."No.";
            SETRANGE("No.", "No.");
            LOCKTABLE;
            IF FINDLAST THEN;

            INIT;
            SetIgnoreErrors;
            "Line No." := "Line No." + 10000;
            "Source Type" := DATABASE::"Purchase Line";
            "Source Subtype" := PurchLine."Document Type";
            "Source No." := PurchLine."Document No.";
            "Source Line No." := PurchLine."Line No.";
            "Source Document" := WhseMgt.GetSourceDocument("Source Type", "Source Subtype");
            "Location Code" := PurchLine."Location Code";
            "Item No." := PurchLine."No.";
            "Variant Code" := PurchLine."Variant Code";
            PurchLine.TESTFIELD("Unit of Measure Code");
            "Unit of Measure Code" := PurchLine."Unit of Measure Code";
            "Qty. per Unit of Measure" := PurchLine."Qty. per Unit of Measure";
            Description := PurchLine.Description;
            "Description 2" := PurchLine."Description 2";
            SetQtysOnShptLine(WhseShptLine, ABS(PurchLine."Outstanding Quantity"), ABS(PurchLine."Outstanding Qty. (Base)"));
            IF PurchLine."Document Type" = PurchLine."Document Type"::Order THEN
                "Due Date" := PurchLine."Expected Receipt Date";
            IF PurchLine."Document Type" = PurchLine."Document Type"::"Return Order" THEN
                "Due Date" := WORKDATE;
            IF WhseShptHeader."Shipment Date" = 0D THEN
                "Shipment Date" := PurchLine."Planned Receipt Date"
            ELSE
                "Shipment Date" := WhseShptHeader."Shipment Date";
            "Destination Type" := "Destination Type"::Vendor;
            "Destination No." := PurchLine."Buy-from Vendor No.";
            IF "Location Code" = WhseShptHeader."Location Code" THEN
                "Bin Code" := WhseShptHeader."Bin Code";
            IF "Bin Code" = '' THEN
                "Bin Code" := PurchLine."Bin Code";
            UpdateShptLine(WhseShptLine, WhseShptHeader);
            CreateShptLine(WhseShptLine);
            EXIT(NOT HasErrorOccured);
        END;
    end;

    procedure PurchLine2ReceiptLine(WhseReceiptHeader: Record "Warehouse Receipt Header"; PurchLine: Record "Purchase Line"): Boolean
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        WITH WhseReceiptLine DO BEGIN
            RESET;
            "No." := WhseReceiptHeader."No.";
            SETRANGE("No.", "No.");
            LOCKTABLE;
            IF FINDLAST THEN;

            INIT;
            SetIgnoreErrors;
            "Line No." := "Line No." + 10000;
            "Source Type" := DATABASE::"Purchase Line";
            "Source Subtype" := PurchLine."Document Type";
            "Source No." := PurchLine."Document No.";
            "Source Line No." := PurchLine."Line No.";
            "Source Document" := WhseMgt.GetSourceDocument("Source Type", "Source Subtype");
            "Location Code" := PurchLine."Location Code";
            "Item No." := PurchLine."No.";
            "Variant Code" := PurchLine."Variant Code";
            PurchLine.TESTFIELD("Unit of Measure Code");
            "Unit of Measure Code" := PurchLine."Unit of Measure Code";
            "Qty. per Unit of Measure" := PurchLine."Qty. per Unit of Measure";
            Description := PurchLine.Description;
            "Description 2" := PurchLine."Description 2";
            CASE PurchLine."Document Type" OF
                PurchLine."Document Type"::Order:
                    BEGIN
                        VALIDATE("Qty. Received", ABS(PurchLine."Quantity Received"));
                        "Due Date" := PurchLine."Expected Receipt Date";
                    END;
                PurchLine."Document Type"::"Return Order":
                    BEGIN
                        VALIDATE("Qty. Received", ABS(PurchLine."Return Qty. Shipped"));
                        "Due Date" := WORKDATE;
                    END;
            END;
            SetQtysOnRcptLine(WhseReceiptLine, ABS(PurchLine.Quantity), ABS(PurchLine."Quantity (Base)"));
            "Starting Date" := PurchLine."Planned Receipt Date";
            IF "Location Code" = WhseReceiptHeader."Location Code" THEN
                "Bin Code" := WhseReceiptHeader."Bin Code";
            IF "Bin Code" = '' THEN
                "Bin Code" := PurchLine."Bin Code";
            UpdateReceiptLine(WhseReceiptLine, WhseReceiptHeader);
            CreateReceiptLine(WhseReceiptLine);
            EXIT(NOT HasErrorOccured);
        END;
    end;

    procedure FromTransLine2ShptLine(WhseShptHeader: Record "Warehouse Shipment Header"; TransLine: Record "Transfer Line"): Boolean
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        TransHeader: Record "Transfer Header";
    begin
        WITH WhseShptLine DO BEGIN
            RESET;
            "No." := WhseShptHeader."No.";
            SETRANGE("No.", "No.");
            LOCKTABLE;
            IF FINDLAST THEN;

            INIT;
            SetIgnoreErrors;
            "Line No." := "Line No." + 10000;
            "Source Type" := DATABASE::"Transfer Line";
            "Source No." := TransLine."Document No.";
            "Source Line No." := TransLine."Line No.";
            "Source Subtype" := 0;
            "Source Document" := WhseMgt.GetSourceDocument("Source Type", "Source Subtype");
            "Item No." := TransLine."Item No.";
            "Variant Code" := TransLine."Variant Code";
            TransLine.TESTFIELD("Unit of Measure Code");
            "Unit of Measure Code" := TransLine."Unit of Measure Code";
            "Qty. per Unit of Measure" := TransLine."Qty. per Unit of Measure";
            Description := TransLine.Description;
            "Description 2" := TransLine."Description 2";
            "Location Code" := TransLine."Transfer-from Code";
            SetQtysOnShptLine(WhseShptLine, TransLine."Outstanding Quantity", TransLine."Outstanding Qty. (Base)");
            "Due Date" := TransLine."Shipment Date";
            IF WhseShptHeader."Shipment Date" = 0D THEN
                "Shipment Date" := WORKDATE
            ELSE
                "Shipment Date" := WhseShptHeader."Shipment Date";
            "Destination Type" := "Destination Type"::Location;
            "Destination No." := TransLine."Transfer-to Code";
            IF TransHeader.GET(TransLine."Document No.") THEN
                "Shipping Advice" := TransHeader."Shipping Advice";
            IF "Location Code" = WhseShptHeader."Location Code" THEN
                "Bin Code" := WhseShptHeader."Bin Code";
            IF "Bin Code" = '' THEN
                "Bin Code" := TransLine."Transfer-from Bin Code";
            UpdateShptLine(WhseShptLine, WhseShptHeader);
            CreateShptLine(WhseShptLine);
            EXIT(NOT HasErrorOccured);
        END;
    end;

    procedure TransLine2ReceiptLine(WhseReceiptHeader: Record "Warehouse Receipt Header"; TransLine: Record "Transfer Line"): Boolean
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        WITH WhseReceiptLine DO BEGIN
            RESET;
            "No." := WhseReceiptHeader."No.";
            SETRANGE("No.", "No.");
            LOCKTABLE;
            IF FINDLAST THEN;

            INIT;
            SetIgnoreErrors;
            "Line No." := "Line No." + 10000;
            "Source Type" := DATABASE::"Transfer Line";
            "Source No." := TransLine."Document No.";
            "Source Line No." := TransLine."Line No.";
            "Source Subtype" := 1;
            "Source Document" := WhseMgt.GetSourceDocument("Source Type", "Source Subtype");
            "Item No." := TransLine."Item No.";
            "Variant Code" := TransLine."Variant Code";
            TransLine.TESTFIELD("Unit of Measure Code");
            "Unit of Measure Code" := TransLine."Unit of Measure Code";
            "Qty. per Unit of Measure" := TransLine."Qty. per Unit of Measure";
            Description := TransLine.Description;
            "Description 2" := TransLine."Description 2";
            "Location Code" := TransLine."Transfer-to Code";
            VALIDATE("Qty. Received", TransLine."Quantity Received");
            SetQtysOnRcptLine(WhseReceiptLine, TransLine."Quantity Received" + TransLine."Qty. in Transit",
              TransLine."Qty. Received (Base)" + TransLine."Qty. in Transit (Base)");
            "Due Date" := TransLine."Receipt Date";
            "Starting Date" := WORKDATE;
            IF "Location Code" = WhseReceiptHeader."Location Code" THEN
                "Bin Code" := WhseReceiptHeader."Bin Code";
            IF "Bin Code" = '' THEN
                "Bin Code" := TransLine."Transfer-To Bin Code";
            UpdateReceiptLine(WhseReceiptLine, WhseReceiptHeader);
            CreateReceiptLine(WhseReceiptLine);
            EXIT(NOT HasErrorOccured);
        END;
    end;

    local procedure CreateShptLine(var WhseShptLine: Record "Warehouse Shipment Line")
    var
        Item: Record Item;
        WhseWkshLine: Record "Whse. Worksheet Line";
        ATOSalesLine: Record "Sales Line";
        AsmHeader: Record "Assembly Header";
        AsmLineMgt: Codeunit "Assembly Line Management";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseSNRequired: Boolean;
        WhseLNRequired: Boolean;
    begin
        WITH WhseShptLine DO BEGIN
            Item."No." := "Item No.";
            Item.ItemSKUGet(Item, "Location Code", "Variant Code");
            "Shelf No." := Item."Shelf No.";
            INSERT;
            IF "Assemble to Order" THEN BEGIN
                TESTFIELD("Source Type", DATABASE::"Sales Line");
                ATOSalesLine.GET("Source Subtype", "Source No.", "Source Line No.");
                ATOSalesLine.AsmToOrderExists(AsmHeader);
                AsmLineMgt.CreateWhseItemTrkgForAsmLines(AsmHeader);
            END ELSE BEGIN
                ItemTrackingMgt.CheckWhseItemTrkgSetup("Item No.", WhseSNRequired, WhseLNRequired, FALSE);
                IF WhseSNRequired OR WhseLNRequired THEN
                    ItemTrackingMgt.InitItemTrkgForTempWkshLine(
                      WhseWkshLine."Whse. Document Type"::Shipment, "No.",
                      "Line No.", "Source Type",
                      "Source Subtype", "Source No.",
                      "Source Line No.", 0);
            END;
        END;
    end;

    local procedure SetQtysOnShptLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; Qty: Decimal; QtyBase: Decimal)
    var
        Location: Record Location;
    begin
        WITH WarehouseShipmentLine DO BEGIN
            Quantity := Qty;
            "Qty. (Base)" := QtyBase;
            InitOutstandingQtys;
            CheckSourceDocLineQty;
            IF Location.GET("Location Code") THEN
                IF Location."Directed Put-away and Pick" THEN
                    CheckBin(0, 0);
        END;
    end;

    local procedure CreateReceiptLine(var WhseReceiptLine: Record "Warehouse Receipt Line")
    var
        Item: Record Item;
    begin
        WITH WhseReceiptLine DO BEGIN
            Item."No." := "Item No.";
            Item.ItemSKUGet(Item, "Location Code", "Variant Code");
            "Shelf No." := Item."Shelf No.";
            Status := GetLineStatus;
            INSERT;
        END;
    end;

    local procedure SetQtysOnRcptLine(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; Qty: Decimal; QtyBase: Decimal)
    begin
        WITH WarehouseReceiptLine DO BEGIN
            Quantity := Qty;
            "Qty. (Base)" := QtyBase;
            InitOutstandingQtys;
        END;
    end;

    local procedure UpdateShptLine(var WhseShptLine: Record "Warehouse Shipment Line"; WhseShptHeader: Record "Warehouse Shipment Header")
    begin
        WITH WhseShptLine DO BEGIN
            IF WhseShptHeader."Zone Code" <> '' THEN
                VALIDATE("Zone Code", WhseShptHeader."Zone Code");
            IF WhseShptHeader."Bin Code" <> '' THEN
                VALIDATE("Bin Code", WhseShptHeader."Bin Code");
        END;
    end;

    local procedure UpdateReceiptLine(var WhseReceiptLine: Record "Warehouse Receipt Line"; WhseReceiptHeader: Record "Warehouse Receipt Header")
    begin
        WITH WhseReceiptLine DO BEGIN
            IF WhseReceiptHeader."Zone Code" <> '' THEN
                VALIDATE("Zone Code", WhseReceiptHeader."Zone Code");
            IF WhseReceiptHeader."Bin Code" <> '' THEN
                VALIDATE("Bin Code", WhseReceiptHeader."Bin Code");
            IF WhseReceiptHeader."Cross-Dock Zone Code" <> '' THEN
                VALIDATE("Cross-Dock Zone Code", WhseReceiptHeader."Cross-Dock Zone Code");
            IF WhseReceiptHeader."Cross-Dock Bin Code" <> '' THEN
                VALIDATE("Cross-Dock Bin Code", WhseReceiptHeader."Cross-Dock Bin Code");
        END;
    end;

    procedure CheckIfFromSalesLine2ShptLine(SalesLine: Record "Sales Line"): Boolean
    begin
        SalesLine.CALCFIELDS("Whse. Outstanding Qty. (Base)");
        IF ABS(SalesLine."Outstanding Qty. (Base)") <= ABS(SalesLine."Whse. Outstanding Qty. (Base)") THEN
            EXIT;
        EXIT(TRUE);
    end;

    procedure CheckIfFromServiceLine2ShptLin(ServiceLine: Record "Service Line"): Boolean
    begin
        ServiceLine.CALCFIELDS("Whse. Outstanding Qty. (Base)");
        EXIT(ABS(ServiceLine."Outstanding Qty. (Base)") > ABS(ServiceLine."Whse. Outstanding Qty. (Base)"));
    end;

    procedure CheckIfSalesLine2ReceiptLine(SalesLine: Record "Sales Line"): Boolean
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        WITH WhseReceiptLine DO BEGIN
            SETCURRENTKEY("Source Type", "Source Subtype", "Source No.", "Source Line No.");
            SETRANGE("Source Type", DATABASE::"Sales Line");
            SETRANGE("Source Subtype", SalesLine."Document Type");
            SETRANGE("Source No.", SalesLine."Document No.");
            SETRANGE("Source Line No.", SalesLine."Line No.");
            CALCSUMS("Qty. Outstanding (Base)");
            IF ABS(SalesLine."Outstanding Qty. (Base)") <= ABS("Qty. Outstanding (Base)") THEN
                EXIT;
            EXIT(TRUE);
        END;
    end;

    procedure CheckIfFromPurchLine2ShptLine(PurchLine: Record "Purchase Line"): Boolean
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        WITH WhseShptLine DO BEGIN
            SETCURRENTKEY("Source Type", "Source Subtype", "Source No.", "Source Line No.");
            SETRANGE("Source Type", DATABASE::"Purchase Line");
            SETRANGE("Source Subtype", PurchLine."Document Type");
            SETRANGE("Source No.", PurchLine."Document No.");
            SETRANGE("Source Line No.", PurchLine."Line No.");
            CALCSUMS("Qty. Outstanding (Base)");
            IF ABS(PurchLine."Outstanding Qty. (Base)") <= "Qty. Outstanding (Base)" THEN
                EXIT;
            EXIT(TRUE);
        END;
    end;

    procedure CheckIfPurchLine2ReceiptLine(PurchLine: Record "Purchase Line"): Boolean
    begin
        PurchLine.CALCFIELDS("Whse. Outstanding Qty. (Base)");
        IF ABS(PurchLine."Outstanding Qty. (Base)") <= ABS(PurchLine."Whse. Outstanding Qty. (Base)") THEN
            EXIT;
        EXIT(TRUE);
    end;

    procedure CheckIfFromTransLine2ShptLine(TransLine: Record "Transfer Line"): Boolean
    var
        Location: Record Location;
    begin
        TransLine.CALCFIELDS("Whse Outbnd. Otsdg. Qty (Base)");

        IF Location.GetLocationSetup(TransLine."Transfer-from Code", Location) THEN
            IF Location."Use As In-Transit" THEN
                EXIT;
        IF TransLine."Outstanding Qty. (Base)" <= TransLine."Whse Outbnd. Otsdg. Qty (Base)" THEN
            EXIT;
        EXIT(TRUE);
    end;

    procedure CheckIfTransLine2ReceiptLine(TransLine: Record "Transfer Line"): Boolean
    var
        Location: Record Location;
    begin
        TransLine.CALCFIELDS("Whse. Inbnd. Otsdg. Qty (Base)");

        IF Location.GetLocationSetup(TransLine."Transfer-to Code", Location) THEN
            IF Location."Use As In-Transit" THEN
                EXIT;
        IF TransLine."Qty. in Transit (Base)" <= TransLine."Whse. Inbnd. Otsdg. Qty (Base)" THEN
            EXIT;

        EXIT(TRUE);
    end;
}

