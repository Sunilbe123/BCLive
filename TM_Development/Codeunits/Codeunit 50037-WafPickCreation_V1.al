codeunit 50037 WafPickCreationV1
{
    //Version = MITL
    Description = 'Waf Specific Pick Creation Version 1';

    trigger OnRun()

    begin

        recWarehouseShipmentLine.RESET;
        recWarehouseShipmentLine.SetCurrentKey("Source Document", "Qty. Picked", "Zone Code", "Bin Code"); // MITL.SM.20200503 Indexing correction
        recWarehouseShipmentLine.SETRANGE("Source Document", recWarehouseShipmentLine."Source Document"::"Sales Order");
        recWarehouseShipmentLine.SETRANGE("Qty. Picked", 0);
        recWarehouseShipmentLine.SETRANGE("Pick Qty.", 0);
        recWarehouseShipmentLine.SetFilter("Zone Code", '<>%1', '');
        recWarehouseShipmentLine.SetFilter("Bin Code", '<>%1', '');
        recWarehouseShipmentLine.SETRANGE("Combined Pick", FALSE); //MITL.AJ.09012020 
        IF recWarehouseShipmentLine.FINDSET THEN
            REPEAT
                IF DocNo <> recWarehouseShipmentLine."Source No." THEN BEGIN
                    SalesHeader.GET(SalesHeader."Document Type"::Order, recWarehouseShipmentLine."Source No.");
                    Customer.Get(SalesHeader."Sell-to Customer No.");
                    IF Customer.Blocked = Customer.Blocked::" " THEN
                        CreatePicks;
                    DocNo := recWarehouseShipmentLine."Source No.";
                END;
            UNTIL recWarehouseShipmentLine.NEXT = 0;

        WhseShipHeader.RESET;
        WhseShipHeader.SETRANGE(Status, WhseShipHeader.Status::Open);
        IF WhseShipHeader.FindSet() then
            repeat
                UpdateZoneandBinCodeinWhseShipment();
            until WhseShipHeader.Next() = 0;

        UpdateNewPickBininPickLines(); //MITL.AJ.11MAR2020 

    end;

    local procedure CreatePicks()
    var
        WarehouseShipmentLineL: Record "Warehouse Shipment Line";
    begin
        WarehouseShipmentLineL.SetCurrentKey("Source Document", "Qty. Picked", "Zone Code", "Bin Code"); // MITL.SM.20200503 Indexing correction
        WarehouseShipmentLineL.SETRANGE("Source Document", WarehouseShipmentLineL."Source Document"::"Sales Order");
        WarehouseShipmentLineL.SETRANGE("Source No.", SalesHeader."No.");
        WarehouseShipmentLineL.SETRANGE("Qty. Picked", 0);
        WarehouseShipmentLineL.SETRANGE("Pick Qty.", 0);
        IF WarehouseShipmentLineL.FINDSET THEN begin
            CheckAndRelease;
            WarehouseShipmentHeader.SETRANGE("No.", WarehouseShipmentLineL."No.");
            WarehouseShipmentHeader.FINDFIRST;
            WarehouseShipmentLineL.SetHideValidationDialogCustom(TRUE);
            WarehouseShipmentLineL.CreatePickDocCustom(WarehouseShipmentLineL, WarehouseShipmentHeader);
        End;
    end;

    local procedure UpdateZoneandBinCodeinWhseShipment()
    var
        WarehouseShipmentLineL: Record "Warehouse Shipment Line";
        Bin: Record Bin;
    begin
        WarehouseShipmentLineL.Reset();
        WarehouseShipmentLineL.SetCurrentKey("Source Document", "Qty. Picked", "Zone Code", "Bin Code"); // MITL.SM.20200503 Indexing correction
        WarehouseShipmentLineL.SETRANGE("Source Document", WarehouseShipmentLineL."Source Document"::"Sales Order");
        WarehouseShipmentLineL.SETRANGE("Qty. Picked", 0);
        WarehouseShipmentLineL.SETRANGE("Pick Qty.", 0);
        WarehouseShipmentLineL.SetFilter("Zone Code", '%1', '');
        WarehouseShipmentLineL.SetFilter("Bin Code", '%1', '');
        IF WarehouseShipmentLineL.FINDSET THEN
            repeat
                GetLocation(WarehouseShipmentLineL."Location Code");
                WarehouseShipmentLineL."Bin Code" := Location."Shipment Bin Code";
                IF Location."Directed Put-away and Pick" THEN BEGIN
                    Bin.GET(WarehouseShipmentLineL."Location Code", WarehouseShipmentLineL."Bin Code");
                    WarehouseShipmentLineL."Zone Code" := Bin."Zone Code";
                END;
                WarehouseShipmentLineL.Modify();
            Until WarehouseShipmentLineL.Next() = 0;
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

    local procedure GetLocation(LocationCode: Code[10])
    var
    begin
        IF LocationCode = '' THEN
            Location.GetLocationSetup(LocationCode, Location)
        ELSE
            IF Location.Code <> LocationCode THEN
                Location.GET(LocationCode);
    end;

    //MITL.AJ.11MAR2020 ++
    Local procedure UpdateNewPickBininPickLines()
    var
        WhseActLinesL: Record "Warehouse Activity Line";
    Begin
        WhseActLinesL.Reset();
        WhseActLinesL.SetCurrentKey("Activity Type", "No.", "Action Type", "Bin Code");
        WhseActLinesL.SetRange("Activity Type", WhseActLinesL."Activity Type"::Pick);
        WhseActLinesL.SetRange("Action Type", WhseActLinesL."Action Type"::Take);
        WhseActLinesL.SetRange("Picking Bin", '');
        IF WhseActLinesL.FindSet() THEN
            REPEAT
                WhseActLinesL."Picking Bin" := FindDefaultBinCode(WhseActLinesL);
                WhseActLinesL."Bin Code" := '';
                WhseActLinesL.Modify();
            UNTIL WhseActLinesL.Next() = 0;

    End;

    local procedure FindDefaultBinCode(WhseActLinesP: Record "Warehouse Activity Line"): Code[20]
    var
        BinContentL: Record "Bin Content";
    Begin
        BinContentL.Reset();
        BinContentL.SetCurrentKey(Default, "Location Code", "Item No.", "Variant Code", "Bin Code");
        BinContentL.SetRange(Default, true);
        BinContentL.SetRange("Location Code", WhseActLinesP."Location Code");
        BinContentL.SetRange("Item No.", WhseActLinesP."Item No.");
        If BinContentL.FindFirst() then
            Exit(BinContentL."Bin Code");
    End;
    //MITL.AJ.11MAR2020 **
    var
        recWarehouseShipmentLine: Record "Warehouse Shipment Line";
        DocNo: Code[20];
        SalesHeader: Record "Sales Header";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        RegisterActivityRecLock: Record "Registered Whse. Activity Hdr.";
        WhseEntryLock: Record "Warehouse Entry";
        WhseActiHeadRecLock: Record "Warehouse Activity Header";
        Location: Record Location;
        Customer: Record Customer;
        WhseShipHeader: Record "Warehouse Shipment Header";
}