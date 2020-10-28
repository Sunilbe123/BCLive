codeunit 50033 UtilitytoProcessBulkOrder
{
    //Version MITL4192
    trigger OnRun()
    begin
        HandleRecord();
    end;

    var
        SalesHeaderG: Record "Sales Header";
        WEBSetup: Record "WEB Setup";
        WebToolbox: Codeunit "WEB Toolbox";
        WebFunc: Codeunit "WEB Functions";



    procedure InsertRecord(Var ProcessRecordP: Record ProcessBulkRecord)
    var
        SalesOrderL: Record "Sales Header";
        WEBShipLines: Record "WEB Shipment Lines";
        SalesOrderLines: Record "Sales Line";
        Continue: Text;
        SalesPost: Codeunit "Sales-Post";
        CrossRefNo: Code[20];
        ItemNo: Code[20];
        WebSetupRecL: Record "WEB Setup";
        SalesOrderNoL: Code[20];
        SalesOrder2L: Record "Sales Header";
    begin
        WebSetupRecL.Get();
        SalesOrderL.Reset();
        SalesOrderL.SetRange("Document Type", SalesOrderL."Document Type"::Order);
        SalesOrderL.SetFilter("No.", ProcessRecordP."Order No.");
        IF NOT SalesOrderL.FindFirst() THEN BEGIN
            SalesOrderL.SETRANGE(SalesOrderL."Document Type", SalesOrderL."Document Type"::Order);
            SalesOrderL.SETRANGE(WebIncrementID, ProcessRecordP."Order No.");
            IF NOT SalesOrderL.FINDFIRST THEN
                UpdateIndex(ProcessRecordP, false, ProcessRecordP."Order No." + ' Order Not Found');
        END;

        if not SalesOrderL.FindFirst() then begin
            UpdateIndex(ProcessRecordP, false, 'Order not found');
            exit;
        end;

        SalesOrderLines.RESET;
        SalesOrderLines.SETRANGE("Document Type", SalesOrderL."Document Type");
        SalesOrderLines.SETRANGE("Document No.", SalesOrderL."No.");
        SalesOrderLines.SETRANGE(Type, SalesOrderLines.Type::Item);
        SalesOrderLines.SETRANGE("Location Code", WebSetupRecL."Web Location");
        // SalesOrderLines.SetFilter("Outstanding Quantity", '<>0');
        IF NOT SalesOrderLines.ISEMPTY THEN begin
            IF NOT CheckandPostWarehouseShipment(SalesOrderL) THEN begin
                SalesOrderLines.SetFilter("Outstanding Quantity", '<>0');
                if SalesOrderLines.FindFirst() then
                    UpdateIndex(ProcessRecordP, false, 'Items not picked')
                else
                    UpdateSalesOrderFields(SalesOrderL);
            end else
                UpdateSalesOrderFields(SalesOrderL);
            // COMMIT;
        End;

        // SalesOrderLines.RESET;

        // SalesOrderNoL := SalesOrderL."No.";
        // UpdateSalesOrderFields(SalesOrderL."No.");

        // SalesOrderL.Reset();
        // IF SalesOrderL.Get(SalesOrderL."Document Type"::Order, SalesOrderNoL) THEN begin
        IF ShipmentPosted(SalesOrderL."No.") THEN begin
            SalesOrderL.Ship := true;
            SalesOrderL.Invoice := true;
            SalesOrderL."Shipping No." := '';
            // SalesOrderL.Modify();
        END;
        // End;


        WEBShipLines.Reset();
        WEBShipLines.SETCURRENTKEY("Shipment ID", LineType);
        WEBShipLines.SetRange("Order ID", SalesOrderL."No.");
        IF WEBShipLines.FINDSET THEN BEGIN
            REPEAT
                CrossRefNo := WebFunc.ReturnCrossReference(WEBShipLines.Sku);
                IF CrossRefNo = '' THEN
                    ItemNo := WEBShipLines.Sku
                ELSE
                    ItemNo := WebFunc.ReturnItemNo(WEBShipLines.Sku);

                SalesOrderLines.SetFilter("Outstanding Quantity", '');
                SalesOrderLines.SETRANGE("Document Type", SalesOrderLines."Document Type"::Order);
                SalesOrderLines.SETRANGE("Document No.", SalesOrderL."No.");
                SalesOrderLines.SETRANGE("No.", ItemNo);
                SalesOrderLines.SETFILTER(Quantity, WEBShipLines.QTY);
                SalesOrderLines.SETRANGE(Processed, FALSE);
                IF NOT SalesOrderLines.FINDFIRST THEN
                    Continue := 'Order line not found ' + SalesOrderLines.GETFILTERS
                ELSE BEGIN
                    IF SalesOrderLines."Outstanding Quantity" >= SalesOrderLines."Qty. to Ship" THEN BEGIN
                        IF SalesOrderLines."Location Code" <> WebSetupRecL."Web Location" THEN
                            EVALUATE(SalesOrderLines."Qty. to Ship", WEBShipLines.QTY);
                        SalesOrderLines.VALIDATE("Qty. to Ship");

                        SalesOrderLines.Processed := TRUE;
                        SalesOrderLines.MODIFY(TRUE);
                    END ELSE
                        Continue := 'Qty to Ship is greater than Oustanding Qty';
                END;
            UNTIL WEBShipLines.NEXT = 0;

            SalesOrderLines.SETRANGE("No.");
            SalesOrderLines.SETRANGE(Quantity);
            SalesOrderLines.SETRANGE(Type, SalesOrderLines.Type::"G/L Account");
            SalesOrderLines.SetRange("Quantity Shipped", 0);
            IF SalesOrderLines.FINDSET THEN
                REPEAT
                    IF ShipmentPosted(SalesOrderLines."Document No.") THEN begin
                        SalesOrderLines.VALIDATE("Qty. to Ship", SalesOrderLines.Quantity);
                        SalesOrderLines.MODIFY(TRUE);
                    End;
                UNTIL SalesOrderLines.NEXT = 0;

            SalesOrderLines.RESET;
            SalesOrderLines.SETRANGE("Document Type", SalesOrderLines."Document Type"::Order);
            SalesOrderLines.SETRANGE("Document No.", SalesOrderL."No.");
            IF SalesOrderLines.FINDSET THEN
                REPEAT
                    SalesOrderLines.Processed := FALSE;
                    SalesOrderLines.MODIFY;
                UNTIL SalesOrderLines.NEXT = 0;
        END;


        IF Continue <> '' THEN
            UpdateIndex(ProcessRecordP, false, Continue)
        ELSE BEGIN
            Clear(SalesPost);
            IF ShipmentPosted(SalesOrderL."No.") THEN begin
                Commit();
                // SalesOrderL.SetHideValidationDialog(true);
                if SalesPost.RUN(SalesOrderL) then
                    UpdateIndex(ProcessRecordP, true, '')
                else
                    UpdateIndex(ProcessRecordP, false, GetLastErrorText());
            END ELSE
                UpdateIndex(ProcessRecordP, false, 'Can not post');
        end;
    End;


    procedure HandleRecord()
    var
        WindowG: Dialog;
        ProcessRecordL: Record ProcessBulkRecord;
    begin
        WindowG.Open('Processing Record #1#########');
        ProcessRecordL.Reset();
        // ProcessRecordL.SetFilter("Order No.", '510574|510575|510581|510582|200724411-85|510670|510637'); // Temp
        // ProcessRecordL.SetFilter("Order No.", '200724411-85'); // Temp
        ProcessRecordL.SetRange(Processed, false);
        IF ProcessRecordL.FINDSET THEN BEGIN
            REPEAT
                WindowG.Update(1, ProcessRecordL."Order No.");
                Sleep(30);
                InsertRecord(ProcessRecordL);
                ProcessRecordL.Modify();
                UpdateStatus(ProcessRecordL."Order No.")
            UNTIL ProcessRecordL.Next() = 0;
            WindowG.Close();
        END ELSE begin
            WindowG.Close();
            EXIT;
        end;

    END;

    procedure GetWEBSetup()
    begin
        WEBSetup.GET;
    end;

    local procedure CheckandPostWarehouseShipment(var SalesHeader: Record "Sales Header") SuccessR: Boolean  //MITL4092
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        invoice: Boolean;
        WhsePostShipment: Codeunit "Whse.-Post Shipment";
    begin
        WarehouseShipmentLine.Reset();
        WarehouseShipmentLine.SETRANGE("Source No.", SalesHeader."No.");
        WarehouseShipmentLine.SETFILTER("Qty. Picked", '<>0');
        WarehouseShipmentLine.SetFilter("Qty. Outstanding", '<>0');
        IF WarehouseShipmentLine.FINDFIRST THEN BEGIN
            CLEAR(WhsePostShipment);
            WarehouseShipmentHeader.Reset();
            WarehouseShipmentHeader.GET(WarehouseShipmentLine."No.");
            invoice := FALSE;
            WarehouseShipmentHeader.SetHideValidationDialog(True);
            WhsePostShipment.SetPostingSettings(invoice);
            WhsePostShipment.SetPrint(FALSE);
            Commit();
            if not WhsePostShipment.RUN(WarehouseShipmentLine) then begin
                SuccessR := false;
                exit;
            end;
            SuccessR := True;
        END Else
            SuccessR := false;
    end;

    local procedure UpdateSalesOrderFields(var SalesHeadL: Record "Sales Header")
    var
        // SalesHeadL: Record "Sales Header";
        WebShipmentHeadL: Record "WEB Shipment Header";
        ProcessBulkRecordL: Record ProcessBulkRecord;
    begin

        SalesHeadL.Reset();
        ProcessBulkRecordL.Reset();
        ProcessBulkRecordL.SetCurrentKey("Order No.");
        ProcessBulkRecordL.Setrange("Order No.", SalesHeadL."No.");
        IF ProcessBulkRecordL.FINDFIRST THEN BEGIN
            IF SalesHeadL.Get(SalesHeadL."Document Type"::Order, SalesHeadL."No.") then begin
                WebShipmentHeadL.Reset();
                WebShipmentHeadL.SetRange("Order ID", SalesHeadL."No.");
                WebShipmentHeadL.SetRange("Shipment ID", ProcessBulkRecordL."Whse. Shipment No.");
                IF WebShipmentHeadL.FindFirst() THEN BEGIN
                    SalesHeadL."Web Shipment Increment Id" := WebShipmentHeadL."Shipment ID";
                    SalesHeadL.Validate(SalesHeadL."Shipping No.", WebShipmentHeadL."Shipment ID");
                    SalesHeadL.Validate(SalesHeadL."Posting Date", WebShipmentHeadL."Shipment Date");
                    SalesHeadL."Web Shipment Tracing No." := WebShipmentHeadL."Tracking Number";
                    SalesHeadL."Web Shipment Carrier" := WebShipmentHeadL."Tracking Carrier";
                    // SalesHeadL.MODIFY();
                END ELSE
                    UpdateIndex(ProcessBulkRecordL, false, 'WEB Shipment does not exist for WEB Order ' + SalesHeadL."No.");
            end;
        END;
    end;

    local procedure UpdateStatus(SalesorderNo: Code[20])
    var
        SalesInvHeadL: Record "Sales Invoice Header";
        ProcessBulkRecordL: Record ProcessBulkRecord;
    begin
        Clear(SalesInvHeadL);
        SalesInvHeadL.SetRange(WebOrderID, SalesorderNo);
        IF SalesInvHeadL.FindFirst() then begin
            ProcessBulkRecordL.Reset();
            ProcessBulkRecordL.Setrange("Order No.", SalesorderNo);
            IF ProcessBulkRecordL.FINDFIRST THEN BEGIN
                ProcessBulkRecordL.Processed := TRUE;
                ProcessBulkRecordL."Sales Invoice No." := SalesInvHeadL."No.";
                ProcessBulkRecordL."Customer No." := SalesInvHeadL."Sell-to Customer No.";
                ProcessBulkRecordL.Error := '';
                ProcessBulkRecordL.MODIFY();
            END;
        end;
    end;

    procedure UpdateIndex(var ProcessRecordP: Record ProcessBulkRecord; ProcessedP: Boolean; ErrorText: Text)
    begin
        ProcessRecordP.Processed := ProcessedP;
        ProcessRecordP.Error := ErrorText;
        // ProcessRecordP.Modify();
        // Commit();
    end;

    local procedure ShipmentPosted(OrderNoP: Code[20]): Boolean
    var
        SalesLineL: Record "Sales Line";
    begin
        SalesLineL.Reset();
        SalesLineL.SetRange("Document Type", SalesLineL."Document Type"::Order);
        SalesLineL.SetRange("Document No.", OrderNoP);
        SalesLineL.SetRange(Type, SalesLineL.Type::Item);
        SalesLineL.SetFilter("Quantity Shipped", '<>0');
        IF SalesLineL.FindFirst() THEN
            Exit(true)
        ELSE
            Exit(false);
    end;


}