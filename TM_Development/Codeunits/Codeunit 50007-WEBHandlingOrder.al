codeunit 50007 "WEB Handling Order"
{
    // version RM 17082015,R4426,R4425,R4476,R4561,R4560,R4565,LOC,230,MITL332

    // 
    // RM 11.12.2015
    // Cut Size changes
    // 
    // R4426 - RM - 15.01.2016
    // When creating orders fail if the Customer ID zero (or blank) AND Customer Email is also blank
    // 
    // R4425 - RM - 15.01.2016
    // Amended CheckOrderAlreadyExists to report errors where the order has been created before. Need to check Posted Sales Invoice
    // as well as order
    // 
    // R4476 - RM - 29.01.2016
    // Check Magento SKU is mapped to a Cross Reference, this is to allow multiple Magento SKUs to map to the one NAV item. The scenario is that the
    // different Magento SKUs represent the same item in NAV with different units.
    // 
    // R4561 - RM - 10.02.2016
    // Modded WEBCheckCustomer to return default customer when no Customer ID/Email is returned from Magento
    // 
    // R4560 - RM - 14.02.2016
    // Ignore duplicate sales order lines inserted within a second of the first set - Magento issue
    // Added function DeDuplicateOrderLines
    // 
    // R4565 - RM - 07.03.2016
    // Remove general journal line for test orders
    // MITL-SP  Case_230  06/08/18  Code Added
    //SM_Business Channel - New field created in Web Order Header and Line for passing the value of Business Channel from Magento to NAV Dimensions.
    //MITL3321- Change in thc connector to use customer id nstead of email.

    TableNo = "WEB Index";

    trigger OnRun()
    begin
        //RM 18.09.2015 >>
        HandleOrder(Rec);
        //RM 18.09.2015 <<
    end;

    var
        WEBSetup: Record "WEB Setup";
        WebToolbox: Codeunit "WEB Toolbox";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        WebOrderHeader: Record "WEB Order Header";
        WEBOrderLines: Record "WEB Order Lines";
        Customer: Record Customer;
        Mapping: Record "WEB Mapping";
        TotalVATLines: Decimal;
        TotalDiscount: Decimal;
        WebFunc: Codeunit "WEB Functions";

    procedure InsertOrder(var WEBIndex: Record "WEB Index")
    var
        ShipDisc: Decimal;
        ShippingErrors: Text;
    begin

        WebCheckErrors(WEBIndex);
        IF WEBIndex.Status <> WEBIndex.Status::" " THEN
            EXIT;

        WEBCheckCustomer(Customer); //need to check why this function is called twice in webcheckerror function also.

        SalesHeader.INIT;
        SalesHeader.SetHideValidationDialog(TRUE); //RM 18.09.2015
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := WebOrderHeader."Order ID";
        SalesHeader.VALIDATE("Order Date", WebOrderHeader."Order Date");
        SalesHeader.VALIDATE("Posting Date", WebOrderHeader."Order Date");
        SalesHeader.INSERT(TRUE);

        SalesHeader.VALIDATE("Sell-to Customer No.", Customer."No.");
        //MITL++
        IF Customer."Invoice Disc. Facility Availed" = true then
            SalesHeader."Invoice Disc. Facility Availed" := Customer."Invoice Disc. Facility Availed";
        //MITL**
        Mapping.GET(WebOrderHeader."Payment Method");

        SalesHeader.VALIDATE("Payment Method Code", Mapping."Dynamics NAV Payment Method Co");
        SalesHeader."Order Online Paymemnt" := Mapping."Online Payment"; //MITL
        SalesHeader.CalcFields(Latest_Dispatch_Date);
        SalesHeader.WebIncrementID := WebOrderHeader."Order ID";
        SalesHeader.WebOrderID := WebOrderHeader."Order ID";
        SalesHeader."Your Reference" := WebOrderHeader."Customer Order No."; //MITL
        // MITL.5593.SM.05022020 ++
        if CompanyName() = 'Walls and Floors' then
            SalesHeader.Validate("Shortcut Dimension 1 Code", WebOrderHeader."Dimension Code"); // SM_Business Channel
        if CompanyName() = 'Tile Mountain' then
            SalesHeader.Validate("Shortcut Dimension 2 Code", WebOrderHeader."Dimension Code");
        // MITL.5593.SM.05022020 --

        // MITL.6039.SM.31032020 ++
        if WebOrderHeader."Order ID" <> '' then begin
            SalesHeader.Validate("Posting No. Series", '');
            SalesHeader.Validate("Posting No.", WebOrderHeader."Order ID");
        end;
        // MITL.6039.SM.31032020 --
        //MITL.6532.SM.20200527 ++
        if WebOrderHeader."Latest Dispatch Date" <> 0D then
            SalesHeader.validate("Shipment Date", WebOrderHeader."Latest Dispatch Date")
        else
            SalesHeader.validate("Shipment Date", Today());
        //MITL.6532.SM.20200527 --
        SalesHeader.MODIFY(TRUE);

        CreateOrderLines(WebOrderHeader."Order ID", WebOrderHeader."Date Time", WebOrderHeader."LineType");
        IF WebOrderHeader."Shipping & Handling" <> 0 THEN BEGIN
            WEBSetup.TESTFIELD("Shipping and Handling Code");
            SalesLine.INIT;
            SalesLine.SetHideValidationDialog(TRUE);
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." := WEBOrderLines."Line No" + 10000;// MITL.5442.SM.20200514
            SalesLine.Type := SalesLine.Type::"G/L Account";
            SalesLine.INSERT(TRUE);

            SalesLine.VALIDATE("No.", WEBSetup."Shipping and Handling Code");
            SalesLine.VALIDATE(Quantity, 1);
            SalesLine.VALIDATE("Qty. to Ship", 0);
            SalesLine.VALIDATE("Unit Price", (WebOrderHeader."Shipping & Handling" + WebOrderHeader.VAT - TotalVATLines));
            // MITL.5593.SM.05022020 ++
            if CompanyName() = 'Walls and Floors' then
                SalesLine.Validate("Shortcut Dimension 1 Code", WEBOrderLines."Dimension Code");// SM_Business Channel
            if CompanyName() = 'Tile Mountain' then
                SalesLine.Validate("Shortcut Dimension 2 Code", WebOrderHeader."Dimension Code");
            // MITL.5593.SM.05022020 --
            SalesLine.MODIFY(TRUE);
        END;

        IF TotalDiscount + WebOrderHeader."Discount Amount" <> 0 THEN BEGIN //if remaining discount, then it is a shipping discount
            IF WebOrderHeader."Shipping & Handling" <> 0 THEN BEGIN
                WEBSetup.TESTFIELD("Shipping and Handling Code");
                SalesLine.INIT;
                SalesLine.SetHideValidationDialog(TRUE);
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := WEBOrderLines."Line No" + 20000;// MITL.5442.SM.20200514
                SalesLine.Type := SalesLine.Type::"G/L Account";
                SalesLine.INSERT(TRUE);
                SalesLine.VALIDATE("No.", WEBSetup."Shipping and Handling Code");
                SalesLine.VALIDATE(Quantity, -1);
                SalesLine.VALIDATE("Qty. to Ship", 0);
                SalesLine.VALIDATE("Unit Price", -(TotalDiscount + WebOrderHeader."Discount Amount")); //RM requested by Matt 11.12.2015
                SalesLine.MODIFY(TRUE);
                ShipDisc := SalesLine."Unit Price"; //to test error
            END;
        END;

        SalesHeader.CALCFIELDS(SalesHeader."Amount Including VAT");

        IF (SalesHeader."Amount Including VAT" = WebOrderHeader."Grand Total") OR (ABS(SalesHeader."Amount Including VAT" - WebOrderHeader."Grand Total") <= WEBSetup."Order Variance Tolerance") THEN BEGIN
            WebToolbox.UpdateIndex(WEBIndex, 1, '');
            WEBProcessPayment(SalesHeader);

            WEBIndex."Order Created" := TRUE; //MITL-SP-CASE_230-060818
            WEBIndex.MODIFY;   //MITL-SP-CASE_230-060818
            Clear(WebFunc); //MITL1927
            WebFunc.SalesOrderReleaseManagement(SalesHeader, ShippingErrors, WebOrderHeader."Combined Pick");
            IF ShippingErrors <> '' THEN
                WebToolbox.UpdateIndex(WEBIndex, 2, ShippingErrors);
            //SalesHeader.DELETE(TRUE); //RM 14.10.2015 MOVE FROM ABOVE ***** commented TO test
        END ELSE BEGIN
            //SalesHeader.DELETE(TRUE); //RM 16.09.2015
            WebToolbox.UpdateIndex(WEBIndex, 2, STRSUBSTNO('Order Value Incorrect %1 VS %2 (%3) (%4)', SalesHeader."Amount Including VAT", WebOrderHeader."Grand Total", ShipDisc, TotalDiscount));
            SalesHeader.DELETE(TRUE); //RM 14.10.2015 MOVE FROM ABOVE ***** commented TO test
        END;
    end;

    procedure CreateOrderLines(WebOrder: Text[100]; WebDateTime: DateTime; WebType: Integer)
    var
        CrossRefNo: Code[20];
        WebSetupL: Record "WEB Setup";
    begin
        //RM 18.08.2015 >> - copied to be re-useable
        TotalVATLines := 0;
        TotalDiscount := 0;
        WebSetupL.Get();
        WEBOrderLines.SetCurrentKey("Order ID", LineType, "Date Time"); //MITLUpgrade
        WEBOrderLines.SETRANGE("Order ID", WebOrder);
        WEBOrderLines.SETFILTER("Date Time", '%1..%2', WebOrderHeader."Date Time" - 1000, WebOrderHeader."Date Time" + 1000);
        WEBOrderLines.SETRANGE("LineType", WebType);
        DeDuplicateOrderLines; //R4560
        IF WEBOrderLines.FINDSET THEN
            REPEAT
                SalesLine.INIT;
                SalesLine.SetHideValidationDialog(TRUE);
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := WEBOrderLines."Line No";
                SalesLine.Type := SalesLine.Type::Item;
                SalesLine.INSERT(TRUE);

                //R4476 >>
                CrossRefNo := WebFunc.ReturnCrossReference(WEBOrderLines.Sku);
                IF CrossRefNo <> '' THEN
                    SalesLine.VALIDATE("Cross-Reference No.", CrossRefNo)
                ELSE
                    //R4476 <<
                    SalesLine.VALIDATE("No.", WEBOrderLines.Sku);

                EVALUATE(SalesLine.Quantity, WEBOrderLines.QTY);
                SalesLine.VALIDATE(Quantity, SalesLine.Quantity);
                SalesLine.VALIDATE("Qty. to Ship", 0);
                //SalesLine.VALIDATE("Unit Price",WEBOrderLines."Unit Price");
                //RM 18.09.2015 >>
                SalesLine.VALIDATE("Unit Price", (WEBOrderLines.Subtotal + WEBOrderLines.VAT) / SalesLine.Quantity);
                //SalesLine.VALIDATE("Unit Price",WEBOrderLines.Subtotal/SalesLine.Quantity);
                //RM 18.09.2015 <<
                SalesLine.VALIDATE("Line Discount Amount", WEBOrderLines."Discount Amount"); //RM Requested by Matt 11.12.2015
                //SalesLine.VALIDATE("Line Discount Amount",ROUND((WEBOrderLines."Discount Amount"/120*100),0.01,'=')); RM Requested by Matt 11.12.2015
                IF SalesLine."Line Discount %" > 100 THEN
                    SalesLine.VALIDATE("Line Discount %", 100);

                SalesLine.WebOrderItemID := WEBOrderLines.Sku;
                TotalVATLines := TotalVATLines + WEBOrderLines.VAT;
                TotalDiscount := TotalDiscount + ABS(WEBOrderLines."Discount Amount");// MITL19.04.2017 ABS ADDED

                SalesLine.VALIDATE("Cut Size", WEBOrderLines."Cut Size"); //RM 11.12.2015
                IF WEBOrderLines."Location Code" <> '' THEN
                    SalesLine.VALIDATE("Location Code", WEBOrderLines."Location Code");
                IF (SalesLine."Cut Size") AND (WEBOrderLines."Location Code" = '') THEN
                    SalesLine.VALIDATE("Location Code", WebSetupL."Web Location");
                // MITL.5593.SM.05022020 ++
                if CompanyName() = 'Walls and Floors' then
                    SalesLine.Validate("Shortcut Dimension 1 Code", WEBOrderLines."Dimension Code")// SM_Business Channel
                else
                    if CompanyName() = 'Tile Mountain' then
                        SalesLine.Validate("Shortcut Dimension 2 Code", WEBOrderLines."Dimension Code");// SM_Business Channel
                // MITL.5593.SM.05022020 --
                SalesLine.Validate("Shipment Date", SalesHeader."Shipment Date");// MITL.6532.SM.20200527
                SalesLine.MODIFY(TRUE);
            UNTIL WEBOrderLines.NEXT = 0;
        //RM 18.08.2015 <<
    end;

    procedure DeleteOrderLines(DocType: Integer; DocNo: Code[20])
    begin
        //RM 18.08.2015 >>
        SalesLine.Reset();
        SalesLine.SETRANGE("Document Type", DocType);
        SalesLine.SETRANGE("Document No.", DocNo);
        SalesLine.DELETEALL(TRUE);
        //RM 18.08.2015 <<
    end;

    procedure ModifyOrder(var WEBIndex: Record "WEB Index")
    var
        CustChanged: Boolean;
        OrderWasShipped: Boolean;
        WhseShptLineL: Record "Warehouse Shipment Line";
        WhsePickLineL: Record "Warehouse Activity Line";
        WhseShptHeadL: Record "Warehouse Shipment Header";
        WhsePickHeadL: Record "Warehouse Activity Header";
    begin
        WebOrderHeader.SetCurrentKey("Index No."); //MITLUpgrade
        WebOrderHeader.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebOrderHeader.FINDFIRST THEN BEGIN
            //RM 14.08.2015>>
            WEBCheckCustomer(Customer);
            Mapping.GET(WebOrderHeader."Payment Method");

            SalesHeader.SetHideValidationDialog(TRUE);
            IF SalesHeader.GET(SalesHeader."Document Type"::Order, WebOrderHeader."Order ID") THEN BEGIN
                SalesHeader.SetHideValidationDialog(TRUE); //RM 18.09.2015
                OrderWasShipped := OrderShipped(SalesHeader."Document Type"::Order, WebOrderHeader."Order ID", 0);


                IF (SalesHeader."Order Date" <> WebOrderHeader."Order Date")
                    OR (SalesHeader."Posting Date" <> WebOrderHeader."Order Date")
                        OR (SalesHeader."Sell-to Customer No." <> Customer."No.")
                            OR (SalesHeader."Payment Method Code" <> Mapping."Dynamics NAV Payment Method Co")
                            or (SalesHeader."Shipment Date" <> WebOrderHeader."Latest Dispatch Date")// MITL.6532.SM.20200527
                             THEN BEGIN

                    IF OrderWasShipped = FALSE THEN BEGIN
                        CustChanged := (SalesHeader."Sell-to Customer No." <> Customer."No.");

                        SalesHeader.VALIDATE("Order Date", WebOrderHeader."Order Date");
                        SalesHeader.VALIDATE("Posting Date", WebOrderHeader."Order Date");
                        SalesHeader.VALIDATE("Payment Method Code", Mapping."Dynamics NAV Payment Method Co");
                        //MITL.6532.SM.20202705 ++
                        if WebOrderHeader."Latest Dispatch Date" <> 0D then
                            SalesHeader."Shipment Date" := WebOrderHeader."Latest Dispatch Date"
                        else
                            SalesHeader."Shipment Date" := Today();
                        //MITL.6532.SM.20202705 --
                        SalesHeader.MODIFY(TRUE);
                        //  MITL332 ++
                        WhseShptLineL.RESET;
                        WhseShptLineL.SETRANGE("Source Document", WhseShptLineL."Source Document"::"Sales Order");
                        WhseShptLineL.SETRANGE("Source No.", SalesHeader."No.");
                        IF WhseShptLineL.FINDFIRST THEN BEGIN
                            WhseShptHeadL.GET(WhseShptLineL."No.");
                            SalesHeader.CALCFIELDS(Latest_Dispatch_Date);
                            WhseShptHeadL."Latest Dispatch Date" := SalesHeader.Latest_Dispatch_Date;
                            WhseShptHeadL."Shipment Date" := SalesHeader."Shipment Date";//MITL.6532.SM.20202705
                            WhseShptHeadL.MODIFY;
                        END;

                        WhsePickLineL.RESET;
                        WhsePickLineL.SETRANGE("Activity Type", WhsePickLineL."Activity Type"::Pick);
                        WhsePickLineL.SETRANGE("Destination Type", WhsePickLineL."Destination Type"::"Sales Order");
                        WhsePickLineL.SETRANGE("Destination No.", SalesHeader."No.");
                        IF WhsePickLineL.FINDFIRST THEN BEGIN
                            WhsePickHeadL.GET(WhsePickLineL."Activity Type", WhsePickLineL."No.");
                            SalesHeader.CALCFIELDS(Latest_Dispatch_Date);
                            WhsePickHeadL."Latest Dispatch Date" := SalesHeader.Latest_Dispatch_Date;
                            WhsePickHeadL."Shipment Date" := SalesHeader."Shipment Date";//MITL.6532.SM.20200527
                            WhsePickHeadL.MODIFY;
                        END;
                        //  MITL332 **
                    END;
                END;

                IF CustChanged THEN
                    CreateOrderLines(WebOrderHeader."Order ID", WebOrderHeader."Date Time", WebOrderHeader."LineType")
                ELSE
                    ModifyOrderLines(WEBIndex);
                WebToolbox.UpdateIndex(WEBIndex, 1, '');
                //END;
            END ELSE
                WebToolbox.UpdateIndex(WEBIndex, 2, 'Sales Header not found!');
            //RM 17.08.2015 <<
        END ELSE
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Record not found to update');
    end;

    procedure ModifyOrderLines(var WEBIndex: Record "WEB Index")
    var
        WebOrdLineQTY: Decimal;
        OrderLineShipped: Boolean;
        CrossRefNo: Code[20];
        MagentoSku: Code[20];
        //MITL.6532.SM.20200527 ++
        WhseShipLines: Record "Warehouse Shipment Line";
        WhseShipHdr: Record "Warehouse Shipment Header";
        WhseActiHdr: Record "Warehouse Activity Header";
        WhseActiLine: Record "Warehouse Activity Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        ReleaseWhseShptDoc: Codeunit "Whse.-Shipment Release";
        ShippingErrors: Text;
    //MITL.6532.SM.20200527 --
    begin
        //RM 17.08.2015 >>
        SalesLine.SetHideValidationDialog(TRUE);

        WEBOrderLines.RESET;
        WEBOrderLines.SetCurrentKey("Order ID", "Date Time", "LineType"); //MITLUpgrade
        WEBOrderLines.SETRANGE("Order ID", WebOrderHeader."Order ID");

        //RM copied from create order lines 14.02.2016 >>
        WEBOrderLines.SETFILTER("Date Time", '%1..%2', WebOrderHeader."Date Time" - 1000, WebOrderHeader."Date Time" + 1000);
        //RM copied from create order lines 14.02.2016 <<

        WEBOrderLines.SETRANGE("LineType", WebOrderHeader."LineType");
        DeDuplicateOrderLines; //R4560
        IF WEBOrderLines.FINDSET THEN
            REPEAT
                EVALUATE(WebOrdLineQTY, WEBOrderLines.QTY);

                IF SalesLine.GET(SalesHeader."Document Type", SalesHeader."No.", WEBOrderLines."Line No") THEN BEGIN
                    SalesLine.SetHideValidationDialog(TRUE); //RM 18.09.2015

                    //R4476 >>
                    CrossRefNo := WebFunc.ReturnCrossReference(WEBOrderLines.Sku);
                    IF CrossRefNo = '' THEN
                        MagentoSku := WEBOrderLines.Sku
                    ELSE
                        MagentoSku := WebFunc.ReturnMagentoSKU(CrossRefNo);

                    IF (MagentoSku <> WEBOrderLines.Sku)
                    //R4476 <<
                    OR (SalesLine.Quantity <> WebOrdLineQTY)
                    OR (SalesLine."Unit Price" <> ((WEBOrderLines.Subtotal + WEBOrderLines.VAT) / SalesLine.Quantity))
                    OR (SalesLine."Cut Size" <> WEBOrderLines."Cut Size") //RM 11.12.2015
                    OR (SalesLine."Line Discount Amount" <> WEBOrderLines."Discount Amount")
                    or (SalesLine."Shipment Date" <> SalesHeader."Shipment Date") //MITL.6532.SM.20200527
                    THEN BEGIN
                        IF OrderShipped(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.") THEN
                            WebToolbox.UpdateIndex(WEBIndex, 2, 'Sales Line shipped already!')
                        ELSE BEGIN
                            //MITL.6532.SM.20200527 ++
                            WhseShipLines.Reset();
                            WhseShipLines.SetRange("Source Type", 37);
                            WhseShipLines.SetRange("Source Subtype", SalesLine."Document Type");
                            WhseShipLines.SetRange("Source No.", SalesLine."Document No.");
                            WhseShipLines.SetRange("Source Line No.", SalesLine."Line No.");
                            WhseShipLines.SetAutoCalcFields("Pick Qty.");
                            if WhseShipLines.FindFirst() then begin
                                if WhseShipLines."Qty. Picked" = 0 then begin
                                    if WhseShipLines."Pick Qty." <> 0 then begin
                                        WhseActiLine.Reset();
                                        WhseActiLine.SetRange("Whse. Document Type", WhseActiLine."Whse. Document Type"::Shipment);
                                        WhseActiLine.SetRange("Whse. Document No.", WhseShipLines."No.");
                                        WhseActiLine.SetRange("Whse. Document Line No.", WhseShipLines."Line No.");
                                        if WhseActiLine.FindFirst() then
                                            if WhseActiHdr.Get(WhseActiHdr.Type::Pick, WhseActiLine."No.") then
                                                WhseActiHdr.Delete(true);
                                    end;
                                    if WhseShipHdr.Get(WhseShipLines."No.") then begin
                                        ReleaseWhseShptDoc.Reopen(WhseShipHdr);
                                        WhseShipHdr.Get(WhseShipLines."No.");
                                        WhseShipHdr.Delete(true);
                                    end;
                                end
                                else
                                    WebToolbox.UpdateIndex(WEBIndex, 2, 'Pick is already registered for the lines!')
                            end;
                            if SalesHeader.Status = SalesHeader.Status::Released then
                                ReleaseSalesDoc.Reopen(SalesHeader);
                            //R4476 >>
                            IF CrossRefNo <> '' THEN
                                SalesLine.VALIDATE("Cross-Reference No.", CrossRefNo)
                            ELSE

                                //R4476 <<
                                SalesLine.VALIDATE("No.", WEBOrderLines.Sku);
                            SalesLine.Quantity := WebOrdLineQTY;
                            SalesLine.VALIDATE(Quantity, SalesLine.Quantity);
                            SalesLine.VALIDATE("Unit Price", (WEBOrderLines.Subtotal + WEBOrderLines.VAT) / SalesLine.Quantity);
                            SalesLine.VALIDATE("Line Discount Amount", WEBOrderLines."Discount Amount");
                            IF SalesLine."Line Discount %" > 100 THEN
                                SalesLine.VALIDATE("Line Discount %", 100);

                            SalesLine.VALIDATE("Cut Size", WEBOrderLines."Cut Size"); //RM 11.12.2015
                            IF WEBOrderLines."Location Code" <> '' THEN
                                SalesLine.VALIDATE("Location Code", WEBOrderLines."Location Code");
                            IF (SalesLine."Cut Size") AND (WEBOrderLines."Location Code" = '') THEN
                                SalesLine.VALIDATE("Location Code", 'HANLEY');
                            //MITL.6532.SM.20200527 ++
                            SalesLine."Shipment Date" := SalesHeader."Shipment Date";
                            // WhseShipLines.Reset();
                            // WhseShipLines.SetRange("Source Type", 37);
                            // WhseShipLines.SetRange("Source Subtype", SalesLine."Document Type");
                            // WhseShipLines.SetRange("Source No.", SalesLine."Document No.");
                            // WhseShipLines.SetRange("Source Line No.", SalesLine."Line No.");
                            // if WhseShipLines.FindFirst() then begin
                            //     WhseShipLines."Shipment Date" := SalesHeader."Shipment Date";
                            //     WhseShipLines.Modify(true);
                            // end;
                            //MITL.6532.SM.20200527 --
                            SalesLine.MODIFY(TRUE);
                        END;
                    END;
                END ELSE
                    WebToolbox.UpdateIndex(WEBIndex, 2, 'Sales Line not found!');
            UNTIL WEBOrderLines.NEXT = 0;
        // MITL.6532.SM.20200527 ++
        WEBOrderLines.SetRange(LineType);
        if WEBOrderLines.FindSet() then
            repeat
                IF SalesLine.GET(SalesHeader."Document Type", SalesHeader."No.", WEBOrderLines."Line No") THEN BEGIN
                    SalesLine.SetHideValidationDialog(TRUE); //RM 18.09.2015

                    IF (SalesLine."Shipment Date" <> SalesHeader."Shipment Date") //MITL.6532.SM.20200527
                    THEN BEGIN
                        IF OrderShipped(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.") THEN
                            WebToolbox.UpdateIndex(WEBIndex, 2, 'Sales Line shipped already!')
                        ELSE BEGIN
                            //MITL.6532.SM.20200527 ++
                            WhseShipLines.Reset();
                            WhseShipLines.SetRange("Source Type", 37);
                            WhseShipLines.SetRange("Source Subtype", SalesLine."Document Type");
                            WhseShipLines.SetRange("Source No.", SalesLine."Document No.");
                            WhseShipLines.SetRange("Source Line No.", SalesLine."Line No.");
                            WhseShipLines.SetAutoCalcFields("Pick Qty.");
                            if WhseShipLines.FindFirst() then begin
                                if WhseShipLines."Qty. Picked" = 0 then begin
                                    if WhseShipLines."Pick Qty." <> 0 then begin
                                        WhseActiLine.Reset();
                                        WhseActiLine.SetRange("Whse. Document Type", WhseActiLine."Whse. Document Type"::Shipment);
                                        WhseActiLine.SetRange("Whse. Document No.", WhseShipLines."No.");
                                        WhseActiLine.SetRange("Whse. Document Line No.", WhseShipLines."Line No.");
                                        if WhseActiLine.FindFirst() then
                                            if WhseActiHdr.Get(WhseActiHdr.Type::Pick, WhseActiLine."No.") then
                                                WhseActiHdr.Delete(true);
                                    end;
                                    if WhseShipHdr.Get(WhseShipLines."No.") then begin
                                        ReleaseWhseShptDoc.Reopen(WhseShipHdr);
                                        WhseShipHdr.Get(WhseShipLines."No.");
                                        WhseShipHdr.Delete(true);
                                    end;
                                end
                                else
                                    WebToolbox.UpdateIndex(WEBIndex, 2, 'Pick is already registered for the lines!')
                            end;
                            if SalesHeader.Status = SalesHeader.Status::Released then
                                ReleaseSalesDoc.Reopen(SalesHeader);
                            //R4476 >>

                            //MITL.6532.SM.20200527 ++
                            SalesLine."Shipment Date" := SalesHeader."Shipment Date";
                            //MITL.6532.SM.20200527 --
                            SalesLine.MODIFY(TRUE);
                        END;
                    END;
                END
            UNTIL WEBOrderLines.NEXT = 0;
        if SalesHeader.Status = SalesHeader.Status::Open then
            WebFunc.SalesOrderReleaseManagement(SalesHeader, ShippingErrors, WebOrderHeader."Combined Pick");
        IF ShippingErrors <> '' THEN
            WebToolbox.UpdateIndex(WEBIndex, 2, ShippingErrors);
        //RM 17.08.2015 <<
    end;

    procedure DeleteOrder(var WEBIndex: Record "WEB Index")
    var
        WebOrder: Record "WEB Order Header";
    begin
        //RM 17.08.2015 >>
        WebOrderHeader.SetCurrentKey("Index No."); //MITLUpgrade
        WebOrderHeader.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebOrderHeader.FINDFIRST THEN BEGIN
            IF SalesHeader.GET(SalesHeader."Document Type"::Order, WebOrderHeader."Order ID") THEN BEGIN
                IF OrderShipped(SalesHeader."Document Type"::Order, WebOrderHeader."Order ID", 0) THEN
                    WebToolbox.UpdateIndex(WEBIndex, 2, 'Order has been shipped')
                ELSE BEGIN
                    SalesHeader.DELETE(TRUE);
                    WebToolbox.UpdateIndex(WEBIndex, 1, '');
                END
            END ELSE
                WebToolbox.UpdateIndex(WEBIndex, 2, 'Sales Header not found');
        END;
        //RM 17.08.2015 <<
    end;

    procedure HandleOrder(var WEBIndex: Record "WEB Index")
    var
        WebOrder: Record "WEB Order Header";
    begin
        WebOrder.SetCurrentKey("Index No.");  //MITLUpgrade
        WebOrder.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebOrder.FINDFIRST THEN BEGIN
            GetWEBSetup;
            CASE WebOrder."LineType" OF
                WebOrder."LineType"::Insert:
                    InsertOrder(WEBIndex);
                WebOrder."LineType"::Modify:
                    ModifyOrder(WEBIndex);
                WebOrder."LineType"::Delete:
                    DeleteOrder(WEBIndex);
            END;
        END;
    end;

    procedure WEBOrder(var WEBIndex: Record "WEB Index")
    begin
    end;

    procedure WEBItemExists(ItemNoP: Code[20]): Boolean
    var
        ItemL: Record Item;
    begin
        IF ItemL.GET(ItemNoP) THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    procedure WEBCheckOrderLines(OrderID: Code[20]; DateTimeP: DateTime; index: Record "WEB Index"): Text
    var
        WEBOrderLines: Record "WEB Order Lines";
        ErrorText: Text;
    begin
        WEBOrderLines.SetCurrentKey("Order ID", "Date Time"); //MITLUpgrade
        WEBOrderLines.SETRANGE("Order ID", OrderID);
        WEBOrderLines.SETRANGE("Date Time", DateTimeP);
        IF WEBOrderLines.FINDSET THEN
            REPEAT
                IF NOT WEBItemExists(WEBOrderLines.Sku) THEN BEGIN
                    WebToolbox.CreateRequest(50016, 'Item', WEBOrderLines.Sku, index."Line no.");
                    ErrorText := 'Item(s) do not exist'
                END;
            UNTIL WEBOrderLines.NEXT = 0;

        EXIT(ErrorText);
    end;

    procedure WEBCheckOrderExist(OrderID: Code[20]; DateTimeP: DateTime; index: Record "WEB Index"): Text
    var
        WEBOrderLines: Record "WEB Order Lines";
        ErrorText: Text;
    begin
        WEBOrderLines.Reset(); //MITL.AJ.23APR202
        WEBOrderLines.SetCurrentKey("Order ID", "Date Time"); //MITLUpgrade
        WEBOrderLines.SETRANGE("Order ID", OrderID);
        WEBOrderLines.SETFILTER("Date Time", '%1..%2', DateTimeP - 1000, DateTimeP + 1000);
        IF WEBOrderLines.ISEMPTY THEN
            ErrorText := 'No Lines Exist';

        EXIT(ErrorText);
    end;

    procedure GetWEBSetup()
    begin
        WEBSetup.GET;
    end;

    procedure WEBCheckCustomer(var Customer: Record Customer): Text
    begin
        WebOrderHeader.SetCurrentKey("Customer ID"); //MITL		
        IF WebOrderHeader."Customer ID" <> '' THEN BEGIN  //MITL3321
            Customer.SETRANGE("E-Mail"); // MITL4342
            Customer.SETRANGE("No.", WebOrderHeader."Customer ID");
            IF Customer.FindFirst() THEN
                EXIT('')
            ELSE BEGIN
                Customer.SetRange("No."); //MITL
                Customer.SetCurrentKey("Customer ID"); //MITL
                Customer.SetRange("Customer ID", WebOrderHeader."Customer ID"); //MITL
                IF Customer.FindFirst() then
                    EXIT('');
            END;
        END;

        //R4561 >>
        IF (WebOrderHeader."Customer ID" = '') AND (WebOrderHeader."Customer Email" = '') THEN BEGIN //MITL3321
            Customer.SetRange("Customer ID"); //MITL
            Customer.SetRange("No."); //MITL
            Customer.SETRANGE("No.", WebFunc.ReturnDefaultCustomer);
            IF Customer.FINDLAST THEN
                EXIT('');
        END;
        //R4561 <<
        //MITL3321 ++
        Customer.SetRange("Customer ID"); //MITL
        Customer.SetRange("No."); //MITL
        Customer.SETRANGE("E-Mail", WebOrderHeader."Customer Email");  //MITL
        IF Customer.FINDFIRST THEN
            EXIT('')
        ELSE
            IF (Customer.COUNT = 0) THEN BEGIN
                InsertNewCustomer(WebOrderHeader."Customer ID", WebOrderHeader."Customer Email");
                EXIT('No customer found ' + Customer.GETFILTERS + ' ' + WebOrderHeader."Customer ID");
            END;
        //MITL3321 **
    end;

    procedure UpdatePaymentMethodMapping(var WEBOrder: Record "WEB Order Header"): Boolean
    begin
        //ensures all codes there for mapping
        IF NOT Mapping.GET(WEBOrder."Payment Method") THEN BEGIN
            Mapping."Magento Payment Method Code" := WEBOrder."Payment Method";
            Mapping.INSERT;
            EXIT(FALSE);
        END ELSE
            IF Mapping."Dynamics NAV Payment Method Co" = '' THEN
                EXIT(FALSE);

        EXIT(TRUE);
    end;

    procedure WEBProcessPayment(var SalesHeder: Record "Sales Header")
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        mapping: Record "WEB Mapping";
        PaymentMethodTemplateMAP: Record "Payment Method Template MAP";
        WEBOrderHeaderL: Record "WEB Order Header"; //MITL_W&F
        CustL: Record Customer; //MITL3772
    begin
        //MITL_W&F ++
        WEBOrderHeaderL.Reset();
        WEBOrderHeaderL.SetRange("Order ID", SalesHeder."No.");
        IF WEBOrderHeaderL.FindFirst() then;
        //MITL_W&F **ss
        mapping.Reset(); //MITLUpgrade
        mapping.SetCurrentKey("Dynamics NAV Payment Method Co"); //MITLUpgrade
        mapping.SetRange("Magento Payment Method Code", WEBOrderHeaderL."Payment Method"); //MITL_W&F - In case NAV Payment Method assigned to Multiple Magento Payment options
        mapping.SETRANGE(mapping."Dynamics NAV Payment Method Co", SalesHeader."Payment Method Code");
        mapping.FINDFIRST;
        IF mapping."Online Payment" THEN BEGIN
            PaymentMethodTemplateMAP.GET(SalesHeder."Payment Method Code");

            GenJnlBatch.GET(PaymentMethodTemplateMAP."Sales Pmt. Jnl Template Name", PaymentMethodTemplateMAP."Sales Pmt. Jnl Batch Name");

            GenJnlLine.INIT;
            GenJnlLine."Journal Template Name" := PaymentMethodTemplateMAP."Sales Pmt. Jnl Template Name";
            GenJnlLine."Journal Batch Name" := PaymentMethodTemplateMAP."Sales Pmt. Jnl Batch Name";
            GenJnlLine."Line No." := 9999;
            GenJnlLine."Document No." := SalesHeder."No.";
            GenJnlLine.INSERT(TRUE);

            IF SalesHeder."Document Type" = SalesHeder."Document Type"::Order THEN
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment
            ELSE
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;

            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
            GenJnlLine."Posting Date" := SalesHeder."Posting Date";
            GenJnlLine."Document Date" := SalesHeder."Document Date";
            GenJnlLine.VALIDATE("Account No.", SalesHeder."Sell-to Customer No.");
            GenJnlLine.VALIDATE("Bal. Account Type", GenJnlLine."Bal. Account Type"::"Bank Account");
            GenJnlLine.VALIDATE("Bal. Account No.", GenJnlBatch."Bal. Account No.");
            // MITL.5593.SM.05022020 ++
            if CompanyName() = 'Walls and Floors' then
                GenJnlLine.Validate("Shortcut Dimension 1 Code", SalesHeder."Shortcut Dimension 1 Code"); // SM_Business Channel
            if CompanyName() = 'Tile Mountain' then
                GenJnlLine.Validate("Shortcut Dimension 2 Code", SalesHeder."Shortcut Dimension 2 Code");
            // MITL.5593.SM.05022020 --
            SalesHeder.CALCFIELDS("Amount Including VAT");

            IF GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment THEN
                GenJnlLine.VALIDATE(Amount, -SalesHeder."Amount Including VAT")
            ELSE
                GenJnlLine.VALIDATE(Amount, SalesHeder."Amount Including VAT");

            GenJnlLine.WebIncrementID := SalesHeder.WebIncrementID;
            GenJnlLine.VALIDATE("Applies-to ID", SalesHeder.WebIncrementID);

            //MITL3772 ++
            IF CustL.Get(SalesHeader."Sell-to Customer No.") then;
            IF GenJnlLine.Description = '' THEN
                GenJnlLine.Description := CustL.Name;
            //MITL3772 **

            GenJnlLine.MODIFY(TRUE);
            CLEAR(GenJnlPostLine);
            IF GenJnlLine.Amount <> 0 THEN BEGIN
                GenJnlPostLine.RunWithCheck(GenJnlLine);
                GenJnlLine.DELETE;
                WebToolbox.InsertWEBlog('Payment Processed', SalesHeader."No.");
            END ELSE
            //R4565 >>
            BEGIN
                GenJnlLine.DELETE;
                WebToolbox.InsertWEBlog('Payment Not Processed', SalesHeader."No.");
            END;
            //R4565 <<
        END ELSE
            WebToolbox.InsertWEBlog('Payment Not Processed', SalesHeader."No.");
    end;

    procedure WebCheckErrors(var WebIndex: Record "WEB Index")
    begin

        CheckOrderExists(WebIndex);
        CheckPaymentMethodMapping(WebIndex);
        CheckCustomer(WebIndex);
        IF WEBCheckOrderExist(WebOrderHeader."Order ID", WebOrderHeader."Date Time", WebIndex) <> '' THEN
            WebToolbox.UpdateIndex(WebIndex, 2, WEBCheckOrderExist(WebOrderHeader."Order ID", WebOrderHeader."Date Time", WebIndex));
        IF WEBCheckOrderLines(WebOrderHeader."Order ID", WebOrderHeader."Date Time", WebIndex) <> '' THEN
            WebToolbox.UpdateIndex(WebIndex, 3, WEBCheckOrderLines(WebOrderHeader."Order ID", WebOrderHeader."Date Time", WebIndex));
        CheckOrderAlreadyExists(WebIndex);
        //CheckOldOrder(WebIndex); //MITL1927
    end;

    procedure CheckOrderExists(var WebIndex: Record "WEB Index")
    begin
        WebOrderHeader.SetCurrentKey("Index No."); //MITLUpgrade
        WebOrderHeader.SETRANGE("Index No.", FORMAT(WebIndex."Line no."));
        IF NOT WebOrderHeader.FINDFIRST THEN BEGIN
            WebToolbox.UpdateIndex(WebIndex, 2, 'Record Not Found');
        END;
    end;

    procedure CheckPaymentMethodMapping(var WebIndex: Record "WEB Index")
    begin
        IF NOT UpdatePaymentMethodMapping(WebOrderHeader) THEN
            WebToolbox.UpdateIndex(WebIndex, 2, 'Payment Method Mapping not Complete');
    end;

    procedure CheckCustomer(var WebIndex: Record "WEB Index")
    var
        Customer: Record Customer;
    begin
        IF WEBCheckCustomer(Customer) <> '' THEN
            WebToolbox.UpdateIndex(WebIndex, 2, WEBCheckCustomer(Customer));
    end;

    procedure CheckOrderAlreadyExists(var WebIndex: Record "WEB Index")
    var
        SalesHeader: Record "Sales Header";
        PostedSalesHeader: Record "Sales Invoice Header";
    begin
        WebOrderHeader.SetCurrentKey("Index No."); //MITLUpgrade
        WebOrderHeader.SETRANGE("Index No.", FORMAT(WebIndex."Line no."));
        IF WebOrderHeader.FINDFIRST THEN BEGIN
            IF SalesHeader.GET(SalesHeader."Document Type"::Order, WebOrderHeader."Order ID") THEN
                WebToolbox.UpdateIndex(WebIndex, 2, 'Order Already Exists');

            //R4425 >>
            PostedSalesHeader.SETCURRENTKEY(WebIncrementID);
            PostedSalesHeader.SETRANGE(WebIncrementID, WebOrderHeader."Order ID");
            IF NOT PostedSalesHeader.ISEMPTY THEN
                WebToolbox.UpdateIndex(WebIndex, 2, 'Order ' + WebOrderHeader."Order ID" + ' Already Exists - as posted invoice');
            //R4425 <<
        END;
    end;

    procedure OrderShipped(DocType: Integer; DocNo: Code[20]; LineNo: Integer) HasShipped: Boolean
    begin
        //RM 17.08.2015 >>
        WITH SalesLine DO BEGIN
            RESET;
            SETRANGE("Document Type", DocType);
            SETRANGE("Document No.", DocNo);

            IF LineNo <> 0 THEN
                SETRANGE("Line No.", LineNo);
            SETFILTER("Quantity Shipped", '<>%1', 0);
            HasShipped := NOT ISEMPTY();
        END;
        EXIT(HasShipped);
        //RM 17.08.2015 <<
    end;

    procedure DeDuplicateOrderLines()
    var
        LastLineNo: Integer;
    begin
        //R4560 >>
        IF WEBOrderLines.FINDSET THEN BEGIN
            WHILE WEBOrderLines."Line No" > LastLineNo DO BEGIN
                LastLineNo := WEBOrderLines."Line No";
                WEBOrderLines.MARK(TRUE);

                IF WEBOrderLines.NEXT = 0 THEN
                    LastLineNo := 999999; //break loop
            END;
            WEBOrderLines.MARKEDONLY(TRUE);
        END;
        //R4560 <<
    end;

    local procedure InsertNewCustomer(CustomerID: Code[20]; CustEmail: Text[100])
    var
        Customer: Record Customer;
        CustTemplate: Record "Customer Template";
        WEBSetup: Record "WEB Setup";
    begin
        WEBSetup.GET();
        WEBSetup.TESTFIELD(WEBSetup."WEB Customer Template");
        Customer.Init();
        Customer."No." := CustomerID;
        Customer."Customer ID" := CustomerID;
        CustTemplate.GET(WEBSetup."WEB Customer Template");
        Customer."Customer Posting Group" := CustTemplate."Customer Posting Group";
        Customer."Customer Price Group" := CustTemplate."Customer Price Group";
        Customer."Invoice Disc. Code" := CustTemplate."Invoice Disc. Code";
        Customer."Customer Disc. Group" := CustTemplate."Customer Disc. Group";
        Customer."Allow Line Disc." := CustTemplate."Allow Line Disc.";
        Customer."Gen. Bus. Posting Group" := CustTemplate."Gen. Bus. Posting Group";
        Customer."VAT Bus. Posting Group" := CustTemplate."VAT Bus. Posting Group";
        Customer."Payment Terms Code" := CustTemplate."Payment Terms Code";
        Customer."Payment Method Code" := CustTemplate."Payment Method Code";
        Customer."Shipment Method Code" := CustTemplate."Shipment Method Code";
        Customer."Prices Including VAT" := CustTemplate."Prices Including VAT";
        Customer."Currency Code" := CustTemplate."Currency Code";
        Customer."E-Mail" := UPPERCASE(CustEmail);
        Customer.INSERT(TRUE);
    end;

}

