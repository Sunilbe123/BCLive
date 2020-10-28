codeunit 50004 "WEB Index Handling"
{
    // version RM 17082015,R4501,R4580,MITL14137

    // bR4501 - RM - 31.01.2016
    // As per Matt's request do not process duplicate transactions(inserts) that were completed succesfully already!
    // 
    // R4580 - RM - 14.02.2016
    // Added "Cancelled Order" field
    // MITL 14137 290118 - Code added to assign the "Whse. Document No." value from "No. Series".


    trigger OnRun()
    var
        HandleWebItem: Codeunit "WEB Handling Item";
        HandleItemAttribute: Codeunit "WEB Handling Item Attribute";
        HandleWebOrder: Codeunit "WEB Handling Order";
        HandleWebCustomer: Codeunit "WEB Handling Customer";
        HandleWebBillTo: Codeunit "WEB Handling BillTo";
        HandleWebShipTo: Codeunit "WEB Handling ShipTo";
        HandleWebShipments: Codeunit "WEB Handling Shipments";
        HandleWebCredits: Codeunit "WEB Handling Credit Memo";
    begin
        HandleStaticData;
        HandleOrders;
        HandleShipments;
        HandleStockAvail;
        PopulateOrderStatus;
        HandleWriteOffs; //MITL2221
    end;

    var
        WebIndex: Record "WEB Index";
        Window: Dialog;
        ii: Integer;
        jj: Integer;
        LineNoFilter: Text[250];
        WebFunc: Codeunit "WEB Functions";

    procedure RecordCALError(var WebIndex: Record "WEB Index")
    begin
        WebIndex.Status := WebIndex.Status::Error;
        WebIndex.Error := COPYSTR(GETLASTERRORTEXT, 1, 250);
        WebIndex.MODIFY;

        IF COPYSTR(WebIndex.Error, 1, 29) = COPYSTR('An attempt was made to change an old version of a Sales', 1, 29) THEN BEGIN
            WebIndex.Status := WebIndex.Status::" ";
            WebIndex.Error := '';
            WebIndex.MODIFY;
        END;
    end;

    procedure HandleStaticData()
    var
        HandleWebItem: Codeunit "WEB Handling Item";
        HandleItemAttribute: Codeunit "WEB Handling Item Attribute";
        HandleWebCustomer: Codeunit "WEB Handling Customer";
    begin


        IF LineNoFilter <> '' THEN
            WebIndex.SETFILTER(WebIndex."Line no.", LineNoFilter)
        ELSE
            WebIndex.SETRANGE(WebIndex.Status, WebIndex.Status::" ");
        WebIndex.SETFILTER(WebIndex."Table No.", '50016|50017|50009');

        jj := WebIndex.COUNT;
        IF WebIndex.FINDSET THEN
            REPEAT
                ii := ii + 1;
                CLEARLASTERROR;
                CLEAR(HandleWebItem);
                CLEAR(HandleItemAttribute);
                CLEAR(HandleWebCustomer);


                CASE WebIndex."Table No." OF
                    50016:
                        IF NOT HandleWebItem.RUN(WebIndex) THEN
                            RecordCALError(WebIndex);
                    50017:
                        IF NOT HandleItemAttribute.RUN(WebIndex) THEN
                            RecordCALError(WebIndex);
                    50009:
                        IF NOT HandleWebCustomer.RUN(WebIndex) THEN
                            RecordCALError(WebIndex);
                END;
                WebIndex.MODIFY;
                COMMIT;
                SELECTLATESTVERSION;
            UNTIL WebIndex.NEXT = 0;
    end;

    procedure HandleOrders()
    var
        HandleWebOrder: Codeunit "WEB Handling Order";
        HandleWebBillTo: Codeunit "WEB Handling BillTo";
        HandleWebShipTo: Codeunit "WEB Handling ShipTo";
        HandleWebCredits: Codeunit "WEB Handling Credit Memo";
        WEBIndexL: Record "WEB Index"; //MITL2995.AJ.28APR2020
    begin

        //do orders before shipments

        IF LineNoFilter <> '' THEN
            WebIndex.SETFILTER(WebIndex."Line no.", LineNoFilter)
        ELSE
            WebIndex.SETRANGE(WebIndex.Status, WebIndex.Status::" ");
        WebIndex.SETFILTER(WebIndex."Table No.", '50010|50027|50013|50018');

        IF WebIndex.FINDSET THEN
            REPEAT

                CLEARLASTERROR;
                CLEAR(HandleWebOrder);
                CLEAR(HandleWebBillTo);
                CLEAR(HandleWebShipTo);
                CLEAR(HandleWebCredits);

                //R4501 >>
                IF WebIndex."Table No." IN [50010, 50018] THEN BEGIN
                    WebFunc.FlagDuplicateTransactions(WebIndex);
                END;

                IF WebIndex.Status = WebIndex.Status::" " THEN
                    //R4501 <<

                    CASE WebIndex."Table No." OF
                        50010:
                            IF NOT HandleWebOrder.RUN(WebIndex) THEN
                                RecordCALError(WebIndex);
                        50027:
                            IF NOT HandleWebBillTo.RUN(WebIndex) THEN
                                RecordCALError(WebIndex);
                        50013:
                            IF NOT HandleWebShipTo.RUN(WebIndex) THEN
                                RecordCALError(WebIndex);
                        50018:
                            IF NOT HandleWebCredits.RUN(WebIndex) THEN
                                RecordCALError(WebIndex);
                    END;
                //MITL2995.AJ.28APR2020 ++
                IF WEBIndexL.GET(WebIndex."Line no.") THEN BEGIN
                    WebIndexL.MODIFY;
                    WebIndex := WEBIndexL;
                END;
                //MITL2995.AJ.28APR2020 **

                COMMIT;
                SELECTLATESTVERSION;
            UNTIL WebIndex.NEXT = 0;
    end;

    procedure HandleShipments()
    var
        HandleWebShipments: Codeunit "WEB Handling Shipments";
    begin

        IF LineNoFilter <> '' THEN
            WebIndex.SETFILTER(WebIndex."Line no.", LineNoFilter)
        ELSE
            WebIndex.SETRANGE(WebIndex.Status, WebIndex.Status::" ");
        WebIndex.SETFILTER(WebIndex."Table No.", '%1', 50014);

        IF WebIndex.FINDSET THEN
            REPEAT
                CLEARLASTERROR;
                CLEAR(HandleWebShipments);

                //R4501 >>
                WebFunc.FlagDuplicateTransactions(WebIndex);
                IF WebIndex.Status = WebIndex.Status::" " THEN
                    //R4501 <<

                    CASE WebIndex."Table No." OF
                        50014:
                            IF NOT HandleWebShipments.RUN(WebIndex) THEN
                                RecordCALError(WebIndex);
                    END;
                WebIndex.MODIFY;
                COMMIT;
                SelectLatestVersion();
            UNTIL WebIndex.NEXT = 0;


    end;

    procedure HandleStockAvail()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        WebSetup: Record "WEB Setup";
        WEBAvail: Record "WEB Available Stock";
        Item: Record Item;
    begin
        IF LineNoFilter <> '' THEN
            EXIT;
        WebSetup.GET;
        ItemLedgEntry.SETFILTER("Entry No.", '%1..', WebSetup."Last Item Ledg. Entry");
        IF ItemLedgEntry.FINDSET THEN
            REPEAT
                WEBAvail.INIT;
                WEBAvail.SKU := ItemLedgEntry."Item No.";
                Item.GET(ItemLedgEntry."Item No.");
                Item.CALCFIELDS(Item.Inventory, Item."Qty. on Sales Order");
                WEBAvail."Line No." := 0;
                WEBAvail."Available Quantity" := Item.Inventory - Item."Qty. on Sales Order";
                WEBAvail.INSERT;
                WebSetup."Last Item Ledg. Entry" := ItemLedgEntry."Entry No.";
            UNTIL ItemLedgEntry.NEXT = 0;

        WebSetup.MODIFY;
        COMMIT;
    end;

    procedure PopulateOrderStatus()
    var
        OrderStatus: Record "WEB Order Status";
        SalesOrder: Record "Sales Header";
        WEBSetup: Record "WEB Setup";
    begin
        IF LineNoFilter <> '' THEN
            EXIT;
        WEBSetup.GET;
        IF (TIME > 230000T) AND (WEBSetup."Order Status Update" < TODAY) THEN BEGIN
            OrderStatus.DELETEALL;
            SalesOrder.SETRANGE("Document Type", SalesOrder."Document Type"::Order);
            IF SalesOrder.FINDSET THEN
                REPEAT
                    OrderStatus."Order ID" := SalesOrder."No.";
                    OrderStatus.INSERT;
                    WEBSetup."Order Status Update" := TODAY;
                    WEBSetup."Order Status Update DateTime" := CURRENTDATETIME;
                    WEBSetup.MODIFY;
                UNTIL SalesOrder.NEXT = 0;
        END;
    end;

    procedure HandleWriteOffs()
    var
        WebWriteOffs: Record "Web Write Offs";
        //ItemJournalLine: Record "Item Journal Line";
        NextLineNo: Integer;
        WEBSetup: Record "WEB Setup";
        WhseJnlLine: Record "Warehouse Journal Line";
        BinContent: Record "Bin Content";
        WebSetupRecL: Record "WEB Setup";
        WhseJnlBatch: Record "Warehouse Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        //MITL2221 ++
        IF LineNoFilter <> '' THEN
            EXIT;
        WEBSetup.GET;
        WEBSetup.TESTFIELD(WEBSetup."Stock Write Off Batch");
        WEBSetup.TESTFIELD(WEBSetup."Stock Write Reason Code");
        WebWriteOffs.SETRANGE(WebWriteOffs."Written Off", FALSE);

        IF WebWriteOffs.FINDSET THEN
            REPEAT
                NextLineNo := NextLineNo + 10000;

                WebSetupRecL.GET;
                WebSetupRecL.TESTFIELD("Web Location");
                BinContent.INIT;
                BinContent.SETRANGE("Item No.", WebWriteOffs.SKU);
                BinContent.SETRANGE("Bin Type Code", 'PUTPICK');
                BinContent.SETRANGE("Location Code", WebSetupRecL."Web Location");// MITL
                BinContent.SETFILTER(Quantity, '>=%1', WebWriteOffs.Quantity);
                IF BinContent.FINDFIRST THEN BEGIN
                    WhseJnlLine.SETRANGE(WhseJnlLine."Journal Batch Name", 'AUTO CUTS');
                    WhseJnlLine.SETRANGE(WhseJnlLine."Journal Template Name", 'ADJMT');
                    IF WhseJnlLine.FINDLAST THEN
                        NextLineNo := WhseJnlLine."Line No." + 1000
                    ELSE
                        NextLineNo := 1000;

                    WhseJnlLine.INIT;
                    WhseJnlLine."Journal Batch Name" := 'AUTO CUTS';
                    WhseJnlLine."Journal Template Name" := 'ADJMT';
                    WhseJnlLine."Line No." := NextLineNo;
                    WhseJnlLine."Registering Date" := TODAY;
                    // MITL 14137 ++
                    IF WhseJnlBatch.GET(WhseJnlLine."Journal Template Name", WhseJnlLine."Journal Batch Name", WebSetupRecL."Web Location") THEN BEGIN
                        WhseJnlBatch.TESTFIELD("No. Series");
                        CLEAR(NoSeriesMgt);
                        WhseJnlLine."Whse. Document No." :=
                          NoSeriesMgt.GetNextNo(WhseJnlBatch."No. Series", WhseJnlLine."Registering Date", FALSE);
                    END;
                    // MITL 14137 --


                    // MITL ++
                    // Location taken from Web setup instead of hardcode value
                    WebSetupRecL.GET;
                    WebSetupRecL.TESTFIELD("Web Location");
                    WhseJnlLine.VALIDATE("Location Code", WebSetupRecL."Web Location");
                    // MITL --
                    WhseJnlLine.VALIDATE(WhseJnlLine."Item No.", WebWriteOffs.SKU);
                    WhseJnlLine.INSERT(TRUE);
                    WhseJnlLine.VALIDATE("Zone Code", BinContent."Zone Code");
                    WhseJnlLine.VALIDATE("Bin Code", BinContent."Bin Code");
                    WhseJnlLine.VALIDATE(WhseJnlLine.Quantity, -WebWriteOffs.Quantity);
                    WhseJnlLine."From Bin Code" := WhseJnlLine."Bin Code";
                    WhseJnlLine."From Zone Code" := WhseJnlLine."Zone Code";
                    WhseJnlLine."To Bin Code" := 'ADJ';
                    WhseJnlLine."To Zone Code" := 'ADJUSTMENT';
                    WhseJnlLine."From Bin Type Code" := 'PUTPICK';
                    WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::"Negative Adjmt.";
                    WhseJnlLine.MODIFY(TRUE);
                    WebWriteOffs."Written Off" := TRUE;
                    WebWriteOffs.MODIFY;
                END;
            UNTIL WebWriteOffs.NEXT = 0;
        //MITL2221 **
    end;

    // procedure MultiPicks()
    // var
    //     "Read-WEBCombinedPicks": Record "WEB Combined Picks";
    //     "Insert-WEBCombinedPicks": Record "WEB Combined Picks";
    //     TEMPWEBCombinedPicks: Record "WEB Combined Picks" temporary;
    //     HeaderCreated: Boolean;
    //     SalesHeader: Record "Sales Header";
    //     SalesLine: Record "Sales Line";
    //     LineNo: Integer;
    // begin
    //     TEMPWEBCombinedPicks.DELETEALL;
    //     "Read-WEBCombinedPicks".SETRANGE(Created, FALSE);
    //     IF "Read-WEBCombinedPicks".FINDSET THEN 
    // REPEAT
    //                                                 TEMPWEBCombinedPicks.SETRANGE("Pick No.", "Read-WEBCombinedPicks"."Pick No.");
    //                                                 IF NOT TEMPWEBCombinedPicks.FINDFIRST THEN BEGIN
    //                                                     TEMPWEBCombinedPicks."Pick No." := "Read-WEBCombinedPicks"."Pick No.";
    //                                                     TEMPWEBCombinedPicks.INSERT;
    //                                                 END;
    //         UNTIL "Read-WEBCombinedPicks".NEXT = 0;

    //     TEMPWEBCombinedPicks.SETRANGE("Pick No.");
    //     IF TEMPWEBCombinedPicks.FINDSET THEN 
    // REPEAT
    //                                              "Insert-WEBCombinedPicks".SETRANGE("Pick No.", TEMPWEBCombinedPicks."Pick No.");
    //                                              IF "Insert-WEBCombinedPicks".FINDSET THEN
    //                                                  WarehouseMultiPicks("Insert-WEBCombinedPicks");
    //         UNTIL TEMPWEBCombinedPicks.NEXT = 0;



    /*
    //"Read-WEBCombinedPicks".SETRANGE("Pick No.",'123456');
    "Read-WEBCombinedPicks".SETRANGE(Created,FALSE);
    IF "Read-WEBCombinedPicks".FINDFIRST THEN 
        REPEAT
        HeaderCreated := FALSE;
        "Insert-WEBCombinedPicks".SETRANGE("Pick No.","Read-WEBCombinedPicks"."Pick No.");
        IF "Insert-WEBCombinedPicks".FINDSET THEN 
            REPEAT

                IF (NOT HeaderCreated) AND (NOT SalesHeader.GET(SalesHeader."Document Type"::Order,"Insert-WEBCombinedPicks"."Pick No.")) THEN BEGIN
                SalesHeader.INIT;
                SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                SalesHeader."No." := "Insert-WEBCombinedPicks"."Pick No.";
                SalesHeader.VALIDATE(SalesHeader."Sell-to Customer No.",'PICK'); ///will need chnaged to setup;
                SalesHeader.WebIncrementID := SalesHeader."No.";
                SalesHeader.INSERT(TRUE);
                HeaderCreated := TRUE;
                END;
                LineNo := LineNo + 1000;
                SalesLine.INIT;
                SalesLine.SetHideValidationDialog(TRUE);
                SalesLine."Document Type" := SalesHeader."Document Type"::Order;
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := LineNo;
                SalesLine.INSERT;
                SalesLine.Type := SalesLine.Type::Item;
                SalesLine.VALIDATE("No.","Insert-WEBCombinedPicks".SKU);
                SalesLine.VALIDATE(Quantity,"Insert-WEBCombinedPicks".Quantity);
                SalesLine."Description 2" := "Insert-WEBCombinedPicks"."Order No.";
                SalesLine.MODIFY(TRUE);
                "Insert-WEBCombinedPicks".Created := TRUE;
                "Insert-WEBCombinedPicks".MODIFY;

            UNTIL "Insert-WEBCombinedPicks".NEXT=0;
        UNTIL "Read-WEBCombinedPicks".NEXT=0;
    */

    // end;

    // procedure WarehouseMultiPicks(var MultiPicks: Record "WEB Combined Picks")
    // var
    //     WhseShptLine: Record "Warehouse Shipment Line";
    //     WhseWkshLine: Record "Whse. Worksheet Line";
    //     WhseShptHeader: Record "Warehouse Shipment Header";
    //     WhseMgt: Codeunit "Whse. Management";
    //     SalesLine: Record "Sales Line";
    //     i: Integer;
    //     PickNo: Code[20];
    // begin
    //     MultiPicks.SETFILTER("Pick No.", MultiPicks."Pick No.");
    //     IF MultiPicks.FINDSET THEN 
    // REPEAT
    //                                    SalesLine.SETFILTER("Document No.", MultiPicks."Order No.");
    //                                    SalesLine.SETFILTER("No.", MultiPicks.SKU);
    //                                    SalesLine.SETRANGE(Quantity, MultiPicks.Quantity);
    //                                    IF SalesLine.FINDFIRST THEN BEGIN
    //                                        WhseShptLine.SETRANGE("Source No.", SalesLine."Document No.");
    //                                        WhseShptLine.SETRANGE("Source Line No.", SalesLine."Line No.");
    //                                        IF WhseShptLine.FINDFIRST THEN BEGIN
    //                                            WITH WhseShptLine DO BEGIN
    //                                                WhseWkshLine.SETCURRENTKEY(
    //                                                  "Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.");
    //                                                WhseWkshLine.SETRANGE("Whse. Document Type", WhseWkshLine."Whse. Document Type"::Shipment);
    //                                                WhseWkshLine.SETRANGE("Whse. Document No.", "No.");
    //                                                WhseWkshLine.SETRANGE("Whse. Document Line No.", "Line No.");
    //                                                IF WhseWkshLine.FIND('-') THEN
    //                                                    EXIT;


    //                                                WhseShptHeader.GET("No.");
    //                                                i := i + 1000;
    //                                                WhseWkshLine.INIT;
    //                                                WhseWkshLine.Name := 'DEFAULT';
    //                                                WhseWkshLine."Worksheet Template Name" := 'PICK';
    //                                                WhseWkshLine.SetHideValidationDialog(TRUE);
    //                                                WhseWkshLine."Line No." := i;//WhseWkshLine."Line No." + 10000;
    //                                                WhseWkshLine."Source Type" := "Source Type";
    //                                                WhseWkshLine."Source Subtype" := "Source Subtype";
    //                                                WhseWkshLine."Source No." := "Source No.";
    //                                                WhseWkshLine."Source Line No." := "Source Line No.";
    //                                                WhseWkshLine."Source Document" := WhseMgt.GetSourceDocument("Source Type", "Source Subtype");
    //                                                WhseWkshLine."Location Code" := "Location Code";
    //                                                WhseWkshLine."Item No." := "Item No.";
    //                                                WhseWkshLine."Variant Code" := "Variant Code";
    //                                                WhseWkshLine."Unit of Measure Code" := "Unit of Measure Code";
    //                                                WhseWkshLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
    //                                                WhseWkshLine.Description := Description;
    //                                                WhseWkshLine."Description 2" := MultiPicks."Pick No.";
    //                                                WhseWkshLine."Due Date" := "Due Date";
    //                                                WhseWkshLine."Qty. Handled" := "Qty. Picked" + "Pick Qty.";
    //                                                WhseWkshLine."Qty. Handled (Base)" := "Qty. Picked (Base)" + "Pick Qty. (Base)";
    //                                                WhseWkshLine.VALIDATE(Quantity, Quantity);
    //                                                WhseWkshLine."To Zone Code" := "Zone Code";
    //                                                WhseWkshLine."To Bin Code" := "Bin Code";
    //                                                WhseWkshLine."Shelf No." := "Shelf No.";
    //                                                WhseWkshLine."Destination Type" := "Destination Type";
    //                                                WhseWkshLine."Destination No." := "Destination No.";
    //                                                IF WhseShptHeader."Shipment Date" = 0D THEN
    //                                                    WhseWkshLine."Shipment Date" := "Shipment Date"
    //                                                ELSE
    //                                                    WhseWkshLine."Shipment Date" := WhseShptHeader."Shipment Date";
    //                                                WhseWkshLine."Shipping Advice" := "Shipping Advice";
    //                                                WhseWkshLine."Shipping Agent Code" := WhseShptHeader."Shipping Agent Code";
    //                                                WhseWkshLine."Shipping Agent Service Code" := WhseShptHeader."Shipping Agent Service Code";
    //                                                WhseWkshLine."Shipment Method Code" := WhseShptHeader."Shipment Method Code";
    //                                                WhseWkshLine."Whse. Document Type" := WhseWkshLine."Whse. Document Type"::Shipment;
    //                                                WhseWkshLine."Whse. Document No." := "No.";
    //                                                WhseWkshLine."Whse. Document Line No." := "Line No.";
    //                                                WhseWkshLine.INSERT;
    //                                            END;
    //                                        END;
    //                                    END;
    //                                    MultiPicks.Created := TRUE;
    //                                    MultiPicks.MODIFY;
    //                                    PickNo := MultiPicks."Pick No.";
    //         UNTIL MultiPicks.NEXT = 0;


    //     WhseWkshLine.RESET;
    //     WhseWkshLine.SETFILTER("Description 2", PickNo);
    //     IF WhseWkshLine.FINDSET THEN
    //         CreateWarehousePick(WhseWkshLine);
    // end;

    // local procedure CreateWarehousePick(var WhseWkshLine: Record "Whse. Worksheet Line")
    // var
    //     WhseCreatePick: Report "WEB Create Pick";
    //     WkshPickLine: Record "Whse. Worksheet Line";
    // begin
    //     WkshPickLine.COPY(WhseWkshLine);
    //     WhseCreatePick.SetWkshPickLine(WkshPickLine);
    //     WhseCreatePick.GetPickNo(WhseWkshLine."Description 2");
    //     WhseCreatePick.RUNMODAL;
    //     CLEAR(WhseCreatePick);
    // end;

    procedure SetLineNoFilter(P_LineNoFilter: Text[250])
    begin
        LineNoFilter := P_LineNoFilter;
    end;
}

