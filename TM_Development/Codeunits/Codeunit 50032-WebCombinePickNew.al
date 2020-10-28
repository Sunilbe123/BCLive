codeunit 50032 "WEB Combine Pick New"
{
    // version 

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
        DeletePicksToCombine;
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
        // WebIndex.MODIFY; //MITL3694 - Commented to avoid page update error

        IF COPYSTR(WebIndex.Error, 1, 29) = COPYSTR('An attempt was made to change an old version of a Sales', 1, 29) THEN BEGIN
            WebIndex.Status := WebIndex.Status::" ";
            WebIndex.Error := '';
            // WebIndex.MODIFY; //MITL3694 - Commented to avoid page update error
        END;
    end;

    procedure HandleStaticData()
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

        WebIndex.SETRANGE(Status, WebIndex.Status::" ");
        WebIndex.SETFILTER("Table No.", '50016|50017|50009');
        jj := WebIndex.COUNT;
        IF WebIndex.FINDSET THEN
            REPEAT
                ii := ii + 1;
                CLEARLASTERROR;
                CLEAR(HandleWebItem);
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
            UNTIL WebIndex.NEXT = 0;
    end;

    procedure HandleOrders()
    var
        HandleWebItem: Codeunit "WEB Handling Item";
        HandleItemAttribute: Codeunit "WEB Handling Item Attribute";
        HandleWebOrder: Codeunit "WEB Handling Order";
        HandleWebCustomer: Codeunit "WEB Handling Customer";
        HandleWebBillTo: Codeunit "WEB Handling BillTo";
        HandleWebShipTo: Codeunit "WEB Handling ShipTo";
        HandleWebCredits: Codeunit "WEB Handling Credit Memo";
    begin

        //do orders before shipments
        WebIndex.SetCurrentKey(Status, "Table No.", "Line no.");
        WebIndex.SETRANGE(Status, WebIndex.Status::" ");
        WebIndex.SETFILTER("Table No.", '50010|50027|50013|50018');
        WebIndex.SETFILTER("Line no.", LineNoFilter);  //TEST
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
                WebIndex.MODIFY;
                COMMIT;
                SELECTLATESTVERSION;
            UNTIL WebIndex.NEXT = 0;
    end;

    procedure HandleShipments()
    var
        HandleWebShipments: Codeunit "WEB Handling Shipments";
    begin
        WebIndex.SetCurrentKey(Status, "Table No.", "Line no.");
        WebIndex.SETRANGE(Status, WebIndex.Status::" ");
        WebIndex.SETFILTER("Table No.", '50014');
        WebIndex.SETFILTER("Line no.", LineNoFilter); //TEST
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
            UNTIL WebIndex.NEXT = 0;

    end;

    procedure HandleStockAvail()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        WebSetup: Record "WEB Setup";
        WEBAvail: Record "WEB Available Stock";
        Item: Record Item;
    begin
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
    end;

    procedure PopulateOrderStatus()
    var
        OrderStatus: Record "WEB Order Status";
        SalesOrder: Record "Sales Header";
        WEBSetup: Record "WEB Setup";
    begin
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

    procedure DailyReconciliation()
    var
        WEBDailyReconciliation: Record "WEB Daily Reconciliation";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        QtyShipped: Decimal;
        WebShipmentHeader: Record "WEB Shipment Header";
        WebShipmentLines: Record "WEB Shipment Lines";
        SalesCreditHeader: Record "Sales Cr.Memo Header";
        SalesCreditLine: Record "Sales Cr.Memo Line";
        WebCreditHeader: Record "WEB Credit Header";
        RoxxLog: Record "Rox Logging";
        WebOrderHeader: Record "WEB Order Header";
        recWebShipmentHeader: Record "WEB Shipment Header";
    begin
        WEBDailyReconciliation.SETRANGE("Reconciliation Complete", FALSE);
        IF WEBDailyReconciliation.FINDSET THEN
            REPEAT
                CASE WEBDailyReconciliation."WEB Type" OF
                    WEBDailyReconciliation."WEB Type"::Order:
                        BEGIN
                            SalesInvoiceHeader.SETRANGE(WebIncrementID, WEBDailyReconciliation.ID);
                            WEBDailyReconciliation."Invoiced Value" := 0; //RM 10.12.2015

                            //R4580 >>
                            WEBDailyReconciliation."Cancelled Order" := WebFunc.TransactionCancelled(WEBDailyReconciliation.ID, 50010);
                            WEBDailyReconciliation.MODIFY;
                            //R4580 <<
                            IF SalesInvoiceHeader.FINDSET THEN
                                REPEAT
                                    SalesInvoiceHeader.CALCFIELDS(SalesInvoiceHeader."Amount Including VAT");
                                    WEBDailyReconciliation.Invoiced := TRUE;
                                    WEBDailyReconciliation."Invoiced Value" := WEBDailyReconciliation."Invoiced Value" + SalesInvoiceHeader."Amount Including VAT";
                                    WEBDailyReconciliation.MODIFY;
                                UNTIL SalesInvoiceHeader.NEXT = 0;
                            IF WEBDailyReconciliation.Invoiced THEN
                                //RM 10.12.2015 >>
                                IF ABS(WEBDailyReconciliation."WEB Value" - WEBDailyReconciliation."Invoiced Value") > 0.01 THEN BEGIN
                                    //RM 10.12.2015 <<
                                    WEBDailyReconciliation.Error := TRUE;
                                    WEBDailyReconciliation.MODIFY;
                                    //RM 10.12.2015 >>
                                END ELSE BEGIN
                                    WEBDailyReconciliation.Error := FALSE;
                                    WEBDailyReconciliation."Reconciliation Complete" := TRUE;
                                    WEBDailyReconciliation.MODIFY;
                                    //RM 10.12.2015 <<
                                END;
                            IF NOT WEBDailyReconciliation.Invoiced THEN BEGIN
                                SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
                                SalesHeader.SETRANGE(WebIncrementID, WEBDailyReconciliation.ID);
                                WEBDailyReconciliation."Ordered Value" := 0; //RM 10/12/2015
                                IF SalesHeader.FINDSET THEN
                                    REPEAT
                                        SalesHeader.CALCFIELDS(SalesHeader."Amount Including VAT");
                                        WEBDailyReconciliation.Ordered := TRUE;
                                        WEBDailyReconciliation."Ordered Value" := WEBDailyReconciliation."Ordered Value" + SalesHeader."Amount Including VAT";
                                        WEBDailyReconciliation.MODIFY;
                                    UNTIL SalesHeader.NEXT = 0;

                                //R4540 >>
                                IF WEBDailyReconciliation.Ordered THEN BEGIN
                                    //R4540 <<
                                    //RM 10.12.2015 >>
                                    IF ABS(WEBDailyReconciliation."WEB Value" - WEBDailyReconciliation."Ordered Value") > 0.01 THEN BEGIN
                                        //RM 10.12.2015 <<
                                        WEBDailyReconciliation.Error := TRUE;
                                        WEBDailyReconciliation.MODIFY;
                                        //RM 10.12.2015 >>
                                    END ELSE BEGIN
                                        WEBDailyReconciliation.Error := FALSE;
                                        WEBDailyReconciliation."Reconciliation Complete" := TRUE;
                                        WEBDailyReconciliation.MODIFY;
                                        //RM 10.12.2015 <<
                                    END;
                                    //R4540 >>
                                END ELSE BEGIN
                                    WebOrderHeader.SETRANGE("Order ID", WEBDailyReconciliation.ID);
                                    IF WebOrderHeader.FINDFIRST THEN BEGIN
                                        RoxxLog.SETCURRENTKEY(WebIncrementID);
                                        RoxxLog.SETRANGE(WebIncrementID, WebOrderHeader."Order ID");
                                        IF RoxxLog.FINDFIRST AND (STRPOS(RoxxLog.ItemType, 'Sales Order Deletion') <> 0)
                                        AND (STRPOS(RoxxLog.ItemType, 'Line') = 0) THEN BEGIN
                                            WEBDailyReconciliation."Further Information" := 'Deleted by credit';
                                            WEBDailyReconciliation.Error := FALSE;
                                            WEBDailyReconciliation."Reconciliation Complete" := TRUE;
                                            WEBDailyReconciliation."Deleted by Credit Memo" := TRUE;
                                            WEBDailyReconciliation.MODIFY;
                                        END;
                                    END;
                                END;
                                //R4540 <<
                            END;
                        END;

                    WEBDailyReconciliation."WEB Type"::Shipment:
                        BEGIN
                            SalesShipmentLine.SetCurrentKey("Document No.", Type); // MITL.SM.20200304 Indexing Added
                            SalesShipmentLine.SETRANGE("Document No.", WEBDailyReconciliation.ID);
                            SalesShipmentLine.SETRANGE(Type, SalesShipmentLine.Type::Item);
                            IF SalesShipmentLine.FINDSET THEN BEGIN
                                WEBDailyReconciliation."Shipment Created" := TRUE;
                                WEBDailyReconciliation."Shipment Quantities" := 0;
                                REPEAT
                                    WEBDailyReconciliation."Shipment Quantities" += SalesShipmentLine.Quantity;
                                UNTIL SalesShipmentLine.NEXT = 0;
                                WEBDailyReconciliation.MODIFY;
                            END
                            // >> MITL19.04.2017
                            ELSE BEGIN
                                recWebShipmentHeader.RESET;
                                recWebShipmentHeader.SETRANGE("Shipment ID", WEBDailyReconciliation.ID);
                                IF recWebShipmentHeader.FINDFIRST THEN BEGIN
                                    SalesShipmentLine.RESET;
                                    SalesShipmentLine.SetCurrentKey("Order No.", Type); // MITL.SM.20200304 Indexing Added
                                    SalesShipmentLine.SETRANGE("Order No.", recWebShipmentHeader."Order ID");
                                    SalesShipmentLine.SETRANGE(Type, SalesShipmentLine.Type::Item);
                                    IF SalesShipmentLine.FINDSET THEN BEGIN
                                        WEBDailyReconciliation."Shipment Created" := TRUE;
                                        WEBDailyReconciliation."Shipment Quantities" := 0;
                                        REPEAT
                                            WEBDailyReconciliation."Shipment Quantities" += SalesShipmentLine.Quantity;
                                        UNTIL SalesShipmentLine.NEXT = 0;
                                        WEBDailyReconciliation.MODIFY;
                                    END;
                                END;
                            END;
                            // << MITL19.04.2017

                            WEBDailyReconciliation."Shipment Quantities - Magento" := 0;
                            WebShipmentHeader.SETRANGE("Shipment ID", WEBDailyReconciliation.ID);
                            IF WebShipmentHeader.FINDFIRST THEN BEGIN
                                WebShipmentLines.SETRANGE("Order ID", WebShipmentHeader."Shipment ID");
                                WebShipmentLines.SETRANGE("LineType", WebShipmentHeader."LineType");
                                WebShipmentLines.SETRANGE("Date Time", WebShipmentHeader."Date Time");
                                IF WebShipmentLines.FINDSET THEN
                                    REPEAT
                                        EVALUATE(QtyShipped, WebShipmentLines.QTY);
                                        WEBDailyReconciliation."Shipment Quantities - Magento" += QtyShipped;
                                    UNTIL WebShipmentLines.NEXT = 0;
                            END;

                            IF WEBDailyReconciliation."Shipment Created"
                            AND (WEBDailyReconciliation."Shipment Quantities" = WEBDailyReconciliation."Shipment Quantities - Magento") THEN
                                WEBDailyReconciliation."Reconciliation Complete" := TRUE
                            ELSE
                                WEBDailyReconciliation.Error := TRUE;
                            WEBDailyReconciliation.MODIFY;
                        END;

                    WEBDailyReconciliation."WEB Type"::Credit:
                        BEGIN
                            SalesCreditHeader.SETCURRENTKEY("Pre-Assigned No.");
                            SalesCreditHeader.SETRANGE("Pre-Assigned No.", WEBDailyReconciliation.ID);
                            WEBDailyReconciliation."Invoiced Value" := 0; //RM 10.12.2015
                            IF SalesCreditHeader.FINDSET THEN
                                REPEAT
                                    SalesCreditHeader.CALCFIELDS(SalesCreditHeader."Amount Including VAT");
                                    WEBDailyReconciliation.Invoiced := TRUE;
                                    WEBDailyReconciliation."Invoiced Value" := WEBDailyReconciliation."Invoiced Value" + SalesCreditHeader."Amount Including VAT";
                                    WEBDailyReconciliation."Reconciliation Complete" := TRUE; //RM 10.12.2015
                                    WEBDailyReconciliation.MODIFY;
                                UNTIL SalesCreditHeader.NEXT = 0;
                            IF WEBDailyReconciliation.Invoiced THEN
                                //RM 10.12.2015 >>
                                IF ABS(WEBDailyReconciliation."WEB Value" - WEBDailyReconciliation."Invoiced Value") > 0.01 THEN BEGIN
                                    //RM 10.12.2015 <<
                                    WEBDailyReconciliation.Error := TRUE;
                                    WEBDailyReconciliation.MODIFY;
                                    //RM 10.12.2015 >>
                                END ELSE BEGIN
                                    WEBDailyReconciliation.Error := FALSE;
                                    WEBDailyReconciliation."Reconciliation Complete" := TRUE;
                                    WEBDailyReconciliation.MODIFY;
                                    //RM 10.12.2015 <<
                                END;
                            IF NOT WEBDailyReconciliation.Invoiced THEN BEGIN
                                SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::"Credit Memo");
                                SalesHeader.SETRANGE("No.", WEBDailyReconciliation.ID);
                                WEBDailyReconciliation."Ordered Value" := 0; //RM 10/12/2015
                                IF SalesHeader.FINDSET THEN
                                    REPEAT
                                        SalesHeader.CALCFIELDS(SalesHeader."Amount Including VAT");
                                        WEBDailyReconciliation.Ordered := TRUE;
                                        WEBDailyReconciliation."Ordered Value" := WEBDailyReconciliation."Ordered Value" + SalesHeader."Amount Including VAT";
                                        WEBDailyReconciliation."Reconciliation Complete" := TRUE;
                                        WEBDailyReconciliation.MODIFY;
                                    UNTIL SalesHeader.NEXT = 0;
                                IF WEBDailyReconciliation.Ordered THEN BEGIN
                                    //RM 10.12.2015 >>
                                    IF ABS(WEBDailyReconciliation."WEB Value" - WEBDailyReconciliation."Ordered Value") > 0.01 THEN BEGIN
                                        //RM 10.12.2015 <<
                                        WEBDailyReconciliation.Error := TRUE;
                                        WEBDailyReconciliation.MODIFY;
                                        //RM 10.12.2015 >>
                                    END ELSE BEGIN
                                        WEBDailyReconciliation.Error := FALSE;
                                        WEBDailyReconciliation."Reconciliation Complete" := TRUE;
                                        WEBDailyReconciliation.MODIFY;
                                        //RM 10.12.2015 <<
                                    END;
                                END ELSE BEGIN
                                    WebCreditHeader.SETRANGE("Credit Memo ID", WEBDailyReconciliation.ID);
                                    IF WebCreditHeader.FINDFIRST THEN BEGIN
                                        RoxxLog.SETCURRENTKEY(WebIncrementID);
                                        RoxxLog.SETRANGE(WebIncrementID, WebCreditHeader."Order ID");
                                        IF RoxxLog.FINDFIRST AND (STRPOS(RoxxLog.ItemType, 'Sales Order Deletion') <> 0) THEN BEGIN
                                            WEBDailyReconciliation."Further Information" := 'Order/Credit Delete';
                                            WEBDailyReconciliation.Error := FALSE;
                                            WEBDailyReconciliation."Reconciliation Complete" := TRUE;
                                            WEBDailyReconciliation.MODIFY;
                                        END;
                                    END ELSE BEGIN
                                        WEBDailyReconciliation."Further Information" := 'Other';
                                        WEBDailyReconciliation.Error := TRUE;
                                        WEBDailyReconciliation."Reconciliation Complete" := FALSE;
                                        WEBDailyReconciliation.MODIFY;
                                    END;
                                END;
                            END;
                        END;

                END;
            UNTIL WEBDailyReconciliation.NEXT = 0;
    end;

    procedure HandleWriteOffs()
    var
        WebWriteOffs: Record "Web Write Offs";
        ItemJournalLine: Record "Item Journal Line";
        NextLineNo: Integer;
        WEBSetup: Record "WEB Setup";
    begin
        //MITL2221 ++
        WEBSetup.GET;
        WEBSetup.TESTFIELD(WEBSetup."Stock Write Off Batch");
        WEBSetup.TESTFIELD(WEBSetup."Stock Write Reason Code");
        WebWriteOffs.SETRANGE(WebWriteOffs."Written Off", FALSE);
        ItemJournalLine.SETRANGE("Journal Template Name", 'ITEM');
        ItemJournalLine.SETRANGE("Journal Batch Name", WEBSetup."Stock Write Off Batch");
        IF ItemJournalLine.FINDLAST THEN
            NextLineNo := ItemJournalLine."Line No." + 10000
        ELSE
            NextLineNo := 10000;

        IF WebWriteOffs.FINDSET THEN
            REPEAT
                NextLineNo := NextLineNo + 10000;
                ItemJournalLine.INIT;
                ItemJournalLine."Journal Template Name" := 'ITEM';
                ItemJournalLine."Journal Batch Name" := WEBSetup."Stock Write Off Batch";
                ItemJournalLine."Line No." := NextLineNo;
                ItemJournalLine.VALIDATE("Item No.", WebWriteOffs.SKU);
                ItemJournalLine."Posting Date" := TODAY;
                ItemJournalLine."Entry Type" := ItemJournalLine."Entry Type"::"Negative Adjmt.";
                ItemJournalLine."Document No." := 'WO ' + FORMAT(TODAY);
                ItemJournalLine."Location Code" := 'HANLEY';
                ItemJournalLine.VALIDATE("Unit of Measure Code", 'PCS');
                ItemJournalLine.VALIDATE(Quantity, WebWriteOffs.Quantity);
                ItemJournalLine."Reason Code" := WEBSetup."Stock Write Reason Code";
                ItemJournalLine.INSERT(TRUE);
                WebWriteOffs."Written Off" := TRUE;
                WebWriteOffs.MODIFY;
            UNTIL WebWriteOffs.NEXT = 0;
        //MITL2221 **
    end;

    local procedure CreateWarehousePick(var WhseWkshLine: Record "Whse. Worksheet Line")
    var
        WhseCreatePick: Report "WEB Create Pick";
        WkshPickLine: Record "Whse. Worksheet Line";
    begin

        WkshPickLine.COPY(WhseWkshLine);
        WhseCreatePick.UseRequestPage(false); //MITL4015
        // WhseCreatePick.InitializeReport(UserId, 0, 0, 3, False, False, False, False, False, False, False, False, False); //MITL4015
        WhseCreatePick.SetWkshPickLine(WkshPickLine);
        WhseCreatePick.GetPickNo(WhseWkshLine."Description 2");
        WhseCreatePick.RUNMODAL;
        CLEAR(WhseCreatePick);
    end;

    local procedure DeletePicksToCombine()
    var
        WEBCombinedPicks: Record "WEB Combined Picks";
        TEMPWEBCombinedPicks: Record "WEB Combined Picks" temporary;
        HeaderCreated: Boolean;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin
        CreateTempWebCombPicks(TEMPWEBCombinedPicks);

        IF TEMPWEBCombinedPicks.FINDSET THEN
            REPEAT
                WEBCombinedPicks.Reset();
                WEBCombinedPicks.SETRANGE("Pick No.", TEMPWEBCombinedPicks."Pick No.");
                IF WEBCombinedPicks.FINDSET THEN
                    FindandDeletePicks(WEBCombinedPicks);
            UNTIL TEMPWEBCombinedPicks.NEXT = 0;
    end;

    local procedure FindandDeletePicks(WEBCombinedPicksP: Record "WEB Combined Picks")
    var
        WEBCombinedPicks: Record "WEB Combined Picks";
        WhseActivityLineL: Record "Warehouse Activity Line";
        WhseActivityHeaderL: Record "Warehouse Activity Header";
        WEBCombPicksL: Record "WEB Combined Picks";
        WEBCombPicksP: Record "WEB Combined Picks";
    begin
        WEBCombPicksL.SetRange("Pick No.", WEBCombinedPicksP."Pick No.");
        IF WEBCombPicksL.FindSet() THEN
            repeat
                WhseActivityHeaderL.Reset();
                WhseActivityHeaderL.SetCurrentKey(Type, "Source Document", "Source No."); // MITL.SM.20200304 Indexing Added
                WhseActivityHeaderL.SetRange(Type, WhseActivityHeaderL.Type::Pick);
                WhseActivityHeaderL.SetRange("Source Document", WhseActivityLineL."Source Document"::"Sales Order");
                WhseActivityHeaderL.SetRange("Source No.", WEBCombPicksL."Order No.");
                IF WhseActivityHeaderL.FindFirst() then begin
                    WhseActivityHeaderL.Delete(True);
                    WEBCombPicksL.Mark();
                end;
            Until WEBCombPicksL.Next() = 0;
        WEBCombPicksL.MarkedOnly(TRUE);
        WEBCombPicksP := WEBCombPicksL;
        WarehouseCombinePick(WEBCombPicksP);
    end;

    local procedure CreateTempWebCombPicks(var TEMPWEBCombinedPicks: Record "WEB Combined Picks")
    var
        WEBCombinedPicks: Record "WEB Combined Picks";
    begin
        TEMPWEBCombinedPicks.DeleteAll();

        WEBCombinedPicks.Reset();
        WEBCombinedPicks.SetCurrentKey(Created); // MITL.SM.20200304 Indexing Added
        WEBCombinedPicks.SetRange(Created, false);
        IF WEBCombinedPicks.FindSet() then
            REPEAT
                TEMPWEBCombinedPicks.SetRange("Pick No.", WEBCombinedPicks."Pick No.");
                IF NOT TEMPWEBCombinedPicks.FINDFIRST THEN BEGIN
                    TEMPWEBCombinedPicks."Pick No." := WEBCombinedPicks."Pick No.";
                    TEMPWEBCombinedPicks.INSERT;
                END;
            UNTIL WEBCombinedPicks.NEXT = 0;
    end;

    procedure WarehouseCombinePick(var CombinePickP: Record "WEB Combined Picks")
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        WhseWkshLine: Record "Whse. Worksheet Line";
        WhseWkshLine2: Record "Whse. Worksheet Line";
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseMgt: Codeunit "Whse. Management";
        SalesLineL: Record "Sales Line";
        i: Integer;
        PickNo: Code[20];
    begin
        CombinePickP.SETFILTER("Pick No.", CombinePickP."Pick No.");
        CombinePickP.SetRange(Created, false); // MITL15Jan2020.RJ
        i := 1000; // MITL15Jan2020.RJ
        IF CombinePickP.FINDSET THEN
            REPEAT
                SalesLineL.Reset();
                SalesLineL.SetCurrentKey("Document Type", "Document No.", "No.", Quantity); // MITL.SM.20200304 Indexing Added
                SalesLineL.SetRange("Document Type", SalesLineL."Document Type"::Order);
                SalesLineL.SETFILTER("Document No.", CombinePickP."Order No.");
                SalesLineL.SETFILTER("No.", CombinePickP.SKU);
                SalesLineL.SETRANGE(Quantity, CombinePickP.Quantity);
                IF SalesLineL.FINDFIRST THEN BEGIN
                    WhseShptLine.SetCurrentKey("Source No.", "Source Line No.", "Item No.", Quantity); // MITL.SM.20200304 Indexing Added
                    WhseShptLine.SETRANGE("Source No.", SalesLineL."Document No.");
                    WhseShptLine.SETRANGE("Source Line No.", SalesLineL."Line No.");
                    WhseShptLine.SETRANGE("Item No.", SalesLineL."No.");
                    WhseShptLine.SETRANGE(Quantity, SalesLineL.Quantity);
                    IF WhseShptLine.FINDFIRST THEN BEGIN
                        WhseWkshLine2.Reset();
                        WhseWkshLine2.SETRANGE(WhseWkshLine2.Name, 'DEFAULT');
                        WhseWkshLine2.SETRANGE(WhseWkshLine2."Worksheet Template Name", 'PICK');
                        IF WhseWkshLine2.FindLast() then
                            i := 1000 + WhseWkshLine2."Line No." // MITL15Jan2020.RJ
                        ELSE
                            i := 1000;

                        WITH WhseShptLine DO BEGIN

                            WhseWkshLine.Reset();
                            WhseWkshLine.SETCURRENTKEY("Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.");
                            WhseWkshLine.SETRANGE(WhseWkshLine.Name, 'DEFAULT');
                            WhseWkshLine.SETRANGE(WhseWkshLine."Worksheet Template Name", 'PICK');
                            WhseWkshLine.SETRANGE("Whse. Document Type", WhseWkshLine."Whse. Document Type"::Shipment);
                            WhseWkshLine.SETRANGE("Whse. Document No.", WhseShptLine."No.");
                            WhseWkshLine.SETRANGE("Whse. Document Line No.", WhseShptLine."Line No.");
                            IF NOT WhseWkshLine.FindFirst() THEN BEGIN
                                WhseShptHeader.GET(WhseShptLine."No.");

                                WhseWkshLine.INIT;
                                WhseWkshLine.Name := 'DEFAULT';
                                WhseWkshLine."Worksheet Template Name" := 'PICK';
                                WhseWkshLine.SetHideValidationDialog(TRUE);
                                WhseWkshLine."Line No." := i;
                                WhseWkshLine."Source Type" := "Source Type";
                                WhseWkshLine."Source Subtype" := "Source Subtype";
                                WhseWkshLine."Source No." := "Source No.";
                                WhseWkshLine."Source Line No." := "Source Line No.";
                                WhseWkshLine."Source Document" := WhseMgt.GetSourceDocument("Source Type", "Source Subtype");
                                WhseWkshLine."Location Code" := "Location Code";
                                WhseWkshLine."Item No." := "Item No.";
                                WhseWkshLine."Variant Code" := "Variant Code";
                                WhseWkshLine."Unit of Measure Code" := "Unit of Measure Code";
                                WhseWkshLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
                                WhseWkshLine.Description := Description;
                                WhseWkshLine."Description 2" := CombinePickP."Pick No.";
                                WhseWkshLine."Due Date" := "Due Date";
                                WhseWkshLine."Qty. Handled" := "Qty. Picked" + "Pick Qty.";
                                WhseWkshLine."Qty. Handled (Base)" := "Qty. Picked (Base)" + "Pick Qty. (Base)";
                                WhseWkshLine.VALIDATE(Quantity, Quantity);
                                WhseWkshLine."To Zone Code" := "Zone Code";
                                WhseWkshLine."To Bin Code" := "Bin Code";
                                WhseWkshLine."Shelf No." := "Shelf No.";
                                WhseWkshLine."Destination Type" := "Destination Type";
                                WhseWkshLine."Destination No." := "Destination No.";
                                IF WhseShptHeader."Shipment Date" = 0D THEN
                                    WhseWkshLine."Shipment Date" := "Shipment Date"
                                ELSE
                                    WhseWkshLine."Shipment Date" := WhseShptHeader."Shipment Date";
                                WhseWkshLine."Shipping Advice" := "Shipping Advice";
                                WhseWkshLine."Shipping Agent Code" := WhseShptHeader."Shipping Agent Code";
                                WhseWkshLine."Shipping Agent Service Code" := WhseShptHeader."Shipping Agent Service Code";
                                WhseWkshLine."Shipment Method Code" := WhseShptHeader."Shipment Method Code";
                                WhseWkshLine."Whse. Document Type" := WhseWkshLine."Whse. Document Type"::Shipment;
                                WhseWkshLine."Whse. Document No." := "No.";
                                WhseWkshLine."Whse. Document Line No." := "Line No.";
                                WhseWkshLine.INSERT;
                            END;
                        END;
                    END;
                END;
                CombinePickP.Created := TRUE;
                CombinePickP.MODIFY;
                PickNo := CombinePickP."Pick No.";
            Until CombinePickP.Next() = 0;


        WhseWkshLine.RESET;
        WhseWkshLine.SETFILTER("Description 2", PickNo);

        IF WhseWkshLine.FINDSET THEN Begin
            CreateWarehousePick(WhseWkshLine);
        End;
    end;

    local procedure CheckPickExists(PickNoP: Code[20])
    var
        WhseActHeaderL: Record "Warehouse Activity Header";
    begin
        WhseActHeaderL.Reset();
        WhseActHeaderL.SetRange(Type, WhseActHeaderL.Type::Pick);
        WhseActHeaderL.SetRange("No.", PickNoP);
        If WhseActHeaderL.FindFirst() then
            Error('Pick no. %1 is already present in the system', PickNoP);
    end;
}

