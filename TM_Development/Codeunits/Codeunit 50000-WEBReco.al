codeunit 50000 "WEB Reco"
{
    // MITL19.04.2017  - SM - 19.04.2017
    //   Code fix applied for the reconcilication of the shipment where the web ID and NAV Document No. differs.


    trigger OnRun()
    begin
        DailyReconciliation;
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
        WebFunc: Codeunit "WEB Functions";
        WebCreditHeaderVal: Record "WEB Credit Header";
        CreditTotal: Decimal;
        WebCreditLineRec: Record "WEB Credit Lines";
        WebCreditQty: Decimal;
        TempWebCreditQty: Decimal;
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
                                    //WEBDailyReconciliation."Reconciliation Complete" := TRUE; //RM 10.12.2015
                                    WEBDailyReconciliation.MODIFY;
                                UNTIL SalesInvoiceHeader.NEXT = 0;
                            // MITL ++
                            CreditTotal := 0;
                            WebCreditHeaderVal.RESET;
                            WebCreditHeaderVal.SETCURRENTKEY("Order ID");
                            WebCreditHeaderVal.SETRANGE("Order ID", WEBDailyReconciliation.ID);
                            IF WebCreditHeaderVal.FINDSET THEN
                                REPEAT
                                    CreditTotal += WebCreditHeaderVal."Grand Total";
                                UNTIL WebCreditHeaderVal.NEXT = 0;
                            // MITL --

                            IF WEBDailyReconciliation.Invoiced THEN
                                //RM 10.12.2015 >>
                                IF ABS((WEBDailyReconciliation."WEB Value" - CreditTotal) - WEBDailyReconciliation."Invoiced Value") > 0.01 THEN BEGIN
                                    // MITL substracted CreditTotal
                                    //IF WEBDailyReconciliation.Value <> WEBDailyReconciliation."Invoiced Value" THEN BEGIN
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
                                        //WEBDailyReconciliation."Reconciliation Complete" := TRUE; //RM 10.12.2015
                                        WEBDailyReconciliation.MODIFY;
                                    UNTIL SalesHeader.NEXT = 0;

                                //R4540 >>
                                IF WEBDailyReconciliation.Ordered THEN BEGIN
                                    //IF WEBDailyReconciliation.Ordered THEN
                                    //R4540 <<
                                    //RM 10.12.2015 >>
                                    IF ABS((WEBDailyReconciliation."WEB Value" - CreditTotal) - WEBDailyReconciliation."Ordered Value") > 0.01 THEN BEGIN
                                        // MITL substracted CreditTotal
                                        //IF WEBDailyReconciliation.Value <> WEBDailyReconciliation."Ordered Value" THEN BEGIN
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
                                        IF RoxxLog.FINDLAST AND (STRPOS(RoxxLog.ItemType, 'Sales Order Deletion') <> 0)
                                        AND (STRPOS(RoxxLog.ItemType, 'Line') = 0) THEN BEGIN // MITL changed from FINDFIRST to FINDLAST
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
                                WebShipmentLines.SETRANGE("Shipment ID", WebShipmentHeader."Shipment ID"); // MITL Changed to Order ID with Shipment ID
                                WebShipmentLines.SETRANGE("LineType", WebShipmentHeader."LineType");
                                WebShipmentLines.SETRANGE("Date Time", WebShipmentHeader."Date Time");
                                IF WebShipmentLines.FINDSET THEN
                                    REPEAT
                                        EVALUATE(QtyShipped, WebShipmentLines.QTY);
                                        WEBDailyReconciliation."Shipment Quantities - Magento" += QtyShipped;
                                    UNTIL WebShipmentLines.NEXT = 0;

                                // MITL ++
                                WebCreditQty := 0;
                                WebCreditLineRec.RESET;
                                WebCreditLineRec.SETCURRENTKEY("Order ID", "LineType", "Date Time", "Line No");
                                WebCreditLineRec.SETRANGE("Order ID", WebShipmentHeader."Shipment ID");
                                IF WebCreditLineRec.FINDSET THEN
                                    REPEAT
                                        TempWebCreditQty := 0;
                                        EVALUATE(TempWebCreditQty, WebCreditLineRec.QTY);
                                        WebCreditQty += TempWebCreditQty;
                                    UNTIL WebCreditLineRec.NEXT = 0;
                                WEBDailyReconciliation."Shipment Quantities - Magento" :=
                                  WEBDailyReconciliation."Shipment Quantities - Magento" - WebCreditQty;
                                // MITL --
                            END;

                            IF (WEBDailyReconciliation."Shipment Created")
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
                                    //IF WEBDailyReconciliation.Value <> WEBDailyReconciliation."Invoiced Value" THEN BEGIN
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
                                        //IF WEBDailyReconciliation.Value <> WEBDailyReconciliation."Ordered Value" THEN BEGIN
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
}

