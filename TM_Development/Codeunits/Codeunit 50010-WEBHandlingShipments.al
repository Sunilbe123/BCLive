codeunit 50010 "WEB Handling Shipments"
{
    // version RM 17082015,R4317,R4425,R4476,LOC

    // messjaRM 13/11/2015
    // Always ship outstanding G/L lines
    // 
    // RM 04.12.2015
    // Also ship -ve G/L Lines
    // 
    // R4317 - RM - 10.12.2015
    // Ensure that shipment with duplicate SKU&Quantity combinations are processed
    // 
    // R4425 - RM - 15.01.2015
    // Check whether the Sales Shipment ID has been used before and report error if so, added function CheckShipmentExists
    // 
    // R4476 - RM - 29.01.2016
    // Check Magento SKU is mapped to a Cross Reference, this is to allow multiple Magento SKUs to map to the one NAV item. The scenario is that the
    // different Magento SKUs represent the same item in NAV with different units.

    TableNo = "WEB Index";

    trigger OnRun()
    begin
        //RM 18.09.2015 >>
        HandleRecord(Rec);
        //RM 18.09.2015 <<
    end;

    var
        WEBSetup: Record "WEB Setup";
        WebToolbox: Codeunit "WEB Toolbox";
        WebRecord: Record "WEB Shipment Header";
        WebFunc: Codeunit "WEB Functions";

    procedure InsertRecord(var WEBIndex: Record "WEB Index")
    var
        // Customer: Record Customer;
        SalesOrder: Record "Sales Header";
        WEBShipLines: Record "WEB Shipment Lines";
        WEBShipLinesL: Record "WEB Shipment Lines"; //MITL5731
        SalesOrderLines: Record "Sales Line";
        Continue: Text;
        SalesPost: Codeunit "Sales-Post";
        LineNoFilter: Text[250];
        CrossRefNo: Code[20];
        ItemNo: Code[20];
        WebSetupRecL: Record "WEB Setup";
        //SalesOrderL: Record "Sales Header";
        SalesOrderNoL: Code[20];
        WhseShipPosted: Boolean; //MITL5731
        SalesLine2L: Record "Sales Line";//MITL.VS.20200819
    begin
        // MITL ++
        WebSetupRecL.GET;
        WebSetupRecL.TESTFIELD("Web Location");
        // MITL --
        WebRecord.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebRecord.FINDFIRST THEN BEGIN
            SalesOrder.Reset(); //MITL4092
            IF NOT SalesOrder.GET(SalesOrder."Document Type"::Order, WebRecord."Order ID") THEN BEGIN
                SalesOrder.SETRANGE(WebIncrementID, WebRecord."Order ID");
                SalesOrder.SETRANGE(SalesOrder."Document Type", SalesOrder."Document Type"::Order);
                IF NOT SalesOrder.FINDFIRST THEN
                    WebToolbox.UpdateIndex(WEBIndex, 2, 'Order Not Found ' + WebRecord."Order ID");
                COMMIT;
                // SELECTLATESTVERSION; //SM
            END;

            //location
            //MITL5731 ++
            WEBShipLinesL.Reset();
            WEBShipLinesL.SetRange("Shipment ID", WebRecord."Shipment ID");
            IF WEBShipLinesL.FindSet() then
                repeat
                    SalesOrderLines.RESET;
                    SalesOrderLines.SetCurrentKey("Document Type", "Document No.", Type, "No."); // MITL.AJ.20200603 Indexing correction
                    SalesOrderLines.SETRANGE("Document Type", SalesOrder."Document Type");
                    SalesOrderLines.SETRANGE("Document No.", SalesOrder."No.");
                    SalesOrderLines.SETRANGE(Type, SalesOrderLines.Type::Item);
                    SalesOrderLines.SETRANGE("No.", WEBShipLinesL.Sku);
                    // MITL ++
                    SalesOrderLines.SETRANGE("Location Code", WebSetupRecL."Web Location");
                    // MITL --
                    IF NOT SalesOrderLines.ISEMPTY THEN //BEGIN //MITL4092
                        IF NOT CheckandPostWarehouseShipment(SalesOrder) THEN
                            WebToolbox.UpdateIndex(WEBIndex, 2, 'Items not picked') //MITL4092
                        else begin
                            COMMIT;
                            WhseShipPosted := TRUE;
                        END;                                                                     // END; //MITL4092

                Until (WEBShipLinesL.Next() = 0) or (WhseShipPosted);
            //MITL5731 **
            // SELECTLATESTVERSION; //SM
            SalesOrderLines.RESET;

            if NOT WEBIndex."Pick Processed" then//MITL.VS.20200819
                                                 //R4425 >>
                CheckShipmentExists(WEBIndex);
            //R4425 <<
            IF WEBIndex.Error = '' THEN BEGIN
                SalesOrderNoL := SalesOrder."No.";
                UpdateSalesOrder(SalesOrder."No.");
                SalesOrder.Reset(); //MITL4092
                SalesOrder.Get(SalesOrder."Document Type"::Order, SalesOrderNoL);

                WEBShipLines.Reset(); //MITL4092
                WEBShipLines.SETCURRENTKEY("Shipment ID", LineType); // MITL.AJ.20200603 Indexing correction
                WEBShipLines.SETRANGE("Shipment ID", WebRecord."Shipment ID");
                WEBShipLines.SETRANGE(WEBShipLines."LineType", WebRecord."LineType");

                //RM 13.11.2015 >>
                IF WEBShipLines.FINDSET THEN BEGIN
                    REPEAT
                        //RM 13.11.2015 <<
                        //R4476 >>
                        CrossRefNo := WebFunc.ReturnCrossReference(WEBShipLines.Sku);
                        IF CrossRefNo = '' THEN
                            ItemNo := WEBShipLines.Sku
                        ELSE
                            ItemNo := WebFunc.ReturnItemNo(WEBShipLines.Sku);
                        //R4476 <<

                        SalesOrderLines.SETRANGE("Document Type", SalesOrderLines."Document Type"::Order);
                        SalesOrderLines.SETRANGE("Document No.", SalesOrder."No.");
                        //R4476 >>
                        SalesOrderLines.SETRANGE("No.", ItemNo);
                        //R4476 <<
                        // SalesOrderLines.SETFILTER(Quantity, WEBShipLines.QTY);//MITL.VS.Commented.20200901
                        SalesOrderLines.SETRANGE(Processed, FALSE); //R4317
                        IF NOT SalesOrderLines.FINDFIRST THEN
                            Continue := 'Order line not found ' + SalesOrderLines.GETFILTERS
                        ELSE BEGIN
                            // MITL ++
                            IF SalesOrderLines."Location Code" <> WebSetupRecL."Web Location" THEN
                                // MITL --
                                EVALUATE(SalesOrderLines."Qty. to Ship", WEBShipLines.QTY);
                            SalesOrderLines.VALIDATE("Qty. to Ship");
                            IF SalesOrderLines."Outstanding Quantity" >= SalesOrderLines."Qty. to Ship" THEN BEGIN
                                // MITL ++
                                IF SalesOrderLines."Location Code" <> WebSetupRecL."Web Location" THEN
                                    // MITL --
                                    SalesOrderLines.VALIDATE("Qty. to Ship");

                                //R4317 >>
                                SalesOrderLines.Processed := TRUE;
                                //R4317 <<
                                SalesOrderLines.MODIFY(TRUE);
                            END ELSE
                                Continue := 'Qty to Ship is greater than Oustanding Qty';
                        END;
                    UNTIL WEBShipLines.NEXT = 0;

                    //RM 13.11.2015 >>
                    SalesOrderLines.SETRANGE("No.");
                    SalesOrderLines.SETRANGE(Quantity);
                    SalesOrderLines.SETRANGE(Type, SalesOrderLines.Type::"G/L Account");
                    SalesOrderLines.SetFilter("Outstanding Qty. (Base)", '<>0');//MITL.VS.20200828
                    IF SalesOrderLines.FINDSET THEN
                        REPEAT
                            //RM 04.12.2015 >>
                            SalesOrderLines.VALIDATE("Qty. to Ship", SalesOrderLines.Quantity); //Qty. to Ship always 0
                            //RM 04.12.2015 <<
                            SalesOrderLines.MODIFY(TRUE);
                        UNTIL SalesOrderLines.NEXT = 0;
                END;
                //RM 13.11.2015 <<

                //R4317 >>
                SalesOrderLines.RESET;
                SalesOrderLines.SETRANGE("Document Type", SalesOrderLines."Document Type"::Order);
                SalesOrderLines.SETRANGE("Document No.", SalesOrder."No.");
                IF SalesOrderLines.FINDSET THEN
                    REPEAT
                        SalesOrderLines.Processed := FALSE;
                        SalesOrderLines.MODIFY;
                    UNTIL SalesOrderLines.NEXT = 0;
                //R4317 <<
            END;


            IF Continue <> '' THEN
                WebToolbox.UpdateIndex(WEBIndex, 2, Continue)
            ELSE BEGIN
                IF WEBIndex.Status = WEBIndex.Status::" " THEN BEGIN
                    SalesOrder.SetHideValidationDialog(true); //MITL4092
                    Clear(SalesPost);
                    SalesPost.RUN(SalesOrder);
                    //MITL.vs.20200828++
                    if WEBIndex."Pick Processed" then begin
                        WEBIndex."Pick Processed" := false;
                        WEBIndex.Modify();
                    end;
                    //MITL.vs.20200828--
                    //MITL.VS.20200814++
                    if CheckPartialPicked(WebRecord."Shipment ID") then
                        WebToolbox.UpdateIndex(WEBIndex, 2, 'Items picked partially')
                    else
                        //MITL.VS.20200814--
                        WebToolbox.UpdateIndex(WEBIndex, 1, '');
                END;
            END;
            //MITL.VS.20200902++
            if CheckAndPostQtyShippedNotInvoiced(WebRecord."Shipment ID") then
                WebToolbox.UpdateIndex(WEBIndex, 1, '');
            //MITL.VS.20200902--
        END ELSE
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Record Not Found');
    end;

    // procedure ModifyRecord(var WEBIndex: Record "WEB Index")
    // begin
    //     WebRecord.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
    //     IF WebRecord.FINDFIRST THEN BEGIN
    //         InsertRecord(WEBIndex); //RM 19082015, see HandleRecord, not needed
    //     END ELSE
    //         WebToolbox.UpdateIndex(WEBIndex, 2, 'Record not found to update');
    // end;

    procedure DeleteRecord(var WEBIndex: Record "WEB Index")
    begin
        WebRecord.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebRecord.FINDFIRST THEN BEGIN
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Delete shipment not allowed!');
        END ELSE
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Record not found to update!');
    end;

    procedure HandleRecord(var WEBIndex: Record "WEB Index")
    var
        WebOrder: Record "WEB Order Header";
    begin
        WebRecord.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebRecord.FINDFIRST THEN BEGIN
            GetWEBSetup;
            CASE WebRecord."LineType" OF
                WebRecord."LineType"::Insert:
                    InsertRecord(WEBIndex);
                    //RM 19.08.2015 >>
                WebRecord."LineType"::Modify:
                    InsertRecord(WEBIndex);  //likely temporary
                                             //WebRecord.LineType::Modify : ModifyRecord(WEBIndex);
                                             //RM 19.08.2015 <<
                WebRecord."LineType"::Delete:
                    DeleteRecord(WEBIndex);
            END;
        END;
    end;

    procedure GetWEBSetup()
    begin
        WEBSetup.GET;
    end;

    procedure CheckShipmentExists(var WEBIndex: Record "WEB Index")
    var
        SalesShipHeader: Record "Sales Shipment Header";
    begin
        //R4425 >>
        SalesShipHeader.Reset(); //MITL4092
        SalesShipHeader.SETRANGE("No.", WebRecord."Shipment ID");
        IF NOT SalesShipHeader.ISEMPTY THEN
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Shipment ' + WebRecord."Shipment ID" + ' Already Exists - as posted shipment');
        //R4425 <<
    end;

    local procedure CheckandPostWarehouseShipment(var SalesHeader: Record "Sales Header") SuccessR: Boolean  //MITL4092
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        invoice: Boolean;
        WhsePostShipment: Codeunit "Whse.-Post Shipment";
    begin
        WarehouseShipmentLine.Reset(); //MITL4092
        WarehouseShipmentLine.SETRANGE("Source No.", SalesHeader."No.");
        WarehouseShipmentLine.SETFILTER("Qty. Picked", '<>0'); //MITL4092
        WarehouseShipmentLine.SetFilter("Qty. Outstanding", '<>0'); //MITL4092
        IF WarehouseShipmentLine.FINDFIRST THEN BEGIN
            WarehouseShipmentHeader.Reset(); //MITL4092
            WarehouseShipmentHeader.GET(WarehouseShipmentLine."No.");
            //MITL_6870_20200703++
            WarehouseShipmentHeader."Posting Date" := WebRecord."Shipment Date";
            WarehouseShipmentHeader."Shipment Date" := WebRecord."Shipment Date";
            WarehouseShipmentHeader.Modify();
            //MITL_6870_20200703--
            invoice := FALSE;
            WarehouseShipmentHeader.SetHideValidationDialog(True); //MITL4092
            WhsePostShipment.SetPostingSettings(invoice);
            WhsePostShipment.SetPrint(FALSE);
            WhsePostShipment.RUN(WarehouseShipmentLine);
            CLEAR(WhsePostShipment);
            SuccessR := True; //MITL4092
        END Else
            SuccessR := false; //MITL4092
    end;


    local procedure UpdateSalesOrder(SalesorderNo: Code[20])
    var
        SalesOrderL: Record "Sales Header";
        PostedSalesShipHdr: Record "Sales Shipment Header";//MITL.VS.20200818
        NoSeriesMgt: codeunit NoSeriesManagement;//mitl.vs.20200910
    begin
        Clear(SalesOrderL);
        IF SalesOrderL.Get(SalesOrderL."Document Type"::Order, SalesorderNo) then begin
            //MITL.VS.20200818++
            IF CheckShipmentExistsInPosted THEN begin
                Clear(NoSeriesMgt);//mitl.vs.20200910
                SalesOrderL."Shipping No." := NoSeriesMgt.GetNextNo(SalesOrderL."Shipping No. Series", SalesOrderL."Posting Date", true);//mitl.vs.20200910
            end else
                //MITL.VS.20200818--
                SalesOrderL.Validate(SalesOrderL."Shipping No.", WebRecord."Shipment ID");
            SalesOrderL.Validate(SalesOrderL."Posting Date", WebRecord."Shipment Date");
            SalesOrderL.Ship := TRUE;
            SalesOrderL.Invoice := TRUE;
            SalesOrderL."Web Shipment Increment Id" := WebRecord."Shipment ID";
            SalesOrderL."Web Shipment Tracing No." := WebRecord."Tracking Number";
            SalesOrderL."Web Shipment Carrier" := WebRecord."Tracking Carrier";
            SalesOrderL.MODIFY();
        end;
    end;
    //MITL.VS.20200814++
    //Check Partially Registered Pick 
    local procedure CheckPartialPicked(WebShipmentIdP: Code[20]) PartialR: Boolean
    var
        WebShipmentLineL: Record "WEB Shipment Lines";
        WebShipmentHeaderL: Record "WEB Shipment Header";
        SalesLinesL: Record "Sales Line";
        RegisteredPickLine: Record "Registered Whse. Activity Line";
        WhseShipLinesL: Record "Warehouse Shipment Line";
        RegisteredQtyL: Decimal;
        ShipmentQtyL: Decimal;
        CrossRefNoL: Code[20];
        ItemNoL: Code[20];
        WhseShippedQtyL: Decimal;
    begin
        PartialR := false;
        WebShipmentHeaderL.Reset();
        WebShipmentHeaderL.SetRange("Shipment ID", WebShipmentIdP);
        if WebShipmentHeaderL.FindFirst() then begin
            WebShipmentLineL.Reset();
            WebShipmentLineL.SetRange("Shipment ID", WebShipmentHeaderL."Shipment ID");
            if WebShipmentLineL.FindSet() then
                repeat
                    CrossRefNoL := WebFunc.ReturnCrossReference(WebShipmentLineL.Sku);
                    IF CrossRefNoL = '' THEN
                        ItemNoL := WebShipmentLineL.Sku
                    ELSE
                        ItemNoL := WebFunc.ReturnItemNo(WebShipmentLineL.Sku);

                    SalesLinesL.Reset();
                    SalesLinesL.SetRange("Document Type", SalesLinesL."Document Type"::Order);
                    SalesLinesL.SetRange("Document No.", WebShipmentHeaderL."Order ID");
                    SalesLinesL.SetRange(Type, SalesLinesL.Type::Item);
                    SalesLinesL.SetRange("No.", ItemNoL);
                    if SalesLinesL.FindFirst() then begin
                        RegisteredQtyL := 0;
                        RegisteredPickLine.Reset();
                        RegisteredPickLine.SetRange("Activity Type", RegisteredPickLine."Activity Type"::Pick);
                        RegisteredPickLine.SetRange("Source Type", 37);
                        RegisteredPickLine.SetRange("Source Subtype", 1);
                        RegisteredPickLine.SetRange("Source No.", SalesLinesL."Document No.");
                        RegisteredPickLine.SetRange("Source Line No.", SalesLinesL."Line No.");
                        RegisteredPickLine.SetRange("Item No.", ItemNoL);
                        if RegisteredPickLine.FindSet() then
                            repeat
                                RegisteredQtyL += RegisteredPickLine.Quantity;
                            until RegisteredPickLine.Next() = 0;

                        Evaluate(ShipmentQtyL, WebShipmentLineL.QTY);
                        //MITL.VS.20200819++
                        WhseShipLinesL.Reset();
                        WhseShipLinesL.SetRange("Source Type", 37);
                        WhseShipLinesL.SetRange("Source Subtype", 1);
                        WhseShipLinesL.SetRange("Source No.", SalesLinesL."Document No.");
                        WhseShipLinesL.SetRange("Source Line No.", SalesLinesL."Line No.");
                        WhseShipLinesL.SetRange("Item No.", ItemNoL);
                        if WhseShipLinesL.FindFirst() then
                            ShipmentQtyL += WhseShipLinesL."Qty. Shipped";
                        //MITL.VS.20200819--    
                        if ShipmentQtyL > RegisteredQtyL then
                            PartialR := true;
                    end;
                until (WebShipmentLineL.Next() = 0) OR PartialR;
        end;
    end;
    //MITL.VS.20200814--
    //MITL.VS.20200818++
    procedure CheckShipmentExistsInPosted() ReturnR: Boolean
    var
        SalesShipHeader: Record "Sales Shipment Header";
    begin
        ReturnR := false;
        SalesShipHeader.Reset();
        IF SalesShipHeader.Get(WebRecord."Shipment ID") then begin
            ReturnR := true;
        end;
    end;
    //MITL.VS.20200818--
    //MITL.VS.20200902++
    local procedure CheckAndPostQtyShippedNotInvoiced(WebShipmentIdP: Code[20]) ReturnR: Boolean
    var
        SalesLineL: Record "Sales Line";
        SalesHeaderL: Record "Sales Header";
        WebShipHeaderL: Record "WEB Shipment Header";
        WebShipLinesL: Record "WEB Shipment Lines";
        CheckQtyL: Decimal;
        WebShipQtyL: Decimal;
        CheckInvPostL: Boolean;
        SalesPost: Codeunit "Sales-Post";
        SalesOrderL: Record "Sales Header";
    begin
        ReturnR := false;
        WebShipHeaderL.Reset();
        WebShipHeaderL.SetRange("Shipment ID", WebShipmentIdP);
        if WebShipHeaderL.FindFirst() then begin
            CheckQtyL := 0;
            WebShipQtyL := 0;
            CheckInvPostL := false;
            WebShipLinesL.Reset();
            WebShipLinesL.SetRange("Shipment ID", WebShipHeaderL."Shipment ID");
            if WebShipLinesL.FindSet then
                repeat
                    Evaluate(WebShipQtyL, WebShipLinesL.QTY);
                    SalesLineL.Reset();
                    SalesLineL.SetRange("Document Type", SalesLineL."Document Type"::Order);
                    SalesLineL.SetRange("Document No.", WebShipHeaderL."Order ID");
                    SalesLineL.SetRange(Type, SalesLineL.type::Item);
                    SalesLineL.SetRange("No.", WebShipLinesL.Sku);
                    if SalesLineL.FindFirst then begin
                        CheckQtyL := SalesLineL."Qty. Shipped (Base)" - SalesLineL."Qty. Invoiced (Base)";
                        if (CheckQtyL > 0) AND (CheckQtyL <= WebShipQtyL) then
                            CheckInvPostL := true;
                    end;
                until (WebShipLinesL.Next = 0) OR CheckInvPostL;

            if CheckInvPostL then begin
                SalesHeaderL.Get(SalesHeaderL."Document Type"::Order, WebShipHeaderL."Order ID");
                SalesHeaderL.SetHideValidationDialog(true);
                // UpdateSalesOrder(SalesHeaderL."No.");
                SetFlag(SalesHeaderL);
                Clear(SalesPost);
                SalesPost.RUN(SalesHeaderL);
                ReturnR := true;
            end;
        end;
    end;

    local procedure SetFlag(Var SalesHeaderP: Record "Sales Header")
    begin
        SalesHeaderP.SetHideValidationDialog(true);
        if Not SalesHeaderP.Invoice then begin
            SalesHeaderP.Ship := true;
            SalesHeaderP.Invoice := true;
        end
    end;
    //MITL.VS.20200902--
}

