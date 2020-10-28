codeunit 50016 "Finding Whse entry"
{
    // version CASE13605


    trigger OnRun()
    var
        BinContentRecL: Record "Bin Content";
        CheckAvailableStockEntriesRecL: Record "Pick Crt_Buffer2";
        recWarehouseShipmentLine: Record "Warehouse Shipment Line";
        TempItemNoL: Code[20];
        TempLocCodeL: Code[10];
        CalendarMgnt: Codeunit "Calendar Management";
        SalesReceiveableSetup: Record "Sales & Receivables Setup";
        CustomCalChange: array[2] of Record "Customized Calendar Change";
    begin
        CheckAvailableStockEntriesRecL.DELETEALL;
        SalesReceiveableSetup.Get();
        recWarehouseShipmentLine.RESET;
        // recWarehouseShipmentLine.SETCURRENTKEY("Item No.", "Location Code");
        recWarehouseShipmentLine.SETCURRENTKEY("Source Document", "Qty. Picked", "Zone Code", "Bin Code"); // MITL.SM.20200503 Indexing correction
        recWarehouseShipmentLine.SETRANGE("Source Document", recWarehouseShipmentLine."Source Document"::"Sales Order");
        recWarehouseShipmentLine.SETRANGE("Qty. Picked", 0);
        recWarehouseShipmentLine.SETRANGE("Pick Qty.", 0);
        recWarehouseShipmentLine.SETRANGE("Combined Pick", FALSE);
        //MITL.6532.SM 20200608 ++
        CustomCalChange[1].SetSource(1, '', '', '');
        recWarehouseShipmentLine.SetRange("Shipment Date", DMY2Date(01, 01, 2000),
        CalendarMgnt.CalcDateBOC(format(SalesReceiveableSetup.PickCreationCalc), Today, CustomCalChange, false));
        //MITL.6532.SM 20200608 --
        IF recWarehouseShipmentLine.FINDSET THEN
            REPEAT
                IF (TempItemNoL <> recWarehouseShipmentLine."Item No.") OR (TempLocCodeL <> recWarehouseShipmentLine."Location Code") THEN BEGIN
                    BinContentRecL.RESET;
                    BinContentRecL.SETRANGE("Location Code", recWarehouseShipmentLine."Location Code");
                    BinContentRecL.SETRANGE("Item No.", recWarehouseShipmentLine."Item No.");
                    BinContentRecL.SETFILTER("Quantity (Base)", '>0');
                    IF BinContentRecL.FINDSET THEN
                        REPEAT
                            FindRemingQtyEntries(BinContentRecL);
                        UNTIL BinContentRecL.NEXT = 0;
                    TempItemNoL := recWarehouseShipmentLine."Item No.";
                    TempLocCodeL := recWarehouseShipmentLine."Location Code";
                END;
            UNTIL recWarehouseShipmentLine.NEXT = 0;
        UpdateAvailQty;
    end;

    procedure FindRemingQtyEntries(BinContentRecP: Record "Bin Content")
    var
        WarehouseEntryRecL: Record "Warehouse Entry";
        AvailableStockEntriesRecL: Record "Pick Crt_Buffer2";
        BinTypeRecL: Record "Bin Type";
        BulckBinL: Boolean;
        AvailableQtyL: Decimal;
        CheckAvailableStockEntriesRecL: Record "Pick Crt_Buffer2";
    begin
        AvailableQtyL := 0;

        AvailableQtyL := BinContentRecP.CalcQtyAvailToPick(0);

        BulckBinL := FALSE;
        BinTypeRecL.RESET;
        BinTypeRecL.SETRANGE(Code, BinContentRecP."Bin Type Code");
        BinTypeRecL.SETRANGE("Put Away", TRUE);
        BinTypeRecL.SETRANGE(Pick, FALSE);
        BinTypeRecL.SETRANGE(Receive, FALSE);
        BinTypeRecL.SETRANGE(Ship, FALSE);
        IF BinTypeRecL.FINDFIRST THEN BEGIN
            WarehouseEntryRecL.RESET;
            // WarehouseEntryRecL.SETCURRENTKEY("Entry No.");
            WarehouseEntryRecL.SETCURRENTKEY("Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type", Dedicated); // MITL.SM.20200503 Indexing correction
            WarehouseEntryRecL.ASCENDING(FALSE);
            WarehouseEntryRecL.SETRANGE("Item No.", BinContentRecP."Item No.");
            WarehouseEntryRecL.SETRANGE("Location Code", BinContentRecP."Location Code");
            WarehouseEntryRecL.SETRANGE("Variant Code", BinContentRecP."Variant Code");
            WarehouseEntryRecL.SETRANGE("Bin Code", BinContentRecP."Bin Code");
            WarehouseEntryRecL.SETRANGE("Unit of Measure Code", BinContentRecP."Unit of Measure Code");
            WarehouseEntryRecL.SETFILTER("Qty. (Base)", '>0');
            IF WarehouseEntryRecL.FINDSET THEN
                REPEAT
                    CheckAvailableStockEntriesRecL.RESET;
                    CheckAvailableStockEntriesRecL.SETCURRENTKEY("Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type", Dedicated);
                    CheckAvailableStockEntriesRecL.SETRANGE("Item No.", WarehouseEntryRecL."Item No.");
                    CheckAvailableStockEntriesRecL.SETRANGE("Location Code", WarehouseEntryRecL."Location Code");
                    CheckAvailableStockEntriesRecL.SETRANGE("Variant Code", WarehouseEntryRecL."Variant Code");
                    CheckAvailableStockEntriesRecL.SETRANGE("Unit of Measure Code", WarehouseEntryRecL."Unit of Measure Code");
                    CheckAvailableStockEntriesRecL.SETRANGE("Bin Code", WarehouseEntryRecL."Bin Code");
                    IF NOT CheckAvailableStockEntriesRecL.FINDFIRST THEN BEGIN
                        AvailableStockEntriesRecL.INIT;
                        AvailableStockEntriesRecL.TRANSFERFIELDS(WarehouseEntryRecL);

                        IF WarehouseEntryRecL."Qty. (Base)" <= AvailableQtyL THEN BEGIN
                            AvailableStockEntriesRecL.Quantity := WarehouseEntryRecL.Quantity;
                            AvailableStockEntriesRecL."Qty. (Base)" := WarehouseEntryRecL."Qty. (Base)";
                            AvailableStockEntriesRecL."Remaning Qty" := WarehouseEntryRecL."Qty. (Base)";
                            AvailableQtyL := AvailableQtyL - WarehouseEntryRecL."Qty. (Base)";
                        END ELSE BEGIN
                            AvailableStockEntriesRecL.Quantity := WarehouseEntryRecL.Quantity;
                            AvailableStockEntriesRecL."Qty. (Base)" := WarehouseEntryRecL."Qty. (Base)";
                            AvailableStockEntriesRecL."Remaning Qty" := AvailableQtyL;
                            AvailableQtyL := 0;
                        END;

                        AvailableStockEntriesRecL.INSERT;
                    END ELSE BEGIN
                        CheckAvailableStockEntriesRecL."Registering Date" := WarehouseEntryRecL."Registering Date";

                        IF WarehouseEntryRecL."Qty. (Base)" <= AvailableQtyL THEN BEGIN
                            CheckAvailableStockEntriesRecL.Quantity += WarehouseEntryRecL.Quantity;
                            CheckAvailableStockEntriesRecL."Qty. (Base)" += WarehouseEntryRecL."Qty. (Base)";
                            CheckAvailableStockEntriesRecL."Remaning Qty" += WarehouseEntryRecL."Qty. (Base)";
                            AvailableQtyL := AvailableQtyL - WarehouseEntryRecL."Qty. (Base)";
                        END ELSE BEGIN
                            CheckAvailableStockEntriesRecL.Quantity += WarehouseEntryRecL.Quantity;
                            CheckAvailableStockEntriesRecL."Qty. (Base)" += WarehouseEntryRecL."Qty. (Base)";
                            CheckAvailableStockEntriesRecL."Remaning Qty" += AvailableQtyL;
                            AvailableQtyL := 0;
                        END;

                        CheckAvailableStockEntriesRecL.MODIFY;
                    END;
                UNTIL (AvailableQtyL = 0) OR (WarehouseEntryRecL.NEXT = 0);
        END;
    end;

    procedure ClacBulkBinQty(LocationCodeP: Code[10]; ItemCodeP: Code[20]; VariantCodeP: Code[10]) BulkBinQtyBaseR: Decimal
    var
        StockBinRecL: Record "Pick Crt_Buffer2";
    begin
        StockBinRecL.RESET;
        StockBinRecL.SETCURRENTKEY("Item No.", "Location Code", "Variant Code", "Bin Type Code", "Unit of Measure Code", "Lot No.", "Serial No.", Dedicated);
        StockBinRecL.SETRANGE("Item No.", ItemCodeP);
        StockBinRecL.SETRANGE("Location Code", LocationCodeP);
        StockBinRecL.SETRANGE("Variant Code", VariantCodeP);
        StockBinRecL.CALCSUMS("Qty. (Base)");
        BulkBinQtyBaseR := StockBinRecL."Qty. (Base)";
    end;

    local procedure UpdateAvailQty()
    var
        AvailableStockEntriesRecL: Record "Pick Crt_Buffer2";
        BinContentRecL: Record "Bin Content";
        AvailableBaseQty: Decimal;
    begin
        AvailableStockEntriesRecL.RESET;
        IF AvailableStockEntriesRecL.FINDSET THEN
            REPEAT
                BinContentRecL.RESET;
                BinContentRecL.SETCURRENTKEY("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
                BinContentRecL.SETRANGE("Location Code", AvailableStockEntriesRecL."Location Code");
                BinContentRecL.SETRANGE("Bin Code", AvailableStockEntriesRecL."Bin Code");
                BinContentRecL.SETRANGE("Item No.", AvailableStockEntriesRecL."Item No.");
                BinContentRecL.SETRANGE("Variant Code", AvailableStockEntriesRecL."Variant Code");
                BinContentRecL.SETRANGE("Unit of Measure Code", AvailableStockEntriesRecL."Unit of Measure Code");
                IF BinContentRecL.FINDFIRST THEN BEGIN
                    AvailableBaseQty := 0;
                    AvailableBaseQty := BinContentRecL.CalcQtyAvailToPick(0);
                    AvailableStockEntriesRecL.VALIDATE("Qty. (Base)", AvailableBaseQty);
                    AvailableStockEntriesRecL.MODIFY;
                END;
            UNTIL AvailableStockEntriesRecL.NEXT = 0;
    end;
}

