codeunit 50015 "WEB Create Pick2"
{
    // version NAVW19.00.00.43402

    Permissions = TableData 6550 = rimd;

    trigger OnRun()
    begin
    end;

    var
        WhseActivHeader: Record "Warehouse Activity Header";
        TempWhseActivLine: Record "Warehouse Activity Line" temporary;
        TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
        TotalTempItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
        SourceTempItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
        WhseShptLine: Record "Warehouse Shipment Line";
        WhseInternalPickLine: Record "Whse. Internal Pick Line";
        ProdOrderCompLine: Record "Prod. Order Component";
        AssemblyLine: Record "Assembly Line";
        WhseWkshLine: Record "Whse. Worksheet Line";
        WhseSetup: Record "Warehouse Setup";
        Location: Record Location;
        WhseSetupLocation: Record Location;
        Item: Record Item;
        Bin: Record Bin;
        BinType: Record "Bin Type";
        SKU: Record "Stockkeeping Unit";
        WhseMgt: Codeunit "Whse. Management";
        WhseAvailMgt: Codeunit "Warehouse Availability Mgt.";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseSource: Option "Pick Worksheet",Shipment,"Movement Worksheet","Internal Pick",Production,Assembly;
        SortPick: Option " ",Item,Document,"Shelf/Bin No.","Due Date","Ship-To","Bin Ranking","Action Type";
        WhseDocType: Option "Put-away",Pick,Movement;
        SourceSubType: Option "0","1","2","3","4","5","6","7","8","9","10";
        SourceNo: Code[20];
        AssignedID: Code[50];
        ShippingAgentCode: Code[10];
        ShippingAgentServiceCode: Code[10];
        ShipmentMethodCode: Code[10];
        TransferRemQtyToPickBase: Decimal;
        TempNo: Integer;
        MaxNoOfLines: Integer;
        BreakbulkNo: Integer;
        TempLineNo: Integer;
        MaxNoOfSourceDoc: Integer;
        SourceType: Integer;
        SourceLineNo: Integer;
        SourceSubLineNo: Integer;
        LastWhseItemTrkgLineNo: Integer;
        WhseItemTrkgLineCount: Integer;
        PerZone: Boolean;
        Text000: Label 'Nothing to handle. %1.';
        PerBin: Boolean;
        DoNotFillQtytoHandle: Boolean;
        BreakbulkFilter: Boolean;
        WhseItemTrkgExists: Boolean;
        SNRequired: Boolean;
        LNRequired: Boolean;
        CrossDock: Boolean;
        ReservationExists: Boolean;
        ReservedForItemLedgEntry: Boolean;
        CalledFromPickWksh: Boolean;
        CalledFromMoveWksh: Boolean;
        CalledFromWksh: Boolean;
        ReqFEFOPick: Boolean;
        HasExpiredItems: Boolean;
        ExpiredItemMessageText: Text[100];
        TotalQtyPickedBase: Decimal;

    procedure CreateTempLine(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; UnitofMeasureCode: Code[10]; FromBinCode: Code[20]; ToBinCode: Code[20]; QtyPerUnitofMeasure: Decimal; var TotalQtytoPick: Decimal; var TotalQtytoPickBase: Decimal)
    var
        QtyToPick: Decimal;
        RemQtyToPick: Decimal;
        i: Integer;
        RemQtyToPickBase: Decimal;
        QtyToPickBase: Decimal;
        QtyToTrackBase: Decimal;
        QtyBaseMaxAvailToPick: Decimal;
        TotalItemTrackedQtyToPick: Decimal;
        TotalItemTrackedQtyToPickBase: Decimal;
        NewQtyToHandle: Decimal;
    begin
        TotalQtyPickedBase := 0;
        GetLocation(LocationCode);

        IF NOT Location."Always Create Pick Line" THEN BEGIN
            IF Location."Directed Put-away and Pick" THEN
                QtyBaseMaxAvailToPick := // Total qty (excl. Receive bin content) that are not assigned to any activity/ order
                  CalcTotalQtyOnBinType('', LocationCode, ItemNo, VariantCode) -
                  CalcTotalQtyAssgndOnWhse(LocationCode, ItemNo, VariantCode) +
                  CalcTotalQtyAssgndOnWhseAct(TempWhseActivLine."Activity Type"::"Put-away", LocationCode, ItemNo, VariantCode) -
                  CalcTotalQtyOnBinType(GetBinTypeFilter(0), LocationCode, ItemNo, VariantCode) // Receive area
            ELSE
                QtyBaseMaxAvailToPick :=
                  CalcAvailableQty(ItemNo, VariantCode) -
                  CalcPickQtyAssigned(LocationCode, ItemNo, VariantCode, UnitofMeasureCode, FromBinCode, TempWhseItemTrkgLine);

            CheckReservation(
              QtyBaseMaxAvailToPick, LocationCode, SourceType, SourceSubType, SourceNo, SourceLineNo, SourceSubLineNo,
              QtyPerUnitofMeasure, TotalQtytoPick, TotalQtytoPickBase);
        END;

        RemQtyToPick := TotalQtytoPick;
        RemQtyToPickBase := TotalQtytoPickBase;
        ItemTrackingMgt.CheckWhseItemTrkgSetup(ItemNo, SNRequired, LNRequired, FALSE);

        ReqFEFOPick := FALSE;
        HasExpiredItems := FALSE;
        IF PickAccordingToFEFO(LocationCode, ItemNo) OR
           PickStrictExpirationPosting(ItemNo)
        THEN BEGIN
            QtyToTrackBase := RemQtyToPickBase;
            IF UndefinedItemTrkg(QtyToTrackBase) THEN BEGIN
                // CreateTempItemTrkgLines(ItemNo, VariantCode, QtyToTrackBase, TRUE);
                // CreateTempItemTrkgLines(ItemNo, VariantCode, TransferRemQtyToPickBase, FALSE);
            END;
        END;
        IF TotalQtytoPickBase <> 0 THEN BEGIN
            TempWhseItemTrkgLine.RESET;
            TempWhseItemTrkgLine.SETFILTER("Qty. to Handle", '<> 0');
            IF TempWhseItemTrkgLine.FIND('-') THEN BEGIN
                REPEAT
                    IF TempWhseItemTrkgLine."Qty. to Handle (Base)" <> 0 THEN BEGIN
                        IF TempWhseItemTrkgLine."Qty. to Handle (Base)" > RemQtyToPickBase THEN BEGIN
                            TempWhseItemTrkgLine."Qty. to Handle (Base)" := RemQtyToPickBase;
                            TempWhseItemTrkgLine.MODIFY;
                        END;
                        NewQtyToHandle := ROUND(RemQtyToPick / RemQtyToPickBase * TempWhseItemTrkgLine."Qty. to Handle (Base)", 0.00001);
                        IF TempWhseItemTrkgLine."Qty. to Handle" <> NewQtyToHandle THEN BEGIN
                            TempWhseItemTrkgLine."Qty. to Handle" := NewQtyToHandle;
                            TempWhseItemTrkgLine.MODIFY;
                        END;

                        QtyToPick := TempWhseItemTrkgLine."Qty. to Handle";
                        QtyToPickBase := TempWhseItemTrkgLine."Qty. to Handle (Base)";
                        TotalItemTrackedQtyToPick += QtyToPick;
                        TotalItemTrackedQtyToPickBase += QtyToPickBase;

                        CreateTempLine2(LocationCode, ItemNo, VariantCode, UnitofMeasureCode, FromBinCode, ToBinCode,
                          QtyPerUnitofMeasure, QtyToPick, TempWhseItemTrkgLine, QtyToPickBase);
                        RemQtyToPickBase -= TempWhseItemTrkgLine."Qty. to Handle (Base)" - QtyToPickBase;
                        RemQtyToPick -= TempWhseItemTrkgLine."Qty. to Handle" - QtyToPick;
                    END;
                UNTIL (TempWhseItemTrkgLine.NEXT = 0) OR (RemQtyToPickBase <= 0);
                RemQtyToPick := Minimum(RemQtyToPick, TotalQtytoPick - TotalItemTrackedQtyToPick);
                RemQtyToPickBase := Minimum(RemQtyToPickBase, TotalQtytoPickBase - TotalItemTrackedQtyToPickBase);
                TotalQtytoPick := RemQtyToPick;
                TotalQtytoPickBase := RemQtyToPickBase;

                SaveTempItemTrkgLines;
                CLEAR(TempWhseItemTrkgLine);
                WhseItemTrkgExists := FALSE;
            END;
            IF TotalQtytoPickBase <> 0 THEN
                IF NOT HasExpiredItems THEN BEGIN
                    IF SNRequired THEN BEGIN
                        FOR i := 1 TO TotalQtytoPick DO BEGIN
                            QtyToPick := 1;
                            QtyToPickBase := 1;
                            CreateTempLine2(LocationCode, ItemNo, VariantCode, UnitofMeasureCode,
                              FromBinCode, ToBinCode, QtyPerUnitofMeasure, QtyToPick, TempWhseItemTrkgLine, QtyToPickBase);
                        END;
                        TotalQtytoPick := 0;
                        TotalQtytoPickBase := 0;
                    END ELSE
                        CreateTempLine2(LocationCode, ItemNo, VariantCode, UnitofMeasureCode,
                          FromBinCode, ToBinCode, QtyPerUnitofMeasure, TotalQtytoPick, TempWhseItemTrkgLine, TotalQtytoPickBase);
                END;
        END;
    end;

    local procedure CreateTempLine2(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; UnitofMeasureCode: Code[10]; FromBinCode: Code[20]; ToBinCode: Code[20]; QtyPerUnitofMeasure: Decimal; var TotalQtytoPick: Decimal; var TempWhseItemTrkgLine: Record 6550 temporary; var TotalQtytoPickBase: Decimal)
    var
        QtytoPick: Decimal;
        QtytoPickBase: Decimal;
        QtyAvailableBase: Decimal;
    begin
        GetLocation(LocationCode);
        IF Location."Bin Mandatory" THEN BEGIN
            IF NOT Location."Directed Put-away and Pick" THEN BEGIN
                QtyAvailableBase :=
                  CalcAvailableQty(ItemNo, VariantCode) -
                  CalcPickQtyAssigned(LocationCode, ItemNo, VariantCode, UnitofMeasureCode, '', TempWhseItemTrkgLine);

                IF QtyAvailableBase > 0 THEN BEGIN
                    IF TotalQtytoPickBase > QtyAvailableBase THEN
                        TotalQtytoPickBase := QtyAvailableBase;
                    CalcBWPickBin(
                      LocationCode, ItemNo, VariantCode, UnitofMeasureCode,
                      QtyPerUnitofMeasure, TotalQtytoPick, TotalQtytoPickBase, TempWhseItemTrkgLine, Location."Use Cross-Docking");
                END;
                EXIT;
            END;

            IF (WhseSource = WhseSource::"Movement Worksheet") AND (FromBinCode <> '') THEN BEGIN
                InsertTmpActLnFromMovWkshLine(
                  LocationCode, ItemNo, VariantCode, FromBinCode,
                  QtyPerUnitofMeasure, TotalQtytoPick, TempWhseItemTrkgLine, TotalQtytoPickBase);
                EXIT;
            END;

            IF (ReservationExists AND ReservedForItemLedgEntry) OR NOT ReservationExists THEN BEGIN
                IF Location."Use Cross-Docking" THEN
                    CalcPickBin(
                      LocationCode, ItemNo, VariantCode, UnitofMeasureCode,
                      ToBinCode, QtyPerUnitofMeasure,
                      TotalQtytoPick, TempWhseItemTrkgLine, TRUE, TotalQtytoPickBase);
                IF TotalQtytoPickBase > 0 THEN
                    CalcPickBin(
                      LocationCode, ItemNo, VariantCode, UnitofMeasureCode,
                      ToBinCode, QtyPerUnitofMeasure,
                      TotalQtytoPick, TempWhseItemTrkgLine, FALSE, TotalQtytoPickBase);
            END;
            IF (TotalQtytoPickBase > 0) AND Location."Always Create Pick Line" THEN BEGIN
                UpdateQuantitiesToPick(
                  TotalQtytoPickBase,
                  QtyPerUnitofMeasure, QtytoPick, QtytoPickBase,
                  QtyPerUnitofMeasure, QtytoPick, QtytoPickBase,
                  TotalQtytoPick, TotalQtytoPickBase);

                CreateTempActivityLine(
                  LocationCode, '', UnitofMeasureCode, QtyPerUnitofMeasure, QtytoPick, QtytoPickBase, 1, 0);
                CreateTempActivityLine(
                  LocationCode, ToBinCode, UnitofMeasureCode, QtyPerUnitofMeasure, QtytoPick, QtytoPickBase, 2, 0);
            END;
            EXIT;
        END;

        QtyAvailableBase :=
          CalcAvailableQty(ItemNo, VariantCode) -
          CalcPickQtyAssigned(LocationCode, ItemNo, VariantCode, UnitofMeasureCode, '', TempWhseItemTrkgLine);

        IF QtyAvailableBase > 0 THEN BEGIN
            UpdateQuantitiesToPick(
              QtyAvailableBase,
              QtyPerUnitofMeasure, QtytoPick, QtytoPickBase,
              QtyPerUnitofMeasure, QtytoPick, QtytoPickBase,
              TotalQtytoPick, TotalQtytoPickBase);

            CreateTempActivityLine(LocationCode, '', UnitofMeasureCode, QtyPerUnitofMeasure, QtytoPick, QtytoPickBase, 0, 0);
        END;
    end;

    local procedure InsertTmpActLnFromMovWkshLine(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; FromBinCode: Code[20]; QtyPerUnitofMeasure: Decimal; var TotalQtytoPick: Decimal; var TempWhseItemTrkgLine: Record 6550; var TotalQtyToPickBase: Decimal)
    var
        FromBinContent: Record "Bin Content";
        FromItemUOM: Record "Item Unit of Measure";
        FromQtyToPick: Decimal;
        FromQtyToPickBase: Decimal;
        ToQtyToPick: Decimal;
        ToQtyToPickBase: Decimal;
        QtyAvailableBase: Decimal;
    begin
        QtyAvailableBase := TotalQtyToPickBase;

        IF WhseWkshLine."From Unit of Measure Code" <> WhseWkshLine."Unit of Measure Code" THEN BEGIN
            FromBinContent.GET(
              LocationCode, FromBinCode, ItemNo, VariantCode, WhseWkshLine."From Unit of Measure Code");
            FromBinContent.SetFilterOnUnitOfMeasure;
            FromBinContent.CALCFIELDS("Quantity (Base)", "Pick Quantity (Base)", "Negative Adjmt. Qty. (Base)");

            QtyAvailableBase :=
              FromBinContent."Quantity (Base)" - FromBinContent."Pick Quantity (Base)" -
              FromBinContent."Negative Adjmt. Qty. (Base)" -
              CalcPickQtyAssigned(
                LocationCode, ItemNo, VariantCode,
                WhseWkshLine."From Unit of Measure Code",
                WhseWkshLine."From Bin Code", TempWhseItemTrkgLine);

            FromItemUOM.GET(ItemNo, FromBinContent."Unit of Measure Code");

            BreakbulkNo := BreakbulkNo + 1;
        END;

        UpdateQuantitiesToPick(
          QtyAvailableBase,
          WhseWkshLine."Qty. per From Unit of Measure", FromQtyToPick, FromQtyToPickBase,
          QtyPerUnitofMeasure, ToQtyToPick, ToQtyToPickBase,
          TotalQtytoPick, TotalQtyToPickBase);

        CreateBreakBulkTempLines(
          WhseWkshLine."Location Code",
          WhseWkshLine."From Unit of Measure Code",
          WhseWkshLine."Unit of Measure Code",
          FromBinCode,
          WhseWkshLine."To Bin Code",
          WhseWkshLine."Qty. per From Unit of Measure",
          WhseWkshLine."Qty. per Unit of Measure",
          BreakbulkNo,
          ToQtyToPick, ToQtyToPickBase, FromQtyToPick, FromQtyToPickBase);

        TotalQtyToPickBase := 0;
        TotalQtytoPick := 0;
    end;

    local procedure CalcMaxQtytoPlace(var QtytoHandle: Decimal; QtyOutstanding: Decimal; var QtytoHandleBase: Decimal; QtyOutstandingBase: Decimal)
    var
        TempWhseActivLine2: Record "Warehouse Activity Line" temporary;
    begin
        TempWhseActivLine2.INIT;
        TempWhseActivLine2.COPY(TempWhseActivLine);
        WITH TempWhseActivLine DO BEGIN
            SETCURRENTKEY(
              "Whse. Document No.", "Whse. Document Type", "Activity Type", "Whse. Document Line No.");
            SETRANGE("Whse. Document Type", "Whse. Document Type");
            SETRANGE("Whse. Document No.", "Whse. Document No.");
            SETRANGE("Activity Type", "Activity Type");
            SETRANGE("Whse. Document Line No.", "Whse. Document Line No.");
            SETRANGE("Source Type", "Source Type");
            SETRANGE("Source Subtype", "Source Subtype");
            SETRANGE("Source No.", "Source No.");
            SETRANGE("Source Line No.", "Source Line No.");
            SETRANGE("Source Subline No.", "Source Subline No.");
            SETRANGE("Action Type", "Action Type"::Place);
            SETRANGE("Breakbulk No.", 0);
            IF FIND('-') THEN BEGIN
                CALCSUMS(Quantity);
                IF QtyOutstanding < Quantity + QtytoHandle THEN
                    QtytoHandle := QtyOutstanding - Quantity;
                IF QtytoHandle < 0 THEN
                    QtytoHandle := 0;
                CALCSUMS("Qty. (Base)");
                IF QtyOutstandingBase < "Qty. (Base)" + QtytoHandleBase THEN
                    QtytoHandleBase := QtyOutstandingBase - "Qty. (Base)";
                IF QtytoHandleBase < 0 THEN
                    QtytoHandleBase := 0;
            END;
        END;
        TempWhseActivLine.COPY(TempWhseActivLine2);
    end;

    local procedure CalcBWPickBin(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; UnitofMeasureCode: Code[10]; QtyPerUnitofMeasure: Decimal; var TotalQtyToPick: Decimal; var TotalQtytoPickBase: Decimal; var TempWhseItemTrkgLine: Record 6550; CrossDockFirst: Boolean)
    var
        WhseSource2: Option;
    begin
        // Basic warehousing

        IF (WhseSource = WhseSource::Shipment) AND WhseShptLine."Assemble to Order" THEN
            WhseSource2 := WhseSource::Assembly
        ELSE
            WhseSource2 := WhseSource;

        // find pick qty. for bin code of source line
        IF TotalQtytoPickBase > 0 THEN
            CASE WhseSource2 OF
                WhseSource::"Pick Worksheet":
                    FindBWPickBin(
                      LocationCode, ItemNo, VariantCode,
                      WhseWkshLine."To Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, FALSE,
                      TotalQtyToPick, TotalQtytoPickBase, TempWhseItemTrkgLine, FALSE);
                WhseSource::Shipment:
                    FindBWPickBin(
                      LocationCode, ItemNo, VariantCode,
                      WhseShptLine."Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, FALSE,
                      TotalQtyToPick, TotalQtytoPickBase, TempWhseItemTrkgLine, CrossDockFirst);
                WhseSource::Production:
                    FindBWPickBin(
                      LocationCode, ItemNo, VariantCode,
                      ProdOrderCompLine."Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, FALSE,
                      TotalQtyToPick, TotalQtytoPickBase, TempWhseItemTrkgLine, FALSE);
                WhseSource::Assembly:
                    FindBWPickBin(
                      LocationCode, ItemNo, VariantCode,
                      AssemblyLine."Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, FALSE,
                      TotalQtyToPick, TotalQtytoPickBase, TempWhseItemTrkgLine, FALSE);
            END;

        // find pick qty. for default bin
        IF TotalQtytoPickBase > 0 THEN
            CASE WhseSource2 OF
                WhseSource::"Pick Worksheet":
                    FindBWPickBin(
                      LocationCode, ItemNo, VariantCode,
                      WhseWkshLine."To Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, TRUE,
                      TotalQtyToPick, TotalQtytoPickBase, TempWhseItemTrkgLine, FALSE);
                WhseSource::Shipment:
                    FindBWPickBin(
                      LocationCode, ItemNo, VariantCode,
                      WhseShptLine."Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, TRUE,
                      TotalQtyToPick, TotalQtytoPickBase, TempWhseItemTrkgLine, FALSE);
                WhseSource::Production:
                    FindBWPickBin(
                      LocationCode, ItemNo, VariantCode,
                      ProdOrderCompLine."Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, TRUE,
                      TotalQtyToPick, TotalQtytoPickBase, TempWhseItemTrkgLine, FALSE);
                WhseSource::Assembly:
                    FindBWPickBin(
                      LocationCode, ItemNo, VariantCode,
                      AssemblyLine."Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, TRUE,
                      TotalQtyToPick, TotalQtytoPickBase, TempWhseItemTrkgLine, FALSE);
            END;

        // find pick qty. for other bins
        IF TotalQtytoPickBase > 0 THEN
            CASE WhseSource2 OF
                WhseSource::"Pick Worksheet":
                    FindBWPickBin(
                      LocationCode, ItemNo, VariantCode,
                      WhseWkshLine."To Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, FALSE,
                      TotalQtyToPick, TotalQtytoPickBase, TempWhseItemTrkgLine, FALSE);
                WhseSource::Shipment:
                    FindBWPickBin(
                      LocationCode, ItemNo, VariantCode,
                      WhseShptLine."Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, FALSE,
                      TotalQtyToPick, TotalQtytoPickBase, TempWhseItemTrkgLine, CrossDockFirst);
                WhseSource::Production:
                    FindBWPickBin(
                      LocationCode, ItemNo, VariantCode,
                      ProdOrderCompLine."Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, FALSE,
                      TotalQtyToPick, TotalQtytoPickBase, TempWhseItemTrkgLine, FALSE);
                WhseSource::Assembly:
                    FindBWPickBin(
                      LocationCode, ItemNo, VariantCode,
                      AssemblyLine."Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, FALSE,
                      TotalQtyToPick, TotalQtytoPickBase, TempWhseItemTrkgLine, FALSE);
            END;
    end;

    local procedure FindBWPickBin(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; ToBinCode: Code[20]; UnitofMeasureCode: Code[10]; QtyPerUnitofMeasure: Decimal; DefaultBin: Boolean; var TotalQtyToPick: Decimal; var TotalQtyToPickBase: Decimal; var TempWhseItemTrkgLine: Record 6550; CrossDockFirst: Boolean)
    var
        FromBinContent: Record "Bin Content";
        QtyAvailableBase: Decimal;
        QtyToPickBase: Decimal;
        QtytoPick: Decimal;
        BinCodeFilterText: Text[250];
    begin
        // Basic warehousing
        WITH FromBinContent DO BEGIN
            IF CrossDockFirst THEN BEGIN
                SETCURRENTKEY("Location Code", "Item No.", "Variant Code", "Cross-Dock Bin", "Qty. per Unit of Measure", "Bin Ranking");
                ASCENDING(FALSE);
            END ELSE
                SETCURRENTKEY(Default, "Location Code", "Item No.", "Variant Code", "Bin Code");
            SETRANGE(Default, DefaultBin);
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Variant Code", VariantCode);
            GetLocation(LocationCode);
            IF Location."Require Pick" AND (Location."Shipment Bin Code" <> '') THEN
                AddToFilterText(BinCodeFilterText, '&', '<>', Location."Shipment Bin Code");
            IF Location."Require Put-away" AND (Location."Receipt Bin Code" <> '') THEN
                AddToFilterText(BinCodeFilterText, '&', '<>', Location."Receipt Bin Code");
            IF ToBinCode <> '' THEN
                AddToFilterText(BinCodeFilterText, '&', '<>', ToBinCode);
            IF BinCodeFilterText <> '' THEN
                SETFILTER("Bin Code", BinCodeFilterText);
            IF WhseItemTrkgExists THEN BEGIN
                SETRANGE("Lot No. Filter", TempWhseItemTrkgLine."Lot No.");
                SETRANGE("Serial No. Filter", TempWhseItemTrkgLine."Serial No.");
            END;
            IF FIND('-') THEN
                REPEAT
                    QtyAvailableBase :=
                      CalcQtyAvailToPick(0) -
                      CalcPickQtyAssigned(LocationCode, ItemNo, VariantCode, "Unit of Measure Code", "Bin Code", TempWhseItemTrkgLine);

                    IF QtyAvailableBase > 0 THEN BEGIN
                        IF SNRequired THEN
                            QtyAvailableBase := 1;

                        UpdateQuantitiesToPick(
                          QtyAvailableBase,
                          QtyPerUnitofMeasure, QtytoPick, QtyToPickBase,
                          QtyPerUnitofMeasure, QtytoPick, QtyToPickBase,
                          TotalQtyToPick, TotalQtyToPickBase);

                        CreateTempActivityLine(
                          LocationCode, "Bin Code", UnitofMeasureCode, QtyPerUnitofMeasure, QtytoPick, QtyToPickBase, 1, 0);
                        CreateTempActivityLine(
                          LocationCode, ToBinCode, UnitofMeasureCode, QtyPerUnitofMeasure, QtytoPick, QtyToPickBase, 2, 0);
                    END;
                UNTIL (NEXT = 0) OR (TotalQtyToPickBase = 0);
        END;
    end;

    local procedure CalcPickBin(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; UnitofMeasureCode: Code[10]; ToBinCode: Code[20]; QtyPerUnitofMeasure: Decimal; var TotalQtytoPick: Decimal; var TempWhseItemTrkgLine: Record 6550; CrossDock: Boolean; var TotalQtytoPickBase: Decimal)
    begin
        // Directed put-away and pick
        ItemTrackingMgt.CheckWhseItemTrkgSetup(ItemNo, SNRequired, LNRequired, FALSE);
        FindPickBin(
          LocationCode, ItemNo, VariantCode, UnitofMeasureCode,
          ToBinCode, TempWhseActivLine, TotalQtytoPick, TempWhseItemTrkgLine, CrossDock, TotalQtytoPickBase);
        IF (TotalQtytoPickBase > 0) AND Location."Allow Breakbulk" THEN BEGIN
            FindBreakBulkBin(
              LocationCode, ItemNo, VariantCode, UnitofMeasureCode, ToBinCode,
              QtyPerUnitofMeasure, TempWhseActivLine, TotalQtytoPick, TempWhseItemTrkgLine, CrossDock, TotalQtytoPickBase);
            IF TotalQtytoPickBase > 0 THEN
                FindSmallerUOMBin(
                  LocationCode, ItemNo, VariantCode, UnitofMeasureCode, ToBinCode,
                  QtyPerUnitofMeasure, TotalQtytoPick, TempWhseItemTrkgLine, CrossDock, TotalQtytoPickBase);
        END;
    end;

    local procedure BinContentExists(var BinContent: Record "Bin Content"; ItemNo: Code[20]; LocationCode: Code[10]; UOMCode: Code[10]; VariantCode: Code[10]; CrossDock: Boolean; LNRequired: Boolean; SNRequired: Boolean): Boolean
    begin
        WITH BinContent DO BEGIN
            SETCURRENTKEY("Location Code", "Item No.", "Variant Code", "Cross-Dock Bin", "Qty. per Unit of Measure", "Bin Ranking");
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Variant Code", VariantCode);
            SETRANGE("Cross-Dock Bin", CrossDock);
            SETRANGE("Unit of Measure Code", UOMCode);
            IF WhseSource = WhseSource::"Movement Worksheet" THEN
                SETFILTER("Bin Ranking", '<%1', Bin."Bin Ranking");
            IF WhseItemTrkgExists THEN BEGIN
                IF LNRequired THEN
                    SETRANGE("Lot No. Filter", TempWhseItemTrkgLine."Lot No.")
                ELSE
                    SETFILTER("Lot No. Filter", '%1|%2', TempWhseItemTrkgLine."Lot No.", '');
                IF SNRequired THEN
                    SETRANGE("Serial No. Filter", TempWhseItemTrkgLine."Serial No.")
                ELSE
                    SETFILTER("Serial No. Filter", '%1|%2', TempWhseItemTrkgLine."Serial No.", '');
            END;
            ASCENDING(FALSE);
            EXIT(FIND('-'));
        END;
    end;

    local procedure BreakBulkPlacingExists(var TempBinContent: Record "Bin Content" temporary; ItemNo: Code[20]; LocationCode: Code[10]; UOMCode: Code[10]; VariantCode: Code[10]; CrossDock: Boolean; LNRequired: Boolean; SNRequired: Boolean): Boolean
    var
        BinContent2: Record "Bin Content";
        WhseActivLine2: Record "Warehouse Activity Line";
    begin
        TempBinContent.RESET;
        TempBinContent.DELETEALL;
        WITH BinContent2 DO BEGIN
            SETCURRENTKEY("Location Code", "Item No.", "Variant Code", "Cross-Dock Bin", "Qty. per Unit of Measure", "Bin Ranking");
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Variant Code", VariantCode);
            SETRANGE("Cross-Dock Bin", CrossDock);
            IF WhseSource = WhseSource::"Movement Worksheet" THEN
                SETFILTER("Bin Ranking", '<%1', Bin."Bin Ranking");
            IF WhseItemTrkgExists THEN BEGIN
                IF LNRequired THEN
                    SETRANGE("Lot No. Filter", TempWhseItemTrkgLine."Lot No.")
                ELSE
                    SETFILTER("Lot No. Filter", '%1|%2', TempWhseItemTrkgLine."Lot No.", '');
                IF SNRequired THEN
                    SETRANGE("Serial No. Filter", TempWhseItemTrkgLine."Serial No.")
                ELSE
                    SETFILTER("Serial No. Filter", '%1|%2', TempWhseItemTrkgLine."Serial No.", '');
            END;
            ASCENDING(FALSE);
        END;

        WhseActivLine2.COPY(TempWhseActivLine);
        WITH TempWhseActivLine DO BEGIN
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Variant Code", VariantCode);
            SETRANGE("Unit of Measure Code", UOMCode);
            SETRANGE("Action Type", "Action Type"::Place);
            SETFILTER("Breakbulk No.", '<>0');
            SETRANGE("Bin Code");
            IF WhseItemTrkgExists THEN BEGIN
                IF LNRequired THEN
                    SETRANGE("Lot No.", TempWhseItemTrkgLine."Lot No.")
                ELSE
                    SETFILTER("Lot No.", '%1|%2', TempWhseItemTrkgLine."Lot No.", '');
                IF SNRequired THEN
                    SETRANGE("Serial No.", TempWhseItemTrkgLine."Serial No.")
                ELSE
                    SETFILTER("Serial No.", '%1|%2', TempWhseItemTrkgLine."Serial No.", '');
            END;
            IF FINDFIRST THEN
                REPEAT
                    BinContent2.SETRANGE("Bin Code", "Bin Code");
                    BinContent2.SETRANGE("Unit of Measure Code", UOMCode);
                    IF BinContent2.ISEMPTY THEN BEGIN
                        BinContent2.SETRANGE("Unit of Measure Code");
                        IF BinContent2.FINDFIRST THEN BEGIN
                            TempBinContent := BinContent2;
                            TempBinContent.VALIDATE("Unit of Measure Code", UOMCode);
                            IF TempBinContent.INSERT THEN;
                        END;
                    END;
                UNTIL NEXT = 0;
        END;
        TempWhseActivLine.COPY(WhseActivLine2);
        EXIT(NOT TempBinContent.ISEMPTY);
    end;

    local procedure FindPickBin(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; UnitofMeasureCode: Code[10]; ToBinCode: Code[20]; var TempWhseActivLine2: Record 5767 temporary; var TotalQtytoPick: Decimal; var TempWhseItemTrkgLine: Record 6550; CrossDock: Boolean; var TotalQtytoPickBase: Decimal)
    var
        FromBinContent: Record "Bin Content";
        FromQtyToPick: Decimal;
        FromQtyToPickBase: Decimal;
        ToQtyToPick: Decimal;
        ToQtyToPickBase: Decimal;
        TotalAvailQtyToPickBase: Decimal;
        AvailableQtyBase: Decimal;
    begin
        // Directed put-away and pick
        GetBin(LocationCode, ToBinCode);
        GetLocation(LocationCode);
        WITH FromBinContent DO
            IF BinContentExists(FromBinContent, ItemNo, LocationCode, UnitofMeasureCode, VariantCode, CrossDock, TRUE, TRUE) THEN BEGIN
                TotalAvailQtyToPickBase :=
                  CalcTotalAvailQtyToPick(
                    LocationCode, ItemNo, VariantCode,
                    TempWhseItemTrkgLine."Lot No.", TempWhseItemTrkgLine."Serial No.",
                    SourceType, SourceSubType, SourceNo, SourceLineNo, SourceSubLineNo, TotalQtytoPickBase, FALSE);
                IF TotalAvailQtyToPickBase < 0 THEN
                    TotalAvailQtyToPickBase := 0;

                REPEAT
                    IF ("Bin Code" <> ToBinCode) AND
                       ((UseForPick(FromBinContent) AND (WhseSource <> WhseSource::"Movement Worksheet")) OR
                        (UseForReplenishment(FromBinContent) AND (WhseSource = WhseSource::"Movement Worksheet")))
                    THEN BEGIN
                        CalcBinAvailQtyToPick(AvailableQtyBase, FromBinContent, TempWhseActivLine2);
                        IF TotalAvailQtyToPickBase < AvailableQtyBase THEN
                            AvailableQtyBase := TotalAvailQtyToPickBase;

                        IF TotalQtytoPickBase < AvailableQtyBase THEN
                            AvailableQtyBase := TotalQtytoPickBase;

                        IF AvailableQtyBase > 0 THEN BEGIN
                            ToQtyToPickBase := CalcQtyToPickBase(FromBinContent);
                            IF AvailableQtyBase > ToQtyToPickBase THEN
                                AvailableQtyBase := ToQtyToPickBase;

                            UpdateQuantitiesToPick(
                              AvailableQtyBase,
                              "Qty. per Unit of Measure", FromQtyToPick, FromQtyToPickBase,
                              "Qty. per Unit of Measure", ToQtyToPick, ToQtyToPickBase,
                              TotalQtytoPick, TotalQtytoPickBase);

                            CreateTempActivityLine(
                              LocationCode, "Bin Code", UnitofMeasureCode, "Qty. per Unit of Measure", FromQtyToPick, FromQtyToPickBase, 1, 0);
                            CreateTempActivityLine(
                              LocationCode, ToBinCode, UnitofMeasureCode, "Qty. per Unit of Measure", ToQtyToPick, ToQtyToPickBase, 2, 0);

                            TotalAvailQtyToPickBase := TotalAvailQtyToPickBase - ToQtyToPickBase;
                        END;
                    END;
                UNTIL (NEXT = 0) OR (TotalQtytoPickBase = 0);
            END;
    end;

    local procedure FindBreakBulkBin(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; ToUOMCode: Code[10]; ToBinCode: Code[20]; ToQtyPerUOM: Decimal; var TempWhseActivLine2: Record 5767 temporary; var TotalQtytoPick: Decimal; var TempWhseItemTrkgLine: Record 6550; CrossDock: Boolean; var TotalQtytoPickBase: Decimal)
    var
        FromItemUOM: Record "Item Unit of Measure";
        FromBinContent: Record "Bin Content";
        FromQtyToPick: Decimal;
        FromQtyToPickBase: Decimal;
        ToQtyToPick: Decimal;
        ToQtyToPickBase: Decimal;
        QtyAvailableBase: Decimal;
        TotalAvailQtyToPickBase: Decimal;
    begin
        // Directed put-away and pick
        GetBin(LocationCode, ToBinCode);

        TotalAvailQtyToPickBase :=
          CalcTotalAvailQtyToPick(
            LocationCode, ItemNo, VariantCode, TempWhseItemTrkgLine."Lot No.", TempWhseItemTrkgLine."Serial No.",
            SourceType, SourceSubType, SourceNo, SourceLineNo, SourceSubLineNo, 0, FALSE);

        IF TotalAvailQtyToPickBase < 0 THEN
            TotalAvailQtyToPickBase := 0;

        IF NOT Location."Always Create Pick Line" THEN BEGIN
            IF TotalAvailQtyToPickBase = 0 THEN
                EXIT;

            IF TotalAvailQtyToPickBase < TotalQtytoPickBase THEN BEGIN
                TotalQtytoPickBase := TotalAvailQtyToPickBase;
                TotalQtytoPick := ROUND(TotalQtytoPickBase / ToQtyPerUOM, 0.00001);
            END;
        END;

        FromItemUOM.SETCURRENTKEY("Item No.", "Qty. per Unit of Measure");
        FromItemUOM.SETRANGE("Item No.", ItemNo);
        FromItemUOM.SETFILTER("Qty. per Unit of Measure", '>=%1', ToQtyPerUOM);
        FromItemUOM.SETFILTER(Code, '<>%1', ToUOMCode);
        IF FromItemUOM.FIND('-') THEN
            WITH FromBinContent DO
                REPEAT
                    IF BinContentExists(
                         FromBinContent, ItemNo, LocationCode, FromItemUOM.Code, VariantCode, CrossDock, LNRequired, SNRequired)
                    THEN
                        REPEAT
                            IF ("Bin Code" <> ToBinCode) AND
                               ((UseForPick(FromBinContent) AND (WhseSource <> WhseSource::"Movement Worksheet")) OR
                                (UseForReplenishment(FromBinContent) AND (WhseSource = WhseSource::"Movement Worksheet")))
                            THEN BEGIN
                                // Check and use bulk that has previously been broken
                                QtyAvailableBase := CalcBinAvailQtyInBreakbulk(TempWhseActivLine2, FromBinContent, ToUOMCode);
                                IF QtyAvailableBase > 0 THEN BEGIN
                                    UpdateQuantitiesToPick(
                                      QtyAvailableBase,
                                      ToQtyPerUOM, FromQtyToPick, FromQtyToPickBase,
                                      ToQtyPerUOM, ToQtyToPick, ToQtyToPickBase,
                                      TotalQtytoPick, TotalQtytoPickBase);

                                    CreateBreakBulkTempLines(
                                      "Location Code", ToUOMCode, ToUOMCode,
                                      "Bin Code", ToBinCode, ToQtyPerUOM, ToQtyPerUOM,
                                      0, FromQtyToPick, FromQtyToPickBase, ToQtyToPick, ToQtyToPickBase);
                                END;

                                IF TotalQtytoPickBase <= 0 THEN
                                    EXIT;

                                // Now break bulk and use
                                QtyAvailableBase := CalcBinAvailQtyToBreakbulk(TempWhseActivLine2, FromBinContent);
                                IF QtyAvailableBase > 0 THEN BEGIN
                                    FromItemUOM.GET(ItemNo, "Unit of Measure Code");
                                    UpdateQuantitiesToPick(
                                      QtyAvailableBase,
                                      FromItemUOM."Qty. per Unit of Measure", FromQtyToPick, FromQtyToPickBase,
                                      ToQtyPerUOM, ToQtyToPick, ToQtyToPickBase,
                                      TotalQtytoPick, TotalQtytoPickBase);

                                    BreakbulkNo := BreakbulkNo + 1;
                                    CreateBreakBulkTempLines(
                                      "Location Code", "Unit of Measure Code", ToUOMCode,
                                      "Bin Code", ToBinCode, FromItemUOM."Qty. per Unit of Measure", ToQtyPerUOM,
                                      BreakbulkNo, ToQtyToPick, ToQtyToPickBase, FromQtyToPick, FromQtyToPickBase);
                                END;
                                IF TotalQtytoPickBase <= 0 THEN
                                    EXIT;
                            END;
                        UNTIL NEXT = 0;
                UNTIL FromItemUOM.NEXT = 0;
    end;

    local procedure FindSmallerUOMBin(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; UnitofMeasureCode: Code[10]; ToBinCode: Code[20]; QtyPerUnitOfMeasure: Decimal; var TotalQtytoPick: Decimal; var TempWhseItemTrkgLine: Record 6550; CrossDock: Boolean; var TotalQtytoPickBase: Decimal)
    var
        ItemUOM: Record "Item Unit of Measure";
        FromBinContent: Record "Bin Content";
        TempFromBinContent: Record "Bin Content" temporary;
        FromQtyToPick: Decimal;
        FromQtyToPickBase: Decimal;
        ToQtyToPick: Decimal;
        ToQtyToPickBase: Decimal;
        QtyAvailableBase: Decimal;
        TotalAvailQtyToPickBase: Decimal;
    begin
        // Directed put-away and pick
        TotalAvailQtyToPickBase :=
          CalcTotalAvailQtyToPick(
            LocationCode, ItemNo, VariantCode,
            TempWhseItemTrkgLine."Lot No.", TempWhseItemTrkgLine."Serial No.",
            SourceType, SourceSubType, SourceNo, SourceLineNo, SourceSubLineNo, 0, FALSE);

        IF TotalAvailQtyToPickBase < 0 THEN
            TotalAvailQtyToPickBase := 0;

        IF NOT Location."Always Create Pick Line" THEN BEGIN
            IF TotalAvailQtyToPickBase = 0 THEN
                EXIT;

            IF TotalAvailQtyToPickBase < TotalQtytoPickBase THEN BEGIN
                TotalQtytoPickBase := TotalAvailQtyToPickBase;
                ItemUOM.GET(ItemNo, UnitofMeasureCode);
                TotalQtytoPick := ROUND(TotalQtytoPickBase / ItemUOM."Qty. per Unit of Measure", 0.00001);
            END;
        END;

        GetBin(LocationCode, ToBinCode);

        ItemUOM.SETCURRENTKEY("Item No.", "Qty. per Unit of Measure");
        ItemUOM.SETRANGE("Item No.", ItemNo);
        ItemUOM.SETFILTER("Qty. per Unit of Measure", '<%1', QtyPerUnitOfMeasure);
        ItemUOM.SETFILTER(Code, '<>%1', UnitofMeasureCode);
        ItemUOM.ASCENDING(FALSE);
        IF ItemUOM.FIND('-') THEN
            WITH FromBinContent DO
                REPEAT
                    IF BinContentExists(FromBinContent, ItemNo, LocationCode, ItemUOM.Code, VariantCode, CrossDock, LNRequired, SNRequired) THEN
                        REPEAT
                            IF ("Bin Code" <> ToBinCode) AND
                               ((UseForPick(FromBinContent) AND (WhseSource <> WhseSource::"Movement Worksheet")) OR
                                (UseForReplenishment(FromBinContent) AND (WhseSource = WhseSource::"Movement Worksheet")))
                            THEN BEGIN
                                CalcBinAvailQtyFromSmallerUOM(QtyAvailableBase, FromBinContent, FALSE);
                                IF QtyAvailableBase > 0 THEN BEGIN
                                    UpdateQuantitiesToPick(
                                      QtyAvailableBase,
                                      ItemUOM."Qty. per Unit of Measure", FromQtyToPick, FromQtyToPickBase,
                                      QtyPerUnitOfMeasure, ToQtyToPick, ToQtyToPickBase,
                                      TotalQtytoPick, TotalQtytoPickBase);

                                    CreateTempActivityLine(
                                      LocationCode, "Bin Code", "Unit of Measure Code",
                                      ItemUOM."Qty. per Unit of Measure", FromQtyToPick, FromQtyToPickBase, 1, 0);
                                    CreateTempActivityLine(
                                      LocationCode, ToBinCode, UnitofMeasureCode,
                                      QtyPerUnitOfMeasure, ToQtyToPick, ToQtyToPickBase, 2, 0);

                                    TotalAvailQtyToPickBase := TotalAvailQtyToPickBase - ToQtyToPickBase;
                                END;
                            END;
                        UNTIL (NEXT = 0) OR (TotalQtytoPickBase = 0);
                    IF TotalQtytoPickBase > 0 THEN
                        IF BreakBulkPlacingExists(TempFromBinContent, ItemNo, LocationCode, ItemUOM.Code, VariantCode, CrossDock, LNRequired, SNRequired) THEN
                            REPEAT
                                WITH TempFromBinContent DO
                                    IF ("Bin Code" <> ToBinCode) AND
                                       ((UseForPick(TempFromBinContent) AND (WhseSource <> WhseSource::"Movement Worksheet")) OR
                                        (UseForReplenishment(TempFromBinContent) AND (WhseSource = WhseSource::"Movement Worksheet")))
                                    THEN BEGIN
                                        CalcBinAvailQtyFromSmallerUOM(QtyAvailableBase, TempFromBinContent, TRUE);
                                        IF QtyAvailableBase > 0 THEN BEGIN
                                            UpdateQuantitiesToPick(
                                              QtyAvailableBase,
                                              ItemUOM."Qty. per Unit of Measure", FromQtyToPick, FromQtyToPickBase,
                                              QtyPerUnitOfMeasure, ToQtyToPick, ToQtyToPickBase,
                                              TotalQtytoPick, TotalQtytoPickBase);

                                            CreateTempActivityLine(
                                              LocationCode, "Bin Code", "Unit of Measure Code",
                                              ItemUOM."Qty. per Unit of Measure", FromQtyToPick, FromQtyToPickBase, 1, 0);
                                            CreateTempActivityLine(
                                              LocationCode, ToBinCode, UnitofMeasureCode,
                                              QtyPerUnitOfMeasure, ToQtyToPick, ToQtyToPickBase, 2, 0);
                                            TotalAvailQtyToPickBase := TotalAvailQtyToPickBase - ToQtyToPickBase;
                                        END;
                                    END;
                            UNTIL (TempFromBinContent.NEXT = 0) OR (TotalQtytoPickBase = 0);
                UNTIL (ItemUOM.NEXT = 0) OR (TotalQtytoPickBase = 0);
    end;

    local procedure CalcBinAvailQtyToPick(var QtyToPickBase: Decimal; var BinContent: Record "Bin Content"; var TempWhseActivLine: Record "Warehouse Activity Line")
    var
        AvailableQtyBase: Decimal;
    begin
        WITH TempWhseActivLine DO BEGIN
            RESET;
            SETCURRENTKEY(
              "Item No.", "Bin Code", "Location Code", "Action Type",
              "Variant Code", "Unit of Measure Code", "Breakbulk No.");
            SETRANGE("Item No.", BinContent."Item No.");
            SETRANGE("Bin Code", BinContent."Bin Code");
            SETRANGE("Location Code", BinContent."Location Code");
            SETRANGE("Unit of Measure Code", BinContent."Unit of Measure Code");
            SETRANGE("Variant Code", BinContent."Variant Code");
            IF WhseItemTrkgExists THEN BEGIN
                IF LNRequired THEN
                    SETRANGE("Lot No.", TempWhseItemTrkgLine."Lot No.")
                ELSE
                    SETFILTER("Lot No.", '%1|%2', TempWhseItemTrkgLine."Lot No.", '');
                IF SNRequired THEN
                    SETRANGE("Serial No.", TempWhseItemTrkgLine."Serial No.")
                ELSE
                    SETFILTER("Serial No.", '%1|%2', TempWhseItemTrkgLine."Serial No.", '');
            END;

            IF Location."Allow Breakbulk" THEN BEGIN
                SETRANGE("Action Type", "Action Type"::Place);
                SETFILTER("Breakbulk No.", '<>0');
                CALCSUMS("Qty. (Base)");
                AvailableQtyBase := "Qty. (Base)";
            END;

            SETRANGE("Action Type", "Action Type"::Take);
            SETRANGE("Breakbulk No.", 0);
            CALCSUMS("Qty. (Base)");
        END;

        QtyToPickBase := BinContent.CalcQtyAvailToPick(AvailableQtyBase - TempWhseActivLine."Qty. (Base)");
    end;

    local procedure CalcBinAvailQtyToBreakbulk(var TempWhseActivLine2: Record "Warehouse Activity Line"; var BinContent: Record "Bin Content") QtyToPickBase: Decimal
    begin
        WITH BinContent DO BEGIN
            SetFilterOnUnitOfMeasure;
            CALCFIELDS("Quantity (Base)", "Pick Quantity (Base)", "Negative Adjmt. Qty. (Base)");
            QtyToPickBase := "Quantity (Base)" - "Pick Quantity (Base)" - "Negative Adjmt. Qty. (Base)";
        END;
        IF QtyToPickBase <= 0 THEN
            EXIT(0);

        WITH TempWhseActivLine2 DO BEGIN
            SETCURRENTKEY(
              "Item No.", "Bin Code", "Location Code", "Action Type",
              "Variant Code", "Unit of Measure Code", "Breakbulk No.");
            SETRANGE("Action Type", "Action Type"::Take);
            SETRANGE("Location Code", BinContent."Location Code");
            SETRANGE("Bin Code", BinContent."Bin Code");
            SETRANGE("Item No.", BinContent."Item No.");
            SETRANGE("Unit of Measure Code", BinContent."Unit of Measure Code");
            SETRANGE("Variant Code", BinContent."Variant Code");
            IF WhseItemTrkgExists THEN BEGIN
                IF LNRequired THEN
                    SETRANGE("Lot No.", TempWhseItemTrkgLine."Lot No.")
                ELSE
                    SETFILTER("Lot No.", '%1|%2', TempWhseItemTrkgLine."Lot No.", '');
                IF SNRequired THEN
                    SETRANGE("Serial No.", TempWhseItemTrkgLine."Serial No.")
                ELSE
                    SETFILTER("Serial No.", '%1|%2', TempWhseItemTrkgLine."Serial No.", '');
            END ELSE BEGIN
                SETRANGE("Lot No.");
                SETRANGE("Serial No.");
            END;
            SETRANGE("Breakbulk No.");
            SETRANGE("Source Type");
            SETRANGE("Source Subtype");
            SETRANGE("Source No.");
            SETRANGE("Source Line No.");
            CALCSUMS("Qty. (Base)");
            QtyToPickBase := QtyToPickBase - "Qty. (Base)";
            EXIT(QtyToPickBase);
        END;
    end;

    local procedure CalcBinAvailQtyInBreakbulk(var TempWhseActivLine2: Record "Warehouse Activity Line"; var BinContent: Record "Bin Content"; ToUOMCode: Code[10]) QtyToPickBase: Decimal
    begin
        WITH TempWhseActivLine2 DO BEGIN
            IF (MaxNoOfSourceDoc > 1) OR (MaxNoOfLines <> 0) THEN
                EXIT(0);

            SETCURRENTKEY(
              "Item No.", "Bin Code", "Location Code", "Action Type",
              "Variant Code", "Unit of Measure Code", "Breakbulk No.");
            SETRANGE("Action Type", "Action Type"::Take);
            SETRANGE("Location Code", BinContent."Location Code");
            SETRANGE("Bin Code", BinContent."Bin Code");
            SETRANGE("Item No.", BinContent."Item No.");
            SETRANGE("Unit of Measure Code", ToUOMCode);
            SETRANGE("Variant Code", BinContent."Variant Code");
            IF WhseItemTrkgExists THEN BEGIN
                IF LNRequired THEN
                    SETRANGE("Lot No.", TempWhseItemTrkgLine."Lot No.")
                ELSE
                    SETFILTER("Lot No.", '%1|%2', TempWhseItemTrkgLine."Lot No.", '');
                IF SNRequired THEN
                    SETRANGE("Serial No.", TempWhseItemTrkgLine."Serial No.")
                ELSE
                    SETFILTER("Serial No.", '%1|%2', TempWhseItemTrkgLine."Serial No.", '');
            END ELSE BEGIN
                SETRANGE("Lot No.");
                SETRANGE("Serial No.");
            END;
            SETRANGE("Breakbulk No.", 0);
            CALCSUMS("Qty. (Base)");
            QtyToPickBase := "Qty. (Base)";

            SETRANGE("Action Type", "Action Type"::Place);
            SETFILTER("Breakbulk No.", '<>0');
            SETRANGE("No.", FORMAT(TempNo));
            IF MaxNoOfSourceDoc = 1 THEN BEGIN
                SETRANGE("Source Type", WhseWkshLine."Source Type");
                SETRANGE("Source Subtype", WhseWkshLine."Source Subtype");
                SETRANGE("Source No.", WhseWkshLine."Source No.");
            END;
            CALCSUMS("Qty. (Base)");
            QtyToPickBase := "Qty. (Base)" - QtyToPickBase;
            EXIT(QtyToPickBase);
        END;
    end;

    local procedure CalcBinAvailQtyFromSmallerUOM(var AvailableQtyBase: Decimal; var BinContent: Record "Bin Content"; AllowInitialZero: Boolean)
    begin
        WITH BinContent DO BEGIN
            SetFilterOnUnitOfMeasure;
            CALCFIELDS("Quantity (Base)", "Pick Quantity (Base)", "Negative Adjmt. Qty. (Base)");
            AvailableQtyBase := "Quantity (Base)" - "Pick Quantity (Base)" - "Negative Adjmt. Qty. (Base)";
        END;
        IF (AvailableQtyBase < 0) OR ((AvailableQtyBase = 0) AND (NOT AllowInitialZero)) THEN
            EXIT;

        WITH TempWhseActivLine DO BEGIN
            SETCURRENTKEY(
              "Item No.", "Bin Code", "Location Code", "Action Type",
              "Variant Code", "Unit of Measure Code", "Breakbulk No.");

            SETRANGE("Item No.", BinContent."Item No.");
            SETRANGE("Bin Code", BinContent."Bin Code");
            SETRANGE("Location Code", BinContent."Location Code");
            SETRANGE("Action Type", "Action Type"::Take);
            SETRANGE("Variant Code", BinContent."Variant Code");
            SETRANGE("Unit of Measure Code", BinContent."Unit of Measure Code");
            IF WhseItemTrkgExists THEN BEGIN
                IF LNRequired THEN
                    SETRANGE("Lot No.", TempWhseItemTrkgLine."Lot No.")
                ELSE
                    SETFILTER("Lot No.", '%1|%2', TempWhseItemTrkgLine."Lot No.", '');
                IF SNRequired THEN
                    SETRANGE("Serial No.", TempWhseItemTrkgLine."Serial No.")
                ELSE
                    SETFILTER("Serial No.", '%1|%2', TempWhseItemTrkgLine."Serial No.", '');
            END ELSE BEGIN
                SETRANGE("Lot No.");
                SETRANGE("Serial No.");
            END;
            CALCSUMS("Qty. (Base)");
            AvailableQtyBase := AvailableQtyBase - "Qty. (Base)";

            SETRANGE("Action Type", "Action Type"::Place);
            SETFILTER("Breakbulk No.", '<>0');
            CALCSUMS("Qty. (Base)");
            AvailableQtyBase := AvailableQtyBase + "Qty. (Base)";
        END;
    end;

    local procedure CreateBreakBulkTempLines(LocationCode: Code[10]; FromUOMCode: Code[10]; ToUOMCode: Code[10]; FromBinCode: Code[20]; ToBinCode: Code[20]; FromQtyPerUOM: Decimal; ToQtyPerUOM: Decimal; BreakbulkNo2: Integer; ToQtyToPick: Decimal; ToQtyToPickBase: Decimal; FromQtyToPick: Decimal; FromQtyToPickBase: Decimal)
    var
        QtyToBreakBulk: Decimal;
    begin
        // Directed put-away and pick
        IF FromUOMCode <> ToUOMCode THEN BEGIN
            CreateTempActivityLine(
              LocationCode, FromBinCode, FromUOMCode, FromQtyPerUOM, FromQtyToPick, FromQtyToPickBase, 1, BreakbulkNo2);

            IF FromQtyToPickBase = ToQtyToPickBase THEN
                QtyToBreakBulk := ToQtyToPick
            ELSE
                QtyToBreakBulk := ROUND(FromQtyToPick * FromQtyPerUOM / ToQtyPerUOM, 0.00001);
            CreateTempActivityLine(
              LocationCode, FromBinCode, ToUOMCode, ToQtyPerUOM, QtyToBreakBulk, FromQtyToPickBase, 2, BreakbulkNo2);
        END;
        CreateTempActivityLine(LocationCode, FromBinCode, ToUOMCode, ToQtyPerUOM, ToQtyToPick, ToQtyToPickBase, 1, 0);
        CreateTempActivityLine(LocationCode, ToBinCode, ToUOMCode, ToQtyPerUOM, ToQtyToPick, ToQtyToPickBase, 2, 0);
    end;

    procedure CreateWhseDocument(var FirstWhseDocNo: Code[20]; var LastWhseDocNo: Code[20]; ShowError: Boolean; PickNo: Code[20])
    var
        WhseActivLine: Record "Warehouse Activity Line";
        OldNo: Code[20];
        OldSourceNo: Code[20];
        OldLocationCode: Code[10];
        OldBinCode: Code[20];
        OldZoneCode: Code[10];
        NoOfLines: Integer;
        NoOfSourceDoc: Integer;
        WhseDocCreated: Boolean;
    begin
        TempWhseActivLine.RESET;
        IF NOT TempWhseActivLine.FIND('-') THEN BEGIN
            IF ShowError THEN
                ERROR(Text000, ExpiredItemMessageText);
            EXIT;
        END;
        WhseActivHeader.LOCKTABLE;
        IF WhseActivHeader.FINDLAST THEN;
        WhseActivLine.LOCKTABLE;
        IF WhseActivLine.FINDLAST THEN;

        IF WhseSource = WhseSource::"Movement Worksheet" THEN
            TempWhseActivLine.SETRANGE("Activity Type", TempWhseActivLine."Activity Type"::Movement)
        ELSE
            TempWhseActivLine.SETRANGE("Activity Type", TempWhseActivLine."Activity Type"::Pick);

        NoOfLines := 0;
        NoOfSourceDoc := 0;

        REPEAT
            GetLocation(TempWhseActivLine."Location Code");
            TempWhseActivLine.SETRANGE("Location Code", TempWhseActivLine."Location Code");
            IF Location."Bin Mandatory" THEN
                TempWhseActivLine.SETRANGE("Action Type", TempWhseActivLine."Action Type"::Take)
            ELSE
                TempWhseActivLine.SETRANGE("Action Type", TempWhseActivLine."Action Type"::" ");

            IF NOT TempWhseActivLine.FIND('-') THEN
                EXIT;

            IF PerBin THEN
                TempWhseActivLine.SETRANGE("Bin Code", TempWhseActivLine."Bin Code");
            IF PerZone THEN
                TempWhseActivLine.SETRANGE("Zone Code", TempWhseActivLine."Zone Code");

            REPEAT
                IF PerBin THEN BEGIN
                    IF TempWhseActivLine."Bin Code" <> OldBinCode THEN BEGIN
                        CreateWhseActivHeader(
                          TempWhseActivLine."Location Code", FirstWhseDocNo, LastWhseDocNo,
                          NoOfSourceDoc, NoOfLines, WhseDocCreated, PickNo);
                        CreateWhseDocLine;
                    END ELSE
                        CreateNewWhseDoc(
                          OldNo, OldSourceNo, OldLocationCode, FirstWhseDocNo, LastWhseDocNo,
                          NoOfSourceDoc, NoOfLines, WhseDocCreated, PickNo);
                END ELSE BEGIN
                    IF PerZone THEN BEGIN
                        IF TempWhseActivLine."Zone Code" <> OldZoneCode THEN BEGIN
                            CreateWhseActivHeader(
                              TempWhseActivLine."Location Code", FirstWhseDocNo, LastWhseDocNo,
                              NoOfSourceDoc, NoOfLines, WhseDocCreated, PickNo);
                            CreateWhseDocLine;
                        END ELSE
                            CreateNewWhseDoc(
                              OldNo, OldSourceNo, OldLocationCode, FirstWhseDocNo, LastWhseDocNo,
                              NoOfSourceDoc, NoOfLines, WhseDocCreated, PickNo);
                    END ELSE
                        CreateNewWhseDoc(
                          OldNo, OldSourceNo, OldLocationCode, FirstWhseDocNo, LastWhseDocNo,
                          NoOfSourceDoc, NoOfLines, WhseDocCreated, PickNo);
                END;

                OldZoneCode := TempWhseActivLine."Zone Code";
                OldBinCode := TempWhseActivLine."Bin Code";
                OldNo := TempWhseActivLine."No.";
                OldSourceNo := TempWhseActivLine."Source No.";
                OldLocationCode := TempWhseActivLine."Location Code";
            UNTIL TempWhseActivLine.NEXT = 0;
            TempWhseActivLine.SETRANGE("Bin Code");
            TempWhseActivLine.SETRANGE("Zone Code");
            TempWhseActivLine.SETRANGE("Location Code");
            TempWhseActivLine.SETRANGE("Action Type");
            IF NOT TempWhseActivLine.FIND('-') THEN
                EXIT;

        UNTIL FALSE;
    end;

    local procedure CreateNewWhseDoc(OldNo: Code[20]; OldSourceNo: Code[20]; OldLocationCode: Code[10]; var FirstWhseDocNo: Code[20]; var LastWhseDocNo: Code[20]; var NoOfSourceDoc: Integer; var NoOfLines: Integer; var WhseDocCreated: Boolean; PickNo: Code[20])
    begin
        IF (TempWhseActivLine."No." <> OldNo) OR
           (TempWhseActivLine."Location Code" <> OldLocationCode)
        THEN BEGIN
            CreateWhseActivHeader(
              TempWhseActivLine."Location Code", FirstWhseDocNo, LastWhseDocNo,
              NoOfSourceDoc, NoOfLines, WhseDocCreated, PickNo);
            CreateWhseDocLine;
        END ELSE BEGIN
            NoOfLines := NoOfLines + 1;
            IF TempWhseActivLine."Source No." <> OldSourceNo THEN
                NoOfSourceDoc := NoOfSourceDoc + 1;
            IF (MaxNoOfSourceDoc > 0) AND (NoOfSourceDoc > MaxNoOfSourceDoc) THEN
                CreateWhseActivHeader(
                  TempWhseActivLine."Location Code", FirstWhseDocNo, LastWhseDocNo,
                  NoOfSourceDoc, NoOfLines, WhseDocCreated, PickNo);
            IF (MaxNoOfLines > 0) AND (NoOfLines > MaxNoOfLines) THEN
                CreateWhseActivHeader(
                  TempWhseActivLine."Location Code", FirstWhseDocNo, LastWhseDocNo,
                  NoOfSourceDoc, NoOfLines, WhseDocCreated, PickNo);
            CreateWhseDocLine;
        END;
    end;

    local procedure CreateWhseActivHeader(LocationCode: Code[10]; var FirstWhseDocNo: Code[20]; var LastWhseDocNo: Code[20]; var NoOfSourceDoc: Integer; var NoOfLines: Integer; var WhseDocCreated: Boolean; PickNo: Code[20])
    begin
        WhseActivHeader.INIT;
        WhseActivHeader."No." := PickNo;

        IF WhseDocType = WhseDocType::Movement THEN
            WhseActivHeader.Type := WhseActivHeader.Type::Movement
        ELSE
            WhseActivHeader.Type := WhseActivHeader.Type::Pick;

        WhseActivHeader."Location Code" := LocationCode;
        IF AssignedID <> '' THEN
            WhseActivHeader.VALIDATE("Assigned User ID", AssignedID);
        WhseActivHeader."Sorting Method" := SortPick;
        WhseActivHeader."Breakbulk Filter" := BreakbulkFilter;
        WhseActivHeader.INSERT(TRUE);

        NoOfLines := 1;
        NoOfSourceDoc := 1;

        IF NOT WhseDocCreated THEN BEGIN
            FirstWhseDocNo := WhseActivHeader."No.";
            WhseDocCreated := TRUE;
        END;
        LastWhseDocNo := WhseActivHeader."No.";
    end;

    local procedure CreateWhseDocLine()
    var
        WhseActivLine: Record "Warehouse Activity Line";
        LineNo: Integer;
    begin
        TempWhseActivLine.SETRANGE("Breakbulk No.", 0);
        TempWhseActivLine.FIND('-');
        WhseActivLine.SETRANGE("Activity Type", WhseActivHeader.Type);
        WhseActivLine.SETRANGE("No.", WhseActivHeader."No.");
        IF WhseActivLine.FINDLAST THEN
            LineNo := WhseActivLine."Line No."
        ELSE
            LineNo := 0;

        ItemTrackingMgt.CheckWhseItemTrkgSetup(
          TempWhseActivLine."Item No.", SNRequired, LNRequired, FALSE);

        LineNo := LineNo + 10000;
        WhseActivLine.INIT;
        WhseActivLine := TempWhseActivLine;
        WhseActivLine."No." := WhseActivHeader."No.";
        IF NOT (WhseActivLine."Whse. Document Type" IN [WhseActivLine."Whse. Document Type"::"Internal Pick", WhseActivLine."Whse. Document Type"::"Movement Worksheet"]) THEN
            WhseActivLine."Source Document" := WhseMgt.GetSourceDocument(WhseActivLine."Source Type", WhseActivLine."Source Subtype");

        IF Location."Bin Mandatory" AND (NOT SNRequired) THEN
            CreateWhseDocTakeLine(WhseActivLine, LineNo)
        ELSE
            TempWhseActivLine.DELETE;

        WhseActivLine."Line No." := LineNo;
        IF DoNotFillQtytoHandle THEN BEGIN
            WhseActivLine."Qty. to Handle" := 0;
            WhseActivLine."Qty. to Handle (Base)" := 0;
            WhseActivLine.Cubage := 0;
            WhseActivLine.Weight := 0;
        END;
        WhseActivLine.INSERT;

        IF Location."Bin Mandatory" THEN
            CreateWhseDocPlaceLine(WhseActivLine.Quantity, WhseActivLine."Qty. (Base)", LineNo);
    end;

    local procedure CreateWhseDocTakeLine(var WhseActivLine: Record "Warehouse Activity Line"; var LineNo: Integer)
    var
        WhseActivLine2: Record "Warehouse Activity Line";
        TempWhseActivLine2: Record "Warehouse Activity Line" temporary;
        TempWhseActivLine3: Record "Warehouse Activity Line" temporary;
    begin
        TempWhseActivLine2.COPY(TempWhseActivLine);
        TempWhseActivLine.SETCURRENTKEY(
          "Whse. Document No.", "Whse. Document Type", "Activity Type", "Whse. Document Line No.", "Action Type");
        TempWhseActivLine.DELETE;

        TempWhseActivLine.SETRANGE("Whse. Document Type", TempWhseActivLine2."Whse. Document Type");
        TempWhseActivLine.SETRANGE("Whse. Document No.", TempWhseActivLine2."Whse. Document No.");
        TempWhseActivLine.SETRANGE("Activity Type", TempWhseActivLine2."Activity Type");
        TempWhseActivLine.SETRANGE("Whse. Document Line No.", TempWhseActivLine2."Whse. Document Line No.");
        TempWhseActivLine.SETRANGE("Action Type", TempWhseActivLine2."Action Type"::Take);
        TempWhseActivLine.SETRANGE("Source Type", TempWhseActivLine2."Source Type");
        TempWhseActivLine.SETRANGE("Source Subtype", TempWhseActivLine2."Source Subtype");
        TempWhseActivLine.SETRANGE("Source No.", TempWhseActivLine2."Source No.");
        TempWhseActivLine.SETRANGE("Source Line No.", TempWhseActivLine2."Source Line No.");
        TempWhseActivLine.SETRANGE("Source Subline No.", TempWhseActivLine2."Source Subline No.");
        TempWhseActivLine.SETRANGE("No.", TempWhseActivLine2."No.");
        TempWhseActivLine.SETFILTER("Line No.", '>%1', TempWhseActivLine2."Line No.");
        TempWhseActivLine.SETRANGE("Bin Code", TempWhseActivLine2."Bin Code");
        TempWhseActivLine.SETRANGE("Unit of Measure Code", WhseActivLine."Unit of Measure Code");
        TempWhseActivLine.SETRANGE("Zone Code");
        TempWhseActivLine.SETRANGE("Breakbulk No.", 0);
        TempWhseActivLine.SETRANGE("Serial No.", TempWhseActivLine2."Serial No.");
        TempWhseActivLine.SETRANGE("Lot No.", TempWhseActivLine2."Lot No.");

        IF TempWhseActivLine.FIND('-') THEN BEGIN
            REPEAT
                WhseActivLine.Quantity := WhseActivLine.Quantity + TempWhseActivLine.Quantity;
            UNTIL TempWhseActivLine.NEXT = 0;
            TempWhseActivLine.DELETEALL;
            WhseActivLine.VALIDATE(Quantity);
        END;

        // insert breakbulk lines
        IF Location."Directed Put-away and Pick" THEN BEGIN
            TempWhseActivLine.SETRANGE("Line No.");
            TempWhseActivLine.SETRANGE("Unit of Measure Code");
            TempWhseActivLine.SETFILTER("Breakbulk No.", '<>0');
            IF TempWhseActivLine.FIND('-') THEN
                REPEAT
                    WhseActivLine2.INIT;
                    WhseActivLine2 := TempWhseActivLine;
                    WhseActivLine2."No." := WhseActivHeader."No.";
                    WhseActivLine2."Line No." := LineNo;
                    WhseActivLine2."Source Document" := WhseActivLine."Source Document";

                    IF DoNotFillQtytoHandle THEN BEGIN
                        WhseActivLine2."Qty. to Handle" := 0;
                        WhseActivLine2."Qty. to Handle (Base)" := 0;
                        WhseActivLine2.Cubage := 0;
                        WhseActivLine2.Weight := 0;
                    END;
                    WhseActivLine2.INSERT;

                    TempWhseActivLine.DELETE;
                    LineNo := LineNo + 10000;

                    TempWhseActivLine3.COPY(TempWhseActivLine);
                    TempWhseActivLine.SETRANGE("Action Type", TempWhseActivLine."Action Type"::Place);
                    TempWhseActivLine.SETRANGE("Line No.");
                    TempWhseActivLine.SETRANGE("Unit of Measure Code", WhseActivLine."Unit of Measure Code");
                    TempWhseActivLine.SETRANGE("Breakbulk No.", TempWhseActivLine."Breakbulk No.");
                    TempWhseActivLine.FIND('-');

                    WhseActivLine2.INIT;
                    WhseActivLine2 := TempWhseActivLine;
                    WhseActivLine2."No." := WhseActivHeader."No.";
                    WhseActivLine2."Line No." := LineNo;
                    WhseActivLine2."Source Document" := WhseActivLine."Source Document";

                    IF DoNotFillQtytoHandle THEN BEGIN
                        WhseActivLine2."Qty. to Handle" := 0;
                        WhseActivLine2."Qty. to Handle (Base)" := 0;
                        WhseActivLine2.Cubage := 0;
                        WhseActivLine2.Weight := 0;
                    END;

                    WhseActivLine2."Original Breakbulk" :=
                      WhseActivLine."Qty. (Base)" = WhseActivLine2."Qty. (Base)";
                    IF BreakbulkFilter THEN
                        WhseActivLine2.Breakbulk := WhseActivLine2."Original Breakbulk";
                    WhseActivLine2.INSERT;

                    TempWhseActivLine.DELETE;
                    LineNo := LineNo + 10000;

                    TempWhseActivLine.COPY(TempWhseActivLine3);
                    WhseActivLine."Original Breakbulk" := WhseActivLine2."Original Breakbulk";
                    IF BreakbulkFilter THEN
                        WhseActivLine.Breakbulk := WhseActivLine."Original Breakbulk";
                UNTIL TempWhseActivLine.NEXT = 0;
        END;

        TempWhseActivLine.COPY(TempWhseActivLine2);
    end;

    local procedure CreateWhseDocPlaceLine(PickQty: Decimal; PickQtyBase: Decimal; var LineNo: Integer)
    var
        WhseActivLine: Record "Warehouse Activity Line";
        TempWhseActivLine2: Record "Warehouse Activity Line" temporary;
        TempWhseActivLine3: Record "Warehouse Activity Line" temporary;
    begin
        TempWhseActivLine2.COPY(TempWhseActivLine);
        TempWhseActivLine.SETCURRENTKEY(
          "Whse. Document No.", "Whse. Document Type", "Activity Type", "Whse. Document Line No.", "Action Type");
        TempWhseActivLine.SETRANGE("Whse. Document No.", TempWhseActivLine2."Whse. Document No.");
        TempWhseActivLine.SETRANGE("Whse. Document Type", TempWhseActivLine2."Whse. Document Type");
        TempWhseActivLine.SETRANGE("Activity Type", TempWhseActivLine2."Activity Type");
        TempWhseActivLine.SETRANGE("Whse. Document Line No.", TempWhseActivLine2."Whse. Document Line No.");
        TempWhseActivLine.SETRANGE("Source Subline No.", TempWhseActivLine2."Source Subline No.");
        TempWhseActivLine.SETRANGE("No.", TempWhseActivLine2."No.");
        TempWhseActivLine.SETRANGE("Action Type", TempWhseActivLine2."Action Type"::Place);
        TempWhseActivLine.SETFILTER("Line No.", '>%1', TempWhseActivLine2."Line No.");
        TempWhseActivLine.SETRANGE("Bin Code");
        TempWhseActivLine.SETRANGE("Zone Code");
        TempWhseActivLine.SETRANGE("Item No.", TempWhseActivLine2."Item No.");
        TempWhseActivLine.SETRANGE("Variant Code", TempWhseActivLine2."Variant Code");
        TempWhseActivLine.SETRANGE("Breakbulk No.", 0);
        TempWhseActivLine.SETRANGE("Serial No.", TempWhseActivLine2."Serial No.");
        TempWhseActivLine.SETRANGE("Lot No.", TempWhseActivLine2."Lot No.");

        IF TempWhseActivLine.FIND('-') THEN
            REPEAT
                LineNo := LineNo + 10000;
                WhseActivLine.INIT;
                WhseActivLine := TempWhseActivLine;

                WITH WhseActivLine DO
                    IF (PickQty * "Qty. per Unit of Measure") <> PickQtyBase THEN
                        PickQty := ROUND(PickQtyBase / "Qty. per Unit of Measure", 0.00001);

                PickQtyBase := PickQtyBase - WhseActivLine."Qty. (Base)";
                PickQty := PickQty - WhseActivLine.Quantity;

                WhseActivLine."No." := WhseActivHeader."No.";
                WhseActivLine."Line No." := LineNo;

                IF NOT (WhseActivLine."Whse. Document Type" IN [WhseActivLine."Whse. Document Type"::"Internal Pick", WhseActivLine."Whse. Document Type"::"Movement Worksheet"]) THEN
                    WhseActivLine."Source Document" := WhseMgt.GetSourceDocument(WhseActivLine."Source Type", WhseActivLine."Source Subtype");

                TempWhseActivLine.DELETE;
                IF PickQtyBase > 0 THEN BEGIN
                    TempWhseActivLine3.COPY(TempWhseActivLine);
                    TempWhseActivLine.SETRANGE(
                      "Unit of Measure Code", WhseActivLine."Unit of Measure Code");
                    TempWhseActivLine.SETFILTER("Line No.", '>%1', TempWhseActivLine."Line No.");
                    TempWhseActivLine.SETRANGE("No.", TempWhseActivLine2."No.");
                    TempWhseActivLine.SETRANGE("Bin Code", WhseActivLine."Bin Code");
                    IF TempWhseActivLine.FIND('-') THEN BEGIN
                        REPEAT
                            IF TempWhseActivLine."Qty. (Base)" >= PickQtyBase THEN BEGIN
                                WhseActivLine.Quantity := WhseActivLine.Quantity + PickQty;
                                WhseActivLine."Qty. (Base)" := WhseActivLine."Qty. (Base)" + PickQtyBase;
                                TempWhseActivLine.VALIDATE(Quantity, TempWhseActivLine.Quantity - PickQty);
                                TempWhseActivLine.MODIFY;
                                PickQty := 0;
                                PickQtyBase := 0;
                            END ELSE BEGIN
                                WhseActivLine.Quantity := WhseActivLine.Quantity + TempWhseActivLine.Quantity;
                                WhseActivLine."Qty. (Base)" := WhseActivLine."Qty. (Base)" + TempWhseActivLine."Qty. (Base)";
                                PickQty := PickQty - TempWhseActivLine.Quantity;
                                PickQtyBase := PickQtyBase - TempWhseActivLine."Qty. (Base)";
                                TempWhseActivLine.DELETE;
                            END;
                        UNTIL (TempWhseActivLine.NEXT = 0) OR (PickQtyBase = 0);
                    END ELSE
                        IF TempWhseActivLine.DELETE THEN;
                    TempWhseActivLine.COPY(TempWhseActivLine3);
                END;

                IF WhseActivLine.Quantity > 0 THEN BEGIN
                    TempWhseActivLine3 := WhseActivLine;
                    WhseActivLine.VALIDATE(Quantity);
                    WhseActivLine."Qty. (Base)" := TempWhseActivLine3."Qty. (Base)";
                    WhseActivLine."Qty. Outstanding (Base)" := TempWhseActivLine3."Qty. (Base)";
                    WhseActivLine."Qty. to Handle (Base)" := TempWhseActivLine3."Qty. (Base)";
                    IF DoNotFillQtytoHandle THEN BEGIN
                        WhseActivLine."Qty. to Handle" := 0;
                        WhseActivLine."Qty. to Handle (Base)" := 0;
                        WhseActivLine.Cubage := 0;
                        WhseActivLine.Weight := 0;
                    END;
                    WhseActivLine.INSERT;
                END;
            UNTIL (TempWhseActivLine.NEXT = 0) OR (PickQtyBase = 0);

        TempWhseActivLine.COPY(TempWhseActivLine2);
    end;

    local procedure AssignSpecEquipment(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]): Code[10]
    begin
        IF (BinCode <> '') AND
           (Location."Special Equipment" =
            Location."Special Equipment"::"According to Bin")
        THEN BEGIN
            GetBin(LocationCode, BinCode);
            IF Bin."Special Equipment Code" <> '' THEN
                EXIT(Bin."Special Equipment Code");

            GetSKU(LocationCode, ItemNo, VariantCode);
            IF SKU."Special Equipment Code" <> '' THEN
                EXIT(SKU."Special Equipment Code");

            GetItem(ItemNo);
            EXIT(Item."Special Equipment Code");
        END;
        GetSKU(LocationCode, ItemNo, VariantCode);
        IF SKU."Special Equipment Code" <> '' THEN
            EXIT(SKU."Special Equipment Code");

        GetItem(ItemNo);
        IF Item."Special Equipment Code" <> '' THEN
            EXIT(Item."Special Equipment Code");

        GetBin(LocationCode, BinCode);
        EXIT(Bin."Special Equipment Code");
    end;

    local procedure CalcAvailableQty(ItemNo: Code[20]; VariantCode: Code[10]): Decimal
    var
        AvailableQtyBase: Decimal;
        LineReservedQty: Decimal;
        QtyReservedOnPickShip: Decimal;
        WhseSource2: Option;
    begin
        // For locations with pick/ship and without directed put-away and pick
        GetItem(ItemNo);
        AvailableQtyBase := WhseAvailMgt.CalcInvtAvailQty(Item, Location, VariantCode, TempWhseActivLine);

        IF (WhseSource = WhseSource::Shipment) AND WhseShptLine."Assemble to Order" THEN
            WhseSource2 := WhseSource::Assembly
        ELSE
            WhseSource2 := WhseSource;
        CASE WhseSource2 OF
            WhseSource::"Pick Worksheet", WhseSource::"Movement Worksheet":
                LineReservedQty :=
                  WhseAvailMgt.CalcLineReservedQtyOnInvt(
                    WhseWkshLine."Source Type",
                    WhseWkshLine."Source Subtype",
                    WhseWkshLine."Source No.",
                    WhseWkshLine."Source Line No.",
                    WhseWkshLine."Source Subline No.",
                    TRUE, '', '', TempWhseActivLine);
            WhseSource::Shipment:
                LineReservedQty :=
                  WhseAvailMgt.CalcLineReservedQtyOnInvt(
                    WhseShptLine."Source Type",
                    WhseShptLine."Source Subtype",
                    WhseShptLine."Source No.",
                    WhseShptLine."Source Line No.",
                    0,
                    TRUE, '', '', TempWhseActivLine);
            WhseSource::Production:
                LineReservedQty :=
                  WhseAvailMgt.CalcLineReservedQtyOnInvt(
                    DATABASE::"Prod. Order Component",
                    ProdOrderCompLine.Status,
                    ProdOrderCompLine."Prod. Order No.",
                    ProdOrderCompLine."Prod. Order Line No.",
                    ProdOrderCompLine."Line No.",
                    TRUE, '', '', TempWhseActivLine);
            WhseSource::Assembly:
                LineReservedQty :=
                  WhseAvailMgt.CalcLineReservedQtyOnInvt(
                    DATABASE::"Assembly Line",
                    AssemblyLine."Document Type",
                    AssemblyLine."Document No.",
                    AssemblyLine."Line No.",
                    0,
                    TRUE, '', '', TempWhseActivLine);
        END;

        QtyReservedOnPickShip := WhseAvailMgt.CalcReservQtyOnPicksShips(Location.Code, ItemNo, VariantCode, TempWhseActivLine);

        EXIT(AvailableQtyBase + LineReservedQty + QtyReservedOnPickShip);
    end;

    local procedure CalcPickQtyAssigned(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; UOMCode: Code[10]; BinCode: Code[20]; var TempWhseItemTrkgLine: Record "Whse. Item Tracking Line") PickQtyAssigned: Decimal
    var
        TempWhseActivLine2: Record "Warehouse Activity Line" temporary;
    begin
        TempWhseActivLine2.COPY(TempWhseActivLine);
        WITH TempWhseActivLine DO BEGIN
            RESET;
            SETCURRENTKEY(
              "Item No.", "Bin Code", "Location Code", "Action Type", "Variant Code",
              "Unit of Measure Code", "Breakbulk No.", "Activity Type", "Lot No.", "Serial No.");
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Location Code", LocationCode);
            IF Location."Bin Mandatory" THEN BEGIN
                SETRANGE("Action Type", "Action Type"::Take);
                IF BinCode <> '' THEN
                    SETRANGE("Bin Code", BinCode)
                ELSE
                    SETFILTER("Bin Code", '<>%1', '');
            END ELSE BEGIN
                SETRANGE("Action Type", "Action Type"::" ");
                SETRANGE("Bin Code", '');
            END;
            SETRANGE("Variant Code", VariantCode);
            IF UOMCode <> '' THEN
                SETRANGE("Unit of Measure Code", UOMCode);
            SETRANGE("Activity Type", "Activity Type");
            SETRANGE("Breakbulk No.", 0);
            IF WhseItemTrkgExists THEN BEGIN
                IF TempWhseItemTrkgLine."Lot No." <> '' THEN
                    SETRANGE("Lot No.", TempWhseItemTrkgLine."Lot No.");
                IF TempWhseItemTrkgLine."Serial No." <> '' THEN
                    SETRANGE("Serial No.", TempWhseItemTrkgLine."Serial No.");
            END;
            CALCSUMS("Qty. Outstanding (Base)");
            PickQtyAssigned := "Qty. Outstanding (Base)";
        END;
        TempWhseActivLine.COPY(TempWhseActivLine2);
        EXIT(PickQtyAssigned);
    end;

    local procedure CalcQtyAssignedToPick(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10]; LotNo: Code[20]; LNRequired: Boolean; SerialNo: Code[20]; SNRequired: Boolean): Decimal
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WITH WhseActivLine DO BEGIN
            RESET;
            SETCURRENTKEY(
              "Item No.", "Location Code", "Activity Type", "Bin Type Code",
              "Unit of Measure Code", "Variant Code", "Breakbulk No.", "Action Type");

            SETRANGE("Item No.", ItemNo);
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Activity Type", "Activity Type"::Pick);
            SETRANGE("Variant Code", VariantCode);
            SETRANGE("Breakbulk No.", 0);
            SETFILTER("Action Type", '%1|%2', "Action Type"::" ", "Action Type"::Take);
            IF LotNo <> '' THEN
                IF LNRequired THEN
                    SETRANGE("Lot No.", LotNo)
                ELSE
                    SETFILTER("Lot No.", '%1|%2', LotNo, '');
            IF SerialNo <> '' THEN
                IF SNRequired THEN
                    SETRANGE("Serial No.", SerialNo)
                ELSE
                    SETFILTER("Serial No.", '%1|%2', SerialNo, '');
            CALCSUMS("Qty. Outstanding (Base)");

            EXIT("Qty. Outstanding (Base)" + CalcBreakbulkOutstdQty(WhseActivLine, LNRequired, SNRequired));
        END;
    end;

    local procedure UseForPick(FromBinContent: Record "Bin Content"): Boolean
    begin
        WITH FromBinContent DO BEGIN
            IF "Block Movement" IN ["Block Movement"::Outbound, "Block Movement"::All] THEN
                EXIT(FALSE);

            GetBinType("Bin Type Code");
            EXIT(BinType.Pick);
        END;
    end;

    local procedure UseForReplenishment(FromBinContent: Record "Bin Content"): Boolean
    begin
        WITH FromBinContent DO BEGIN
            IF "Block Movement" IN ["Block Movement"::Outbound, "Block Movement"::All] THEN
                EXIT(FALSE);

            GetBinType("Bin Type Code");
            EXIT(NOT (BinType.Receive OR BinType.Ship));
        END;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        IF LocationCode = '' THEN
            Location := WhseSetupLocation
        ELSE
            IF Location.Code <> LocationCode THEN
                Location.GET(LocationCode);
    end;

    local procedure GetBinType(BinTypeCode: Code[10])
    begin
        IF BinTypeCode = '' THEN
            BinType.INIT
        ELSE
            IF BinType.Code <> BinTypeCode THEN
                BinType.GET(BinTypeCode);
    end;

    local procedure GetBin(LocationCode: Code[10]; BinCode: Code[20])
    begin
        IF (Bin."Location Code" <> LocationCode) OR
           (Bin.Code <> BinCode)
        THEN
            IF NOT Bin.GET(LocationCode, BinCode) THEN
                CLEAR(Bin);
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        IF Item."No." <> ItemNo THEN
            Item.GET(ItemNo);
    end;

    local procedure GetSKU(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    begin
        IF (SKU."Location Code" <> LocationCode) OR
           (SKU."Item No." <> ItemNo) OR
           (SKU."Variant Code" <> VariantCode)
        THEN
            IF NOT SKU.GET(LocationCode, ItemNo, VariantCode) THEN BEGIN
                CLEAR(SKU);
                EXIT(FALSE)
            END;
        EXIT(TRUE);
    end;

    procedure SetValues(AssignedID2: Code[50]; WhseDocument2: Option "Pick Worksheet",Shipment,"Movement Worksheet","Internal Pick",Production,Assembly; SortPick2: Option " ",Item,Document,"Shelf/Bin No.","Due Date","Ship-To","Bin Ranking","Action Type"; WhseDocType2: Option "Put-away",Pick,Movement; MaxNoOfSourceDoc2: Integer; MaxNoOfLines2: Integer; PerZone2: Boolean; DoNotFillQtytoHandle2: Boolean; BreakbulkFilter2: Boolean; PerBin2: Boolean)
    begin
        WhseSource := WhseDocument2;
        AssignedID := AssignedID2;
        SortPick := SortPick2;
        WhseDocType := WhseDocType2;
        PerBin := PerBin2;
        IF PerBin THEN
            PerZone := FALSE
        ELSE
            PerZone := PerZone2;
        DoNotFillQtytoHandle := DoNotFillQtytoHandle2;
        MaxNoOfSourceDoc := MaxNoOfSourceDoc2;
        MaxNoOfLines := MaxNoOfLines2;
        BreakbulkFilter := BreakbulkFilter2;
        WhseSetup.GET;
        WhseSetupLocation.GetLocationSetup('', WhseSetupLocation);
        CLEAR(TempWhseActivLine);
        LastWhseItemTrkgLineNo := 0;
    end;

    procedure SetWhseWkshLine(WhseWkshLine2: Record "Whse. Worksheet Line"; TempNo2: Integer)
    begin
        WhseWkshLine := WhseWkshLine2;
        TempNo := TempNo2;
        SetSource(
          WhseWkshLine2."Source Type",
          WhseWkshLine2."Source Subtype",
          WhseWkshLine2."Source No.",
          WhseWkshLine2."Source Line No.",
          WhseWkshLine2."Source Subline No.");
    end;

    procedure SetWhseShipment(WhseShptLine2: Record "Warehouse Shipment Line"; TempNo2: Integer; ShippingAgentCode2: Code[10]; ShippingAgentServiceCode2: Code[10]; ShipmentMethodCode2: Code[10])
    begin
        WhseShptLine := WhseShptLine2;
        TempNo := TempNo2;
        ShippingAgentCode := ShippingAgentCode2;
        ShippingAgentServiceCode := ShippingAgentServiceCode2;
        ShipmentMethodCode := ShipmentMethodCode2;
        SetSource(
          WhseShptLine2."Source Type",
          WhseShptLine2."Source Subtype",
          WhseShptLine2."Source No.",
          WhseShptLine2."Source Line No.",
          0);
    end;

    procedure SetWhseInternalPickLine(WhseInternalPickLine2: Record "Whse. Internal Pick Line"; TempNo2: Integer)
    begin
        WhseInternalPickLine := WhseInternalPickLine2;
        TempNo := TempNo2;
    end;

    procedure SetProdOrderCompLine(ProdOrderCompLine2: Record "Prod. Order Component"; TempNo2: Integer)
    begin
        ProdOrderCompLine := ProdOrderCompLine2;
        TempNo := TempNo2;
        SetSource(
          DATABASE::"Prod. Order Component",
          ProdOrderCompLine2.Status,
          ProdOrderCompLine2."Prod. Order No.",
          ProdOrderCompLine2."Prod. Order Line No.",
          ProdOrderCompLine2."Line No.");
    end;

    procedure SetAssemblyLine(AssemblyLine2: Record "Assembly Line"; TempNo2: Integer)
    begin
        AssemblyLine := AssemblyLine2;
        TempNo := TempNo2;
        SetSource(
          DATABASE::"Assembly Line",
          AssemblyLine2."Document Type",
          AssemblyLine2."Document No.",
          AssemblyLine2."Line No.",
          0);
    end;

    procedure SetTempWhseItemTrkgLine(SourceID: Code[20]; SourceType: Integer; SourceBatchName: Code[10]; SourceProdOrderLine: Integer; SourceRefNo: Integer; LocationCode: Code[10])
    var
        WhseItemTrkgLine: Record "Whse. Item Tracking Line";
    begin
        TempWhseItemTrkgLine.DELETEALL;
        TempWhseItemTrkgLine.INIT;
        WhseItemTrkgLineCount := 0;
        WhseItemTrkgExists := FALSE;
        WhseItemTrkgLine.RESET;
        WhseItemTrkgLine.SETCURRENTKEY(
          "Source ID", "Source Type", "Source Subtype", "Source Batch Name",
          "Source Prod. Order Line", "Source Ref. No.", "Location Code");
        WhseItemTrkgLine.SETRANGE("Source ID", SourceID);
        WhseItemTrkgLine.SETRANGE("Source Type", SourceType);
        WhseItemTrkgLine.SETRANGE("Source Batch Name", SourceBatchName);
        WhseItemTrkgLine.SETRANGE("Source Prod. Order Line", SourceProdOrderLine);
        WhseItemTrkgLine.SETRANGE("Source Ref. No.", SourceRefNo);
        WhseItemTrkgLine.SETRANGE("Location Code", LocationCode);
        IF WhseItemTrkgLine.FIND('-') THEN
            REPEAT
                IF WhseItemTrkgLine."Qty. to Handle (Base)" > 0 THEN BEGIN
                    TempWhseItemTrkgLine := WhseItemTrkgLine;
                    TempWhseItemTrkgLine."Entry No." := LastWhseItemTrkgLineNo + 1;
                    TempWhseItemTrkgLine.INSERT;
                    LastWhseItemTrkgLineNo := TempWhseItemTrkgLine."Entry No.";
                    WhseItemTrkgExists := TRUE;
                    WhseItemTrkgLineCount += 1;
                END;
            UNTIL WhseItemTrkgLine.NEXT = 0;

        SourceTempItemTrkgLine.INIT;
        SourceTempItemTrkgLine."Source Type" := SourceType;
        SourceTempItemTrkgLine."Source ID" := SourceID;
        SourceTempItemTrkgLine."Source Batch Name" := SourceBatchName;
        SourceTempItemTrkgLine."Source Prod. Order Line" := SourceProdOrderLine;
        SourceTempItemTrkgLine."Source Ref. No." := SourceRefNo;
    end;

    local procedure SaveTempItemTrkgLines()
    var
        i: Integer;
    begin
        IF WhseItemTrkgLineCount = 0 THEN
            EXIT;

        i := 0;
        TempWhseItemTrkgLine.RESET;
        IF TempWhseItemTrkgLine.FIND('-') THEN
            REPEAT
                TotalTempItemTrkgLine := TempWhseItemTrkgLine;
                TotalTempItemTrkgLine.INSERT;
                i += 1;
            UNTIL (TempWhseItemTrkgLine.NEXT = 0) OR (i = WhseItemTrkgLineCount);
    end;

    procedure ReturnTempItemTrkgLines(var TempWhseItemTrkgLine2: Record "Whse. Item Tracking Line")
    begin
        IF TotalTempItemTrkgLine.FIND('-') THEN
            REPEAT
                TempWhseItemTrkgLine2 := TotalTempItemTrkgLine;
                TempWhseItemTrkgLine2.INSERT;
            UNTIL TotalTempItemTrkgLine.NEXT = 0;
    end;

    // local procedure CreateTempItemTrkgLines(ItemNo: Code[20]; VariantCode: Code[10]; TotalQtytoPickBase: Decimal; HasExpiryDate: Boolean)
    // var
    //     EntrySummary: Record 338;
    //     EntrySummary2: Record 338;
    //     ItemTrackingDataCollection: Codeunit 6501;
    //     TotalAvailQtyToPickBase: Decimal;
    //     RemQtyToPickBase: Decimal;
    //     QtyToPickBase: Decimal;
    //     QtyTracked: Decimal;
    //     FromBinContentQty: Decimal;
    // begin
    //     IF NOT HasExpiryDate THEN
    //         IF TotalQtytoPickBase <= 0 THEN
    //             EXIT;

    //     ItemTrackingDataCollection.SetSource(SourceType, SourceSubType, SourceNo, SourceLineNo, SourceSubLineNo);
    //     ItemTrackingDataCollection.CreateEntrySummaryFEFO(Location, ItemNo, VariantCode, HasExpiryDate);

    //     RemQtyToPickBase := TotalQtytoPickBase;
    //     IF HasExpiryDate THEN
    //         TransferRemQtyToPickBase := TotalQtytoPickBase;
    //     IF ItemTrackingDataCollection.FindFirstEntrySummaryFEFO(EntrySummary) THEN BEGIN
    //         ReqFEFOPick := TRUE;
    //         REPEAT
    //             IF ((EntrySummary."Expiration Date" <> 0D) AND HasExpiryDate) OR
    //                ((EntrySummary."Expiration Date" = 0D) AND (NOT HasExpiryDate))
    //             THEN BEGIN
    //                 QtyTracked := ItemTrackedQuantity(EntrySummary."Lot No.", EntrySummary."Serial No.");

    //                 IF NOT ((EntrySummary."Serial No." <> '') AND (QtyTracked > 0)) THEN BEGIN
    //                     TotalAvailQtyToPickBase :=
    //                       CalcTotalAvailQtyToPick(
    //                         Location.Code, ItemNo, VariantCode,
    //                         EntrySummary."Lot No.", EntrySummary."Serial No.",
    //                         SourceType, SourceSubType, SourceNo, SourceLineNo, SourceSubLineNo, 0, HasExpiryDate);

    //                     IF CalledFromWksh AND (WhseWkshLine."From Bin Code" <> '') THEN BEGIN
    //                         FromBinContentQty := 0;
    //                         FromBinContentQty :=
    //                           GetFromBinContentQty(
    //                             WhseWkshLine."Location Code", WhseWkshLine."From Bin Code", WhseWkshLine."Item No.",
    //                             WhseWkshLine."Variant Code", WhseWkshLine."From Unit of Measure Code",
    //                             EntrySummary."Lot No.", EntrySummary."Serial No.");
    //                         IF TotalAvailQtyToPickBase > FromBinContentQty THEN
    //                             TotalAvailQtyToPickBase := FromBinContentQty;
    //                     END;

    //                     TotalAvailQtyToPickBase := TotalAvailQtyToPickBase - QtyTracked;
    //                     QtyToPickBase := 0;

    //                     IF TotalAvailQtyToPickBase > 0 THEN
    //                         IF TotalAvailQtyToPickBase >= RemQtyToPickBase THEN BEGIN
    //                             QtyToPickBase := RemQtyToPickBase;
    //                             RemQtyToPickBase := 0
    //                         END ELSE BEGIN
    //                             QtyToPickBase := TotalAvailQtyToPickBase;
    //                             RemQtyToPickBase := RemQtyToPickBase - QtyToPickBase;
    //                         END;

    //                     IF QtyToPickBase > 0 THEN
    //                         InsertTempItemTrkgLine(Location.Code, ItemNo, VariantCode, EntrySummary, QtyToPickBase);
    //                 END;
    //             END;
    //         UNTIL NOT ItemTrackingDataCollection.FindNextEntrySummaryFEFO(EntrySummary) OR (RemQtyToPickBase = 0);
    //         IF HasExpiryDate THEN
    //             TransferRemQtyToPickBase := RemQtyToPickBase;
    //     END;
    //     IF NOT HasExpiryDate THEN
    //         IF RemQtyToPickBase > 0 THEN
    //             IF Location."Always Create Pick Line" THEN BEGIN
    //                 CLEAR(EntrySummary2);
    //                 InsertTempItemTrkgLine(Location.Code, ItemNo, VariantCode, EntrySummary2, RemQtyToPickBase);
    //             END;
    //     IF NOT HasExpiredItems THEN BEGIN
    //         HasExpiredItems := ItemTrackingDataCollection.GetHasExpiredItems;
    //         ExpiredItemMessageText := ItemTrackingDataCollection.GetResultMessageForExpiredItem;
    //     END;
    // end;

    local procedure ItemTrackedQuantity(LotNo: Code[20]; SerialNo: Code[20]): Decimal
    begin
        WITH TempWhseItemTrkgLine DO BEGIN
            RESET;
            IF (LotNo = '') AND (SerialNo = '') THEN
                IF ISEMPTY THEN
                    EXIT(0);

            IF SerialNo <> '' THEN BEGIN
                SETCURRENTKEY("Serial No.", "Lot No.");
                SETRANGE("Serial No.", SerialNo);
                IF ISEMPTY THEN
                    EXIT(0);

                EXIT(1);
            END;

            IF LotNo <> '' THEN BEGIN
                SETCURRENTKEY("Serial No.", "Lot No.");
                SETRANGE("Lot No.", LotNo);
                IF ISEMPTY THEN
                    EXIT(0);
            END;

            SETCURRENTKEY(
              "Source ID", "Source Type", "Source Subtype", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.", "Location Code");
            IF LotNo <> '' THEN
                SETRANGE("Lot No.", LotNo);
            CALCSUMS("Qty. to Handle (Base)");
            EXIT("Qty. to Handle (Base)");
        END;
    end;

    local procedure InsertTempItemTrkgLine(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; EntrySummary: Record "Entry Summary"; QuantityBase: Decimal)
    begin
        WITH TempWhseItemTrkgLine DO BEGIN
            INIT;
            "Entry No." := LastWhseItemTrkgLineNo + 1;
            "Location Code" := LocationCode;
            "Item No." := ItemNo;
            "Variant Code" := VariantCode;
            "Lot No." := EntrySummary."Lot No.";
            "Serial No." := EntrySummary."Serial No.";
            "Expiration Date" := EntrySummary."Expiration Date";
            "Source ID" := SourceTempItemTrkgLine."Source ID";
            "Source Type" := SourceTempItemTrkgLine."Source Type";
            "Source Batch Name" := SourceTempItemTrkgLine."Source Batch Name";
            "Source Prod. Order Line" := SourceTempItemTrkgLine."Source Prod. Order Line";
            "Source Ref. No." := SourceTempItemTrkgLine."Source Ref. No.";
            VALIDATE("Quantity (Base)", QuantityBase);
            INSERT;
            LastWhseItemTrkgLineNo := "Entry No.";
            WhseItemTrkgExists := TRUE;
        END;
    end;

    local procedure TransferItemTrkgFields(var WhseActivLine2: Record "Warehouse Activity Line"; TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary)
    var
        EntriesExist: Boolean;
    begin
        IF WhseItemTrkgExists THEN BEGIN
            IF TempWhseItemTrkgLine."Serial No." <> '' THEN
                TempWhseItemTrkgLine.TESTFIELD("Qty. per Unit of Measure", 1);
            WhseActivLine2."Serial No." := TempWhseItemTrkgLine."Serial No.";
            WhseActivLine2."Lot No." := TempWhseItemTrkgLine."Lot No.";
            WhseActivLine2."Warranty Date" := TempWhseItemTrkgLine."Warranty Date";
            IF TempWhseItemTrkgLine.TrackingExists THEN
                WhseActivLine2."Expiration Date" :=
                  ItemTrackingMgt.ExistingExpirationDate(
                    TempWhseItemTrkgLine."Item No.", TempWhseItemTrkgLine."Variant Code",
                    TempWhseItemTrkgLine."Lot No.", TempWhseItemTrkgLine."Serial No.",
                    FALSE, EntriesExist);
        END ELSE
            IF SNRequired THEN
                WhseActivLine2.TESTFIELD("Qty. per Unit of Measure", 1);
    end;

    procedure SetSource(SourceType2: Integer; SourceSubType2: Option "0","1","2","3","4","5","6","7","8","9","10"; SourceNo2: Code[20]; SourceLineNo2: Integer; SourceSubLineNo2: Integer)
    begin
        SourceType := SourceType2;
        SourceSubType := SourceSubType2;
        SourceNo := SourceNo2;
        SourceLineNo := SourceLineNo2;
        SourceSubLineNo := SourceSubLineNo2;
    end;

    procedure CheckReservation(QtyBaseAvailToPick: Decimal; LocationCode: Code[10]; SourceType: Integer; SourceSubType: Option "0","1","2","3","4","5","6","7","8","9","10"; SourceNo: Code[20]; SourceLineNo: Integer; SourceSubLineNo: Integer; QtyPerUnitOfMeasure: Decimal; var Quantity: Decimal; var QuantityBase: Decimal)
    var
        ReservEntry: Record "Reservation Entry";
        WhseManagement: Codeunit "Whse. Management";
        Quantity2: Decimal;
        QuantityBase2: Decimal;
        QtyBaseResvdNotOnILE: Decimal;
        QtyResvdNotOnILE: Decimal;
        SrcDocQtyBaseToBeFilledByInvt: Decimal;
        SrcDocQtyToBeFilledByInvt: Decimal;
    begin
        ReservationExists := FALSE;
        ReservedForItemLedgEntry := FALSE;
        Quantity2 := Quantity;
        QuantityBase2 := QuantityBase;

        SetFiltersOnReservEntry(ReservEntry, SourceType, SourceSubType, SourceNo, SourceLineNo, SourceSubLineNo);
        IF ReservEntry.FIND('-') THEN BEGIN
            ReservationExists := TRUE;
            REPEAT
                QtyResvdNotOnILE += CalcQtyResvdNotOnILE(ReservEntry."Entry No.", ReservEntry.Positive);
            UNTIL ReservEntry.NEXT = 0;
            QtyBaseResvdNotOnILE := QtyResvdNotOnILE;
            QtyResvdNotOnILE := ROUND(QtyResvdNotOnILE / QtyPerUnitOfMeasure, 0.00001);

            WhseManagement.GetOutboundDocLineQtyOtsdg(SourceType, SourceSubType,
              SourceNo, SourceLineNo, SourceSubLineNo, SrcDocQtyToBeFilledByInvt, SrcDocQtyBaseToBeFilledByInvt);
            SrcDocQtyBaseToBeFilledByInvt := SrcDocQtyBaseToBeFilledByInvt - QtyBaseResvdNotOnILE;
            SrcDocQtyToBeFilledByInvt := SrcDocQtyToBeFilledByInvt - QtyResvdNotOnILE;

            IF QuantityBase > SrcDocQtyBaseToBeFilledByInvt THEN BEGIN
                QuantityBase := SrcDocQtyBaseToBeFilledByInvt;
                Quantity := SrcDocQtyToBeFilledByInvt;
            END;

            IF QuantityBase <= SrcDocQtyBaseToBeFilledByInvt THEN
                IF QuantityBase > QtyBaseAvailToPick THEN BEGIN
                    QuantityBase := QtyBaseAvailToPick;
                    Quantity := ROUND(QtyBaseAvailToPick / QtyPerUnitOfMeasure, 0.00001);
                END;

            IF QuantityBase = 0 THEN BEGIN
                GetLocation(LocationCode);
                IF Location."Always Create Pick Line" THEN BEGIN
                    Quantity := Quantity2;
                    QuantityBase := QuantityBase2;
                END;
            END ELSE
                ReservedForItemLedgEntry := TRUE;
        END ELSE
            ReservationExists := FALSE;
    end;

    procedure CalcTotalAvailQtyToPick(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[20]; SerialNo: Code[20]; SourceType: Integer; SourceSubType: Option "0","1","2","3","4","5","6","7","8","9","10"; SourceNo: Code[20]; SourceLineNo: Integer; SourceSubLineNo: Integer; NeededQtyBase: Decimal; RespectLocationBins: Boolean): Decimal
    var
        WhseEntry: Record "Warehouse Entry";
        WhseActivLine: Record "Warehouse Activity Line";
        TempWhseItemTrkgLine2: Record "Whse. Item Tracking Line";
        TotalAvailQtyBase: Decimal;
        QtyInWhse: Decimal;
        QtyOnPickBins: Decimal;
        QtyOnPutAwayBins: Decimal;
        QtyOnOutboundBins: Decimal;
        QtyOnReceiveBins: Decimal;
        QtyOnDedicatedBins: Decimal;
        QtyBlocked: Decimal;
        SubTotal: Decimal;
        QtyReservedOnPickShip: Decimal;
        LineReservedQty: Decimal;
        QtyAssignedPick: Decimal;
        QtyAssignedToPick: Decimal;
        AvailableAfterReshuffle: Decimal;
        QtyOnToBinsBase: Decimal;
        ReservedQtyOnInventory: Decimal;
        ResetWhseItemTrkgExists: Boolean;
        BinTypeFilter: Text[1024];
    begin
        // Directed put-away and pick
        GetLocation(LocationCode);

        ItemTrackingMgt.CheckWhseItemTrkgSetup(ItemNo, SNRequired, LNRequired, FALSE);
        ReservedQtyOnInventory :=
          CalcReservedQtyOnInventory(ItemNo, LocationCode, VariantCode, LotNo, LNRequired, SerialNo, SNRequired);
        QtyAssignedToPick := CalcQtyAssignedToPick(ItemNo, LocationCode, VariantCode, LotNo, LNRequired, SerialNo, SNRequired);

        WITH WhseEntry DO BEGIN
            RESET;
            SETCURRENTKEY("Item No.", "Location Code", "Variant Code", "Bin Type Code");
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Variant Code", VariantCode);
            IF LotNo <> '' THEN
                IF LNRequired THEN
                    SETRANGE("Lot No.", LotNo)
                ELSE
                    SETFILTER("Lot No.", '%1|%2', LotNo, '');
            IF SerialNo <> '' THEN
                IF SNRequired THEN
                    SETRANGE("Serial No.", SerialNo)
                ELSE
                    SETFILTER("Serial No.", '%1|%2', SerialNo, '');
            CALCSUMS("Qty. (Base)");
            QtyInWhse := "Qty. (Base)";

            BinTypeFilter := GetBinTypeFilter(0);
            IF BinTypeFilter <> '' THEN BEGIN
                IF RespectLocationBins AND (Location."Receipt Bin Code" <> '') THEN BEGIN
                    SETRANGE("Bin Code", Location."Receipt Bin Code");
                    CALCSUMS("Qty. (Base)");
                    QtyOnReceiveBins := "Qty. (Base)";
                    SETFILTER("Bin Code", '<>%1', Location."Receipt Bin Code");
                END;
                SETFILTER("Bin Type Code", BinTypeFilter); // Receive
                CALCSUMS("Qty. (Base)");
                QtyOnReceiveBins += "Qty. (Base)";

                SETFILTER("Bin Type Code", '<>%1', BinTypeFilter); // Pick from all but Receive area
            END;
            CALCSUMS("Qty. (Base)");
            QtyOnPickBins := "Qty. (Base)";
            SETRANGE("Bin Code");

            IF CalledFromMoveWksh THEN BEGIN
                BinTypeFilter := GetBinTypeFilter(4);
                IF BinTypeFilter <> '' THEN BEGIN
                    SETFILTER("Bin Type Code", BinTypeFilter); // Put-Away only
                    CALCSUMS("Qty. (Base)");
                    QtyOnPutAwayBins := "Qty. (Base)";
                END;
            END;

            QtyOnOutboundBins :=
              CalcQtyOnOutboundBins(
                LocationCode, ItemNo, VariantCode, LotNo, SerialNo, TRUE);

            QtyOnDedicatedBins := WhseAvailMgt.CalcQtyOnDedicatedBins(LocationCode, ItemNo, VariantCode, LotNo, SerialNo);

            IF NOT IsShipZone(WhseWkshLine."Location Code", WhseWkshLine."To Zone Code") THEN BEGIN
                SETCURRENTKEY("Item No.", "Bin Code", "Location Code", "Variant Code");
                SETRANGE("Bin Type Code");
                SETRANGE("Bin Code", WhseWkshLine."To Bin Code");
                CALCSUMS("Qty. (Base)");
                QtyOnToBinsBase := "Qty. (Base)";
            END;
        END;

        QtyBlocked :=
          WhseAvailMgt.CalcQtyOnBlockedITOrOnBlockedOutbndBins(
            LocationCode, ItemNo, VariantCode, LotNo, SerialNo, LNRequired, SNRequired);

        TempWhseItemTrkgLine2.COPY(TempWhseItemTrkgLine);
        IF ReqFEFOPick THEN BEGIN
            TempWhseItemTrkgLine2."Entry No." := TempWhseItemTrkgLine2."Entry No." + 1;
            TempWhseItemTrkgLine2."Lot No." := LotNo;
            TempWhseItemTrkgLine2."Serial No." := SerialNo;
            IF NOT WhseItemTrkgExists THEN BEGIN
                WhseItemTrkgExists := TRUE;
                ResetWhseItemTrkgExists := TRUE;
            END;
        END;

        QtyAssignedPick := CalcPickQtyAssigned(LocationCode, ItemNo, VariantCode, '', '', TempWhseItemTrkgLine2);

        IF ResetWhseItemTrkgExists THEN BEGIN
            WhseItemTrkgExists := FALSE;
            ResetWhseItemTrkgExists := FALSE;
        END;

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
            IF LotNo <> '' THEN
                IF LNRequired THEN
                    WhseActivLine.SETRANGE("Lot No.", LotNo)
                ELSE
                    WhseActivLine.SETFILTER("Lot No.", '%1|%2', LotNo, '');
            IF SerialNo <> '' THEN
                IF SNRequired THEN
                    WhseActivLine.SETRANGE("Serial No.", SerialNo)
                ELSE
                    WhseActivLine.SETFILTER("Serial No.", '%1|%2', SerialNo, '');
            WhseActivLine.SETRANGE("Breakbulk No.", 0);
            WhseActivLine.SETRANGE("Activity Type", WhseActivLine."Activity Type"::Pick);
            WhseActivLine.CALCSUMS("Qty. Outstanding (Base)");
            QtyAssignedPick := QtyAssignedPick - WhseActivLine."Qty. Outstanding (Base)";
        END;

        SubTotal :=
          QtyInWhse - QtyOnPickBins - QtyOnPutAwayBins - QtyOnOutboundBins - QtyOnDedicatedBins - QtyBlocked -
          QtyOnReceiveBins - ABS(ReservedQtyOnInventory);

        IF (SubTotal < 0) OR CalledFromPickWksh OR CalledFromMoveWksh THEN BEGIN
            QtyReservedOnPickShip :=
              WhseAvailMgt.CalcReservQtyOnPicksShips(
                LocationCode, ItemNo, VariantCode, TempWhseActivLine);

            LineReservedQty :=
              WhseAvailMgt.CalcLineReservedQtyOnInvt(
                SourceType, SourceSubType, SourceNo, SourceLineNo, SourceSubLineNo, TRUE, '', '', TempWhseActivLine);

            IF SubTotal < 0 THEN
                IF ABS(SubTotal) < QtyReservedOnPickShip + LineReservedQty THEN
                    QtyReservedOnPickShip := ABS(SubTotal) - LineReservedQty;

            CASE TRUE OF
                CalledFromPickWksh:
                    BEGIN
                        TotalAvailQtyBase :=
                          QtyOnPickBins - QtyAssignedToPick - ABS(ReservedQtyOnInventory) +
                          QtyReservedOnPickShip + LineReservedQty;
                        MovementFromShipZone(TotalAvailQtyBase, QtyOnOutboundBins + QtyBlocked);
                    END;
                CalledFromMoveWksh:
                    BEGIN
                        TotalAvailQtyBase :=
                          QtyOnPickBins + QtyOnPutAwayBins - QtyAssignedToPick - ABS(ReservedQtyOnInventory) +
                          QtyReservedOnPickShip + LineReservedQty;
                        IF CalledFromWksh THEN
                            TotalAvailQtyBase := TotalAvailQtyBase - QtyAssignedPick - QtyOnPutAwayBins;
                        MovementFromShipZone(TotalAvailQtyBase, QtyOnOutboundBins + QtyBlocked);
                    END;
                ELSE
                    TotalAvailQtyBase :=
                      QtyOnPickBins -
                      QtyAssignedPick - QtyAssignedToPick +
                      SubTotal +
                      QtyReservedOnPickShip +
                      LineReservedQty;
            END
        END ELSE
            TotalAvailQtyBase := QtyOnPickBins - QtyAssignedPick - QtyAssignedToPick;

        IF (NeededQtyBase <> 0) AND (NeededQtyBase > TotalAvailQtyBase) THEN
            IF ReleaseNonSpecificReservations(
                 LocationCode, ItemNo, VariantCode, LotNo, SerialNo, NeededQtyBase - TotalAvailQtyBase)
            THEN BEGIN
                AvailableAfterReshuffle :=
                  CalcTotalAvailQtyToPick(
                    LocationCode, ItemNo, VariantCode,
                    TempWhseItemTrkgLine."Lot No.", TempWhseItemTrkgLine."Serial No.",
                    SourceType, SourceSubType, SourceNo, SourceLineNo, SourceSubLineNo, 0, FALSE);
                EXIT(AvailableAfterReshuffle);
            END;

        EXIT(TotalAvailQtyBase - QtyOnToBinsBase);
    end;

    procedure CalcQtyOnOutboundBins(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[20]; SerialNo: Code[20]; ExcludeDedicatedBinContent: Boolean) QtyOnOutboundBins: Decimal
    var
        WhseEntry: Record "Warehouse Entry";
        WhseShptLine: Record "Warehouse Shipment Line";
        OutBoundFilter: Text[1024];
    begin
        // Directed put-away and pick
        GetLocation(LocationCode);

        IF Location."Directed Put-away and Pick" THEN
            WITH WhseEntry DO BEGIN
                FilterWhseEntry(WhseEntry, ItemNo, LocationCode, VariantCode, LotNo, SerialNo, ExcludeDedicatedBinContent);
                SETFILTER("Bin Type Code", GetBinTypeFilter(1)); // Shipping area
                CALCSUMS("Qty. (Base)");
                QtyOnOutboundBins := "Qty. (Base)";
                OutBoundFilter := SetOutBoundFilter(Location);
                IF OutBoundFilter <> '' THEN BEGIN
                    SETRANGE("Bin Type Code");
                    SETFILTER("Bin Code", OutBoundFilter);
                    CALCSUMS("Qty. (Base)");
                    QtyOnOutboundBins += "Qty. (Base)";
                END
            END
        ELSE
            IF Location."Require Pick" THEN
                IF Location."Bin Mandatory" AND ((LotNo <> '') OR (SerialNo <> '')) THEN BEGIN
                    FilterWhseEntry(WhseEntry, ItemNo, LocationCode, VariantCode, LotNo, SerialNo, FALSE);
                    WITH WhseEntry DO BEGIN
                        SETRANGE("Whse. Document Type", "Whse. Document Type"::Shipment);
                        SETRANGE("Reference Document", "Reference Document"::Pick);
                        SETFILTER("Qty. (Base)", '>%1', 0);
                        QtyOnOutboundBins := CalcResidualPickedQty(WhseEntry);
                    END
                END ELSE
                    WITH WhseShptLine DO BEGIN
                        SETRANGE("Item No.", ItemNo);
                        SETRANGE("Location Code", LocationCode);
                        SETRANGE("Variant Code", VariantCode);
                        CALCSUMS("Qty. Picked (Base)", "Qty. Shipped (Base)");
                        QtyOnOutboundBins := "Qty. Picked (Base)" - "Qty. Shipped (Base)";
                    END;
    end;

    procedure GetBinTypeFilter(Type: Option Receive,Ship,"Put Away",Pick,"Put Away only"): Text[1024]
    var
        BinType: Record "Bin Type";
        "Filter": Text[1024];
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
                Type::"Put Away only":
                    BEGIN
                        SETRANGE("Put Away", TRUE);
                        SETRANGE(Pick, FALSE);
                    END;
            END;
            IF FIND('-') THEN
                REPEAT
                    Filter := STRSUBSTNO('%1|%2', Filter, Code);
                UNTIL NEXT = 0;
            IF Filter <> '' THEN
                Filter := COPYSTR(Filter, 2);
        END;
        EXIT(Filter);
    end;

    local procedure SetOutBoundFilter(Location2: Record Location): Text[1024]
    var
        "Filter": Text[1024];
    begin
        WITH Location2 DO BEGIN
            IF "Adjustment Bin Code" <> '' THEN
                IF Filter <> '' THEN
                    Filter := STRSUBSTNO('%1|%2', Filter, "Adjustment Bin Code")
                ELSE
                    Filter := "Adjustment Bin Code";
        END;
        EXIT(Filter);
    end;

    procedure CheckOutBound(SourceType: Integer; SourceSubType: Option "0","1","2","3","4","5","6","7","8","9","10"; SourceNo: Code[20]; SourceLineNo: Integer; SourceSubLineNo: Integer): Decimal
    var
        WhseShipLine: Record "Warehouse Shipment Line";
        WhseActLine: Record "Warehouse Activity Line";
        ProdOrderComp: Record "Prod. Order Component";
        AsmLine: Record "Assembly Line";
        OutBoundQty: Decimal;
    begin
        CASE SourceType OF
            DATABASE::"Sales Line", DATABASE::"Purchase Line", DATABASE::"Transfer Line":
                BEGIN
                    WhseShipLine.RESET;
                    WhseShipLine.SETCURRENTKEY(
                      "Source Type", "Source Subtype", "Source No.", "Source Line No.");
                    WhseShipLine.SETRANGE("Source Type", SourceType);
                    WhseShipLine.SETRANGE("Source Subtype", SourceSubType);
                    WhseShipLine.SETRANGE("Source No.", SourceNo);
                    WhseShipLine.SETRANGE("Source Line No.", SourceLineNo);
                    IF WhseShipLine.FINDFIRST THEN BEGIN
                        WhseShipLine.CALCFIELDS("Pick Qty. (Base)");
                        OutBoundQty := WhseShipLine."Pick Qty. (Base)" + WhseShipLine."Qty. Picked (Base)";
                    END ELSE BEGIN
                        WhseActLine.RESET;
                        WhseActLine.SETCURRENTKEY(
                          "Source Type", "Source Subtype", "Source No.", "Source Line No.");
                        WhseActLine.SETRANGE("Source Type", SourceType);
                        WhseActLine.SETRANGE("Source Subtype", SourceSubType);
                        WhseActLine.SETRANGE("Source No.", SourceNo);
                        WhseActLine.SETRANGE("Source Line No.", SourceLineNo);
                        IF WhseActLine.FINDFIRST THEN
                            OutBoundQty := WhseActLine."Qty. Outstanding (Base)"
                        ELSE
                            OutBoundQty := 0;
                    END;
                END;
            DATABASE::"Prod. Order Component":
                BEGIN
                    ProdOrderComp.RESET;
                    ProdOrderComp.SETRANGE(Status, SourceSubType);
                    ProdOrderComp.SETRANGE("Prod. Order No.", SourceNo);
                    ProdOrderComp.SETRANGE("Prod. Order Line No.", SourceSubLineNo);
                    ProdOrderComp.SETRANGE("Line No.", SourceLineNo);
                    IF ProdOrderComp.FINDFIRST THEN BEGIN
                        ProdOrderComp.CALCFIELDS("Pick Qty. (Base)");
                        OutBoundQty := ProdOrderComp."Pick Qty. (Base)" + ProdOrderComp."Qty. Picked (Base)";
                    END ELSE
                        OutBoundQty := 0;
                END;
            DATABASE::"Assembly Line":
                BEGIN
                    IF AsmLine.GET(SourceSubType, SourceNo, SourceLineNo) THEN BEGIN
                        AsmLine.CALCFIELDS("Pick Qty. (Base)");
                        OutBoundQty := AsmLine."Pick Qty. (Base)" + AsmLine."Qty. Picked (Base)";
                    END ELSE
                        OutBoundQty := 0;
                END;
        END;
        EXIT(OutBoundQty);
    end;

    procedure SetCrossDock(CrossDock2: Boolean)
    begin
        CrossDock := CrossDock2;
    end;

    procedure GetReservationStatus(var ReservationExists2: Boolean; var ReservedForItemLedgEntry2: Boolean)
    begin
        ReservationExists2 := ReservationExists;
        ReservedForItemLedgEntry2 := ReservedForItemLedgEntry;
    end;

    procedure SetCalledFromPickWksh(CalledFromPickWksh2: Boolean)
    begin
        CalledFromPickWksh := CalledFromPickWksh2;
    end;

    procedure SetCalledFromMoveWksh(CalledFromMoveWksh2: Boolean)
    begin
        CalledFromMoveWksh := CalledFromMoveWksh2;
    end;

    local procedure CalcQtyToPickBase(var BinContent: Record "Bin Content"): Decimal
    var
        WhseEntry: Record "Warehouse Entry";
        WhseActivLine: Record "Warehouse Activity Line";
        WhseJrnl: Record "Warehouse Journal Line";
        QtyPlaced: Decimal;
        QtyTaken: Decimal;
    begin
        WITH BinContent DO BEGIN
            WhseEntry.SETCURRENTKEY(
              "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.");
            WhseEntry.SETRANGE("Location Code", "Location Code");
            WhseEntry.SETRANGE("Bin Code", "Bin Code");
            WhseEntry.SETRANGE("Item No.", "Item No.");
            WhseEntry.SETRANGE("Variant Code", "Variant Code");
            WhseEntry.SETRANGE("Unit of Measure Code", "Unit of Measure Code");
            COPYFILTER("Serial No. Filter", WhseEntry."Serial No.");
            COPYFILTER("Lot No. Filter", WhseEntry."Lot No.");
            WhseEntry.CALCSUMS("Qty. (Base)");

            WhseActivLine.SETCURRENTKEY(
              "Item No.", "Bin Code", "Location Code",
              "Action Type", "Variant Code", "Unit of Measure Code", "Breakbulk No.", "Activity Type", "Lot No.", "Serial No.");
            WhseActivLine.SETRANGE("Location Code", "Location Code");
            WhseActivLine.SETRANGE("Action Type", WhseActivLine."Action Type"::Take);
            WhseActivLine.SETRANGE("Bin Code", "Bin Code");
            WhseActivLine.SETRANGE("Item No.", "Item No.");
            WhseActivLine.SETRANGE("Variant Code", "Variant Code");
            WhseActivLine.SETRANGE("Unit of Measure Code", "Unit of Measure Code");
            COPYFILTER("Lot No. Filter", WhseActivLine."Lot No.");
            COPYFILTER("Serial No. Filter", WhseActivLine."Serial No.");
            WhseActivLine.CALCSUMS("Qty. Outstanding (Base)");
            QtyTaken := WhseActivLine."Qty. Outstanding (Base)";

            TempWhseActivLine.COPY(WhseActivLine);
            TempWhseActivLine.CALCSUMS("Qty. Outstanding (Base)");
            QtyTaken += TempWhseActivLine."Qty. Outstanding (Base)";

            TempWhseActivLine.SETRANGE("Action Type", WhseActivLine."Action Type"::Place);
            TempWhseActivLine.CALCSUMS("Qty. Outstanding (Base)");
            QtyPlaced := TempWhseActivLine."Qty. Outstanding (Base)";

            TempWhseActivLine.RESET;

            WhseJrnl.SETCURRENTKEY(
              "Item No.", "From Bin Code", "Location Code", "Entry Type", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.");
            WhseJrnl.SETRANGE("Location Code", "Location Code");
            WhseJrnl.SETRANGE("From Bin Code", "Bin Code");
            WhseJrnl.SETRANGE("Item No.", "Item No.");
            WhseJrnl.SETRANGE("Variant Code", "Variant Code");
            WhseJrnl.SETRANGE("Unit of Measure Code", "Unit of Measure Code");
            COPYFILTER("Lot No. Filter", WhseJrnl."Lot No.");
            COPYFILTER("Serial No. Filter", WhseJrnl."Serial No.");
            WhseJrnl.CALCSUMS("Qty. (Absolute, Base)");

            EXIT(WhseEntry."Qty. (Base)" + WhseJrnl."Qty. (Absolute, Base)" + QtyPlaced - QtyTaken);
        END;
    end;

    local procedure PickAccordingToFEFO(LocationCode: Code[10]; ItemNo: Code[20]): Boolean
    begin
        GetLocation(LocationCode);
        EXIT(Location."Pick According to FEFO" AND (SNRequired OR LNRequired));
    end;

    local procedure UndefinedItemTrkg(var QtyToTrackBase: Decimal): Boolean
    begin
        QtyToTrackBase := QtyToTrackBase - ItemTrackedQuantity('', '');
        EXIT(QtyToTrackBase > 0);
    end;

    local procedure ReleaseNonSpecificReservations(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[20]; SerialNo: Code[20]; QtyToRelease: Decimal): Boolean
    var
        LateBindingMgt: Codeunit "Late Binding Management";
        xReservedQty: Decimal;
    begin
        IF QtyToRelease <= 0 THEN
            EXIT;

        IF LNRequired OR SNRequired THEN
            IF Item."Reserved Qty. on Inventory" > 0 THEN BEGIN
                xReservedQty := Item."Reserved Qty. on Inventory";
                LateBindingMgt.ReleaseForReservation(ItemNo, VariantCode, LocationCode, SerialNo, LotNo, QtyToRelease);
                Item.CALCFIELDS("Reserved Qty. on Inventory");
            END;

        EXIT(xReservedQty > Item."Reserved Qty. on Inventory");
    end;

    procedure SetCalledFromWksh(NewCalledFromWksh: Boolean)
    begin
        CalledFromWksh := NewCalledFromWksh;
    end;

    local procedure GetFromBinContentQty(LocCode: Code[10]; FromBinCode: Code[20]; ItemNo: Code[20]; Variant: Code[20]; UoMCode: Code[10]; LotNo: Code[20]; SerialNo: Code[20]): Decimal
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.GET(LocCode, FromBinCode, ItemNo, Variant, UoMCode);
        BinContent.SETRANGE("Lot No. Filter", LotNo);
        BinContent.SETRANGE("Serial No. Filter", SerialNo);
        BinContent.CALCFIELDS("Quantity (Base)");
        EXIT(BinContent."Quantity (Base)");
    end;

    local procedure CreateTempActivityLine(LocationCode: Code[10]; BinCode: Code[20]; UOMCode: Code[10]; QtyPerUOM: Decimal; QtyToPick: Decimal; QtyToPickBase: Decimal; ActionType: Integer; BreakBulkNo: Integer)
    var
        WhseSource2: Option;
    begin
        IF Location."Directed Put-away and Pick" THEN
            GetBin(LocationCode, BinCode);

        TempLineNo := TempLineNo + 10000;
        WITH TempWhseActivLine DO BEGIN
            RESET;
            INIT;

            "No." := FORMAT(TempNo);
            "Location Code" := LocationCode;
            "Unit of Measure Code" := UOMCode;
            "Qty. per Unit of Measure" := QtyPerUOM;
            "Starting Date" := WORKDATE;
            "Bin Code" := BinCode;
            "Action Type" := ActionType;
            "Breakbulk No." := BreakBulkNo;
            "Line No." := TempLineNo;

            CASE WhseSource OF
                WhseSource::"Pick Worksheet":
                    TransferFromPickWkshLine(WhseWkshLine);
                WhseSource::Shipment:
                    IF WhseShptLine."Assemble to Order" THEN
                        TransferFromATOShptLine(WhseShptLine, AssemblyLine)
                    ELSE
                        TransferFromShptLine(WhseShptLine);
                WhseSource::"Internal Pick":
                    TransferFromIntPickLine(WhseInternalPickLine);
                WhseSource::Production:
                    TransferFromCompLine(ProdOrderCompLine);
                WhseSource::Assembly:
                    TransferFromAssemblyLine(AssemblyLine);
                WhseSource::"Movement Worksheet":
                    TransferFromMovWkshLine(WhseWkshLine);
            END;

            IF (WhseSource = WhseSource::Shipment) AND WhseShptLine."Assemble to Order" THEN
                WhseSource2 := WhseSource::Assembly
            ELSE
                WhseSource2 := WhseSource;
            IF (BreakBulkNo = 0) AND ("Action Type" = "Action Type"::Place) THEN
                CASE WhseSource2 OF
                    WhseSource::"Pick Worksheet", WhseSource::"Movement Worksheet":
                        CalcMaxQtytoPlace(
                          QtyToPick, WhseWkshLine."Qty. to Handle", QtyToPickBase, WhseWkshLine."Qty. to Handle (Base)");
                    WhseSource::Shipment:
                        BEGIN
                            WhseShptLine.CALCFIELDS("Pick Qty.", "Pick Qty. (Base)");
                            CalcMaxQtytoPlace(
                              QtyToPick,
                              WhseShptLine.Quantity -
                              WhseShptLine."Qty. Picked" -
                              WhseShptLine."Pick Qty.",
                              QtyToPickBase,
                              WhseShptLine."Qty. (Base)" -
                              WhseShptLine."Qty. Picked (Base)" -
                              WhseShptLine."Pick Qty. (Base)");
                        END;
                    WhseSource::"Internal Pick":
                        BEGIN
                            WhseInternalPickLine.CALCFIELDS("Pick Qty.", "Pick Qty. (Base)");
                            CalcMaxQtytoPlace(
                              QtyToPick,
                              WhseInternalPickLine.Quantity -
                              WhseInternalPickLine."Qty. Picked" -
                              WhseInternalPickLine."Pick Qty.",
                              QtyToPickBase,
                              WhseInternalPickLine."Qty. (Base)" -
                              WhseInternalPickLine."Qty. Picked (Base)" -
                              WhseInternalPickLine."Pick Qty. (Base)");
                        END;
                    WhseSource::Production:
                        BEGIN
                            ProdOrderCompLine.CALCFIELDS("Pick Qty.", "Pick Qty. (Base)");
                            CalcMaxQtytoPlace(
                              QtyToPick,
                              ProdOrderCompLine."Expected Quantity" -
                              ProdOrderCompLine."Qty. Picked" -
                              ProdOrderCompLine."Pick Qty.",
                              QtyToPickBase,
                              ProdOrderCompLine."Expected Qty. (Base)" -
                              ProdOrderCompLine."Qty. Picked (Base)" -
                              ProdOrderCompLine."Pick Qty. (Base)");
                        END;
                    WhseSource::Assembly:
                        BEGIN
                            AssemblyLine.CALCFIELDS("Pick Qty.", "Pick Qty. (Base)");
                            CalcMaxQtytoPlace(
                              QtyToPick,
                              AssemblyLine.Quantity -
                              AssemblyLine."Qty. Picked" -
                              AssemblyLine."Pick Qty.",
                              QtyToPickBase,
                              AssemblyLine."Quantity (Base)" -
                              AssemblyLine."Qty. Picked (Base)" -
                              AssemblyLine."Pick Qty. (Base)");
                        END;
                END;

            IF (LocationCode <> '') AND (BinCode <> '') THEN BEGIN
                GetBin(LocationCode, BinCode);
                Dedicated := Bin.Dedicated;
            END;
            IF Location."Directed Put-away and Pick" THEN BEGIN
                "Zone Code" := Bin."Zone Code";
                "Bin Ranking" := Bin."Bin Ranking";
                "Bin Type Code" := Bin."Bin Type Code";
                IF Location."Special Equipment" <> Location."Special Equipment"::" " THEN
                    "Special Equipment Code" :=
                      AssignSpecEquipment(LocationCode, BinCode, "Item No.", "Variant Code");
            END;

            VALIDATE(Quantity, QtyToPick);
            IF QtyToPickBase <> 0 THEN BEGIN
                "Qty. (Base)" := QtyToPickBase;
                "Qty. to Handle (Base)" := QtyToPickBase;
                "Qty. Outstanding (Base)" := QtyToPickBase;
            END;

            CASE WhseSource OF
                WhseSource::Shipment:
                    BEGIN
                        "Shipping Agent Code" := ShippingAgentCode;
                        "Shipping Agent Service Code" := ShippingAgentServiceCode;
                        "Shipment Method Code" := ShipmentMethodCode;
                        "Shipping Advice" := "Shipping Advice";
                    END;
                WhseSource::Production, WhseSource::Assembly:
                    IF "Shelf No." = '' THEN BEGIN
                        Item."No." := "Item No.";
                        Item.ItemSKUGet(Item, "Location Code", "Variant Code");
                        "Shelf No." := Item."Shelf No.";
                    END;
                WhseSource::"Movement Worksheet":
                    IF (WhseWkshLine."Qty. Outstanding" <> QtyToPick) AND (BreakBulkNo = 0) THEN BEGIN
                        "Source Type" := DATABASE::"Whse. Worksheet Line";
                        "Source No." := WhseWkshLine."Worksheet Template Name";
                        "Source Line No." := "Line No.";
                    END;
            END;

            TransferItemTrkgFields(TempWhseActivLine, TempWhseItemTrkgLine);

            IF (BreakBulkNo = 0) AND (ActionType <> 2) THEN
                TotalQtyPickedBase += QtyToPickBase;

            INSERT;
        END;
    end;

    local procedure UpdateQuantitiesToPick(QtyAvailableBase: Decimal; FromQtyPerUOM: Decimal; var FromQtyToPick: Decimal; var FromQtyToPickBase: Decimal; ToQtyPerUOM: Decimal; var ToQtyToPick: Decimal; var ToQtyToPickBase: Decimal; var TotalQtyToPick: Decimal; var TotalQtyToPickBase: Decimal)
    begin
        UpdateToQtyToPick(QtyAvailableBase, ToQtyPerUOM, ToQtyToPick, ToQtyToPickBase, TotalQtyToPick, TotalQtyToPickBase);
        UpdateFromQtyToPick(QtyAvailableBase, FromQtyPerUOM, FromQtyToPick, FromQtyToPickBase, ToQtyPerUOM, ToQtyToPick, ToQtyToPickBase);
        UpdateTotalQtyToPick(ToQtyToPick, ToQtyToPickBase, TotalQtyToPick, TotalQtyToPickBase)
    end;

    local procedure UpdateFromQtyToPick(QtyAvailableBase: Decimal; FromQtyPerUOM: Decimal; var FromQtyToPick: Decimal; var FromQtyToPickBase: Decimal; ToQtyPerUOM: Decimal; ToQtyToPick: Decimal; ToQtyToPickBase: Decimal)
    begin
        CASE FromQtyPerUOM OF
            ToQtyPerUOM:
                BEGIN
                    FromQtyToPick := ToQtyToPick;
                    FromQtyToPickBase := ToQtyToPickBase;
                END;
            0 .. ToQtyPerUOM:
                BEGIN
                    FromQtyToPick := ROUND(ToQtyToPickBase / FromQtyPerUOM, 0.00001);
                    FromQtyToPickBase := ToQtyToPickBase;
                END;
            ELSE
                FromQtyToPick := ROUND(ToQtyToPickBase / FromQtyPerUOM, 1, '>');
                FromQtyToPickBase := FromQtyToPick * FromQtyPerUOM;
                IF FromQtyToPickBase > QtyAvailableBase THEN BEGIN
                    FromQtyToPickBase := ToQtyToPickBase;
                    FromQtyToPick := ROUND(FromQtyToPickBase / FromQtyPerUOM, 0.00001);
                END;
        END;
    end;

    local procedure UpdateToQtyToPick(QtyAvailableBase: Decimal; ToQtyPerUOM: Decimal; var ToQtyToPick: Decimal; var ToQtyToPickBase: Decimal; TotalQtyToPick: Decimal; TotalQtyToPickBase: Decimal)
    begin
        ToQtyToPickBase := QtyAvailableBase;
        IF ToQtyToPickBase > TotalQtyToPickBase THEN
            ToQtyToPickBase := TotalQtyToPickBase;

        ToQtyToPick := ROUND(ToQtyToPickBase / ToQtyPerUOM, 0.00001);
        IF ToQtyToPick > TotalQtyToPick THEN
            ToQtyToPick := TotalQtyToPick;
        IF (ToQtyToPick <> TotalQtyToPick) AND (ToQtyToPickBase = TotalQtyToPickBase) THEN
            IF ABS(1 - ToQtyToPick / TotalQtyToPick) <= 0.00001 THEN
                ToQtyToPick := TotalQtyToPick;
    end;

    local procedure UpdateTotalQtyToPick(ToQtyToPick: Decimal; ToQtyToPickBase: Decimal; var TotalQtyToPick: Decimal; var TotalQtyToPickBase: Decimal)
    begin
        TotalQtyToPick := TotalQtyToPick - ToQtyToPick;
        TotalQtyToPickBase := TotalQtyToPickBase - ToQtyToPickBase;
    end;

    local procedure CalcTotalQtyAssgndOnWhse(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Decimal
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        ProdOrderComp: Record "Prod. Order Component";
        AsmLine: Record "Assembly Line";
        QtyAssgndToWhseAct: Decimal;
        QtyAssgndToShipment: Decimal;
        QtyAssgndToProdComp: Decimal;
        QtyAssgndToAsmLine: Decimal;
    begin
        QtyAssgndToWhseAct +=
          CalcTotalQtyAssgndOnWhseAct(TempWhseActivLine."Activity Type"::" ", LocationCode, ItemNo, VariantCode);
        QtyAssgndToWhseAct +=
          CalcTotalQtyAssgndOnWhseAct(TempWhseActivLine."Activity Type"::"Put-away", LocationCode, ItemNo, VariantCode);
        QtyAssgndToWhseAct +=
          CalcTotalQtyAssgndOnWhseAct(TempWhseActivLine."Activity Type"::Pick, LocationCode, ItemNo, VariantCode);
        QtyAssgndToWhseAct +=
          CalcTotalQtyAssgndOnWhseAct(TempWhseActivLine."Activity Type"::Movement, LocationCode, ItemNo, VariantCode);
        QtyAssgndToWhseAct +=
          CalcTotalQtyAssgndOnWhseAct(TempWhseActivLine."Activity Type"::"Invt. Put-away", LocationCode, ItemNo, VariantCode);
        QtyAssgndToWhseAct +=
          CalcTotalQtyAssgndOnWhseAct(TempWhseActivLine."Activity Type"::"Invt. Pick", LocationCode, ItemNo, VariantCode);

        WITH WhseShipmentLine DO BEGIN
            SETCURRENTKEY("Item No.", "Location Code", "Variant Code", "Due Date");
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Variant Code", VariantCode);
            CALCSUMS("Qty. Picked (Base)", "Qty. Shipped (Base)");
            QtyAssgndToShipment := "Qty. Picked (Base)" - "Qty. Shipped (Base)";
        END;

        WITH ProdOrderComp DO BEGIN
            SETCURRENTKEY("Item No.", "Variant Code", "Location Code", Status, "Due Date");
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Variant Code", VariantCode);
            SETRANGE(Status, Status::Released);
            CALCSUMS("Qty. Picked (Base)", "Expected Qty. (Base)", "Remaining Qty. (Base)");
            QtyAssgndToProdComp := "Qty. Picked (Base)" - ("Expected Qty. (Base)" - "Remaining Qty. (Base)");
        END;

        WITH AsmLine DO BEGIN
            SETCURRENTKEY("Document Type", Type, "No.", "Variant Code", "Location Code");
            SETRANGE("Document Type", "Document Type"::Order);
            SETRANGE("Location Code", LocationCode);
            SETRANGE(Type, Type::Item);
            SETRANGE("No.", ItemNo);
            SETRANGE("Variant Code", VariantCode);
            CALCSUMS("Qty. Picked (Base)", "Consumed Quantity (Base)");
            QtyAssgndToAsmLine := CalcQtyPickedNotConsumedBase;
        END;

        EXIT(QtyAssgndToWhseAct + QtyAssgndToShipment + QtyAssgndToProdComp + QtyAssgndToAsmLine);
    end;

    local procedure CalcTotalQtyAssgndOnWhseAct(ActivityType: Option; LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Decimal
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WITH WhseActivLine DO BEGIN
            SETCURRENTKEY(
              "Item No.", "Location Code", "Activity Type", "Bin Type Code",
              "Unit of Measure Code", "Variant Code", "Breakbulk No.", "Action Type");
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Variant Code", VariantCode);
            SETRANGE("Activity Type", ActivityType);
            SETRANGE("Breakbulk No.", 0);
            SETFILTER("Action Type", '%1|%2', "Action Type"::" ", "Action Type"::Take);
            CALCSUMS("Qty. Outstanding (Base)");
            EXIT("Qty. Outstanding (Base)");
        END;
    end;

    local procedure CalcTotalQtyOnBinType(BinTypeFilter: Text[1024]; LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Decimal
    var
        WhseEntry: Record "Warehouse Entry";
    begin
        WITH WhseEntry DO BEGIN
            SETCURRENTKEY("Item No.", "Location Code", "Variant Code", "Bin Type Code");
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Variant Code", VariantCode);
            IF BinTypeFilter <> '' THEN
                SETFILTER("Bin Type Code", BinTypeFilter);
            CALCSUMS("Qty. (Base)");
            EXIT("Qty. (Base)");
        END;
    end;

    procedure CalcBreakbulkOutstdQty(var WhseActivLine: Record "Warehouse Activity Line"; LNRequired: Boolean; SNRequired: Boolean): Decimal
    var
        BinContent: Record "Bin Content";
        WhseActivLine1: Record "Warehouse Activity Line";
        WhseActivLine2: Record "Warehouse Activity Line";
        TempUOM: Record "Unit of Measure" temporary;
        QtyOnBreakbulk: Decimal;
    begin
        WITH WhseActivLine1 DO BEGIN
            COPYFILTERS(WhseActivLine);
            SETFILTER("Breakbulk No.", '<>%1', 0);
            SETRANGE("Action Type", "Action Type"::Place);
            IF FINDSET THEN BEGIN
                BinContent.SETCURRENTKEY(
                  "Location Code", "Item No.", "Variant Code", "Cross-Dock Bin", "Qty. per Unit of Measure", "Bin Ranking");
                BinContent.SETRANGE("Location Code", "Location Code");
                BinContent.SETRANGE("Item No.", "Item No.");
                BinContent.SETRANGE("Variant Code", "Variant Code");
                BinContent.SETRANGE("Cross-Dock Bin", CrossDock);

                REPEAT
                    IF NOT TempUOM.GET("Unit of Measure Code") THEN BEGIN
                        TempUOM.INIT;
                        TempUOM.Code := "Unit of Measure Code";
                        TempUOM.INSERT;
                        SETRANGE("Unit of Measure Code", "Unit of Measure Code");
                        CALCSUMS("Qty. Outstanding (Base)");
                        QtyOnBreakbulk += "Qty. Outstanding (Base)";

                        // Exclude the qty counted in QtyAssignedToPick
                        BinContent.SETRANGE("Unit of Measure Code", "Unit of Measure Code");
                        IF LNRequired THEN
                            BinContent.SETRANGE("Lot No. Filter", "Lot No.")
                        ELSE
                            BinContent.SETFILTER("Lot No. Filter", '%1|%2', "Lot No.", '');
                        IF SNRequired THEN
                            BinContent.SETRANGE("Serial No. Filter", "Serial No.")
                        ELSE
                            BinContent.SETFILTER("Serial No. Filter", '%1|%2', "Serial No.", '');

                        IF BinContent.FINDSET THEN
                            REPEAT
                                BinContent.SetFilterOnUnitOfMeasure;
                                BinContent.CALCFIELDS("Quantity (Base)", "Pick Quantity (Base)");
                                IF BinContent."Pick Quantity (Base)" > BinContent."Quantity (Base)" THEN
                                    QtyOnBreakbulk -= (BinContent."Pick Quantity (Base)" - BinContent."Quantity (Base)");
                            UNTIL BinContent.NEXT = 0
                        ELSE BEGIN
                            WhseActivLine2.COPYFILTERS(WhseActivLine1);
                            WhseActivLine2.SETFILTER("Action Type", '%1|%2', "Action Type"::" ", "Action Type"::Take);
                            WhseActivLine2.SETRANGE("Breakbulk No.", 0);
                            WhseActivLine2.CALCSUMS("Qty. Outstanding (Base)");
                            QtyOnBreakbulk -= WhseActivLine2."Qty. Outstanding (Base)";
                        END;
                        SETRANGE("Unit of Measure Code");
                    END;
                UNTIL NEXT = 0;
            END;
            EXIT(QtyOnBreakbulk);
        END;
    end;

    procedure GetExpiredItemMessage(): Text[100]
    begin
        EXIT(ExpiredItemMessageText);
    end;

    local procedure PickStrictExpirationPosting(ItemNo: Code[20]): Boolean
    begin
        EXIT(ItemTrackingMgt.StrictExpirationPosting(ItemNo) AND (SNRequired OR LNRequired));
    end;

    local procedure AddToFilterText(var TextVar: Text[250]; Separator: Code[1]; Comparator: Code[2]; Addendum: Code[20])
    begin
        IF TextVar = '' THEN
            TextVar := Comparator + Addendum
        ELSE
            TextVar += Separator + Comparator + Addendum;
    end;

    procedure CreateAssemblyPickLine(AsmLine: Record "Assembly Line")
    var
        QtyToPickBase: Decimal;
        QtyToPick: Decimal;
    begin
        WITH AsmLine DO BEGIN
            TESTFIELD("Qty. per Unit of Measure");
            QtyToPickBase := CalcQtyToPickBase;
            QtyToPick := CalcQtyToPick;
            IF QtyToPick > 0 THEN BEGIN
                SetAssemblyLine(AsmLine, 1);
                SetTempWhseItemTrkgLine(
                  "Document No.", DATABASE::"Assembly Line", '',
                  0, "Line No.", "Location Code");
                CreateTempLine(
                  "Location Code", "No.", "Variant Code", "Unit of Measure Code",
                  '', "Bin Code",
                  "Qty. per Unit of Measure", QtyToPick, QtyToPickBase);
            END;
        END;
    end;

    local procedure MovementFromShipZone(var TotalAvailQtyBase: Decimal; QtyOnOutboundBins: Decimal)
    begin
        IF NOT IsShipZone(WhseWkshLine."Location Code", WhseWkshLine."To Zone Code") THEN
            TotalAvailQtyBase := TotalAvailQtyBase - QtyOnOutboundBins;
    end;

    procedure IsShipZone(LocationCode: Code[10]; ZoneCode: Code[10]): Boolean
    var
        Zone: Record Zone;
        BinType: Record "Bin Type";
    begin
        IF NOT Zone.GET(LocationCode, ZoneCode) THEN
            EXIT(FALSE);
        IF NOT BinType.GET(Zone."Bin Type Code") THEN
            EXIT(FALSE);
        EXIT(BinType.Ship);
    end;

    local procedure Minimum(a: Decimal; b: Decimal): Decimal
    begin
        IF a < b THEN
            EXIT(a);

        EXIT(b);
    end;

    procedure CalcQtyResvdNotOnILE(ReservEntryNo: Integer; ReservEntryPositive: Boolean) QtyResvdNotOnILE: Decimal
    var
        ReservEntry: Record "Reservation Entry";
    begin
        IF ReservEntry.GET(ReservEntryNo, NOT ReservEntryPositive) THEN
            IF ReservEntry."Source Type" <> DATABASE::"Item Ledger Entry" THEN
                QtyResvdNotOnILE += ReservEntry."Quantity (Base)";

        EXIT(QtyResvdNotOnILE);
    end;

    procedure SetFiltersOnReservEntry(var ReservEntry: Record "Reservation Entry"; SourceType: Integer; SourceSubType: Option; SourceNo: Code[20]; SourceLineNo: Integer; SourceSubLineNo: Integer)
    begin
        WITH ReservEntry DO BEGIN
            SETCURRENTKEY(
              "Source ID", "Source Ref. No.", "Source Type", "Source Subtype",
              "Source Batch Name", "Source Prod. Order Line", "Reservation Status");
            SETRANGE("Source ID", SourceNo);
            IF SourceType = DATABASE::"Prod. Order Component" THEN BEGIN
                SETRANGE("Source Ref. No.", SourceSubLineNo);
                SETRANGE("Source Prod. Order Line", SourceLineNo);
            END ELSE
                SETRANGE("Source Ref. No.", SourceLineNo);
            SETRANGE("Source Type", SourceType);
            SETRANGE("Source Subtype", SourceSubType);
            SETRANGE("Reservation Status", "Reservation Status"::Reservation);
        END;
    end;

    procedure GetActualQtyPickedBase(): Decimal
    begin
        EXIT(TotalQtyPickedBase);
    end;

    procedure CalcReservedQtyOnInventory(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10]; LotNo: Code[20]; LNRequired: Boolean; SerialNo: Code[20]; SNRequired: Boolean): Decimal
    begin
        GetItem(ItemNo);
        WITH Item DO BEGIN
            SETRANGE("Location Filter", LocationCode);
            SETRANGE("Variant Filter", VariantCode);
            IF LotNo <> '' THEN BEGIN
                IF LNRequired THEN
                    SETRANGE("Lot No. Filter", LotNo)
                ELSE
                    SETFILTER("Lot No. Filter", '%1|%2', LotNo, '')
            END ELSE
                SETRANGE("Lot No. Filter");
            IF SerialNo <> '' THEN BEGIN
                IF SNRequired THEN
                    SETRANGE("Serial No. Filter", SerialNo)
                ELSE
                    SETFILTER("Serial No. Filter", '%1|%2', SerialNo, '');
            END ELSE
                SETRANGE("Serial No. Filter");
            CALCFIELDS("Reserved Qty. on Inventory");
            EXIT("Reserved Qty. on Inventory");
        END;
    end;

    local procedure FilterWhseEntry(var WarehouseEntry: Record "Warehouse Entry"; ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10]; LotNo: Code[20]; SerialNo: Code[20]; ExcludeDedicatedBinContent: Boolean)
    begin
        WITH WarehouseEntry DO BEGIN
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Location Code", LocationCode);
            SETRANGE("Variant Code", VariantCode);
            IF LotNo <> '' THEN
                SETRANGE("Lot No.", LotNo);
            IF SerialNo <> '' THEN
                SETRANGE("Serial No.", SerialNo);
            IF ExcludeDedicatedBinContent THEN
                SETRANGE(Dedicated, FALSE);
        END
    end;

    procedure CalcResidualPickedQty(var WhseEntry: Record "Warehouse Entry") Result: Decimal
    var
        WhseEntry2: Record "Warehouse Entry";
    begin
        WhseEntry.SETCURRENTKEY("Source Type", "Source Subtype", "Source No.");
        IF NOT WhseEntry.FINDSET THEN
            EXIT;

        WhseEntry2.INIT;
        REPEAT
            WITH WhseEntry2 DO
                IF (WhseEntry."Bin Code" <> "Bin Code") OR (WhseEntry."Source Type" <> "Source Type") OR
                   (WhseEntry."Source Subtype" <> "Source Subtype") OR (WhseEntry."Source No." <> "Source No.") OR
                   (WhseEntry."Source Line No." <> "Source Line No.") OR
                   (WhseEntry."Source Subline No." <> "Source Subline No.") OR
                   (WhseEntry."Source Document" <> "Source Document")
                THEN BEGIN
                    COPYFILTERS(WhseEntry);
                    SETRANGE("Whse. Document Type");
                    SETRANGE("Reference Document");
                    SETRANGE("Qty. (Base)");

                    SETRANGE("Bin Code", WhseEntry."Bin Code");
                    SETRANGE("Source Type", WhseEntry."Source Type");
                    SETRANGE("Source Subtype", WhseEntry."Source Subtype");
                    SETRANGE("Source No.", WhseEntry."Source No.");
                    SETRANGE("Source Line No.", WhseEntry."Source Line No.");
                    SETRANGE("Source Subline No.", WhseEntry."Source Subline No.");
                    SETRANGE("Source Document", WhseEntry."Source Document");

                    CALCSUMS("Qty. (Base)");
                    Result += "Qty. (Base)";

                    TRANSFERFIELDS(WhseEntry);
                END
        UNTIL WhseEntry.NEXT = 0;
    end;
}

