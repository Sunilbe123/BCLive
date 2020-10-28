codeunit 50030 "New Pick Creation for CombPick"
{
    // version CASE13605,MITL1803,MITL2024


    trigger OnRun()
    var
        CreateStockEntriesCOD_L: Codeunit "Finding Whse entry";
        NoStockLineRecL: Record "Pick Crt_Whse Shp Lines";
        TempCount: Integer;
        CustomCalendarChange: array[2] of Record "Customized Calendar Change";
    begin
        // NoStockLineRecL.LockTable(); //MITL2024
        NoStockLineRecL.DELETEALL;

        // Lock required tables
        // RegisterActivityRecLock.LOCKTABLE;
        // WarehouseShipmentHeader.LOCKTABLE;
        // WhseActiHeadRecLock.LOCKTABLE;
        // WhseEntryLock.LOCKTABLE;
        // recWarehouseShipmentLine.LockTable; //MITL1803 


        // Start point for creating Picks as Due Date, Source Document & Source No.
        DocNo := '';
        TempItemTrcBuffRecG.DELETEALL;
        TempLineNoL := 10000;
        CLEAR(OrdersG);
        SalesReceiveableSetup.Get();//mitl_6532
        recWarehouseShipmentLine.RESET;
        // recWarehouseShipmentLine.SETCURRENTKEY("Due Date", "Source Document", "Source No.");
        recWarehouseShipmentLine.SetCurrentKey("Source Document", "Qty. Picked", "Zone Code", "BIN Code"); // MITL.SM.20200503 Indexing correction
        recWarehouseShipmentLine.SETRANGE("Source Document", recWarehouseShipmentLine."Source Document"::"Sales Order");
        recWarehouseShipmentLine.SETRANGE("Qty. Picked", 0);
        recWarehouseShipmentLine.SETRANGE("Pick Qty.", 0);
        // recWarehouseShipmentLine.SETRANGE("Combined Pick", FALSE); //MITL.AJ.07012020
        IF recWarehouseShipmentLine.FINDSET THEN
            REPEAT
                IF DocNo <> recWarehouseShipmentLine."Source No." THEN BEGIN
                    SalesHeader.GET(SalesHeader."Document Type"::Order, recWarehouseShipmentLine."Source No.");
                    //mitl_6532++
                    if recWarehouseShipmentLine."Combined Pick" then
                        CreatePicks
                    else begin
                        //WebOrderHeader.Reset();
                        //WebOrderHeader.SetRange("Order ID", SalesHeader.WebOrderID);
                        //if WebOrderHeader.FindLast() then
                        CustomCalendarChange[1].SetSource(1, '', '', '');
                        if (recWarehouseShipmentLine."Shipment Date" in [DMY2Date(01, 01, 2000) ..
                    CalendarMgnt.CalcDateBOC(format(SalesReceiveableSetup.PickCreationCalc), Today, CustomCalendarChange, false)]) then
                            //mitl_6532--
                            CreatePicks;
                    end;

                    DocNo := recWarehouseShipmentLine."Source No.";
                END;
            UNTIL recWarehouseShipmentLine.NEXT = 0;

        CreateStockEntriesCOD_L.RUN;
        CreateSummaryTable;
        CreateWorksheetLines;
        DeleteZeroQtyBeforeMovementCreate;
        MovementCreate;
        UpdateNoStockStatus;
        CheckMovementcreated;
        UpstatusMovementCreatedStatusInOrderStatus;
        CreatePickStatusLineForCombinedPicks;

    end;

    var
        SalesHeader: Record "Sales Header";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        recWarehouseShipmentLine: Record "Warehouse Shipment Line";
        CheckAvailL: Boolean;
        TotalAvailQtyL: Decimal;
        TempLineNoL: Integer;
        CombinedPick: Boolean;
        DocNo: Code[20];
        OrdersG: BigText;
        TempItemTrcBuffRecG: Record "Item Tracing Buffer" temporary;
        RegisterActivityRecLock: Record "Registered Whse. Activity Hdr.";
        WhseEntryLock: Record "Warehouse Entry";
        WhseActiHeadRecLock: Record "Warehouse Activity Header";
        SalesReceiveableSetup: Record "Sales & Receivables Setup";//mitl_6532
        WebOrderHeader: Record "WEB Order Header";//mitl_6532
        CalendarMgnt: Codeunit "Calendar Management"; //MITL.6532.SM

    local procedure CreatePicks()
    var
        StausPickL: Option " ","Pick Created","Pick Pending Movement Created","Pick Pending No Stock","Skipped-Comb Pick","Update in-Progress";
        WarehouseShipmentLineL: Record "Warehouse Shipment Line";
    begin
        // MITL ++

        // Pick Creation per Source No.
        CheckAvailL := TRUE;
        // TempItemTrcBuffRecG.DeleteAll(); //MITL5754
        WarehouseShipmentLineL.SetCurrentKey("Source Document", "Qty. Picked", "Zone Code", "BIN Code"); // MITL.SM.20200503 Indexing correction        
        WarehouseShipmentLineL.SETRANGE("Source Document", WarehouseShipmentLineL."Source Document"::"Sales Order");
        WarehouseShipmentLineL.SETRANGE("Source No.", SalesHeader."No.");
        WarehouseShipmentLineL.SETRANGE("Qty. Picked", 0);
        WarehouseShipmentLineL.SETRANGE("Pick Qty.", 0);
        IF WarehouseShipmentLineL.FINDSET THEN
            REPEAT
                // Calculating Total Quantity Avaialable to Pick
                TotalAvailQtyL := CalcAvailQtyBaseToPick(WarehouseShipmentLineL);
                IF TotalAvailQtyL <= 0 THEN
                    CheckAvailL := FALSE
                ELSE BEGIN
                    // Buffer Table for maintaining Stock information & if stock available then Pick will create else mainting info for further process
                    TempItemTrcBuffRecG.SETRANGE("Item No.", WarehouseShipmentLineL."Item No.");
                    TempItemTrcBuffRecG.SETRANGE("Location Code", WarehouseShipmentLineL."Location Code");
                    TempItemTrcBuffRecG.SETRANGE("Variant Code", WarehouseShipmentLineL."Variant Code");
                    IF NOT TempItemTrcBuffRecG.FINDFIRST THEN BEGIN
                        TempItemTrcBuffRecG."Line No." := TempLineNoL;
                        TempItemTrcBuffRecG."Item No." := WarehouseShipmentLineL."Item No.";
                        TempItemTrcBuffRecG."Location Code" := WarehouseShipmentLineL."Location Code";
                        TempItemTrcBuffRecG."Variant Code" := WarehouseShipmentLineL."Variant Code";
                        TempItemTrcBuffRecG.Quantity := WarehouseShipmentLineL."Qty. Outstanding (Base)";
                        TempItemTrcBuffRecG.INSERT;
                        TempLineNoL += 10000;
                    END ELSE BEGIN
                        TempItemTrcBuffRecG.Quantity += WarehouseShipmentLineL."Qty. Outstanding (Base)";
                        TempItemTrcBuffRecG.MODIFY;
                    END;
                END;

                IF CheckAvailL THEN BEGIN
                    IF (TotalAvailQtyL - TempItemTrcBuffRecG.Quantity) < 0 THEN BEGIN
                        CheckAvailL := FALSE;
                    END;
                END;
            UNTIL WarehouseShipmentLineL.NEXT = 0;
        // MITL --


        // IF (NOT CombinedPick) AND (CheckAvailL) THEN BEGIN// MITL added CheckAvailL condition //MITL.AJ.07012020
        IF CheckAvailL then begin //MITL.AJ.07012020
            CheckAndRelease;
            WarehouseShipmentHeader.SETRANGE("No.", WarehouseShipmentLineL."No.");
            WarehouseShipmentHeader.FINDFIRST;
            WarehouseShipmentLineL.SetHideValidationDialogCustom(TRUE);
            WarehouseShipmentLineL.CreatePickDocCustom(WarehouseShipmentLineL, WarehouseShipmentHeader);
            CreatePickStatusLine(WarehouseShipmentLineL, StausPickL::"Pick Created");
        END ELSE BEGIN
            CreateDetailLines(WarehouseShipmentLineL);
            CreatePickStatusLine(WarehouseShipmentLineL, StausPickL::"Update in-Progress");
        END;
    end;

    procedure CalcTotalAvailQtyToPick(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; QtyPerUnitofMeasure: Decimal; CrossDock: Boolean): Decimal
    var
        WhseEntry: Record "Warehouse Entry";
        WhseActivLine: Record "Warehouse Activity Line";
        TotalAvailQtyBase: Decimal;
        QtyInWhse: Decimal;
        QtyOnPickBins: Decimal;
        QtyOnOutboundBins: Decimal;
        SubTotal: Decimal;
        QtyReservedOnPickShip: Decimal;
        LineReservedQty: Decimal;
        QtyAssignedPick: Decimal;
        QtyAssignedToPick: Decimal;
        Location: Record Location;
        Item: Record Item;
        Bin: Record Bin;
        BinType: Record "Bin Type";
    begin
        GetLocation(LocationCode);

        GetItem(ItemNo);

        WITH WhseActivLine DO BEGIN
            SETCURRENTKEY(
              "Item No.", "Location Code", "Activity Type", "Bin Type Code",
              "Unit of Measure Code", "Variant Code", "Breakbulk No.", "Action Type");

            SETRANGE("Item No.", ItemNo);
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Activity Type", WhseActivLine."Activity Type"::Pick);
            SETRANGE("Variant Code", VariantCode);
            SETRANGE("Breakbulk No.", 0);
            SETFILTER("Action Type", '%1|%2', "Action Type"::" ", "Action Type"::Take);
            CALCSUMS("Qty. Outstanding (Base)");
            QtyAssignedToPick := WhseActivLine."Qty. Outstanding (Base)";
        END;

        WITH WhseEntry DO BEGIN
            RESET;
            SETCURRENTKEY("Item No.", "Location Code", "Variant Code", "Bin Type Code");
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Variant Code", VariantCode);
            CALCSUMS("Qty. (Base)");
            QtyInWhse := "Qty. (Base)";

            SETFILTER("Bin Type Code", GetBinTypeFilter(3)); // Picking area
            MESSAGE(FORMAT(GetBinTypeFilter(3)));
            CALCSUMS("Qty. (Base)");
            QtyOnPickBins := "Qty. (Base)";

            QtyOnOutboundBins :=
              CalcQtyOnOutboundBins(
                LocationCode, ItemNo, VariantCode);
        END;

        QtyAssignedPick := 0;

        IF Location."Always Create Pick Line" OR CrossDock THEN BEGIN
            WhseActivLine.RESET;
            WhseActivLine.SETCURRENTKEY(
              "Item No.", "Bin Code", "Location Code", "Action Type", "Variant Code",
              "Unit of Measure Code", "Breakbulk No.", "Activity Type");

            WhseActivLine.SETRANGE("Item No.", ItemNo);
            WhseActivLine.SETRANGE("Bin Code", '');
            WhseActivLine.SETRANGE("Location Code", LocationCode);
            WhseActivLine.SETRANGE("Action Type", WhseActivLine."Action Type"::Take);
            WhseActivLine.SETRANGE("Variant Code", VariantCode);
            WhseActivLine.SETRANGE("Breakbulk No.", 0);
            WhseActivLine.SETRANGE("Activity Type", WhseActivLine."Activity Type"::Pick);
            WhseActivLine.CALCSUMS("Qty. Outstanding (Base)");
            QtyAssignedPick := QtyAssignedPick - WhseActivLine."Qty. Outstanding (Base)";
        END;

        TotalAvailQtyBase :=
          QtyOnPickBins -
          QtyAssignedPick - QtyAssignedToPick;

        EXIT(ROUND(TotalAvailQtyBase / QtyPerUnitofMeasure, 0.00001));
    end;

    local procedure GetLocation(LocationCode: Code[10])
    var
        Location: Record Location;
    begin
        IF Location.Code <> LocationCode THEN BEGIN
            Location.GET(LocationCode);
        END;
    end;

    local procedure GetBin(LocationCode: Code[10]; BinCode: Code[20])
    var
        Bin: Record Bin;
    begin
        IF (Bin."Location Code" <> LocationCode) OR
           (Bin.Code <> BinCode)
        THEN
            IF NOT Bin.GET(LocationCode, BinCode) THEN
                CLEAR(Bin);
    end;

    local procedure GetItem(ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        IF Item."No." <> ItemNo THEN
            Item.GET(ItemNo);
    end;

    procedure GetBinTypeFilter(Type: Option Receive,Ship,"Put Away",Pick): Text[1024]
    var
        BinType: Record "Bin Type";
        BinFilter: Text[1024];
    begin
        WITH BinType DO BEGIN
            CASE Type OF
                Type::Receive:
                    SETRANGE(Receive, TRUE);
                Type::Ship:
                    SETRANGE(Ship, TRUE);
                Type::"Put Away":
                    SETRANGE("Put Away", TRUE);
                Type::Pick:
                    SETRANGE(Pick, TRUE);
            END;
            IF FINDSET(FALSE, FALSE) THEN // << [ABS Ref 11331]
                REPEAT
                    BinFilter := STRSUBSTNO('%1|%2', BinFilter, BinType.Code);
                UNTIL NEXT = 0;
            IF BinFilter <> '' THEN
                BinFilter := COPYSTR(BinFilter, 2);
        END;
        EXIT(BinFilter);
    end;

    procedure CalcQtyOnOutboundBins(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Decimal
    var
        WhseEntry: Record "Warehouse Entry";
        WhseShptLine: Record "Warehouse Shipment Line";
        QtyOnOutboundBins1: Decimal;
        QtyOnOutboundBins2: Decimal;
        OutBoundFilter: Text[1024];
        Location: Record Location;
        Item: Record Item;
        Bin: Record Bin;
        BinType: Record "Bin Type";
    begin
        GetLocation(LocationCode);

        IF Location."Directed Put-away and Pick" THEN
            WITH WhseEntry DO BEGIN
                RESET;
                SETCURRENTKEY(
                  "Item No.", "Location Code", "Variant Code", "Bin Type Code",
                  "Unit of Measure Code", "Lot No.", "Serial No.");

                SETRANGE("Item No.", ItemNo);
                SETRANGE("Location Code", LocationCode);
                SETRANGE("Variant Code", VariantCode);
                SETFILTER("Bin Type Code", GetBinTypeFilter(1)); // Shipping area
                CALCSUMS("Qty. (Base)");
                QtyOnOutboundBins1 := "Qty. (Base)";

                OutBoundFilter := SetOutBoundFilter(Location);
                IF OutBoundFilter <> '' THEN BEGIN
                    RESET;
                    SETCURRENTKEY(
                      "Item No.", "Bin Code", "Location Code", "Variant Code",
                      "Unit of Measure Code", "Lot No.", "Serial No.");

                    SETRANGE("Item No.", ItemNo);
                    SETFILTER("Bin Code", OutBoundFilter);
                    SETRANGE("Location Code", LocationCode);
                    SETRANGE("Variant Code", VariantCode);
                    CALCSUMS("Qty. (Base)");
                    QtyOnOutboundBins2 := "Qty. (Base)";
                END ELSE
                    QtyOnOutboundBins2 := 0;
            END
        ELSE
            IF Location."Require Pick" THEN BEGIN
                WhseShptLine.RESET;
                WhseShptLine.SETCURRENTKEY("Item No.", "Location Code", "Variant Code");
                WhseShptLine.SETRANGE("Item No.", ItemNo);
                WhseShptLine.SETRANGE("Location Code", LocationCode);
                WhseShptLine.SETRANGE("Variant Code", VariantCode);
                WhseShptLine.CALCSUMS("Qty. Outstanding (Base)", "Qty. Picked (Base)");
                IF WhseShptLine."Qty. Outstanding (Base)" < WhseShptLine."Qty. Picked (Base)" THEN
                    QtyOnOutboundBins1 := WhseShptLine."Qty. Outstanding (Base)"
                ELSE
                    QtyOnOutboundBins1 := WhseShptLine."Qty. Picked (Base)";
            END;
        EXIT(QtyOnOutboundBins1 + QtyOnOutboundBins2);
    end;

    local procedure SetOutBoundFilter(Location2: Record Location): Text[1024]
    var
        "Filter": Text[1024];
    begin
        WITH Location2 DO BEGIN
            IF "Open Shop Floor Bin Code" <> '' THEN
                Filter := "Open Shop Floor Bin Code";
            IF "Adjustment Bin Code" <> '' THEN
                IF Filter <> '' THEN
                    Filter := STRSUBSTNO('%1|%2', Filter, "Adjustment Bin Code")
                ELSE
                    Filter := "Adjustment Bin Code";
        END;
        EXIT(Filter);
    end;

    local procedure CreatePickStatusLine(WarehouseShipmentLineP: Record "Warehouse Shipment Line"; StatusPickP: Option " ","Pick Created","Pick Pending Movement Created","Pick Pending No Stock","Skipped-Comb Pick","Update in-Progress")
    var
        PickCreationStatusRecL: Record "Pick Creation Status";
        GetPickCreationStatusRecL: Record "Pick Creation Status";
        GetNo: Integer;
    begin
        GetNo := 0;
        GetPickCreationStatusRecL.RESET;
        IF GetPickCreationStatusRecL.FINDLAST THEN
            GetNo := GetPickCreationStatusRecL."No." + 1
        ELSE
            GetNo := 1;

        GetPickCreationStatusRecL.RESET;
        GetPickCreationStatusRecL.SETCURRENTKEY("Source Document", "Source No.");
        GetPickCreationStatusRecL.SETRANGE("Source Document", GetPickCreationStatusRecL."Source Document"::"Sales Order");
        GetPickCreationStatusRecL.SETRANGE("Source No.", SalesHeader."No.");
        IF NOT GetPickCreationStatusRecL.FINDFIRST THEN BEGIN
            PickCreationStatusRecL.INIT;
            PickCreationStatusRecL."No." := GetNo;
            PickCreationStatusRecL."Source Type" := WarehouseShipmentLineP."Source Type";
            PickCreationStatusRecL."Source Subtype" := WarehouseShipmentLineP."Source Subtype";
            PickCreationStatusRecL."Source Document" := WarehouseShipmentLineP."Source Document";
            PickCreationStatusRecL."Source No." := WarehouseShipmentLineP."Source No.";
            PickCreationStatusRecL.Status := StatusPickP;
            PickCreationStatusRecL."Last Status" := StatusPickP;
            PickCreationStatusRecL."Web Order No." := SalesHeader.WebOrderID;
            PickCreationStatusRecL.Whse_Movement_No := '';
            PickCreationStatusRecL."Creation Date Time" := CURRENTDATETIME;
            PickCreationStatusRecL."Last modified Date Time" := PickCreationStatusRecL."Creation Date Time";
            PickCreationStatusRecL.INSERT;
        END ELSE BEGIN
            GetPickCreationStatusRecL."Last Status" := GetPickCreationStatusRecL.Status;
            GetPickCreationStatusRecL.Status := StatusPickP;
            GetPickCreationStatusRecL.Whse_Movement_No := '';
            GetPickCreationStatusRecL."Creation Date Time" := CURRENTDATETIME;
            GetPickCreationStatusRecL."Last modified Date Time" := GetPickCreationStatusRecL."Creation Date Time";
            GetPickCreationStatusRecL.MODIFY;
        END;
    end;

    local procedure CreateWorksheetLines()
    var
        WhseWkshLineL: Record "Whse. Worksheet Line";
        StockAvailRecL: Record "Pick Crt_Buffer2";
        WahseEntryRecL: Record "Warehouse Entry";
        LocationRecL: Record Location;
        SummaryBufferRecL: Record "Pick Crt_Buffer1";
        ShortQtyBaseL: Decimal;
        BinRecL: Record Bin;
        NextLineNo: Integer;
        MovementQtyBase: Decimal;
        GetWhseWkshLineL: Record "Whse. Worksheet Line";
    begin
        SummaryBufferRecL.RESET;
        SummaryBufferRecL.SETFILTER("Short Fall (Base)", '>0');
        IF SummaryBufferRecL.FINDSET THEN
            REPEAT
                ShortQtyBaseL := 0;
                ShortQtyBaseL := SummaryBufferRecL."Short Fall (Base)";
                MovementQtyBase := 0;

                LocationRecL.RESET;
                LocationRecL.GET(SummaryBufferRecL."Location Code");
                GetWhseWkshLineL.RESET;
                GetWhseWkshLineL.SETRANGE("Worksheet Template Name", LocationRecL."Auto Pick Template Name");
                GetWhseWkshLineL.SETRANGE(Name, LocationRecL."Auto Pick Batch Name");
                IF GetWhseWkshLineL.FINDLAST THEN
                    NextLineNo := GetWhseWkshLineL."Line No." + 10000
                ELSE
                    NextLineNo := 10000;

                StockAvailRecL.RESET;
                StockAvailRecL.SETCURRENTKEY("Registering Date");
                StockAvailRecL.SETRANGE("Location Code", SummaryBufferRecL."Location Code");
                StockAvailRecL.SETRANGE("Item No.", SummaryBufferRecL."Item No.");
                StockAvailRecL.SETRANGE("Variant Code", SummaryBufferRecL."Variant Code");
                StockAvailRecL.SETFILTER("Qty. (Base)", '>0');
                IF StockAvailRecL.FINDSET THEN
                    REPEAT
                        IF ShortQtyBaseL > 0 THEN BEGIN
                            WhseWkshLineL.INIT;
                            WhseWkshLineL."Worksheet Template Name" := LocationRecL."Auto Pick Template Name";
                            WhseWkshLineL.Name := LocationRecL."Auto Pick Batch Name";
                            WhseWkshLineL."Location Code" := StockAvailRecL."Location Code";
                            WhseWkshLineL."Line No." := NextLineNo;
                            WhseWkshLineL."From Bin Code" := StockAvailRecL."Bin Code";
                            WhseWkshLineL."From Zone Code" := StockAvailRecL."Zone Code";
                            WhseWkshLineL."From Unit of Measure Code" := StockAvailRecL."Unit of Measure Code";
                            WhseWkshLineL."Qty. per From Unit of Measure" := StockAvailRecL."Qty. per Unit of Measure";

                            BinRecL.RESET;
                            IF BinRecL.GET(StockAvailRecL."Location Code",
                              GetToBinCode(StockAvailRecL."Item No.", StockAvailRecL."Location Code", StockAvailRecL."Variant Code")) THEN
                                ;

                            WhseWkshLineL."To Bin Code" := BinRecL.Code;
                            WhseWkshLineL."To Zone Code" := BinRecL."Zone Code";
                            WhseWkshLineL."Unit of Measure Code" := SummaryBufferRecL."Unit of Measure Code";
                            WhseWkshLineL."Qty. per Unit of Measure" := SummaryBufferRecL."Qty. per Unit of Measure";
                            WhseWkshLineL."Item No." := StockAvailRecL."Item No.";
                            WhseWkshLineL.VALIDATE("Variant Code", StockAvailRecL."Variant Code");

                            IF ShortQtyBaseL > 0 THEN BEGIN
                                MovementQtyBase := StockAvailRecL."Qty. (Base)";
                                ShortQtyBaseL := ShortQtyBaseL - StockAvailRecL."Qty. (Base)";
                            END;

                            WhseWkshLineL.VALIDATE(Quantity, ROUND(MovementQtyBase / StockAvailRecL."Qty. per Unit of Measure", 0.00001));

                            WhseWkshLineL."Qty. (Base)" := MovementQtyBase;
                            WhseWkshLineL."Qty. Outstanding (Base)" := MovementQtyBase;
                            WhseWkshLineL."Qty. to Handle (Base)" := MovementQtyBase;
                            WhseWkshLineL."Qty. Handled (Base)" := MovementQtyBase;

                            WhseWkshLineL."Whse. Document Type" := WhseWkshLineL."Whse. Document Type"::"Whse. Mov.-Worksheet";
                            WhseWkshLineL."Whse. Document No." := LocationRecL."Auto Pick Batch Name";
                            WhseWkshLineL."Whse. Document Line No." := WhseWkshLineL."Line No.";
                            WhseWkshLineL.INSERT;

                            NextLineNo := NextLineNo + 10000;
                        END;
                    UNTIL StockAvailRecL.NEXT = 0;
            UNTIL SummaryBufferRecL.NEXT = 0;
    end;

    local procedure CreateSummaryTable()
    var
        DetailWsheRecL: Record "Pick Crt_Whse Shp Lines";
        SummaryBufferRecL: Record "Pick Crt_Buffer1";
        CheckSummaryBufferRecL: Record "Pick Crt_Buffer1";
        ItemL: Record Item;
    begin
        CheckSummaryBufferRecL.DELETEALL;

        DetailWsheRecL.RESET;
        DetailWsheRecL.SETCURRENTKEY("Item No.", "Location Code", "Variant Code", "Due Date");
        IF DetailWsheRecL.FINDSET THEN
            REPEAT
                CheckSummaryBufferRecL.RESET;
                CheckSummaryBufferRecL.SETRANGE("Location Code", DetailWsheRecL."Location Code");
                CheckSummaryBufferRecL.SETRANGE("Item No.", DetailWsheRecL."Item No.");
                CheckSummaryBufferRecL.SETRANGE("Variant Code", DetailWsheRecL."Variant Code");
                CheckSummaryBufferRecL.SETRANGE("Unit of Measure Code", DetailWsheRecL."Unit of Measure Code");
                IF NOT CheckSummaryBufferRecL.FINDFIRST THEN BEGIN
                    SummaryBufferRecL.INIT;
                    SummaryBufferRecL."Location Code" := DetailWsheRecL."Location Code";
                    SummaryBufferRecL."Item No." := DetailWsheRecL."Item No.";
                    SummaryBufferRecL."Variant Code" := DetailWsheRecL."Variant Code";
                    ItemL.RESET;
                    IF ItemL.GET(DetailWsheRecL."Item No.") THEN
                        SummaryBufferRecL."Unit of Measure Code" := ItemL."Base Unit of Measure"
                    ELSE
                        SummaryBufferRecL."Unit of Measure Code" := DetailWsheRecL."Unit of Measure Code";
                    SummaryBufferRecL.INSERT;
                END;
            UNTIL DetailWsheRecL.NEXT = 0;

        UpdateSumaryTable;
    end;

    local procedure UpdateSumaryTable()
    var
        SummaryBufferRecL: Record "Pick Crt_Buffer1";
        AvailableQtyL: Decimal;
        DetailReqLinesRecL: Record "Pick Crt_Whse Shp Lines";
        GetBulkBinQtyCOD_L: Codeunit "Finding Whse entry";
        LocationRecL: Record Location;
    begin
        SummaryBufferRecL.RESET;
        SummaryBufferRecL.SETCURRENTKEY("Location Code", "Item No.", "Variant Code", "Unit of Measure Code");
        SummaryBufferRecL.SETFILTER("Item No.", '<>%1', '');
        SummaryBufferRecL.SETAUTOCALCFIELDS("Move Quantity (Base)");
        IF SummaryBufferRecL.FINDSET THEN
            REPEAT
                LocationRecL.RESET;
                IF LocationRecL.GET(SummaryBufferRecL."Location Code") THEN;
                SummaryBufferRecL.SETFILTER("Adjustment Bin Code Filter", '<>%1', LocationRecL."Adjustment Bin Code");

                AvailableQtyL := 0;
                AvailableQtyL := SummaryBufferRecL.CalcQtyAvailToPick(0);
                AvailableQtyL := AvailableQtyL - CalcShipNReceiveBinQty(SummaryBufferRecL);
                SummaryBufferRecL."Qty to Pick (Base)" := AvailableQtyL;

                DetailReqLinesRecL.RESET;
                DetailReqLinesRecL.SETCURRENTKEY("Item No.", "Location Code", "Variant Code", "Due Date");
                DetailReqLinesRecL.SETRANGE("Item No.", SummaryBufferRecL."Item No.");
                DetailReqLinesRecL.SETRANGE("Location Code", SummaryBufferRecL."Location Code");
                DetailReqLinesRecL.SETRANGE("Variant Code", SummaryBufferRecL."Variant Code");
                IF DetailReqLinesRecL.FINDSET THEN BEGIN
                    DetailReqLinesRecL.CALCSUMS("Qty. Outstanding (Base)");
                    SummaryBufferRecL."Demand Qty (Base)" := DetailReqLinesRecL."Qty. Outstanding (Base)";
                END;

                CLEAR(GetBulkBinQtyCOD_L);
                SummaryBufferRecL."Bulk Bin Qty (Base)" :=
                  GetBulkBinQtyCOD_L.ClacBulkBinQty(SummaryBufferRecL."Location Code", SummaryBufferRecL."Item No.", SummaryBufferRecL."Variant Code");
                SummaryBufferRecL."Pick Bin Stock (Base)" := CalcPickBinQty(SummaryBufferRecL);
                SummaryBufferRecL."Short Fall (Base)" := SummaryBufferRecL."Demand Qty (Base)" -
                  (SummaryBufferRecL."Pick Bin Stock (Base)" + SummaryBufferRecL."Move Quantity (Base)");
                SummaryBufferRecL."Total Avail Qty to Pick (Base)" := AvailableQtyL;
                SummaryBufferRecL."Shortage Stock (Base)" := AvailableQtyL - SummaryBufferRecL."Demand Qty (Base)";
                SummaryBufferRecL.MODIFY;
            UNTIL SummaryBufferRecL.NEXT = 0;
    end;

    local procedure GetToBinCode(ItemNoP: Code[20]; LocationCodeP: Code[10]; VariantCodeP: Code[10]) BinCodeR: Code[20]
    var
        BinContentRecL: Record "Bin Content";
        RegisPickLinesRecL: Record "Registered Whse. Activity Line";
        BinTypeRecL: Record "Bin Type";
    begin
        BinContentRecL.RESET;
        BinContentRecL.SETCURRENTKEY("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
        BinContentRecL.SETRANGE("Item No.", ItemNoP);
        BinContentRecL.SETRANGE("Location Code", LocationCodeP);
        BinContentRecL.SETRANGE("Variant Code", VariantCodeP);
        BinContentRecL.SETRANGE(Fixed, TRUE);
        IF BinContentRecL.FINDSET THEN
            REPEAT
                IF BinContentRecL."Block Movement" = BinContentRecL."Block Movement"::" " THEN BEGIN
                    BinTypeRecL.RESET;
                    BinTypeRecL.SETRANGE(Code, BinContentRecL."Bin Type Code");
                    BinTypeRecL.SETRANGE(Pick, TRUE);
                    IF BinTypeRecL.FINDFIRST THEN
                        BinCodeR := BinContentRecL."Bin Code";
                END;
            UNTIL (BinCodeR <> '') OR (BinContentRecL.NEXT = 0);

        IF BinCodeR = '' THEN BEGIN
            RegisPickLinesRecL.RESET;
            RegisPickLinesRecL.SETRANGE("Item No.", ItemNoP);
            RegisPickLinesRecL.SETRANGE("Location Code", LocationCodeP);
            RegisPickLinesRecL.SETRANGE("Action Type", RegisPickLinesRecL."Action Type"::Take);
            RegisPickLinesRecL.SETRANGE("Activity Type", RegisPickLinesRecL."Activity Type"::Pick);
            RegisPickLinesRecL.SETFILTER(Quantity, '>0');
            IF RegisPickLinesRecL.FINDLAST THEN BEGIN
                BinCodeR := RegisPickLinesRecL."Bin Code";
            END;
        END;
    end;

    local procedure CreateDetailLines(WhseShipmentLineRecP: Record "Warehouse Shipment Line")
    var
        NoStockLineRecL: Record "Pick Crt_Whse Shp Lines";
        WhseShipmentLineRecL: Record "Warehouse Shipment Line";
    begin
        WhseShipmentLineRecL.RESET;
        WhseShipmentLineRecL.SETCURRENTKEY("No.", "Source Document", "Source No.");
        WhseShipmentLineRecL.SETRANGE("Source Document", WhseShipmentLineRecP."Source Document");
        WhseShipmentLineRecL.SETRANGE("Source No.", WhseShipmentLineRecP."Source No.");
        WhseShipmentLineRecL.SETFILTER("Location Code", '<>%1', '');
        WhseShipmentLineRecL.SETFILTER("Item No.", '<>%1', '');
        IF WhseShipmentLineRecL.FINDSET THEN
            REPEAT
                NoStockLineRecL.INIT;
                NoStockLineRecL.TRANSFERFIELDS(WhseShipmentLineRecL);
                NoStockLineRecL.INSERT;
            UNTIL WhseShipmentLineRecL.NEXT = 0;
    end;

    local procedure CalcPickBinQty(SummaryBufferRecP: Record "Pick Crt_Buffer1") PickBaseQtyR: Decimal
    var
        BinContentRecL: Record "Bin Content";
        BinTypeRecL: Record "Bin Type";
    begin
        PickBaseQtyR := 0;
        BinContentRecL.RESET;
        BinContentRecL.SETCURRENTKEY("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
        BinContentRecL.SETRANGE("Location Code", SummaryBufferRecP."Location Code");
        BinContentRecL.SETRANGE("Item No.", SummaryBufferRecP."Item No.");
        BinContentRecL.SETRANGE("Variant Code", SummaryBufferRecP."Variant Code");
        BinContentRecL.SETRANGE("Unit of Measure Code", SummaryBufferRecP."Unit of Measure Code");
        IF BinContentRecL.FINDSET THEN
            REPEAT
                BinTypeRecL.RESET;
                BinTypeRecL.SETRANGE(Code, BinContentRecL."Bin Type Code");
                BinTypeRecL.SETRANGE(Pick, TRUE);
                IF BinTypeRecL.FINDFIRST THEN BEGIN
                    PickBaseQtyR += BinContentRecL.CalcQtyAvailToPick(0);
                END;

            UNTIL BinContentRecL.NEXT = 0;
    end;

    local procedure CalcShipNReceiveBinQty(SummaryBufferRecP: Record "Pick Crt_Buffer1") ShiPRecevBaseQtyR: Decimal
    var
        BinContentRecL: Record "Bin Content";
        BinTypeRecL: Record "Bin Type";
    begin
        ShiPRecevBaseQtyR := 0;
        BinContentRecL.RESET;
        BinContentRecL.SETCURRENTKEY("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
        BinContentRecL.SETRANGE("Location Code", SummaryBufferRecP."Location Code");
        BinContentRecL.SETRANGE("Item No.", SummaryBufferRecP."Item No.");
        BinContentRecL.SETRANGE("Variant Code", SummaryBufferRecP."Variant Code");
        BinContentRecL.SETRANGE("Unit of Measure Code", SummaryBufferRecP."Unit of Measure Code");
        IF BinContentRecL.FINDSET THEN
            REPEAT
                BinTypeRecL.RESET;
                BinTypeRecL.SETRANGE(Code, BinContentRecL."Bin Type Code");
                BinTypeRecL.SETRANGE(Pick, FALSE);
                BinTypeRecL.SETRANGE("Put Away", FALSE);
                IF BinTypeRecL.FINDFIRST THEN BEGIN
                    ShiPRecevBaseQtyR += BinContentRecL.CalcQtyAvailToPick(0);
                END;

            UNTIL BinContentRecL.NEXT = 0;
    end;

    local procedure CheckAndRelease()
    var
        WhseShipLineRecL: Record "Warehouse Shipment Line";
        WhseShipHeadRecL: Record "Warehouse Shipment Header";
        ReleaseWhseShptDoc: Codeunit "Whse.-Shipment Release";
        WhseDocNo: Code[20];
    begin
        WhseDocNo := '';
        WhseShipLineRecL.RESET;
        WhseShipLineRecL.SETCURRENTKEY("No.", "Source Document", "Source No.");
        WhseShipLineRecL.SETRANGE("Source Document", WhseShipLineRecL."Source Document"::"Sales Order");
        WhseShipLineRecL.SETRANGE("Source No.", SalesHeader."No.");
        IF WhseShipLineRecL.FINDSET THEN
            REPEAT
                IF WhseDocNo <> WhseShipLineRecL."No." THEN BEGIN
                    WhseShipHeadRecL.RESET;
                    WhseShipHeadRecL.SETRANGE("No.", WhseShipLineRecL."No.");
                    WhseShipHeadRecL.SETRANGE(Status, WhseShipHeadRecL.Status::Open);
                    IF WhseShipHeadRecL.FINDFIRST THEN BEGIN
                        ReleaseWhseShptDoc.Release(WhseShipHeadRecL);
                    END;
                    WhseDocNo := WhseShipLineRecL."No.";
                END;
            UNTIL WhseShipLineRecL.NEXT = 0;
    end;

    local procedure UpdateNoStockStatus()
    var
        SummaryBuffRecL: Record "Pick Crt_Buffer1";
        DetailLineRecL: Record "Pick Crt_Whse Shp Lines";
    begin
        DetailLineRecL.RESET;
        DetailLineRecL.SETCURRENTKEY("Due Date", "Source Document", "Source No.");
        IF DetailLineRecL.FINDSET(FALSE, FALSE) THEN
            REPEAT
                SummaryBuffRecL.RESET;
                SummaryBuffRecL.SETCURRENTKEY("Location Code", "Item No.", "Variant Code", "Unit of Measure Code");
                SummaryBuffRecL.SETRANGE("Location Code", DetailLineRecL."Location Code");
                SummaryBuffRecL.SETRANGE("Item No.", DetailLineRecL."Item No.");
                SummaryBuffRecL.SETRANGE("Variant Code", DetailLineRecL."Variant Code");
                SummaryBuffRecL.SETRANGE("Unit of Measure Code", DetailLineRecL."Unit of Measure Code");
                SummaryBuffRecL.SETFILTER("Shortage Stock (Base)", '<%1', 0);
                IF SummaryBuffRecL.FINDFIRST THEN
                    REPEAT
                        IF DetailLineRecL."Qty. Outstanding (Base)" < SummaryBuffRecL."Total Avail Qty to Pick (Base)" THEN BEGIN
                            SummaryBuffRecL."Total Avail Qty to Pick (Base)" :=
                              SummaryBuffRecL."Total Avail Qty to Pick (Base)" - DetailLineRecL."Qty. Outstanding (Base)";
                            SummaryBuffRecL.MODIFY;
                            UpstatusInOrderStatus(DetailLineRecL);
                        END ELSE BEGIN
                            UpstatusInOrderStatus(DetailLineRecL);
                        END;
                    UNTIL SummaryBuffRecL.NEXT = 0;
            UNTIL DetailLineRecL.NEXT = 0;
    end;

    procedure DeleteZeroQtyBeforeMovementCreate()
    var
        LocationRecL: Record Location;
        WhseWorksheetLineRecL: Record "Whse. Worksheet Line";
        SummaryBuffRecL: Record "Pick Crt_Buffer1";
        TempLocL: Code[10];
    begin
        TempLocL := '';
        SummaryBuffRecL.RESET;
        SummaryBuffRecL.SETCURRENTKEY("Location Code");
        IF SummaryBuffRecL.FINDSET THEN
            REPEAT
                IF TempLocL <> SummaryBuffRecL."Location Code" THEN BEGIN
                    LocationRecL.RESET;
                    LocationRecL.SETRANGE(Code, SummaryBuffRecL."Location Code");
                    LocationRecL.SETFILTER("Auto Pick Template Name", '<>%1', '');
                    LocationRecL.SETFILTER("Auto Pick Batch Name", '<>%1', '');
                    IF LocationRecL.FINDFIRST THEN BEGIN
                        WhseWorksheetLineRecL.RESET;
                        WhseWorksheetLineRecL.SETRANGE("Worksheet Template Name", LocationRecL."Auto Pick Template Name");
                        WhseWorksheetLineRecL.SETRANGE(Name, LocationRecL."Auto Pick Batch Name");
                        WhseWorksheetLineRecL.SETRANGE("Qty. to Handle (Base)", 0);
                        IF WhseWorksheetLineRecL.FINDSET THEN
                            WhseWorksheetLineRecL.DELETEALL(TRUE);
                        TempLocL := SummaryBuffRecL."Location Code";
                    END;
                END;
            UNTIL SummaryBuffRecL.NEXT = 0;
    end;

    procedure MovementCreate()
    var
        CreateMovFromWhseSource: Report "WhseSource-CreateDocument";
        LocationRecL: Record Location;
        WhseWorksheetLineRecL: Record "Whse. Worksheet Line";
        SummaryBuffRecL: Record "Pick Crt_Buffer1";
        TempLocL: Code[10];
    begin
        TempLocL := '';
        SummaryBuffRecL.RESET;
        SummaryBuffRecL.SETCURRENTKEY("Location Code");
        IF SummaryBuffRecL.FINDSET THEN
            REPEAT
                IF TempLocL <> SummaryBuffRecL."Location Code" THEN BEGIN
                    LocationRecL.RESET;
                    LocationRecL.SETRANGE(Code, SummaryBuffRecL."Location Code");
                    LocationRecL.SETFILTER("Auto Pick Template Name", '<>%1', '');
                    LocationRecL.SETFILTER("Auto Pick Batch Name", '<>%1', '');
                    IF LocationRecL.FINDFIRST THEN BEGIN
                        WhseWorksheetLineRecL.RESET;
                        WhseWorksheetLineRecL.SETRANGE("Worksheet Template Name", LocationRecL."Auto Pick Template Name");
                        WhseWorksheetLineRecL.SETRANGE(Name, LocationRecL."Auto Pick Batch Name");
                        WhseWorksheetLineRecL.SETFILTER("Qty. (Base)", '>0');
                        IF WhseWorksheetLineRecL.FINDSET THEN BEGIN
                            CreateMovFromWhseSource.USEREQUESTPAGE(FALSE);
                            CreateMovFromWhseSource.SetItemWiseMovements(TRUE);
                            CreateMovFromWhseSource.SetWhseWkshLine(WhseWorksheetLineRecL);
                            CreateMovFromWhseSource.RUNMODAL;
                            CLEAR(CreateMovFromWhseSource);
                        END;
                        TempLocL := SummaryBuffRecL."Location Code";
                    END;
                END;
            UNTIL SummaryBuffRecL.NEXT = 0;
    end;

    local procedure CalcAvailQtyBaseToPick(WarehouseShipmentLineP: Record "Warehouse Shipment Line") QtyAvailBaseToPickR: Decimal
    var
        BinContentRecL: Record "Bin Content";
        BinTypeFilterL: Text;
    begin
        BinTypeFilterL := '';
        QtyAvailBaseToPickR := 0;
        BinTypeFilterL := GetBinTypeFilter(3);
        // BinContentRecL.LockTable(); //MITL2024
        BinContentRecL.RESET;
        BinContentRecL.SETCURRENTKEY("Bin Type Code");
        BinContentRecL.SETRANGE("Location Code", WarehouseShipmentLineP."Location Code");
        BinContentRecL.SETRANGE("Item No.", WarehouseShipmentLineP."Item No.");
        BinContentRecL.SETRANGE("Unit of Measure Code", WarehouseShipmentLineP."Unit of Measure Code");
        IF BinTypeFilterL <> '' THEN
            BinContentRecL.SETFILTER("Bin Type Code", BinTypeFilterL);
        IF BinContentRecL.FINDSET THEN
            REPEAT
                QtyAvailBaseToPickR += BinContentRecL.CalcQtyAvailToPick(0);
            UNTIL BinContentRecL.NEXT = 0;
    end;

    local procedure UpstatusInOrderStatus(DetailLineRecP: Record "Pick Crt_Whse Shp Lines")
    var
        PickStatusRecL: Record "Pick Creation Status";
        MovementCreatedL: Boolean;
    begin
        PickStatusRecL.RESET;
        PickStatusRecL.SETCURRENTKEY("Source Document", "Source No.");
        PickStatusRecL.SETRANGE("Source Document", PickStatusRecL."Source Document"::"Sales Order");
        PickStatusRecL.SETRANGE("Source No.", DetailLineRecP."Source No.");
        PickStatusRecL.SETFILTER(Status, '%1|%2', PickStatusRecL.Status::"Pick Pending Movement Created", PickStatusRecL.Status::"Update in-Progress");
        IF PickStatusRecL.FINDFIRST THEN BEGIN
            PickStatusRecL.Status := PickStatusRecL.Status::"Pick Pending No Stock";
            PickStatusRecL.MODIFY;
        END;
    end;

    local procedure CheckMovementcreated()
    var
        MovementLinesL: Record "Warehouse Activity Line";
        SummaryBuffRecL: Record "Pick Crt_Buffer1";
        PickStatusRecL: Record "Pick Creation Status";
        DetailLineRecL: Record "Pick Crt_Whse Shp Lines";
        MovementQtyL: Integer;
        TempMovementLinesL: Record "Warehouse Activity Line" temporary;
    begin
        TempMovementLinesL.Reset();
        MovementQtyL := 0;
        MovementLinesL.Reset();
        MovementLinesL.SetCurrentKey("Item No.", "Location Code", "Bin Code", "Action Type", "Variant Code", "Unit of Measure Code", "Breakbulk No.", "Activity Type",
            "Lot No.", "Serial No.", "Original Breakbulk", "Assemble to Order", "ATO Component");
        MovementLinesL.SetRange("Activity Type", MovementLinesL."Activity Type"::Movement);
        MovementLinesL.SetRange("Action Type", MovementLinesL."Action Type"::Take);
        IF MovementLinesL.FindSet() then
            repeat
                if (TempMovementLinesL."Item No." <> MovementLinesL."Item No.") or (TempMovementLinesL."Location Code" <> MovementLinesL."Location Code") then begin
                    MovementLinesL.SetRange("Item No.");
                    MovementLinesL.SetRange("Location Code");
                    TempMovementLinesL."Item No." := MovementLinesL."Item No.";
                    TempMovementLinesL."Location Code" := MovementLinesL."Location Code";
                    MovementLinesL.SetRange("Item No.", TempMovementLinesL."Item No.");
                    MovementLinesL.SetRange("Location Code", TempMovementLinesL."Location Code");
                    MovementLinesL.CalcSums(Quantity);
                    MovementQtyL := MovementLinesL.Quantity;
                    DetailLineRecL.Reset();
                    DetailLineRecL.SetCurrentKey("Location Code", "Item No.");
                    DetailLineRecL.SetRange("Location Code", MovementLinesL."Location Code");
                    DetailLineRecL.SetRange("Item No.", MovementLinesL."Item No.");
                    IF DetailLineRecL.FindSet() then
                        repeat
                            MovementQtyL := MovementQtyL - DetailLineRecL.Quantity;
                            PickStatusRecL.RESET;
                            PickStatusRecL.SETCURRENTKEY("Source Document", "Source No.");
                            PickStatusRecL.SETRANGE("Source Document", PickStatusRecL."Source Document"::"Sales Order");
                            PickStatusRecL.SETRANGE("Source No.", DetailLineRecL."Source No.");
                            PickStatusRecL.SETFILTER(Status, '%1', PickStatusRecL.Status::"Pick Pending No Stock");
                            IF PickStatusRecL.FINDFIRST THEN BEGIN
                                If MovementQtyL > 0 then begin
                                    PickStatusRecL.Status := PickStatusRecL.Status::"Pick Pending Movement Created";
                                    IF MovementLinesL."No." <> '' then
                                        PickStatusRecL.Whse_Movement_No := MovementLinesL."No.";
                                    PickStatusRecL.MODIFY;
                                end;
                            END;
                        Until (DetailLineRecL.Next() = 0) OR (MovementQtyL <= 0);
                end;
                MovementLinesL.SetRange("Item No.");
                MovementLinesL.SetRange("Location Code");
            until MovementLinesL.Next() = 0;
    end;

    local procedure CreatePickStatusLineForCombinedPicks()
    var
        PickCreationStatusRecL: Record "Pick Creation Status";
        GetPickCreationStatusRecL: Record "Pick Creation Status";
        GetNo: Integer;
        WarehouseShipmentLineRecL: Record "Warehouse Shipment Line";
        SalesHeaderL: Record "Sales Header";
    begin
        // Inserting Lines in Pick Status to Know Which are the Whse. Shipment lines Skipped because of Combined Pick
        GetNo := 0;
        GetPickCreationStatusRecL.RESET;
        IF GetPickCreationStatusRecL.FINDLAST THEN
            GetNo := GetPickCreationStatusRecL."No." + 1
        ELSE
            GetNo := 1;
        WarehouseShipmentLineRecL.RESET;
        WarehouseShipmentLineRecL.SETCURRENTKEY("Due Date", "Source Document", "Source No.");
        WarehouseShipmentLineRecL.SETRANGE("Source Document", WarehouseShipmentLineRecL."Source Document"::"Sales Order");
        WarehouseShipmentLineRecL.SETRANGE("Qty. Picked", 0);
        WarehouseShipmentLineRecL.SETRANGE("Pick Qty.", 0);
        WarehouseShipmentLineRecL.SETRANGE("Combined Pick", TRUE);
        IF WarehouseShipmentLineRecL.FINDSET THEN
            REPEAT
                SalesHeaderL.RESET;
                SalesHeaderL.GET(SalesHeaderL."Document Type"::Order, WarehouseShipmentLineRecL."Source No.");

                GetPickCreationStatusRecL.RESET;
                GetPickCreationStatusRecL.SETCURRENTKEY("Source Document", "Source No.");
                GetPickCreationStatusRecL.SETRANGE("Source Document", GetPickCreationStatusRecL."Source Document"::"Sales Order");
                GetPickCreationStatusRecL.SETRANGE("Source No.", SalesHeaderL."No.");
                IF NOT GetPickCreationStatusRecL.FINDFIRST THEN BEGIN
                    PickCreationStatusRecL.INIT;
                    PickCreationStatusRecL."No." := GetNo;
                    PickCreationStatusRecL."Source Type" := WarehouseShipmentLineRecL."Source Type";
                    PickCreationStatusRecL."Source Subtype" := WarehouseShipmentLineRecL."Source Subtype";
                    PickCreationStatusRecL."Source Document" := WarehouseShipmentLineRecL."Source Document";
                    PickCreationStatusRecL."Source No." := WarehouseShipmentLineRecL."Source No.";
                    PickCreationStatusRecL.Status := PickCreationStatusRecL.Status::"Skipped-Comb Pick";
                    PickCreationStatusRecL."Web Order No." := SalesHeaderL.WebOrderID;
                    PickCreationStatusRecL."Creation Date Time" := CURRENTDATETIME;
                    PickCreationStatusRecL."Last modified Date Time" := PickCreationStatusRecL."Creation Date Time";
                    PickCreationStatusRecL.INSERT;

                    GetNo += 1;
                END;
            UNTIL WarehouseShipmentLineRecL.NEXT = 0;
    end;

    procedure OnNavAppUpgradePerCompany()
    begin
    end;

    procedure OnNavAppUpgradePerDatabase()
    begin
    end;

    local procedure UpstatusMovementCreatedStatusInOrderStatus()
    var
        PickStatusRecL: Record "Pick Creation Status";
    begin
        PickStatusRecL.RESET;
        PickStatusRecL.SETCURRENTKEY("Source Document", "Source No.");
        PickStatusRecL.SETRANGE("Source Document", PickStatusRecL."Source Document"::"Sales Order");
        PickStatusRecL.SETRANGE(Status, PickStatusRecL.Status::"Update in-Progress");
        IF PickStatusRecL.FINDSET THEN
            REPEAT
                PickStatusRecL.Status := PickStatusRecL.Status::"Pick Pending Movement Created";
                PickStatusRecL.MODIFY;
            UNTIL PickStatusRecL.NEXT = 0;
    end;
}

