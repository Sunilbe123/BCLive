codeunit 50013 "WEB Index Handling - Comb Pick"
{
    // version RM 17082015,R4501,R4580

    // R4501 - RM - 31.01.2016
    // As per Matt's request do not process duplicate transactions(inserts) that were completed succesfully already!
    // 
    // R4580 - RM - 14.02.2016
    // Added "Cancelled Order" field
    // 
    // MITL19.04.2017  - SM - 19.04.2017
    //   Code fix applied for the reconcilication of the shipment where the web ID and NAV Document No. differs.


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
        MultiPicks;
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

    procedure MultiPicks()
    var
        "Read-WEBCombinedPicks": Record "WEB Combined Picks";
        "Insert-WEBCombinedPicks": Record "WEB Combined Picks";
        TEMPWEBCombinedPicks: Record "WEB Combined Picks" temporary;
        HeaderCreated: Boolean;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin
        TEMPWEBCombinedPicks.DELETEALL;
        "Read-WEBCombinedPicks".SETRANGE(Created, FALSE);
        IF "Read-WEBCombinedPicks".FINDSET THEN
            REPEAT
                TEMPWEBCombinedPicks.SETRANGE("Pick No.", "Read-WEBCombinedPicks"."Pick No.");
                IF NOT TEMPWEBCombinedPicks.FINDFIRST THEN BEGIN
                    TEMPWEBCombinedPicks."Pick No." := "Read-WEBCombinedPicks"."Pick No.";
                    TEMPWEBCombinedPicks.INSERT;
                END;
            UNTIL "Read-WEBCombinedPicks".NEXT = 0;

        TEMPWEBCombinedPicks.SETRANGE("Pick No.");
        IF TEMPWEBCombinedPicks.FINDSET THEN
            REPEAT
                "Insert-WEBCombinedPicks".SETRANGE("Pick No.", TEMPWEBCombinedPicks."Pick No.");
                IF "Insert-WEBCombinedPicks".FINDSET THEN
                    WarehouseMultiPicks("Insert-WEBCombinedPicks");
            UNTIL TEMPWEBCombinedPicks.NEXT = 0;



        /*
        //"Read-WEBCombinedPicks".SETRANGE("Pick No.",'123456');
        "Read-WEBCombinedPicks".SETRANGE(Created,FALSE);
        IF "Read-WEBCombinedPicks".FINDFIRST THEN REPEAT
          HeaderCreated := FALSE;
          "Insert-WEBCombinedPicks".SETRANGE("Pick No.","Read-WEBCombinedPicks"."Pick No.");
          IF "Insert-WEBCombinedPicks".FINDSET THEN REPEAT
        
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

    end;

    procedure WarehouseMultiPicks(var MultiPicks: Record "WEB Combined Picks")
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        WhseWkshLine: Record "Whse. Worksheet Line";
        WhseWkshLine2: Record "Whse. Worksheet Line";
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseMgt: Codeunit "Whse. Management";
        SalesLine: Record "Sales Line";
        i: Integer;
        PickNo: Code[20];
    begin
        // MultiPicks.SETFILTER("Pick No.", MultiPicks."Pick No.");
        IF MultiPicks.FINDSET THEN
            REPEAT
                SalesLine.Reset;
                SalesLine.SETFILTER("Document No.", MultiPicks."Order No.");
                SalesLine.SETFILTER("No.", MultiPicks.SKU);
                SalesLine.SETRANGE(Quantity, MultiPicks.Quantity);
                IF SalesLine.FINDFIRST THEN BEGIN
                    WhseShptLine.Reset;
                    WhseShptLine.SETRANGE("Source No.", SalesLine."Document No.");
                    WhseShptLine.SETRANGE("Source Line No.", SalesLine."Line No.");
                    IF WhseShptLine.FINDFIRST THEN BEGIN
                        WITH WhseShptLine DO BEGIN
                            WhseWkshLine.Reset();
                            WhseWkshLine.SETCURRENTKEY("Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.");
                            WhseWkshLine.SETRANGE("Whse. Document Type", WhseWkshLine."Whse. Document Type"::Shipment);
                            WhseWkshLine.SETRANGE("Whse. Document No.", WhseShptLine."No.");
                            WhseWkshLine.SETRANGE("Whse. Document Line No.", WhseShptLine."Line No.");
                            WhseWkshLine.SETRANGE(WhseWkshLine.Name, 'DEFAULT');
                            WhseWkshLine.SETRANGE(WhseWkshLine."Worksheet Template Name", 'PICK');
                            IF NOT WhseWkshLine.FindFirst() THEN BEGIN
                                WhseShptHeader.GET(WhseShptLine."No.");
                                WhseWkshLine2.Reset();
                                // WhseWkshLine2.SETCURRENTKEY("Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.");
                                WhseWkshLine2.SETRANGE(Name, 'DEFAULT');
                                WhseWkshLine2.SETRANGE("Worksheet Template Name", 'PICK');
                                IF WhseWkshLine2.FindLast() then
                                    i := WhseWkshLine2."Line No." + 1000
                                Else
                                    i := i + 1000;

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
                                WhseWkshLine."Description 2" := MultiPicks."Pick No.";
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
                MultiPicks.Created := TRUE;
                MultiPicks.MODIFY;
                PickNo := MultiPicks."Pick No.";
            UNTIL MultiPicks.NEXT = 0;


        WhseWkshLine2.RESET;
        WhseWkshLine2.SETRANGE(WhseWkshLine2.Name, 'DEFAULT');
        WhseWkshLine2.SETRANGE(WhseWkshLine2."Worksheet Template Name", 'PICK');
        WhseWkshLine2.SETFILTER("Description 2", PickNo);
        IF WhseWkshLine2.FINDSET THEN
            CreateWarehousePick(WhseWkshLine2);
    end;

    local procedure CreateWarehousePick(var WhseWkshLineP: Record "Whse. Worksheet Line")
    var
        WhseCreatePick: Report "WEB Create Pick";
        WkshPickLine: Record "Whse. Worksheet Line";
    begin
        WkshPickLine.COPY(WhseWkshLineP);
        WhseCreatePick.UseRequestPage(false);
        WhseCreatePick.SetWkshPickLine(WkshPickLine);
        WhseCreatePick.GetPickNo(WhseWkshLineP."Description 2");
        WhseCreatePick.RUNMODAL;
        CLEAR(WhseCreatePick);
    end;
}

