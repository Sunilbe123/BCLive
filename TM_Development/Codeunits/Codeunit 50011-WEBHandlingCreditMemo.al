codeunit 50011 "WEB Handling Credit Memo"
{
    // version RM 17082015,R4426,R4425,R4342,R4476,R4535,R4561,MITL14041, CASE 13601

    // 12.11.2015 - RM
    // Changed to  credit memo processing
    // 
    // 24.11.2015 - RM
    // Added function GetDiscountFromWebOrderLines as credit lines don't have it
    // 
    // 25.11.2015 - RM
    // Go live changes to process credit memos with no sales order processed under new scheme - look back to posted sales invoice
    // 
    // 26.11.2015 - RM
    // A couple of changes, introduce Order Variance Tolerance and also standardize ModifyCreditMemoLines along the lines of CreateCreditLines, though
    // MODIFY record type seems to be unused for Credit memos!
    // 
    // 13.12.2015 - RM
    // Changes to credit memo discount process to tie in with Magento changes
    // 
    // R4426 - RM - 15.01.2016
    // When creating orders fail if the Customer ID zero (or blank) AND Customer Email is also blank
    // 
    // R4425 - RM - 15.01.2016
    // Amended CheckCreditAlreadyExists to check against Posted Sales Credit Memos also
    // 
    // R4342 - RM - 24.12.2015
    // Delete\Amend existing sales order lines based on credit memo to allow subsequent shipment to work - rare occasion
    // 
    // R4429 - RM - 18.01.2016
    // Multiple credits to create refund rather than credit memo if original credit memo not shipped
    // Renamed DeleteUnshippedOrder as DeleteUnshippedOrderLines
    // 
    // R4476 - RM - 29.01.2016
    // Check Magento SKU is mapped to a Cross Reference, this is to allow multiple Magento SKUs to map to the one NAV item. The scenario is that the
    // different Magento SKUs represent the same item in NAV with different units.
    // 
    // R4561 - RM - 10.02.2016
    // Modded WEBCheckCustomer to select default customer if original order has no customer details (ID & Email)
    // 
    // MITL 14041 Ankit 15-11-2017 Code Commented And Used The Location Parameter From Web Credit Line Table in CreateCreditLines function
    //SM_Business Channel - New field created in Web Order Header and Line for passing the value of Business Channel from Magento to NAV Dimensions.

    TableNo = "WEB Index";

    trigger OnRun()
    begin
        WEBSetup.GET;
        GLAccount.GET(WEBSetup."Credit Memo Discount Account");
        VATPostingSetup.GET(GLAccount."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");
        MovementCreated := false; // MITL.SM.5442.20200729
        HandleCreditMemo(Rec);
        if MovementCreated then // MITL.SM.5442.20200729
            SalesOrderLine.PostMovementLines(WebCreditHeader); // CASE 13601, MITL2879
    end;

    var
        WEBSetup: Record "WEB Setup";
        WebToolbox: Codeunit "WEB Toolbox";
        SalesCreditHeader: Record "Sales Header";
        SalesCreditLine: Record "Sales Line";
        WebCreditHeader: Record "WEB Credit Header";
        WEBCreditLines: Record "WEB Credit Lines";
        Customer: Record Customer;
        Mapping: Record "WEB Mapping";
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesOrderHeader: Record "Sales Header";
        SalesOrderLine: Record "Sales Line";
        WebOrderLines: Record "WEB Order Lines";
        SalesShipHeader: Record "Sales Shipment Header";
        SalesOrderDelTxt: Label 'Sales Order Deletion %1';
        NoPaymentPostedTxt: Label 'There are no payments';
        TooManyPaymentsTxt: Label 'There are too many payments';
        WebOrderHeader: Record "WEB Order Header";
        TotalVATLines: Decimal;
        TotalDiscount: Decimal;
        ShipDisc: Decimal;
        PostedSalesInvHeader: Record "Sales Invoice Header";
        PostedSalesInvLine: Record "Sales Invoice Line";
        NoPreviousOrderText: Label 'No previous Web Order or Order/Sales Invoice found';
        SalesOrdHeader: Record "Sales Header";
        SalesOrdLine: Record "Sales Line";
        SalesOrderLineDelTxt: Label 'Sales Order Deletion %1, Line %2';
        WebFunc: Codeunit "WEB Functions";
        PartialRefundAmtG: Decimal; //MITL_VS_20200707
        FullCancelOrderG: Boolean; //mitl.vs.20200708
        MovementCreated: Boolean; //MITL.SM.5442.20200729
        ShowShipmentError: Boolean; //MITL.SM.5442.20200730        
        VatPercentage: Decimal;
        VATPostSetup: Record "VAT Posting Setup";
        GLAcc: Record "G/L Account";
        CreditLineVATAmount: Decimal;

    procedure InsertCreditMemo(var WEBIndex: Record "WEB Index")
    var
        //MITL_VS_20200601++
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        WhseShipLines: Record "Warehouse Shipment Line";
        WhseShipHdr: Record "Warehouse Shipment Header";
        WhseActiHdr: Record "Warehouse Activity Header";
        WhseActiLine: Record "Warehouse Activity Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        ReleaseWhseShptDoc: Codeunit "Whse.-Shipment Release";
        WebCreditLinesL: Record "WEB Credit Lines";
        QtyL: Decimal;
        ShippingErrors: Text;
        WebCrMemoLinesL: Record "WEB Credit Lines";
        WhseShipLn: Record "Warehouse Shipment Line";
        ItemNoL: Code[20];
        CrossRefNoL: Code[20];
        //MITL_VS_20200601--
    begin
        WEBSetup.GET;

        WebCheckErrors(WEBIndex);
        IF WEBIndex.Status <> WEBIndex.Status::" " THEN
            EXIT;

        WEBCheckCustomer(Customer);
        //MITL4006 ++
        IF NoCreditLinesFound(WEBIndex) then BEGIN //MITL4523 //MITL.AJ.19Dec2019 ++
            CheckInvoiceandPayment(WEBIndex);
            WebToolbox.UpdateIndex(WEBIndex, 1, ''); // MITL5442
        END ELSE //MITL4523 //MITL.AJ.19Dec2019 **
            IF PartialShipment THEN BEGIN  //MITL4006
                CheckMultipleInvoiceAndShippingCharges(WEBIndex);
                // WebToolbox.UpdateIndex(WEBIndex, 1, ''); // MITL5442
            END ELSE
                // IF OrderExists THEN BEGIN//Code Comment MITL_VS_20200601
                IF OrderExists AND NOT PartialCrCancel THEN BEGIN//MITL_VS_20200601
                    IF ReverseOrderAndPayments(WEBIndex) THEN
                        WebToolbox.UpdateIndex(WEBIndex, 1, ''); // MITL3832
                    // IF NOT ReverseOrderAndPayments(WEBIndex) THEN
                    //     CreateCreditMemo(WEBIndex)
                    // else // MITL3832 
                    //     WebToolbox.UpdateIndex(WEBIndex, 1, ''); // MITL3832
                END
                //MITL_VS_20200601++
                else
                    if OrderExists and PartialCrCancel then begin
                        if NOT CheckOnlyShipped then begin//MITL.VS.20200714

                            if SalesHeader.Get(SalesHeader."Document Type"::Order, WebCreditHeader."Order ID") then;
                            // MITL.SM.20200716 ++
                            SalesLine.SetHideValidationDialog(true);
                            SalesLine.SuspendStatusCheck(true);
                            // MITL.SM.20200716 --
                            WebCrMemoLinesL.Reset;
                            WebCrMemoLinesL.Reset;
                            WebCrMemoLinesL.SetCurrentKey("Credit Memo ID", "Date Time");
                            WebCrMemoLinesL.SetRange("Credit Memo ID", WebCreditHeader."Credit Memo ID");
                            WebCrMemoLinesL.SetRange("Date Time", WebCreditHeader."Date Time");
                            IF WebCrMemoLinesL.FindSet() THEN
                                repeat
                                    // MITL.SM.20200716 ++
                                    CrossRefNoL := WebFunc.ReturnCrossReference(WebCrMemoLinesL.Sku);
                                    IF CrossRefNoL = '' THEN
                                        ItemNoL := WebCrMemoLinesL.Sku
                                    ELSE
                                        ItemNoL := WebFunc.ReturnItemNo(WebCrMemoLinesL.Sku);
                                    // MITL.SM.20200716 --
                                    SalesLine.Reset;
                                    SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
                                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                                    SalesLine.SetRange("No.", ItemNoL);
                                    if SalesLine.FindFirst() then begin
                                        Evaluate(QtyL, WebCrMemoLinesL.QTY);
                                        // MILT.SM.20200717 ++
                                        IF SalesLine.Quantity <> QtyL then
                                            if IsPickRegisteredPartially(SalesLine) then begin
                                                RefundPayment(WebIndex);
                                                WebToolbox.UpdateIndex(WEBIndex, 2,
                                                                        'Partial pick already registered. Please ship and invoice dispatched lines and the reset the credit memo error.');
                                                exit;
                                            end

                                            else
                                                CreateMovement(WebCrMemoLinesL);
                                        //SalesLine.CreateMovementLinesPartialQty(QtyL);
                                        // else
                                        //     SalesLine.CreateMovementLines();
                                        // IF SalesLine.Quantity <> QtyL then
                                        //     SalesLine.CreateMovementLines()
                                        // MILT.SM.20200717 --
                                    end;
                                Until WebCrMemoLinesL.next = 0;

                            WhseShipLines.Reset();
                            WhseShipLines.SetRange("Source Type", 37);
                            WhseShipLines.SetRange("Source Subtype", SalesLine."Document Type");
                            WhseShipLines.SetRange("Source No.", SalesLine."Document No.");
                            WhseShipLines.SetRange("Source Line No.", SalesLine."Line No.");
                            WhseShipLines.SetAutoCalcFields("Pick Qty.");
                            if WhseShipLines.FindFirst() then begin

                                if (WhseShipLines."Qty. Picked" <> 0) OR
                                    (WhseShipLines."Pick Qty." <> 0)


                                then begin
                                    // if WhseShipLines."Pick Qty." <> 0 then begin
                                    WhseActiLine.Reset();
                                    WhseActiLine.SetRange("Whse. Document Type", WhseActiLine."Whse. Document Type"::Shipment);
                                    WhseActiLine.SetRange("Whse. Document No.", WhseShipLines."No.");
                                    WhseActiLine.SetRange("Whse. Document Line No.", WhseShipLines."Line No.");
                                    if WhseActiLine.FindFirst() then
                                        if WhseActiHdr.Get(WhseActiHdr.Type::Pick, WhseActiLine."No.") then
                                            WhseActiHdr.Delete(true);
                                    // end;
                                    WhseShipHdr.SetHideValidationDialog(true);
                                    if WhseShipHdr.Get(WhseShipLines."No.") then begin
                                        ReleaseWhseShptDoc.Reopen(WhseShipHdr);

                                        WhseShipLn.Reset();
                                        WhseShipLn.SetRange("Source Type", 37);
                                        WhseShipLn.SetRange("Source Subtype", SalesLine."Document Type");
                                        WhseShipLn.SetRange("Source No.", SalesLine."Document No.");
                                        WhseShipLn.DeleteAll();

                                        WhseShipHdr.Get(WhseShipLines."No.");
                                        WhseShipHdr.Delete();
                                    end;
                                end;
                            end;
                            //     end;
                            // Until WebCrMemoLinesL.next = 0;

                            if SalesHeader.Status = SalesHeader.Status::Released then
                                ReleaseSalesDoc.Reopen(SalesHeader);

                            SalesLine.SetHideValidationDialog(true);

                            WebCreditLinesL.Reset;
                            WebCreditLinesL.SetCurrentKey("Credit Memo ID", "Date Time");
                            WebCreditLinesL.SetRange("Credit Memo ID", WebCreditHeader."Credit Memo ID");
                            WebCreditLinesL.SetRange("Date Time", WebCreditHeader."Date Time");
                            IF WebCreditLinesL.FindSet() THEN
                                repeat
                                    CrossRefNoL := WebFunc.ReturnCrossReference(WEBCreditLinesL.Sku);
                                    IF CrossRefNoL = '' THEN
                                        ItemNoL := WEBCreditLinesL.Sku
                                    ELSE
                                        ItemNoL := WebFunc.ReturnItemNo(WEBCreditLinesL.Sku);
                                    SalesLine.Reset;
                                    SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
                                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                                    SalesLine.SetRange("No.", ItemNoL);
                                    if SalesLine.FindFirst() then begin
                                        Evaluate(QtyL, WEBCreditLinesL.QTY);
                                        IF SalesLine.Quantity <> QtyL then begin
                                            SalesLine.Validate(Quantity, (SalesLine.Quantity - QtyL));
                                            SalesLine.Modify(true);
                                            // MITL.SM.20200714 ++
                                        end else
                                            SalesLine.Delete(true);
                                        // MITL.SM.20200714 --
                                    end;
                                Until WebCreditLinesL.next = 0;


                            WEBSetup.TESTFIELD("Shipping and Handling Code");
                            if WebCreditHeader."Shipping & Handling" <> 0 then begin
                                SalesLine.Reset;
                                SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
                                SalesLine.SetRange("Document No.", SalesHeader."No.");
                                SalesLine.SetRange("No.", WEBSetup."Shipping and Handling Code");
                                if SalesLine.FindFirst() then begin
                                    if SalesLine.Amount = WebCreditHeader."Shipping & Handling" then
                                        SalesLine.Delete(true)
                                    else begin
                                        SalesLine.Validate(Amount, SalesLine.Amount - WebCreditHeader."Shipping & Handling");
                                        SalesLine.Modify(true);
                                    end;
                                end;
                            end;

                            RefundPayment(WEBIndex);

                            if (SalesHeader.Status = SalesHeader.Status::Open) then
                                WebFunc.SalesOrderReleaseManagement(SalesHeader, ShippingErrors, false);


                            WebToolbox.UpdateIndex(WEBIndex, 1, '');
                            // MITL.VS.20200714++
                        end
                        else begin
                            RefundPayment(WebIndex);
                            // MITL.SM.5442.20200730 ++
                            ShowShipmentError := false;
                            if SalesHeader.Get(SalesHeader."Document Type"::Order, WebCreditHeader."Order ID") then;
                            WebCrMemoLinesL.Reset;
                            WebCrMemoLinesL.Reset;
                            WebCrMemoLinesL.SetCurrentKey("Credit Memo ID", "Date Time");
                            WebCrMemoLinesL.SetRange("Credit Memo ID", WebCreditHeader."Credit Memo ID");
                            WebCrMemoLinesL.SetRange("Date Time", WebCreditHeader."Date Time");
                            IF WebCrMemoLinesL.FindSet() THEN
                                repeat
                                    CrossRefNoL := WebFunc.ReturnCrossReference(WebCrMemoLinesL.Sku);
                                    IF CrossRefNoL = '' THEN
                                        ItemNoL := WebCrMemoLinesL.Sku
                                    ELSE
                                        ItemNoL := WebFunc.ReturnItemNo(WebCrMemoLinesL.Sku);
                                    SalesLine.Reset;
                                    SalesLine.SetRange(SalesLine."Document Type", SalesHeader."Document Type");
                                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                                    SalesLine.SetRange("No.", ItemNoL);
                                    if SalesLine.FindFirst() then begin
                                        Evaluate(QtyL, WebCrMemoLinesL.QTY);
                                        if QtyL > SalesLine.Quantity - SalesLine."Quantity Shipped" then
                                            ShowShipmentError := true;

                                    end;
                                until (WebCrMemoLinesL.Next() = 0) or ShowShipmentError;
                            if ShowShipmentError then
                                WebToolbox.UpdateIndex(WEBIndex, 2,
                                                            'Shipment lines exists without invoice. You will have to manually undo the shipment.')
                            else
                                WebToolbox.UpdateIndex(WEBIndex, 2,
                                                            'Partial pick already registered. Please ship and invoice dispatched lines and the reset the credit memo error.')
                            // MITL.SM.5442.20200730 --

                        end;
                        //MITL.VS.20200714--
                    end
                    //mitl_vs_20200601--
                    ELSE
                        WebToolbox.UpdateIndex(WEBIndex, 2, 'CreditMemo without order OR shipment');
    end;

    local procedure CheckWhseLoc(var WebCrHeaderP: Record "WEB Credit Header") WhseReqR: Boolean
    var
        WebCrLineL: Record "WEB Credit Lines";
        LocL: Record Location;
    begin
        WhseReqR := false;
        WebCrLineL.Reset();
        //"Order ID", "LineType", "Date Time"
        WebCrLineL.SetRange("Order ID", WebCrHeaderP."Order ID");
        WebCrLineL.SetRange(LineType, WebCrHeaderP.LineType);
        WebCrLineL.SetRange("Date Time", WebCrHeaderP."Date Time");
        WebCrLineL.SetFilter("Location Code", '<>%1', '');
        if WebCrLineL.FindFirst() then begin
            LocL.Reset();
            LocL.SetRange(Code, WebCrLineL."Location Code");
            LocL.SetFilter("Receipt Bin Code", '<>%1', '');
            if LocL.FindFirst() then
                WhseReqR := true;
        end;
    end;

    procedure CreateCreditMemo(var WEBIndex: Record "WEB Index")
    var
        UPCheck: Decimal;
        Top: Decimal;
        Bottom: Decimal;
        SalesPost: Codeunit "Sales-Post";
        SalesLine: Record "Sales Line";
        IsWhseReqL: Boolean; //MITL2995
        WebReturnPostL: Codeunit "WEB Handling Sales Return Post"; //MITL2995
    begin
        SalesCreditHeader.INIT;
        SalesCreditHeader.SetHideValidationDialog(TRUE);
        SalesCreditHeader."No." := WebCreditHeader."Credit Memo ID";
        // MITL2995 ++
        IsWhseReqL := CheckWhseLoc(WebCreditHeader);
        if not IsWhseReqL then
            SalesCreditHeader."Document Type" := SalesCreditHeader."Document Type"::"Credit Memo"
        else
            SalesCreditHeader."Document Type" := SalesCreditHeader."Document Type"::"Return Order";  //MITL2995
        //MITL2995 --
        SalesCreditHeader.INSERT(TRUE);
        SalesCreditHeader.VALIDATE("Order Date", WebCreditHeader."Credit Memo Date");
        SalesCreditHeader.VALIDATE("Posting Date", WebCreditHeader."Credit Memo Date");
        SalesCreditHeader.VALIDATE(WebIncrementID, WebCreditHeader."Order ID");
        SalesCreditHeader."Your Reference" := WebCreditHeader."Customer Order No."; //MITL
        SalesCreditHeader.VALIDATE("Sell-to Customer No.", Customer."No.");
        Mapping.GET(WebCreditHeader."Payment Method");
        SalesCreditHeader.VALIDATE("Payment Method Code", Mapping."Dynamics NAV Payment Method Co");
        // MITL.5593.SM.05022020 ++
        if CompanyName() = 'Walls and Floors' then
            SalesCreditHeader.Validate("Shortcut Dimension 1 Code", WebCreditHeader."Dimension Code"); // SM_Business Channel
        if CompanyName() = 'Tile Mountain' then
            SalesCreditHeader.Validate("Shortcut Dimension 2 Code", WebCreditHeader."Dimension Code");
        // MITL.5593.SM.05022020 --

        SalesCreditHeader.MODIFY(TRUE);


        CreateCreditLines(WebCreditHeader."Credit Memo ID", WebCreditHeader."Date Time", WebCreditHeader."LineType");

        IF WebCreditHeader."Shipping & Handling" <> 0 THEN BEGIN
            WEBSetup.TESTFIELD("Shipping and Handling Code");
            SalesCreditLine.INIT;
            SalesCreditLine.SetHideValidationDialog(TRUE);
            SalesCreditLine."Document Type" := SalesCreditHeader."Document Type";
            SalesCreditLine."Document No." := SalesCreditHeader."No.";
            SalesCreditLine."Line No." := WEBCreditLines."Line No" + 10000;
            SalesCreditLine.Type := SalesCreditLine.Type::"G/L Account";
            SalesCreditLine.INSERT(TRUE);
            SalesCreditLine.VALIDATE("No.", WEBSetup."Shipping and Handling Code");
            SalesCreditLine.VALIDATE(Quantity, 1);
            SalesCreditLine.VALIDATE("Qty. to Ship", 0);
            SalesCreditLine.VALIDATE("Unit Price", (WebCreditHeader."Shipping & Handling" + WebCreditHeader.VAT - TotalVATLines));
            // MITL.5593.SM.05022020 ++
            if CompanyName() = 'Walls and Floors' then
                SalesCreditLine.Validate("Shortcut Dimension 1 Code", WEBCreditLines."Dimension Code");// SM_Business Channel
            if CompanyName() = 'Tile Mountain' then
                SalesCreditLine.Validate("Shortcut Dimension 2 Code", WEBCreditLines."Dimension Code");
            // MITL.5593.SM.05022020 --
            SalesCreditLine.MODIFY(TRUE);

            //delete order shipping lines
            SalesLine.RESET;
            SalesLine.SetCurrentKey("Document Type", "Document No.", "No.", "Unit Price", "Quantity Shipped"); // MITL.AJ.20200603 Indexing correction
            SalesLine.SETRANGE(SalesLine."Document Type", SalesLine."Document Type"::Order);
            SalesLine.SETRANGE(SalesLine."Document No.", WebCreditHeader."Order ID");
            SalesLine.SETRANGE(SalesLine."No.", WEBSetup."Shipping and Handling Code");
            SalesLine.SETRANGE(SalesLine."Unit Price", SalesCreditLine."Unit Price");
            SalesLine.SETFILTER(SalesLine."Qty. Shipped (Base)", '0');
            IF SalesLine.FINDFIRST THEN
                SalesLine.DELETE(TRUE);
            //delete order shipping lines
        END;

        IF TotalDiscount + WebCreditHeader."Discount Amount" <> 0 THEN BEGIN //if remaining discount, then it is a shipping discount
            IF WebCreditHeader."Shipping & Handling" <> 0 THEN BEGIN
                WEBSetup.TESTFIELD("Shipping and Handling Code");
                SalesCreditLine.INIT;
                SalesCreditLine.SetHideValidationDialog(TRUE);
                SalesCreditLine."Document Type" := SalesCreditHeader."Document Type";
                SalesCreditLine."Document No." := SalesCreditHeader."No.";
                SalesCreditLine."Line No." := WEBCreditLines."Line No" + 10000;
                SalesCreditLine.Type := SalesCreditLine.Type::"G/L Account";
                SalesCreditLine.INSERT(TRUE);
                SalesCreditLine.VALIDATE("No.", WEBSetup."Shipping and Handling Code");
                SalesCreditLine.VALIDATE(Quantity, -1);
                SalesCreditLine.VALIDATE("Qty. to Ship", 0);

                UPCheck := -(TotalDiscount + WebCreditHeader."Discount Amount");

                SalesCreditLine.VALIDATE("Unit Price", UPCheck);
                SalesCreditLine.MODIFY(TRUE);
                ShipDisc := SalesCreditLine."Unit Price";

                //delete order shipping lines
                SalesLine.RESET;
                SalesLine.SETRANGE(SalesLine."Document Type", SalesLine."Document Type"::Order);
                SalesLine.SETRANGE(SalesLine."Document No.", WebCreditHeader."Order ID");
                SalesLine.SETRANGE(SalesLine."No.", WEBSetup."Shipping and Handling Code");
                SalesLine.SETRANGE(SalesLine."Unit Price", SalesCreditLine."Unit Price");
                SalesLine.SETFILTER(SalesLine."Qty. Shipped (Base)", '0');
                IF SalesLine.FINDFIRST THEN
                    SalesLine.DELETE(TRUE);
                //delete order shipping lines
            END;
        END;

        IF ((WebCreditHeader."Adjustment Refund Amount" <> 0) OR (WebCreditHeader."Adjustment Fee Amount" <> 0)) THEN
            CreateCreditDiscountLine;

        SalesCreditHeader.CALCFIELDS(SalesCreditHeader."Amount Including VAT");

        IF (SalesCreditHeader."Amount Including VAT" = WebCreditHeader."Grand Total") OR
           (ABS(SalesCreditHeader."Amount Including VAT" - WebCreditHeader."Grand Total") <= WEBSetup."Order Variance Tolerance") THEN BEGIN

            WebToolbox.UpdateIndex(WEBIndex, 1, '');
            WITH SalesCreditHeader DO BEGIN

                WEBProcessPayment("No.", "Posting Date", "Document Date", "Sell-to Customer No.", "Payment Method Code", WebIncrementID, -"Amount Including VAT");

                Clear(SalesPost);
                // SalesPost.RUN(SalesCreditHeader); //MITL2995
                //MITL2995 ++
                if not IsWhseReqL then
                    SalesPost.RUN(SalesCreditHeader) //MITL2995
                else begin
                    Clear(WebReturnPostL); //MITL2995
                    WebReturnPostL.Run(SalesCreditHeader); //MITL2995
                    SalesCreditHeader.Invoice := True; //MITL2995
                    SalesCreditHeader.Modify(); //MITL2995
                    Commit(); //MITL2995.AJ.28APR2020
                    SalesPost.RUN(SalesCreditHeader); //MITL2995
                end;
                //MITL2995 --
                WebToolbox.UpdateIndex(WEBIndex, 1, '');
            END;
        END ELSE BEGIN
            WebToolbox.UpdateIndex(WEBIndex, 2, STRSUBSTNO('CreditMemo Value Incorrect %1 VS %2 (%3) (%4)',
                                    SalesCreditHeader."Amount Including VAT", WebCreditHeader."Grand Total", ShipDisc, TotalDiscount));
            SalesCreditHeader.DELETE(TRUE);
        END;

    end;

    procedure CreateCreditLines(WebOrder: Text[100]; WebDateTime: DateTime; WebType: Integer)
    var
        WebOrdLineQty: Decimal;
        CreditFactor: Decimal;
        CrossRefNo: Code[20];
    begin
        TotalVATLines := 0;
        TotalDiscount := 0;
        WEBCreditLines.SetCurrentKey("Credit Memo ID", "Date Time", LineType); // MITL.AJ.20200603 Indexing correction
        WEBCreditLines.SETRANGE("Credit Memo ID", WebOrder);
        WEBCreditLines.SETRANGE("Date Time", WebDateTime);
        WEBCreditLines.SETRANGE("LineType", WebType);
        IF WEBCreditLines.FINDSET THEN
            REPEAT
                SalesCreditLine.INIT;
                SalesCreditLine.SetHideValidationDialog(TRUE);
                SalesCreditLine."Document Type" := SalesCreditHeader."Document Type";
                SalesCreditLine."Document No." := SalesCreditHeader."No.";
                SalesCreditLine."Line No." := WEBCreditLines."Line No";
                SalesCreditLine.Type := SalesCreditLine.Type::Item;
                SalesCreditLine.INSERT(TRUE);

                CrossRefNo := WebFunc.ReturnCrossReference(WEBCreditLines.Sku);
                IF CrossRefNo <> '' THEN
                    SalesCreditLine.VALIDATE("Cross-Reference No.", CrossRefNo)
                ELSE
                    SalesCreditLine.VALIDATE("No.", WEBCreditLines.Sku);
                EVALUATE(SalesCreditLine.Quantity, WEBCreditLines.QTY);
                SalesCreditLine.VALIDATE(Quantity, SalesCreditLine.Quantity);
                SalesCreditLine.VALIDATE("Qty. to Ship", 0);
                // MITL 14041 +++++
                IF WEBCreditLines."Location Code" <> '' THEN
                    SalesCreditLine.VALIDATE("Location Code", WEBCreditLines."Location Code")
                ELSE
                    SalesCreditLine.VALIDATE("Location Code", WEBSetup."Returns Location");
                // MITL 14041 -----
                //Note that in the existing sales credit memo routine (codeunit 50007), the Order ID and Shipment ID is used to find *****
                //the orginating sales invoice in order to ensure that the unit price is the same

                IF GetWebOrderLine THEN BEGIN
                    SalesCreditLine.VALIDATE("Unit Price", GetUnitPriceFromWebOrderLines);
                    EVALUATE(WebOrdLineQty, WebOrderLines.QTY);
                    CreditFactor := (SalesCreditLine.Quantity / WebOrdLineQty);

                    SalesCreditLine.VALIDATE("Line Discount Amount", CreditFactor * (WebOrderLines."Discount Amount"));
                    IF SalesCreditLine."Line Discount %" > 100 THEN
                        SalesCreditLine.VALIDATE("Line Discount %", 100);

                    TotalVATLines := TotalVATLines + WebOrderLines.VAT * CreditFactor;
                    TotalDiscount := TotalDiscount + WebOrderLines."Discount Amount" * CreditFactor;
                END ELSE
                    IF GetSalesOrderLine(SalesCreditLine."No.") THEN BEGIN
                        CreditFactor := (SalesCreditLine.Quantity / SalesOrdLine.Quantity);
                        SalesCreditLine.VALIDATE("Unit Price", SalesOrdLine."Unit Price");
                        SalesCreditLine.VALIDATE("Line Discount Amount", SalesOrdLine."Line Discount Amount" * CreditFactor);
                        IF SalesCreditLine."Line Discount %" > 100 THEN
                            SalesCreditLine.VALIDATE("Line Discount %", 100);

                        TotalVATLines := TotalVATLines + (SalesOrdLine."Amount Including VAT" - SalesOrdLine.Amount) * CreditFactor;
                        TotalDiscount := TotalDiscount + SalesOrdLine."Line Discount Amount" * CreditFactor;
                    END ELSE
                        IF GetPostedInvoiceLine(SalesCreditLine."No.") THEN BEGIN
                            CreditFactor := (SalesCreditLine.Quantity / PostedSalesInvLine.Quantity);
                            SalesCreditLine.VALIDATE("Unit Price", PostedSalesInvLine."Unit Price");
                            SalesCreditLine.VALIDATE("Line Discount Amount", PostedSalesInvLine."Line Discount Amount" * CreditFactor);
                            IF SalesCreditLine."Line Discount %" > 100 THEN
                                SalesCreditLine.VALIDATE("Line Discount %", 100);

                            TotalVATLines := TotalVATLines + (PostedSalesInvLine."Amount Including VAT" - PostedSalesInvLine.Amount) * CreditFactor;
                            TotalDiscount := TotalDiscount + PostedSalesInvLine."Line Discount Amount" * CreditFactor;
                        END ELSE BEGIN
                            ERROR(NoPreviousOrderText);
                        END;
                // MITL.5593.SM.05022020 ++
                if CompanyName() = 'Walls and Floors' then
                    SalesCreditLine.Validate("Shortcut Dimension 1 Code", WEBCreditLines."Dimension Code");// SM_Business Channel
                if CompanyName() = 'Tile Mountain' then
                    SalesCreditLine.Validate("Shortcut Dimension 2 Code", WEBCreditLines."Dimension Code");// SM_Business Channel
                // MITL.5593.SM.05022020 --
                SalesCreditLine.MODIFY(TRUE);
            UNTIL WEBCreditLines.NEXT = 0;
    end;

    procedure DeleteCreditLines(DocType: Integer; DocNo: Code[20])
    begin
        SalesCreditLine.SETRANGE("Document Type", DocType);
        SalesCreditLine.SETRANGE("Document No.", DocNo);
        SalesCreditLine.DELETEALL(TRUE);
    end;

    procedure ModifyCreditMemo(var WEBIndex: Record "WEB Index")
    var
        CustChanged: Boolean;
        OrderWasShipped: Boolean;
    begin
        WebCreditHeader.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebCreditHeader.FINDFIRST THEN BEGIN
            WEBCheckCustomer(Customer);
            Mapping.GET(WebCreditHeader."Payment Method");

            SalesCreditHeader.SetHideValidationDialog(TRUE);
            IF SalesCreditHeader.GET(SalesCreditHeader."Document Type"::"Credit Memo", WebCreditHeader."Credit Memo ID") THEN BEGIN

                IF (SalesCreditHeader."Order Date" <> WebCreditHeader."Credit Memo Date")
                OR (SalesCreditHeader."Posting Date" <> WebCreditHeader."Credit Memo Date")
                OR (SalesCreditHeader."Sell-to Customer No." <> Customer."No.")
                OR (SalesCreditHeader."Payment Method Code" <> Mapping."Dynamics NAV Payment Method Co") THEN BEGIN

                    CustChanged := (SalesCreditHeader."Sell-to Customer No." <> Customer."No.");
                    IF CustChanged THEN BEGIN
                        DeleteCreditLines(SalesCreditHeader."Document Type", SalesCreditHeader."No."); //may need if codeunit for this function to isolate commit!
                        SalesCreditHeader.VALIDATE("Sell-to Customer No.", Customer."No.");
                    END;

                    SalesCreditHeader.VALIDATE("Order Date", WebCreditHeader."Credit Memo Date");
                    SalesCreditHeader.VALIDATE("Posting Date", WebCreditHeader."Credit Memo Date");
                    SalesCreditHeader.VALIDATE("Payment Method Code", Mapping."Dynamics NAV Payment Method Co");
                    SalesCreditHeader.MODIFY(TRUE);
                END;

                IF CustChanged THEN
                    CreateCreditLines(WebCreditHeader."Credit Memo ID", WebCreditHeader."Date Time", WebCreditHeader."LineType")
                ELSE
                    ModifyCreditMemoLines(WEBIndex);
                WebToolbox.UpdateIndex(WEBIndex, 1, '');
            END ELSE
                WebToolbox.UpdateIndex(WEBIndex, 2, 'Sales Header not found!');
        END ELSE
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Record not found to update');
    end;

    procedure ModifyCreditMemoLines(var WEBIndex: Record "WEB Index")
    var
        WebOrdLineQTY: Decimal;
        OrderLineShipped: Boolean;
        NewUnitPrice: Decimal;
        CrossRefNo: Code[20];
        MagentoSKU: Code[20];
    begin
        SalesCreditLine.SetHideValidationDialog(TRUE);

        WEBCreditLines.RESET;
        WEBCreditLines.SetCurrentKey("Credit Memo ID", "Date Time", LineType); // MITL.AJ.20200603 Indexing correction
        WEBCreditLines.SETRANGE("Credit Memo ID", WebCreditHeader."Credit Memo ID");
        WEBCreditLines.SETRANGE("Date Time", WebCreditHeader."Date Time");
        WEBCreditLines.SETRANGE("LineType", WebCreditHeader."LineType");
        IF WEBCreditLines.FINDSET THEN
            REPEAT
                EVALUATE(WebOrdLineQTY, WEBCreditLines.QTY);

                IF SalesCreditLine.GET(SalesCreditHeader."Document Type", SalesCreditHeader."No.", WEBCreditLines."Line No") THEN BEGIN
                    SalesCreditLine.SetHideValidationDialog(TRUE);

                    CrossRefNo := WebFunc.ReturnCrossReference(WEBCreditLines.Sku);
                    IF CrossRefNo = '' THEN
                        MagentoSKU := WEBCreditLines.Sku
                    ELSE
                        MagentoSKU := WebFunc.ReturnMagentoSKU(CrossRefNo);

                    IF GetWebOrderLine THEN
                        NewUnitPrice := GetUnitPriceFromWebOrderLines
                    ELSE
                        IF GetPostedInvoiceLine(SalesCreditLine."No.") THEN
                            NewUnitPrice := PostedSalesInvLine."Unit Price"
                        ELSE
                            IF GetSalesOrderLine(SalesCreditLine."No.") THEN
                                NewUnitPrice := SalesOrderLine."Unit Price"
                            ELSE
                                ERROR(NoPreviousOrderText);

                    IF (MagentoSKU <> WEBCreditLines.Sku)
                    OR (SalesCreditLine.Quantity <> WebOrdLineQTY)

                    OR (SalesCreditLine."Unit Price" <> NewUnitPrice)

                    OR (SalesCreditLine."Line Discount Amount" <> WEBCreditLines."Discount Amount") THEN BEGIN

                        IF CrossRefNo <> '' THEN
                            SalesCreditLine.VALIDATE("Cross-Reference No.", CrossRefNo)
                        ELSE
                            SalesCreditLine.VALIDATE("No.", WEBCreditLines.Sku);

                        SalesCreditLine.Quantity := WebOrdLineQTY;
                        SalesCreditLine.VALIDATE(Quantity, SalesCreditLine.Quantity);
                        SalesCreditLine.VALIDATE("Unit Price", NewUnitPrice);

                        IF GetWebOrderLine THEN
                            SalesCreditLine.VALIDATE("Line Discount Amount", WebOrderLines."Discount Amount")
                        ELSE
                            IF GetSalesOrderLine(SalesCreditLine."No.") THEN
                                SalesCreditLine.VALIDATE("Line Discount Amount", SalesOrdLine."Line Discount Amount")
                            ELSE
                                IF GetPostedInvoiceLine(SalesCreditLine."No.") THEN
                                    SalesCreditLine.VALIDATE("Line Discount Amount", PostedSalesInvLine."Line Discount Amount")
                                ELSE
                                    ERROR(NoPreviousOrderText);

                        IF SalesCreditLine."Line Discount %" > 100 THEN
                            SalesCreditLine.VALIDATE("Line Discount %", 100);

                        SalesCreditLine.MODIFY(TRUE);
                    END;
                END ELSE
                    WebToolbox.UpdateIndex(WEBIndex, 2, 'Sales Line not found!');
            UNTIL WEBCreditLines.NEXT = 0;
    end;

    procedure DeleteCreditMemo(var WEBIndex: Record "WEB Index")
    var
        WebOrder: Record "WEB Order Header";
    begin
        WebCreditHeader.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebCreditHeader.FINDFIRST THEN BEGIN
            IF SalesCreditHeader.GET(SalesCreditHeader."Document Type"::"Credit Memo", WebCreditHeader."Credit Memo ID") THEN BEGIN
                SalesCreditHeader.DELETE(TRUE);
                WebToolbox.UpdateIndex(WEBIndex, 1, '');
            END ELSE
                WebToolbox.UpdateIndex(WEBIndex, 2, 'Sales Header not found');
        END;
    end;

    procedure HandleCreditMemo(var WEBIndex: Record "WEB Index")
    var
        WebCreditMemo: Record "WEB Credit Header";
    begin
        WebCreditMemo.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebCreditMemo.FINDFIRST THEN BEGIN
            // GetWEBSetup; //garbage code commented MITL.AJ.27Mar2020
            CASE WebCreditMemo."LineType" OF
                WebCreditMemo."LineType"::Insert:
                    InsertCreditMemo(WEBIndex);
                WebCreditMemo."LineType"::Modify:
                    ModifyCreditMemo(WEBIndex);
                WebCreditMemo."LineType"::Delete:
                    DeleteCreditMemo(WEBIndex);
            END;
        END;
    end;

    procedure WEBItemExists(ItemNo: Code[20]): Boolean
    var
        item: Record Item;
    begin
        IF item.GET(ItemNo) THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    procedure WEBCheckCreditLines(CreditMemoID: Code[20]; "Date Time": DateTime; index: Record "WEB Index"): Text
    var
        WEBOrderLines: Record "WEB Order Lines";
        ErrorText: Text;
    begin
        WEBCreditLines.SetCurrentKey("Credit Memo ID", "Date Time"); // MITL.AJ.20200603 Indexing correction
        WEBCreditLines.SETRANGE("Credit Memo ID", CreditMemoID);
        WEBCreditLines.SETRANGE("Date Time", "Date Time");
        IF WEBCreditLines.FINDSET THEN
            REPEAT
                IF NOT WEBItemExists(WEBCreditLines.Sku) THEN BEGIN
                    WebToolbox.CreateRequest(50016, 'Item', WEBCreditLines.Sku, index."Line no.");
                    ErrorText := 'Item(s) do not exist'
                END;
            UNTIL WEBCreditLines.NEXT = 0;

        EXIT(ErrorText);
    end;

    // WEBCheckCreditExist function is not used anywhere
    procedure WEBCheckCreditExist(CreditMemoID: Code[20]; "Date Time": DateTime; index: Record "WEB Index"): Text
    var
        WEBOrderLines: Record "WEB Order Lines";
        ErrorText: Text;
    begin
        WEBCreditLines.SetCurrentKey("Credit Memo ID", "Date Time"); // MITL.AJ.20200603 Indexing correction 
        WEBCreditLines.SETRANGE("Credit Memo ID", CreditMemoID);
        WEBCreditLines.SETRANGE("Date Time", "Date Time");
        IF WEBCreditLines.ISEMPTY THEN
            ErrorText := 'No Lines Exist';

        EXIT(ErrorText);
    end;

    procedure GetWEBSetup()
    begin
        WEBSetup.GET;
    end;

    procedure WEBCheckCustomer(var Customer: Record Customer): Text //MITL.AJ.19Dec2019 ++
    begin
        IF WebFunc.UseDefaultCustomerForCredit(FORMAT(WebCreditHeader."Index No.")) THEN BEGIN
            Customer.SETRANGE("No.", WebFunc.ReturnDefaultCustomer);
            IF Customer.FINDLAST THEN
                EXIT('')
        END;

        IF WebCreditHeader."Customer ID" <> '' THEN BEGIN   //MITL3321
            Customer.SetRange("E-Mail"); //MITL4342
            Customer.SetRange("No.", WebCreditHeader."Customer ID"); //MITL
            IF Customer.FindFirst() then
                exit('')
            ELSE Begin
                Customer.SetRange("No."); //MITL
                Customer.SETRANGE("Customer ID", WebCreditHeader."Customer ID");
                IF Customer.FindFirst() THEN
                    EXIT('');
            End;
        END;

        IF (WebCreditHeader."Customer ID" = '') AND (WebCreditHeader."Customer Email" = '') THEN //MITL3321
            EXIT('Credit ' + WebCreditHeader."Credit Memo ID" + ' has no customer details');

        Customer.SetRange("No."); //MITL
        Customer.SetRange("Customer ID"); //MITL
        Customer.SetRange("E-Mail", WebCreditHeader."Customer Email"); //MITL3321
        IF (Customer.COUNT = 0) THEN BEGIN
            InsertNewCustomer(WebCreditHeader."Customer ID", WebCreditHeader."Customer Email");
            EXIT('No customer found ' + Customer.GETFILTERS + ' ' + WebCreditHeader."Customer ID"); //MITL3321
        END ELSE
            IF (Customer.COUNT >= 1) THEN BEGIN
                Customer.FINDLAST;
                EXIT('');
            END;
    end; //MITL.AJ.19Dec2019 **

    procedure UpdatePaymentMethodMapping(var WEBCreditMemo: Record "WEB Credit Header"): Boolean
    begin
        //ensures all codes there for mapping
        IF NOT Mapping.GET(WEBCreditMemo."Payment Method") THEN BEGIN
            Mapping."Magento Payment Method Code" := WEBCreditMemo."Payment Method";
            Mapping.INSERT;
            EXIT(FALSE);
        END ELSE
            IF Mapping."Dynamics NAV Payment Method Co" = '' THEN
                EXIT(FALSE);

        EXIT(TRUE);
    end;

    procedure WEBProcessPayment(DocNo: Code[20]; PostingDate: Date; DocDate: Date; SellToCustNo: Code[20]; PayMethCode: Code[10]; WebIncrementID: Text[30]; AmountIncVAT: Decimal)
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        PaymentMethodTemplateMAP: Record "Payment Method Template MAP";
        CustL: Record Customer; //MITL3772
        CustLedgerEntL: Record "Cust. Ledger Entry";//mitl.vs.20200709
        ApplyRefundtoCrEntryNo: Code[50];
    begin
        Mapping.SETRANGE(Mapping."Dynamics NAV Payment Method Co", PayMethCode);
        Mapping.FINDFIRST;
        PaymentMethodTemplateMAP.GET(PayMethCode);

        IF PaymentMethodTemplateMAP."Create No Payment" THEN
            EXIT;

        //mitl.vs.20200709<<
        ApplyRefundtoCrEntryNo := '';
        IF NOT Mapping."Online Payment" then
            exit;
        //mitl.vs.20200709>>

        GenJnlBatch.GET(PaymentMethodTemplateMAP."Sales Pmt. Jnl Template Name", PaymentMethodTemplateMAP."Sales Pmt. Jnl Batch Name");


        GenJnlLine."Journal Template Name" := GenJnlBatch."Journal Template Name";
        GenJnlLine."Journal Batch Name" := GenJnlBatch.Name;
        EVALUATE(GenJnlLine."Line No.", WebCreditHeader."Index No.");
        GenJnlLine."Document No." := DocNo;
        GenJnlLine.INSERT(TRUE);

        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;

        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Posting Date" := Today;
        GenJnlLine."Document Date" := Today;
        GenJnlLine.VALIDATE("Account No.", SellToCustNo);
        GenJnlLine.VALIDATE("Bal. Account Type", GenJnlLine."Bal. Account Type"::"Bank Account");
        GenJnlLine.VALIDATE("Bal. Account No.", GenJnlBatch."Bal. Account No.");

        //MITL_VS_20200707++
        // if PartialShipment AND (PartialRefundAmtG > 0) then
        //     GenJnlLine.Validate(Amount, PartialRefundAmtG)
        // else//MITL_VS_20200707--
        GenJnlLine.VALIDATE(Amount, -AmountIncVAT);
        // MITL.5593.SM.05022020 ++
        if CompanyName() = 'Walls and Floors' then
            GenJnlLine.Validate("Shortcut Dimension 1 Code", WebCreditHeader."Dimension Code"); // SM_Business Channel
        if CompanyName() = 'Tile Mountain' then
            GenJnlLine.Validate("Shortcut Dimension 2 Code", WebCreditHeader."Dimension Code");
        // MITL.5593.SM.05022020 --

        GenJnlLine.WebIncrementID := WebIncrementID;

        //MITL.AK.5030 ++
        IF CustL.Get(SellToCustNo) then;

        //mitl.vs.20200709<<
        //refund applies to credit memo 
        CustLedgerEntL.Reset();
        CustLedgerEntL.SetRange("Customer No.", CustL."No.");
        CustLedgerEntL.SetRange(WebIncrementID, WebIncrementID);
        CustLedgerEntL.SetRange("Document Type", CustLedgerEntL."Document Type"::"Credit Memo");
        // CustLedgerEntL.SetRange(Open, true); // MITL.SM.5442.20200817
        if CustLedgerEntL.FindFirst() then
            ApplyRefundtoCrEntryNo := format(CustLedgerEntL."Document No."); // MITL.SM.5442.20200720
                                                                             //mitl.vs.20200709>>

        if (CustL."Credit Limit (LCY)" <= 0) and (ApplyRefundtoCrEntryNo <> '') then begin
            // GenJnlLine.VALIDATE("Applies-to ID", WebIncrementID);//mitl.vs.20200709 commented
            GenJnlLine.Validate("Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type"::"Credit Memo");
            GenJnlLine.VALIDATE("Applies-to Doc. No.", ApplyRefundtoCrEntryNo);//mitl.vs.20200709
        end;
        //MITL.AK.5030 --
        //MITL3772 ++

        IF GenJnlLine.Description = '' THEN
            GenJnlLine.Description := CustL.Name;
        //MITL3772 **

        GenJnlLine.MODIFY(TRUE);

        IF GenJnlLine.Amount <> 0 THEN
            GenJnlPostLine.RunWithCheck(GenJnlLine);
        GenJnlLine.DELETE;
    end;

    procedure WebCheckErrors(var WebIndex: Record "WEB Index")
    begin
        CheckCreditMemoExists(WebIndex);
        CheckPaymentMethodMapping(WebIndex);
        CheckCustomer(WebIndex);

        IF WEBCheckCreditLines(WebCreditHeader."Credit Memo ID", WebCreditHeader."Date Time", WebIndex) <> '' THEN
            WebToolbox.UpdateIndex(WebIndex, 3, WEBCheckCreditLines(WebCreditHeader."Credit Memo ID", WebCreditHeader."Date Time", WebIndex));
        CheckCreditAlreadyExists(WebIndex);
    end;

    procedure CheckCreditMemoExists(var WebIndex: Record "WEB Index")
    begin
        WebCreditHeader.SETRANGE("Index No.", FORMAT(WebIndex."Line no."));
        IF NOT WebCreditHeader.FINDFIRST THEN BEGIN
            WebToolbox.UpdateIndex(WebIndex, 2, 'Record Not Found');
        END;
    end;

    procedure CheckPaymentMethodMapping(var WebIndex: Record "WEB Index")
    begin
        IF NOT UpdatePaymentMethodMapping(WebCreditHeader) THEN
            WebToolbox.UpdateIndex(WebIndex, 2, 'Payment Method Mapping not Complete');
    end;

    procedure CheckCustomer(var WebIndex: Record "WEB Index")
    var
        Customer: Record Customer;
    begin
        IF WEBCheckCustomer(Customer) <> '' THEN
            WebToolbox.UpdateIndex(WebIndex, 2, WEBCheckCustomer(Customer));
    end;

    procedure CheckCreditAlreadyExists(var WebIndex: Record "WEB Index")
    var
        SalesHeader: Record "Sales Header";
        PostedCreditHeader: Record "Sales Cr.Memo Header";
    begin
        WebCreditHeader.SETRANGE("Index No.", FORMAT(WebIndex."Line no."));
        IF WebCreditHeader.FINDFIRST THEN BEGIN
            IF SalesCreditHeader.GET(SalesCreditHeader."Document Type"::"Credit Memo", WebCreditHeader."Credit Memo ID") THEN
                WebToolbox.UpdateIndex(WebIndex, 2, 'CreditMemo Already Exists');

            PostedCreditHeader.SETCURRENTKEY("Pre-Assigned No.");
            PostedCreditHeader.SETRANGE("Pre-Assigned No.", WebCreditHeader."Credit Memo ID");
            IF NOT PostedCreditHeader.ISEMPTY THEN
                WebToolbox.UpdateIndex(WebIndex, 2, 'Credit ' + WebCreditHeader."Credit Memo ID" + ' Already Exists - as posted credit');

        END;
    end;

    procedure CreateCreditDiscountLine()
    begin
        SalesCreditLine.INIT;
        SalesCreditLine.SetHideValidationDialog(TRUE);
        SalesCreditLine."Document Type" := SalesCreditHeader."Document Type";
        SalesCreditLine."Document No." := SalesCreditHeader."No.";
        SalesCreditLine."Line No." := 10000000;
        SalesCreditLine.Type := SalesCreditLine.Type::"G/L Account";
        SalesCreditLine.INSERT(TRUE);

        GLAccount.GET(WEBSetup."Credit Memo Discount Account");
        VATPostingSetup.GET(GLAccount."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");

        SalesCreditLine.VALIDATE("No.", WEBSetup."Credit Memo Discount Account");
        SalesCreditLine.VALIDATE(Quantity, 1);
        SalesCreditLine.VALIDATE("Unit Price", WebCreditHeader."Adjustment Refund Amount" - WebCreditHeader."Adjustment Fee Amount");
        SalesCreditLine.MODIFY(TRUE);
    end;

    procedure GetUnitPriceFromWebOrderLines() UnitPrice: Decimal
    var
        Quantity: Decimal;
    begin
        WebOrderLines.SETRANGE("Order ID", WEBCreditLines."Order ID");
        WebOrderLines.SETRANGE(Sku, WEBCreditLines.Sku);
        WebOrderLines.SETFILTER("LineType", '<>%1', WebOrderLines."LineType"::Delete);
        IF WebOrderLines.FINDLAST THEN BEGIN
            EVALUATE(Quantity, WebOrderLines.QTY);
            UnitPrice := (WebOrderLines.Subtotal + WebOrderLines.VAT) / Quantity;
        END;

        EXIT(UnitPrice);
    end;

    procedure ShipmentExists(): Boolean
    begin
        SalesShipHeader.RESET;
        SalesShipHeader.SETCURRENTKEY("Order No."); // MITL.AJ.20200603 Indexing correction
        SalesShipHeader.SETRANGE("Order No.", WebCreditHeader."Order ID");

        IF SalesShipHeader.ISEMPTY THEN BEGIN
            SalesShipHeader.SETRANGE("Order No.");
            SalesShipHeader.SETRANGE(SalesShipHeader.WebIncrementID, WebCreditHeader."Order ID");
        END;
        EXIT(NOT SalesShipHeader.ISEMPTY);
    end;

    procedure OrderExists(): Boolean
    begin
        SalesOrderHeader.RESET;
        SalesOrderHeader.SETRANGE("Document Type", SalesOrderHeader."Document Type"::Order);
        SalesOrderHeader.SETRANGE("No.", WebCreditHeader."Order ID");

        IF SalesOrderHeader.ISEMPTY THEN BEGIN
            SalesOrderHeader.SETRANGE("No.");
            SalesOrderHeader.SETRANGE(WebIncrementID, WebCreditHeader."Order ID");
        END;
        // MITL 23-oct-2019 ++
        if NOT SalesOrderHeader.ISEMPTY then
            SalesOrderHeader.Get(SalesOrderHeader."Document Type"::Order, WebCreditHeader."Order ID");
        // MITL 23-oct-2019 --
        EXIT(NOT SalesOrderHeader.ISEMPTY);
    end;

    procedure ReverseOrderAndPayments(var WebIndex: Record "WEB Index") Reversed: Boolean
    var
        WebCreditLine_L: Record "WEB Credit Lines";
        WebCreditHeader_L: Record "WEB Credit Header";
    begin
        Reversed := DeleteUnshippedOrderLines(WebIndex);

        IF Reversed THEN begin
            RefundPayment(WebIndex);
            MovementCreated := true;
        end
        else begin

            // UndoShipment(WebIndex);
            //MITL.SM.20200713 ++
            WebCreditLine_L.Reset();
            // WebCreditLine_L.SetRange("Credit Memo ID", WebIndex."Order ID");//MITL.VS.20200715
            if WebIndex."Order ID" <> '' then
                WebCreditLine_L.SetRange("Order ID", WebIndex."Order ID")//MITL.VS.20200715
            else begin
                WebCreditHeader_L.Reset();
                WebCreditHeader_L.SetRange("Index No.", format(WebIndex."Line no."));
                if WebCreditHeader_L.FindFirst() then
                    WebCreditLine_L.SetRange("Credit Memo ID", WebCreditHeader_L."Credit Memo ID");
            end;
            if WebCreditLine_L.FindSet() then
                repeat
                    CreateMovement(WebCreditLine_L);// MITL.SM.5442.20200728
                                                    //SOOutstandQtyMovement(WEBCreditLines, 0); //MITL.SM.5442.20200727
                until WebCreditLine_L.Next() = 0;
            //MITL.SM.20200713  --
            RefundPayment(WebIndex);
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Shipment lines exists without invoice. You will have to manually undo the shipment.');
            //exit(true);
        end;

        EXIT(Reversed)
    end;

    procedure RefundPayment(var WebIndex: Record "WEB Index")
    var
        ReversalEntry: Record "Reversal Entry";
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        CustCount: Integer;
        RefundAmount: Decimal;
        PaymentMethodTemplateMAP: Record "Payment Method Template MAP";
        PayMethCode: Code[10];
    begin

        Mapping.GET(WebCreditHeader."Payment Method");

        //MITL.VS.20200709<<
        if NOT Mapping."Online Payment" then
            Exit;
        //MITL.VS.20200709>>

        PayMethCode := Mapping."Dynamics NAV Payment Method Co";

        PaymentMethodTemplateMAP.GET(PayMethCode);
        IF PaymentMethodTemplateMAP."Create No Payment" THEN
            EXIT;

        CustomerLedgerEntry.SETCURRENTKEY(WebIncrementID);
        CustomerLedgerEntry.SETRANGE(WebIncrementID, WebCreditHeader."Order ID");
        CustomerLedgerEntry.SETRANGE("Document Type", CustomerLedgerEntry."Document Type"::Payment);
        // CustomerLedgerEntry.SetRange(Open, true);// MITL.5442.SM.20200514//mitl.vs.20200709
        CustCount := CustomerLedgerEntry.COUNT;

        //mitl.vs.20200709<<
        if CustCount > 1 then
            CustomerLedgerEntry.SetRange(Open, true);
        //mitl.vs.20200709>>

        CASE CustCount OF
            0:
                ERROR(NoPaymentPostedTxt);
            1:
                BEGIN
                    CustomerLedgerEntry.FINDFIRST;
                    CustomerLedgerEntry.CALCFIELDS(Amount);

                    Mapping.GET(WebCreditHeader."Payment Method");

                    WEBProcessPayment(WebCreditHeader."Credit Memo ID", WebCreditHeader."Credit Memo Date", WebCreditHeader."Credit Memo Date", Customer."No.",
                                     Mapping."Dynamics NAV Payment Method Co", WebCreditHeader."Order ID", -WebCreditHeader."Grand Total");

                    WebToolbox.UpdateIndex(WebIndex, 1, '');
                END;
            ELSE
                ERROR(TooManyPaymentsTxt);
        END;
    end;

    procedure DeleteUnshippedOrderLines(var WebIndex: Record "WEB Index") OrderLinesDeleted: Boolean
    var
        Qty: Decimal;
        ItemNo: Code[20];
        CrossRefNo: Code[20];
        SalesLine: Record "Sales Line";
        TotalCredited: Decimal;
        NewSalesLine: Record "Sales Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        ModifiedLines: Boolean;
        ShippingErrors: Text;
    begin

        TotalCredited := 0;
        OrderLinesDeleted := FALSE;
        SalesOrderHeader.RESET;
        SalesOrderHeader.SETRANGE("Document Type", SalesOrderHeader."Document Type"::Order);
        SalesOrderHeader.SETRANGE("No.", WebCreditHeader."Order ID");
        IF SalesOrderHeader.FINDSET THEN BEGIN
            SalesOrderLine.RESET;
            SalesOrderLine.SetCurrentKey("Document Type", "Document No.", "Quantity Shipped", "Unit Price"); // MITL.AJ.20200603 Indexing correction
            SalesOrderLine.SETRANGE("Document Type", SalesOrderHeader."Document Type"::Order);
            SalesOrderLine.SETRANGE("Document No.", SalesOrderHeader."No.");
            SalesOrderLine.SETFILTER("Quantity Shipped", '<>%1', 0);

            WebOrderHeader.SETRANGE("Order ID", WebCreditHeader."Order ID");
            WebOrderHeader.SETFILTER("LineType", '<>%1', WebOrderHeader."LineType"::Delete);
            IF NOT WebOrderHeader.FINDLAST THEN
                WebOrderHeader.INIT;

            IF SalesOrderLine.ISEMPTY AND (WebCreditHeader."Grand Total" = WebOrderHeader."Grand Total") THEN BEGIN // if no lines shipped and totals agree then delete order
                SalesOrderHeader.UpdateRoxLog(STRSUBSTNO(SalesOrderDelTxt, SalesOrderHeader."No."), SalesOrderHeader.WebIncrementID, SalesOrderHeader."Web Shipment Increment Id");
                SalesOrderHeader.DELETE(TRUE);
                OrderLinesDeleted := TRUE;
            END ELSE BEGIN
                WEBCreditLines.RESET;
                WEBCreditLines.SetCurrentKey("Credit Memo ID", "Date Time", "LineType"); // MITL.AJ.20200603 Indexing correction 
                WEBCreditLines.SETRANGE("Credit Memo ID", WebCreditHeader."Credit Memo ID");
                WEBCreditLines.SETRANGE("Date Time", WebCreditHeader."Date Time");
                WEBCreditLines.SETRANGE("LineType", WebCreditHeader."LineType");
                IF WEBCreditLines.FINDSET THEN
                    REPEAT
                        EVALUATE(Qty, WEBCreditLines.QTY);

                        SalesOrderLine.SETRANGE(Type, SalesOrderLine.Type::Item);
                        CrossRefNo := WebFunc.ReturnCrossReference(WEBCreditLines.Sku);
                        IF CrossRefNo = '' THEN
                            ItemNo := WEBCreditLines.Sku
                        ELSE
                            ItemNo := WebFunc.ReturnItemNo(WEBCreditLines.Sku);

                        SalesOrderLine.SETRANGE("No.", ItemNo);
                        SalesOrderLine.SETRANGE("Quantity Shipped", 0);
                        IF SalesOrderLine.FINDFIRST THEN BEGIN

                            IF SalesOrderLine.Quantity > Qty THEN BEGIN
                                TotalCredited := TotalCredited + SalesOrderLine."Unit Price" * Qty;
                                WarehouseActivityLine.SETRANGE("Source No.", SalesOrderLine."Document No.");
                                WarehouseActivityLine.SETRANGE("Source Line No.", SalesOrderLine."Line No.");
                                IF WarehouseActivityLine.FINDSET THEN
                                    WarehouseActivityLine.DELETEALL(TRUE);
                                ModifiedLines := TRUE;
                                SalesOrderLine.SuspendStatusCheck(true); //MITL.AJ.14012020 //MITL5442
                                SalesOrderLine.VALIDATE(Quantity, SalesOrderLine.Quantity - Qty);

                                SalesOrderLine.MODIFY(TRUE);
                            END ELSE BEGIN
                                TotalCredited := TotalCredited + SalesOrderLine."Unit Price" * SalesOrderLine.Quantity;
                                SalesOrderHeader.UpdateRoxLog(STRSUBSTNO(SalesOrderLineDelTxt, SalesOrderHeader."No.", SalesOrderLine."Line No."),
                                  SalesOrderHeader.WebIncrementID, SalesOrderHeader."Web Shipment Increment Id");
                                SalesOrderLine.DELETE(TRUE);
                            END;

                            OrderLinesDeleted := TRUE;
                        END;
                    UNTIL WEBCreditLines.NEXT = 0;

                //delete order shipping lines
                WEBSetup.GET;
                SalesLine.RESET;
                SalesLine.SetCurrentKey("Document Type", "Document No.", "No.", "Unit Price", "Qty. Shipped (Base)"); // MITL.AJ.20200603 Indexing correction
                SalesLine.SETRANGE(SalesLine."Document Type", SalesLine."Document Type"::Order);
                SalesLine.SETRANGE(SalesLine."Document No.", SalesOrderHeader."No.");
                SalesLine.SETRANGE(SalesLine."No.", WEBSetup."Shipping and Handling Code");
                SalesLine.SETRANGE(SalesLine."Unit Price", WebCreditHeader."Grand Total" - TotalCredited);
                SalesLine.SETFILTER(SalesLine."Qty. Shipped (Base)", '0');
                IF SalesLine.FINDFIRST THEN
                    SalesLine.DELETE(TRUE);
                //delete order shipping lines


                SalesOrderLine.RESET;
                SalesOrderLine.SETRANGE("Document Type", SalesOrderHeader."Document Type"::Order);
                SalesOrderLine.SETRANGE("Document No.", SalesOrderHeader."No.");
                IF SalesOrderLine.ISEMPTY THEN BEGIN
                    SalesOrderHeader.UpdateRoxLog(STRSUBSTNO(SalesOrderDelTxt, SalesOrderHeader."No."), SalesOrderHeader.WebIncrementID, SalesOrderHeader."Web Shipment Increment Id");
                    SalesOrderHeader.DELETE(TRUE);
                END;
            END;
        END;

        IF ModifiedLines THEN BEGIN
            WebFunc.SalesOrderReleaseManagement(SalesOrderHeader, ShippingErrors, FALSE);
        END;

        EXIT(OrderLinesDeleted);

    end;

    procedure GetWebOrderLine() WEBOrderFound: Boolean
    begin

        WebOrderLines.SetCurrentKey("Order ID", "LineType"); // MITL.AJ.20200603 Indexing correction
        WebOrderLines.SETRANGE("Order ID", WEBCreditLines."Order ID");
        WebOrderLines.SETRANGE(Sku, WEBCreditLines.Sku);
        WebOrderLines.SETFILTER("LineType", '<>%1', WebOrderLines."LineType"::Delete);
        IF WebOrderLines.FINDLAST THEN
            WEBOrderFound := TRUE
        ELSE BEGIN
            WebOrderLines.INIT;
            WEBOrderFound := FALSE;
        END;


        EXIT(WEBOrderFound);
    end;

    procedure GetPostedInvoiceLine(ItemNo: Code[20]) PostedInvoiceFound: Boolean
    begin

        PostedInvoiceFound := FALSE;

        PostedSalesInvHeader.SETCURRENTKEY(WebIncrementID);
        PostedSalesInvHeader.SETRANGE(WebIncrementID, WEBCreditLines."Order ID");
        IF PostedSalesInvHeader.FINDSET THEN BEGIN
            PostedSalesInvLine.SETRANGE("Document No.", PostedSalesInvHeader."No.");
            PostedSalesInvLine.SETRANGE(Type, PostedSalesInvLine.Type::Item);
            PostedSalesInvLine.SETRANGE("No.", ItemNo);
            IF PostedSalesInvLine.FINDFIRST THEN
                PostedInvoiceFound := TRUE
            ELSE BEGIN
                PostedSalesInvLine.INIT;
                PostedInvoiceFound := TRUE;
            END;
        END;

        EXIT(PostedInvoiceFound);

    end;

    procedure GetSalesOrderLine(ItemNo: Code[20]) SalesOrderFound: Boolean
    begin

        SalesOrderFound := FALSE;

        SalesOrdHeader.SETCURRENTKEY(WebIncrementID);
        SalesOrdHeader.SETRANGE(WebIncrementID, WEBCreditLines."Order ID");
        SalesOrdHeader.SETRANGE("Document Type", SalesOrdHeader."Document Type"::Order);
        IF SalesOrdHeader.FINDSET THEN BEGIN
            SalesOrdLine.SETRANGE("Document Type", SalesOrdHeader."Document Type");
            SalesOrdLine.SETRANGE("Document No.", SalesOrdHeader."No.");
            SalesOrdLine.SETRANGE(Type, SalesOrdLine.Type::Item);
            SalesOrdLine.SETRANGE("No.", ItemNo);
            IF SalesOrdLine.FINDFIRST THEN
                SalesOrderFound := TRUE
            ELSE BEGIN
                SalesOrdLine.INIT;
                SalesOrderFound := TRUE;
            END;
        END;

        EXIT(SalesOrderFound);

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

    //MITL4006 ++
    local procedure PartialShipment() PartialExistR: Boolean
    var
        WebCreditLinesL: Record "WEB Credit Lines";
        SalesShipLinesL: Record "Sales Shipment Line";
    begin
        PartialExistR := false;
        SalesShipHeader.RESET;
        SalesShipHeader.SETCURRENTKEY("Order No.");
        SalesShipHeader.SETRANGE("Order No.", WebCreditHeader."Order ID");
        IF SalesShipHeader.IsEmpty() THEN BEGIN
            SalesShipHeader.SETRANGE("Order No.");
            SalesShipHeader.SETRANGE(SalesShipHeader.WebIncrementID, WebCreditHeader."Order ID");
            IF not SalesShipHeader.IsEmpty() THEN BEGIN
                WebCreditLinesL.Reset();
                WebCreditLinesL.SetCurrentKey("Credit Memo ID", "Date Time"); // MITL.AJ.20200603 Indexing correction
                WebCreditLinesL.SetRange("Credit Memo ID", WebCreditHeader."Credit Memo ID");
                WebCreditLinesL.SetRange("Date Time", WebCreditHeader."Date Time");
                IF WebCreditLinesL.FindSet() THEN
                    repeat
                        SalesShipLinesL.Reset();
                        SalesShipLinesL.SetCurrentKey("Order No.", "No.", "Quantity Invoiced"); // MITL.AJ.20200603 Indexing correction
                        // SalesShipLinesL.SetRange("Document No.", SalesShipHeader."No."); //MITL5442.AJ.03Mar2020
                        SalesShipLinesL.SetRange("Order No.", WebCreditHeader."Order ID"); //MITL5442.AJ.03Mar2020
                        SalesShipLinesL.SetRange("No.", WebCreditLinesL.Sku);
                        SalesShipLinesL.Setfilter("Quantity Invoiced", '<>%1', 0); //MITL.AJ.19Dec2019 ++
                        IF SalesShipLinesL.FindFirst() then
                            PartialExistR := true;
                        // The below code should be commented because of no use. Qty shipped should be used for filter //MITL.AJ.23012020 ++
                        // ELSE BEGIN
                        //     SalesShipLinesL.SETRANGE("Quantity Invoiced");
                        //     SalesShipLinesL.Setfilter("Qty. Shipped Not Invoiced", '<>%1', 0);
                        //     IF SalesShipLinesL.FindFirst() then
                        //         PartialExistR := true
                        // END; //MITL.AJ.19Dec2019 ** //MITL.AJ.23012020 **
                    until (WebCreditLinesL.Next() = 0) or (PartialExistR);
            END;
        END ELSE BEGIN
            SalesShipHeader.FindLast();
            WebCreditLinesL.Reset();
            WebCreditLinesL.SetCurrentKey("Credit Memo ID", "Date Time"); // MITL.AJ.20200603 Indexing correction
            WebCreditLinesL.SetRange("Credit Memo ID", WebCreditHeader."Credit Memo ID");
            WebCreditLinesL.SetRange(WebCreditLinesL."Date Time", WebCreditHeader."Date Time");
            IF WebCreditLinesL.FindSet() THEN
                repeat
                    SalesShipLinesL.Reset();
                    SalesShipLinesL.SetCurrentKey("Order No.", "No.", "Quantity Invoiced"); // MITL.AJ.20200603 Indexing correction
                    // SalesShipLinesL.SetRange("Document No.", SalesShipHeader."No."); //MITL5442.AJ.03Mar2020
                    SalesShipLinesL.SetRange("Order No.", WebCreditHeader."Order ID"); //MITL5442.AJ.03Mar2020
                    SalesShipLinesL.SetRange(SalesShipLinesL."No.", WebCreditLinesL.Sku);
                    SalesShipLinesL.Setfilter("Quantity Invoiced", '<>%1', 0); //MITL.AJ.19Dec2019 ++
                    IF SalesShipLinesL.FindFirst() then
                        PartialExistR := true
                // The below code should be commented because of no use. Qty shipped should be used for filter //MITL.AJ.23012020 ++
                // ELSE BEGIN
                //     SalesShipLinesL.SETRANGE("Quantity Invoiced");
                //     SalesShipLinesL.Setfilter("Qty. Shipped Not Invoiced", '<>%1', 0);
                //     IF SalesShipLinesL.FindFirst() then
                //         PartialExistR := true
                // END; //MITL.AJ.19Dec2019 ** //MITL.AJ.23012020 **
                until (WebCreditLinesL.Next() = 0) or (PartialExistR);
        end;
    end;
    //MITL4006 **

    //MITL4006 ++
    procedure CreateCreditMemoshippedItems(VAR WebIndex: Record "WEB Index"; WebCreditP: Record "WEB Credit Header")
    var
        UPCheck: Decimal;
        Top: Decimal;
        Bottom: Decimal;
        SalesPost: Codeunit "Sales-Post";
        SalesLine: Record "Sales Line";
        WebCreditTotalL: Decimal; //MITL.AJ.09012020
        SalesCreditLineL: Record "Sales Line"; //MITL.AJ.23012020
        SalesLineL: Record "Sales Line"; //MITL.AJ.23012020
        IsWhseReqL: Boolean; //MITL2995
        WebReturnPostL: Codeunit "WEB Handling Sales Return Post"; //MITL2995
        SaleCrHeaderL: Record "Sales Header"; //MITL2995
        WebIndexL: Record "WEB Index"; //MITL2995
        SalesInvLineL: Record "Sales Invoice Line";
        PostedCrHdr_L: Record "Sales Cr.Memo Header";
    begin
        SalesCreditHeader.INIT;
        SalesCreditHeader.SetHideValidationDialog(TRUE);
        SalesCreditHeader."No." := WebCreditP."Credit Memo ID";
        // MITL2995 ++
        IsWhseReqL := CheckWhseLoc(WebCreditHeader);
        if not IsWhseReqL then
            SalesCreditHeader."Document Type" := SalesCreditHeader."Document Type"::"Credit Memo"
        else
            SalesCreditHeader."Document Type" := SalesCreditHeader."Document Type"::"Return Order";  //MITL2995
        //MITL2995 --
        SalesCreditHeader.INSERT(TRUE);

        SalesCreditHeader.VALIDATE("Order Date", WebCreditP."Credit Memo Date");
        SalesCreditHeader.VALIDATE("Posting Date", WebCreditP."Credit Memo Date");
        SalesCreditHeader.VALIDATE(WebIncrementID, WebCreditP."Order ID");
        SalesCreditHeader.VALIDATE("Sell-to Customer No.", Customer."No.");
        SalesCreditHeader."Your Reference" := WebCreditP."Customer Order No.";

        Mapping.GET(WebCreditP."Payment Method");

        SalesCreditHeader.VALIDATE("Payment Method Code", Mapping."Dynamics NAV Payment Method Co");
        // MITL.5593.SM.05022020 ++
        if CompanyName() = 'Walls and Floors' then
            SalesCreditHeader.Validate("Shortcut Dimension 1 Code", WebCreditP."Dimension Code");
        if CompanyName() = 'Tile Mountain' then
            SalesCreditHeader.Validate("Shortcut Dimension 2 Code", WebCreditP."Dimension Code");
        // MITL.5593.SM.05022020 --
        // MITL.5542.SM.20200731 ++
        PostedCrHdr_L.Reset();
        PostedCrHdr_L.SetRange(WebIncrementID, WebCreditP."Order ID");
        if PostedCrHdr_L.FindLast() then
            SalesCreditHeader."Posting No." := IncStr(PostedCrHdr_L."No.")
        else
            SalesCreditHeader."Posting No." := WebCreditP."Credit Memo ID";
        // MITL.5542.SM.20200731 --
        SalesCreditHeader.MODIFY(TRUE);

        CreateCreditLinesforShippedItems(WebCreditP."Credit Memo ID", WebCreditP."Date Time", WebCreditP."LineType");

        IF WebCreditP."Shipping & Handling" <> 0 THEN BEGIN
            WEBSetup.TESTFIELD("Shipping and Handling Code");
            //MITL.AJ.23012020 ++
            SalesCreditLineL.Reset();
            SalesCreditLineL.SetRange("Document Type", SalesCreditHeader."Document Type");
            SalesCreditLineL.SetRange("Document No.", SalesCreditHeader."No.");
            IF SalesCreditLineL.FindLast() THEN;
            //MITL.AJ.23012020 **

            //MITL.AJ.23012020 ++
            SalesInvLineL.Reset();
            SalesInvLineL.SetRange("Order No.", WebCreditP."Order ID");
            SalesInvLineL.SetRange(Type, SalesLineL.Type::"G/L Account");
            SalesInvLineL.SetFilter(quantity, '>%1', 0);
            // IF SalesLineL.FindFirst() then BEGIN//Commented MITL_VS_20200703
            //MITL.AJ.23012020 **
            IF SalesInvLineL.FindFirst() then BEGIN//MITL_VS_20200703
                SalesCreditLine.INIT;
                SalesCreditLine.SetHideValidationDialog(TRUE);
                SalesCreditLine."Document Type" := SalesCreditHeader."Document Type";
                SalesCreditLine."Document No." := SalesCreditHeader."No.";
                SalesCreditLine."Line No." := SalesCreditLineL."Line No." + 10000; //MITL.AJ.23012020
                SalesCreditLine.Type := SalesCreditLine.Type::"G/L Account";
                SalesCreditLine.INSERT(TRUE);
                SalesCreditLine.VALIDATE("No.", WEBSetup."Shipping and Handling Code");
                SalesCreditLine.VALIDATE(Quantity, 1);
                SalesCreditLine.VALIDATE("Qty. to Ship", 0);
                // MITL.SM.5442.20200730 ++
                GLAcc.Get(WEBSetup."Shipping and Handling Code");
                VATPostSetup.Reset();
                VATPostSetup.Get(SalesCreditHeader."VAT Bus. Posting Group", GLAcc."VAT Prod. Posting Group");
                // MITL.SM.5442.20200730 ++
                SalesCreditLine.VALIDATE("Unit Price",
                (WebCreditP."Shipping & Handling" + WebCreditP.VAT - TotalVATLines)); // // MITL.SM.5442.20200730 ++
                // MITL.5593.SM.05022020 ++
                if CompanyName() = 'Walls and Floors' then
                    SalesCreditLine.Validate("Shortcut Dimension 1 Code", WebCreditP."Dimension Code");
                if CompanyName() = 'Tile Mountain' then
                    SalesCreditLine.Validate("Shortcut Dimension 2 Code", WebCreditP."Dimension Code");
                // MITL.5593.SM.05022020 --
                SalesCreditLine.MODIFY(TRUE);
            END; //MITL.AJ.23012020

            //delete order shipping lines
            SalesLine.RESET;
            SalesLine.SetCurrentKey("Document Type", "Document No.", Type, "No."); // MITL.AJ.20200603 Indexing correction
            SalesLine.SETRANGE(SalesLine."Document Type", SalesLine."Document Type"::Order);
            SalesLine.SETRANGE(SalesLine."Document No.", WebCreditP."Order ID");
            SalesLine.SETRANGE(SalesLine."No.", WEBSetup."Shipping and Handling Code");
            SalesLine.SETFILTER(SalesLine."Qty. Shipped (Base)", '0');
            IF SalesLine.FINDFIRST THEN
                SalesLine.DELETE(TRUE);
            //delete order shipping lines
        END;
        IF TotalDiscount + WebCreditP."Discount Amount" <> 0 THEN BEGIN //if remaining discount, then it is a shipping discount
            IF WebCreditP."Shipping & Handling" <> 0 THEN BEGIN
                WEBSetup.TESTFIELD("Shipping and Handling Code");
                //MITL.AJ.23012020 ++
                SalesCreditLineL.Reset();
                SalesCreditLineL.SetRange("Document Type", SalesCreditHeader."Document Type");
                SalesCreditLineL.SetRange("Document No.", SalesCreditHeader."No.");
                IF SalesCreditLineL.FindLast() THEN;
                //MITL.AJ.23012020 **

                //MITL.AJ.23012020 ++
                SalesInvLineL.Reset();
                SalesInvLineL.SetRange("Order No.", WebCreditP."Order ID");
                SalesInvLineL.SetRange(Type, SalesLineL.Type::"G/L Account");
                SalesInvLineL.SetFilter("Quantity", '<%1', 0);
                // IF SalesLineL.FindFirst() then BEGIN //Commented MITL_VS_20200703
                //MITL.AJ.23012020 **
                if SalesInvLineL.FindFirst() then begin//MITL_VS_20200703
                    SalesCreditLine.INIT;
                    SalesCreditLine.SetHideValidationDialog(TRUE);
                    SalesCreditLine."Document Type" := SalesCreditHeader."Document Type";
                    SalesCreditLine."Document No." := SalesCreditHeader."No.";
                    SalesCreditLine."Line No." := SalesCreditLineL."Line No." + 20000;  //MITL.AJ.23012020
                    SalesCreditLine.Type := SalesCreditLine.Type::"G/L Account";
                    SalesCreditLine.INSERT(TRUE);
                    SalesCreditLine.VALIDATE("No.", WEBSetup."Shipping and Handling Code");
                    SalesCreditLine.VALIDATE(Quantity, -1);
                    SalesCreditLine.VALIDATE("Qty. to Ship", 0);

                    UPCheck := -(TotalDiscount + WebCreditP."Discount Amount");

                    SalesCreditLine.VALIDATE("Unit Price", UPCheck);
                    SalesCreditLine.MODIFY(TRUE);
                    ShipDisc := SalesCreditLine."Unit Price";
                END; //MITL.AJ.23012020
                //delete order shipping lines
                SalesLine.RESET;
                SalesLine.SetCurrentKey("Document Type", "Document No.", Type, "No."); // MITL.AJ.20200603 Indexing correction
                SalesLine.SETRANGE(SalesLine."Document Type", SalesLine."Document Type"::Order);
                SalesLine.SETRANGE(SalesLine."Document No.", WebCreditP."Order ID");
                SalesLine.SETRANGE(SalesLine."No.", WEBSetup."Shipping and Handling Code");
                SalesLine.SETFILTER(SalesLine."Qty. Shipped (Base)", '0');
                IF SalesLine.FINDFIRST THEN
                    SalesLine.DELETE(TRUE);
                //delete order shipping lines
            END;
        END;

        IF ((WebCreditP."Adjustment Refund Amount" <> 0) OR (WebCreditP."Adjustment Fee Amount" <> 0)) THEN
            CreateCreditDiscountLine;

        SalesCreditHeader.CALCFIELDS(SalesCreditHeader."Amount Including VAT");


        // WebToolbox.UpdateIndex(WEBIndex, 1, ''); //MITL2995.AJ.28APR2020
        SalesCreditLineL.Reset();
        SalesCreditLineL.SetRange("Document Type", SalesCreditHeader."Document Type");
        SalesCreditLineL.SetRange("Document No.", SalesCreditHeader."No.");
        if SalesCreditLineL.IsEmpty() then
            SalesCreditHeader.Delete(true);

        WITH SalesCreditHeader DO BEGIN
            // WEBProcessPayment("No.", "Posting Date", "Document Date", "Sell-to Customer No.", "Payment Method Code", WebIncrementID, -"Amount Including VAT");
            Clear(SalesPost);

            //MITL2995 ++
            if not IsWhseReqL then
                SalesPost.RUN(SalesCreditHeader) //MITL2995
            else begin
                Clear(WebReturnPostL); //MITL2995
                WebReturnPostL.Run(SalesCreditHeader); //MITL2995
                SaleCrHeaderL.Reset();
                IF SaleCrHeaderL.GET(SalesCreditHeader."Document Type", SalesCreditHeader."No.") THEN BEGIN
                    SaleCrHeaderL.Receive := true;
                    SaleCrHeaderL.Invoice := True;
                    SaleCrHeaderL.Modify();
                    SalesPost.RUN(SaleCrHeaderL); //MITL2995
                END;

            end;
            //MITL2995 --
            IF WebIndexL.Get(WebIndex."Line no.") THEN  //MITL2995
                WebToolbox.UpdateIndex(WebIndexL, 1, ''); //MITL2995
        END;

    end;
    //MITL4006 **

    //MITL4006 ++
    procedure CreateCreditLinesforShippedItems(WebOrder: Text[100]; WebDateTime: DateTime; WebType: Integer)
    var
        WebOrdLineQty: Decimal;
        CreditFactor: Decimal;
        CrossRefNo: Code[20];
        QtyL: Decimal;
        ItemNoL: Code[20];
        CrossRefNoL: Code[20];
        SalesLine: Record "Sales Line";
        TotalCredited: Decimal;
        NewSalesLine: Record "Sales Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        ModifiedLines: Boolean;
        ShippingErrors: Text;
        WhseShipLinesL: Record "Warehouse Shipment Line"; //MITL5442
        QtytoReturn: Decimal;
        CreditQty: Decimal;
    begin
        // MITL 23-oct-2019 ++
        if SalesOrderHeader.Get(SalesOrderHeader."Document Type"::Order, WebCreditHeader."Order ID") then;
        // MITL 23-oct-2019 --
        TotalVATLines := 0;
        TotalDiscount := 0;
        WEBCreditLines.Reset();
        WEBCreditLines.SetCurrentKey("Credit Memo ID", "Date Time", LineType); // MITL.AJ.20200603 Indexing correction
        WEBCreditLines.SETRANGE("Credit Memo ID", WebOrder);
        WEBCreditLines.SETRANGE("Date Time", WebDateTime);
        WEBCreditLines.SETRANGE("LineType", WebType);
        IF WEBCreditLines.FINDSET THEN
            REPEAT
                // MITL.SM.20200714 ++ Code to check the outstanding qty on SO. 
                // If the outstanding Qty is there, reduce the Credit memo qty from SO and for the remaining Qty
                // Create credit memo
                Evaluate(CreditQty, WEBCreditLines.QTY);
                QtytoReturn := CreditQty;
                CrossRefNoL := WebFunc.ReturnCrossReference(WEBCreditLines.Sku);
                IF CrossRefNoL = '' THEN
                    ItemNoL := WEBCreditLines.Sku
                ELSE
                    ItemNoL := WebFunc.ReturnItemNo(WEBCreditLines.Sku);
                SalesOrderLine.Reset();
                SalesOrderLine.SetRange("Document Type", SalesOrderLine."Document Type"::Order);
                SalesOrderLine.SetRange("Document No.", WEBCreditLines."Order ID");
                SalesOrderLine.SetRange(Type, SalesOrderLine.Type::Item);
                SalesOrderLine.SetRange("No.", ItemNoL);
                SalesOrderLine.SetFilter("Outstanding Quantity", '>%1', 0);
                if SalesOrderLine.FindFirst() then
                    if SalesOrderLine."Outstanding Quantity" >= CreditQty then begin
                        QtytoReturn := 0;
                        SalesOrderLine.SuspendStatusCheck(true);
                        if SalesOrderLine."Outstanding Quantity" = CreditQty then begin
                            SalesOrderLine.Delete(true);
                            SalesOrderLine.Reset();
                            SalesOrderLine.SetRange("Document Type", SalesOrderLine."Document Type"::Order);
                            SalesOrderLine.SetRange("Document No.", WEBCreditLines."Order ID");
                            SalesOrderLine.SetRange(Type, SalesOrderLine.Type::Item);
                            if SalesOrderLine.IsEmpty then begin
                                if SalesOrderHeader.get(SalesOrderHeader."Document Type"::Order, WEBCreditLines."Order ID") then
                                    SalesOrderHeader.Delete(true);
                            end;
                        end
                        else begin
                            UpdateQtyonSalesLine(SalesOrderLine, CreditQty);
                            WebFunc.SalesOrderReleaseManagement(SalesOrderHeader, ShippingErrors, FALSE);
                        end;
                    end
                    else begin
                        QtytoReturn := CreditQty - SalesOrderLine."Outstanding Quantity";
                    end;

                // IF CheckShippedLines(WEBCreditLines) THEN BEGIN
                IF CheckShippedLines(WEBCreditLines) and (QtytoReturn > 0) THEN BEGIN
                    // MITL.SM.20200714 --    
                    // SOOutstandQtyMovement(WEBCreditLines); // MITL.SM.20200714
                    SalesCreditLine.INIT;
                    SalesCreditLine.SetHideValidationDialog(TRUE);
                    SalesCreditLine."Document Type" := SalesCreditHeader."Document Type";
                    SalesCreditLine."Document No." := SalesCreditHeader."No.";
                    SalesCreditLine."Line No." := WEBCreditLines."Line No";
                    SalesCreditLine.Type := SalesCreditLine.Type::Item;
                    SalesCreditLine.INSERT(TRUE);

                    CrossRefNo := WebFunc.ReturnCrossReference(WEBCreditLines.Sku);
                    IF CrossRefNo <> '' THEN
                        SalesCreditLine.VALIDATE("Cross-Reference No.", CrossRefNo)
                    ELSE
                        SalesCreditLine.VALIDATE("No.", WEBCreditLines.Sku);

                    //MITL_VS_20200707++
                    //mitl.vs.20200708++
                    FullOrderCancelCheck(WEBCreditLines);
                    if FullCancelOrderG then begin
                        if CheckPartialShippedQty(WEBCreditLines) <> 0 then
                            SalesCreditLine.validate(Quantity, CheckPartialShippedQty(WEBCreditLines))
                        // MITL.SM.5442.20200717 ++
                        else
                            SalesCreditLine.VALIDATE(Quantity, QtytoReturn);
                        // MITL.SM.5442.20200717 --
                    end//mitl.vs.20200708--
                    else begin
                        //MITL_VS_20200707--   
                        //EVALUATE(SalesCreditLine.Quantity, WEBCreditLines.QTY);
                        //MITL.SM.20200714 ++
                        // SalesCreditLine.VALIDATE(Quantity, SalesCreditLine.Quantity);
                        SalesCreditLine.VALIDATE(Quantity, QtytoReturn);
                        //MITL.SM.20200714 --
                    end;//MITL_VS_20200707
                    SalesCreditLine.VALIDATE("Qty. to Ship", 0);
                    IF WEBCreditLines."Location Code" <> '' THEN
                        SalesCreditLine.VALIDATE("Location Code", WEBCreditLines."Location Code")
                    ELSE
                        SalesCreditLine.VALIDATE("Location Code", WEBSetup."Returns Location");
                    //Note that in the existing sales credit memo routine (codeunit 50007), the Order ID and Shipment ID is used to find *****
                    //the orginating sales invoice in order to ensure that the unit price is the same

                    IF GetWebOrderLine THEN BEGIN
                        SalesCreditLine.VALIDATE("Unit Price", GetUnitPriceFromWebOrderLines);

                        EVALUATE(WebOrdLineQty, WebOrderLines.QTY);
                        // MITL.SM.5542.20200720 ++
                        // CreditFactor := (SalesCreditLine.Quantity / WebOrdLineQty);
                        CreditFactor := (CreditQty / WebOrdLineQty);
                        // MITL.SM.5542.20200720 --

                        SalesCreditLine.VALIDATE("Line Discount Amount", CreditFactor * (WebOrderLines."Discount Amount"));
                        IF SalesCreditLine."Line Discount %" > 100 THEN
                            SalesCreditLine.VALIDATE("Line Discount %", 100);

                        // TotalVATLines := TotalVATLines + WebOrderLines.VAT * CreditFactor;
                        // TotalDiscount := TotalDiscount + WebOrderLines."Discount Amount" * CreditFactor;

                    END ELSE
                        IF GetSalesOrderLine(SalesCreditLine."No.") THEN BEGIN
                            // MITL.SM.5542.20200720 ++
                            //CreditFactor := (SalesCreditLine.Quantity / SalesOrdLine.Quantity);
                            CreditFactor := (CreditQty / SalesOrdLine.Quantity);
                            // MITL.SM.5542.20200720 --
                            SalesCreditLine.VALIDATE("Unit Price", SalesOrdLine."Unit Price");
                            SalesCreditLine.VALIDATE("Line Discount Amount", SalesOrdLine."Line Discount Amount" * CreditFactor);
                            IF SalesCreditLine."Line Discount %" > 100 THEN
                                SalesCreditLine.VALIDATE("Line Discount %", 100);

                            // TotalVATLines := TotalVATLines + (SalesOrdLine."Amount Including VAT" - SalesOrdLine.Amount) * CreditFactor;
                            // TotalDiscount := TotalDiscount + SalesOrdLine."Line Discount Amount" * CreditFactor;
                        END ELSE
                            IF GetPostedInvoiceLine(SalesCreditLine."No.") THEN BEGIN
                                CreditFactor := (SalesCreditLine.Quantity / PostedSalesInvLine.Quantity);
                                SalesCreditLine.VALIDATE("Unit Price", PostedSalesInvLine."Unit Price");
                                SalesCreditLine.VALIDATE("Line Discount Amount", PostedSalesInvLine."Line Discount Amount" * CreditFactor);
                                IF SalesCreditLine."Line Discount %" > 100 THEN
                                    SalesCreditLine.VALIDATE("Line Discount %", 100);

                                // TotalVATLines := TotalVATLines + (PostedSalesInvLine."Amount Including VAT" - PostedSalesInvLine.Amount) * CreditFactor;
                                // TotalDiscount := TotalDiscount + PostedSalesInvLine."Line Discount Amount" * CreditFactor;
                            END ELSE BEGIN
                                ERROR(NoPreviousOrderText);
                            END;

                    // MITL.5593.SM.05022020 ++
                    if CompanyName() = 'Walls and Floors' then
                        SalesCreditLine.Validate("Shortcut Dimension 1 Code", WEBCreditLines."Dimension Code");
                    if CompanyName() = 'Tile Mountain' then
                        SalesCreditLine.Validate("Shortcut Dimension 2 Code", WEBCreditLines."Dimension Code");
                    // MITL.5593.SM.05022020 --
                    SalesCreditLine.MODIFY(TRUE);
                END;
            UNTIL WEBCreditLines.NEXT = 0;

        WEBCreditLines.Reset();
        WEBCreditLines.SetCurrentKey("Credit Memo ID", "Date Time", LineType); // MITL.AJ.20200603 Indexing correction
        WEBCreditLines.SETRANGE("Credit Memo ID", WebOrder);
        WEBCreditLines.SETRANGE("Date Time", WebDateTime);
        WEBCreditLines.SETRANGE("LineType", WebType);
        IF WEBCreditLines.FINDSET THEN
            REPEAT
                // MITL.SM.5442.30072020 ++   
                Evaluate(CreditQty, WEBCreditLines.QTY);
                IF GetWebOrderLine THEN BEGIN
                    EVALUATE(WebOrdLineQty, WebOrderLines.QTY);
                    CreditFactor := (CreditQty / WebOrdLineQty);
                    TotalVATLines := TotalVATLines + WebOrderLines.VAT * CreditFactor;
                    TotalDiscount := TotalDiscount + WebOrderLines."Discount Amount" * CreditFactor;
                END ELSE
                    IF GetSalesOrderLine(SalesCreditLine."No.") THEN BEGIN
                        CreditFactor := (CreditQty / SalesOrdLine.Quantity);
                        TotalVATLines := TotalVATLines + (SalesOrdLine."Amount Including VAT" - SalesOrdLine.Amount) * CreditFactor;
                        TotalDiscount := TotalDiscount + SalesOrdLine."Line Discount Amount" * CreditFactor;
                    END ELSE
                        IF GetPostedInvoiceLine(SalesCreditLine."No.") THEN BEGIN
                            CreditFactor := (SalesCreditLine.Quantity / PostedSalesInvLine.Quantity);
                            TotalVATLines := TotalVATLines + (PostedSalesInvLine."Amount Including VAT" - PostedSalesInvLine.Amount) * CreditFactor;
                            TotalDiscount := TotalDiscount + PostedSalesInvLine."Line Discount Amount" * CreditFactor;
                        END;
                // MITL.SM.5442.30072020 ++
                SOOutstandQtyMovement(WEBCreditLines, QtytoReturn);//mitl.vs+nk.20200709 //MITL.SM.5442.20200727
                // MITL 23-oct-2019 ++
                if SalesOrderHeader.Get(SalesOrderHeader."Document Type"::Order, WebCreditHeader."Order ID") then;
                // MITL 23-oct-2019 --
                SalesOrderLine.RESET;
                SalesOrderLine.SetCurrentKey("Document Type", "Document No.", Type, "No."); // MITL.AJ.20200603 Indexing correction
                SalesOrderLine.SETRANGE("Document Type", SalesOrderHeader."Document Type"::Order);
                SalesOrderLine.SETRANGE("Document No.", SalesOrderHeader."No.");
                SalesOrderLine.SETRANGE(Type, SalesOrderLine.Type::Item);

                EVALUATE(QtyL, WEBCreditLines.QTY);

                CrossRefNoL := WebFunc.ReturnCrossReference(WEBCreditLines.Sku);
                IF CrossRefNoL = '' THEN
                    ItemNoL := WEBCreditLines.Sku
                ELSE
                    ItemNoL := WebFunc.ReturnItemNo(WEBCreditLines.Sku);

                SalesOrderLine.SETRANGE("No.", ItemNoL);
                SalesOrderLine.SETRANGE("Quantity Shipped", 0);
                IF SalesOrderLine.FINDFIRST THEN BEGIN
                    IF SalesOrderLine.Quantity > QtyL THEN BEGIN
                        TotalCredited := TotalCredited + SalesOrderLine."Unit Price" * QtyL;
                        // MITL.SM.5442.20200727 Test Code ++

                        // MITL.SM.5442.20200727 Test Code --
                        // MITL.SM.20200714 ++
                        UpdateQtyonSalesLine(SalesOrderLine, QtyL);
                        ModifiedLines := TRUE;
                        // WarehouseActivityLine.SETRANGE("Source No.", SalesOrderLine."Document No.");
                        // WarehouseActivityLine.SETRANGE("Source Line No.", SalesOrderLine."Line No.");
                        // IF WarehouseActivityLine.FINDSET THEN
                        //     WarehouseActivityLine.DELETEALL(TRUE);

                        // //MITL4552 ++  //MITL.AJ.14012020
                        // WhseShipLinesL.Reset();
                        // WhseShipLinesL.SetRange("Source Type", 37);
                        // WhseShipLinesL.SetRange(WhseShipLinesL."Source No.", SalesOrderLine."Document No.");
                        // WhseShipLinesL.SetRange(WhseShipLinesL."Item No.", SalesOrderLine."No.");
                        // WhseShipLinesL.Setfilter(WhseShipLinesL."Qty. Shipped", '%1', 0);
                        // IF WhseShipLinesL.FindFirst() then begin //MITL.AJ.21012020 //MITL5442
                        //     WhseShipLinesL.SuspendStatusCheck(True); //MITL.AJ.21012020 //MITL5442
                        //     WhseShipLinesL.Delete(True);
                        // END; //MITL.AJ.21012020 //MITL5442
                        //      //MITL5442 ** //MITL.AJ.14012020
                        // ModifiedLines := TRUE;
                        // SalesOrderLine.SuspendStatusCheck(True); //MITL.AJ.14012020 //MITL5442
                        // SalesOrderLine.VALIDATE(Quantity, SalesOrderLine.Quantity - QtyL);
                        // SalesOrderLine.MODIFY(TRUE);
                    END ELSE BEGIN
                        TotalCredited := TotalCredited + SalesOrderLine."Unit Price" * SalesOrderLine.Quantity;
                        SalesOrderHeader.UpdateRoxLog(STRSUBSTNO(SalesOrderLineDelTxt, SalesOrderHeader."No.", SalesOrderLine."Line No."),
                          SalesOrderHeader.WebIncrementID, SalesOrderHeader."Web Shipment Increment Id");
                        SalesOrderLine.DELETE(TRUE);
                    END;
                END;

                //delete order shipping lines
                WEBSetup.GET;

                SalesLine.RESET;
                SalesLine.SetCurrentKey("Document Type", "Document No.", Type, "No."); // MITL.AJ.20200603 Indexing correction
                SalesLine.SETRANGE(SalesLine."Document Type", SalesLine."Document Type"::Order);
                SalesLine.SETRANGE(SalesLine."Document No.", SalesOrderHeader."No.");
                SalesLine.SETRANGE(SalesLine."No.", WEBSetup."Shipping and Handling Code");
                SalesLine.SETFILTER(SalesLine."Qty. Shipped (Base)", '0');
                IF SalesLine.FINDFIRST THEN
                    SalesLine.DELETE(TRUE);
                //delete order shipping lines

                if SalesOrderHeader.Get(SalesOrderHeader."Document Type"::Order, WebCreditHeader."Order ID") then begin // MITL 23-oct-2019
                    SalesOrderLine.RESET;
                    SalesOrderLine.SETRANGE("Document Type", SalesOrderHeader."Document Type"::Order);
                    SalesOrderLine.SETRANGE("Document No.", SalesOrderHeader."No.");
                    IF SalesOrderLine.ISEMPTY THEN BEGIN
                        SalesOrderHeader.UpdateRoxLog(STRSUBSTNO(SalesOrderDelTxt, SalesOrderHeader."No."), SalesOrderHeader.WebIncrementID, SalesOrderHeader."Web Shipment Increment Id");
                        SalesOrderHeader.DELETE(TRUE);
                    END ELSE BEGIN //MITL.AJ.23012020 ++ //MITL5442 ++
                        SalesOrderLine.SetFilter("Quantity Invoiced", '%1', 0);
                        SalesOrderLine.SetFilter("Quantity Shipped", '%1', 0);
                        IF SalesOrderLine.FindSet() then
                            repeat
                                SalesOrderLine.Delete(true);
                            until SalesOrderLine.Next() = 0
                        Else begin
                            SalesOrderLine.Setrange("Quantity Invoiced");
                            SalesOrderLine.Setrange("Quantity Shipped");
                            SalesOrderLine.SetFilter("Quantity Invoiced", '<>%1', 0);
                            IF SalesOrderLine.FindSet() then
                                SalesOrderHeader.Delete(True);
                        END;
                    END;
                    //MITL.AJ.23012020 ** //MITL5442 **
                END;// MITL 23-oct-2019

                IF ModifiedLines THEN BEGIN
                    WebFunc.SalesOrderReleaseManagement(SalesOrderHeader, ShippingErrors, FALSE);
                END;

            UNTIL WEBCreditLines.NEXT = 0;
    end;
    //MITL4006 **
    local procedure CheckShippedLines(WebCreditLineP: Record "WEB Credit Lines") LineExistR: Boolean
    var
        SalesShipLinesL: Record "Sales Shipment Line";
    begin
        LineExistR := false;
        SalesShipHeader.RESET;
        SalesShipHeader.SETCURRENTKEY("Order No.");
        SalesShipHeader.SETRANGE("Order No.", WebCreditHeader."Order ID");
        // IF SalesShipHeader.IsEmpty() THEN BEGIN
        IF NOT SalesShipHeader.FindSet() THEN BEGIN
            SalesShipHeader.SETRANGE("Order No.");
            SalesShipHeader.SETRANGE(SalesShipHeader.WebIncrementID, WebCreditHeader."Order ID");
            // IF not SalesShipHeader.IsEmpty() THEN
            IF SalesShipHeader.FindSet() THEN  //MITL5442.AJ.04Mar20
                REPEAT //MITL5442.AJ.04Mar20
                       // LineExistR := CheckItemShipped(SalesShipHeader."No.", WebCreditLineP.Sku) //MITL5442.AJ.04Mar20
                    LineExistR := CheckItemShipped(SalesShipHeader."Order No.", WebCreditLineP.Sku); //MITL5442.AJ.04Mar20
                                                                                                     // ELSE //MITL5442.AJ.04Mar20
                                                                                                     // LineExistR := CheckItemShipped(SalesShipHeader."No.", WebCreditLineP.Sku); //MITL5442.AJ.04Mar20
                UNTIL (SalesShipHeader.Next() = 0) OR (LineExistR); //MITL5442.AJ.04Mar20
        END ELSE
            REPEAT //MITL5442.AJ.04Mar20
                   // LineExistR := CheckItemShipped(SalesShipHeader."No.", WebCreditLineP.Sku); //MITL5442.AJ.04Mar20
                LineExistR := CheckItemShipped(SalesShipHeader."Order No.", WebCreditLineP.Sku) //MITL5442.AJ.04Mar20
            UNTIL (SalesShipHeader.Next() = 0) OR (LineExistR); //MITL5442.AJ.04Mar20
    end;

    // local procedure CheckItemShipped(ShipmentDocNoP: Code[20]; ItemNoP: Code[20]): Boolean   //MITL5442.AJ.04Mar20
    local procedure CheckItemShipped(ShipmentOrderNoP: Code[20]; ItemNoP: Code[20]): Boolean //MITL5442.AJ.04Mar20
    var
        SalesShipLinesL: Record "Sales Shipment Line";
    BEGIN
        SalesShipLinesL.Reset();
        SalesShipLinesL.SetCurrentKey("Order No.", "No.", "Quantity Invoiced"); // MITL.AJ.20200603 Indexing correction
        // SalesShipLinesL.SetRange("Document No.", ShipmentDocNoP);  //MITL5442.AJ.04Mar20
        SalesShipLinesL.SetRange("Order No.", ShipmentOrderNoP);  //MITL5442.AJ.04Mar20
        SalesShipLinesL.SetRange("No.", ItemNoP);
        SalesShipLinesL.Setfilter("Quantity Invoiced", '<>%1', 0); //MITL.AJ.19Dec2019
        IF SalesShipLinesL.FindFirst() then
            exit(True);
        // ELSE BEGIN //MITL.AJ.19Dec2019 ++
        //     SalesShipLinesL.SETRANGE("Quantity Invoiced");
        //     SalesShipLinesL.Setfilter("Qty. Shipped Not Invoiced", '<>%1', 0);
        //     IF SalesShipLinesL.FindFirst() then
        //         Exit(True);
        // END;
        Exit(False);
        //MITL.AJ.19Dec2019**
    END;
    //MITL4006 **

    //MITL4523 ++ //MITL.AJ.19Dec2019 ++
    local procedure NoCreditLinesFound(WebIndexP: Record "WEB Index"): Boolean
    var
        WebCreditHeaderL: Record "WEB Credit Header";
        WebCreditLinesL: Record "WEB Credit Lines";
    Begin
        WebCreditHeaderL.Reset();
        WebCreditHeaderL.SETRANGE("Index No.", FORMAT(WebIndexP."Line no."));
        IF WebCreditHeaderL.FINDFIRST THEN BEGIN
            WebCreditLinesL.Reset();
            WebCreditLinesL.SetRange("Credit Memo ID", WebCreditHeaderL."Credit Memo ID");
            WebCreditLinesL.SetRange(WebCreditLinesL."Date Time", WebCreditHeaderL."Date Time");
            IF WebCreditLinesL.IsEmpty() THEN
                Exit(true);
        End;

        exit(false);
    End;

    local procedure CheckInvoiceandPayment(WebIndexP: Record "WEB Index")
    var
        WebCreditHeaderL: Record "WEB Credit Header";
        CustLedgerEntryL: Record "Cust. Ledger Entry";
        SalesCreditHeaderL: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
    Begin

        WebCreditHeaderL.Reset();
        WebCreditHeaderL.SetRange("Index No.", Format(WebIndexP."Line no."));
        IF WebCreditHeaderL.FindFirst() THEN BEGIN
            IF WebCreditHeaderL."Order ID" <> '' then BEGIN
                CustLedgerEntryL.Reset();
                CustLedgerEntryL.SetCurrentKey(WebIncrementID); // MITL.AJ.20200603 Indexing correction
                CustLedgerEntryL.SetRange(WebIncrementID, WebCreditHeaderL."Order ID");
                CustLedgerEntryL.SetRange("Document Type", CustLedgerEntryL."Document Type"::Invoice);
                IF CustLedgerEntryL.FindSet() THEN BEGIN
                    IF (CustLedgerEntryL.Count() <> 0) THEN BEGIN
                        IF (CustLedgerEntryL.Count() > 1) then
                            CreateCreditMemoWithoutLinesforShippingCharges(WebCreditHeaderL)
                        Else
                            CreateCreditMemoWithoutLines(WebCreditHeaderL);
                    END;
                END ELSE //MITL.AJ.10012020
                    CreateCreditMemoWithoutLines(WebCreditHeaderL); //MITL.AJ.10012020
            END;
            IF WebCreditHeaderL."Payment Method" <> '' THEN BEGIN
                SalesCreditHeaderL.Reset();
                SalesCreditHeaderL.SetRange("Document Type", SalesCreditHeaderL."Document Type"::"Credit Memo");
                SalesCreditHeaderL.SetRange("No.", WebCreditHeaderL."Credit Memo ID");
                IF SalesCreditHeaderL.FindFirst() THEN BEGIN
                    SalesCreditHeaderL.CalcFields("Amount Including VAT"); //MITL.AJ.06012020
                    IF (SalesCreditHeaderL."Amount Including VAT" = WebCreditHeaderL."Grand Total") OR
                        (ABS(SalesCreditHeaderL."Amount Including VAT" - WebCreditHeaderL."Grand Total") <= WEBSetup."Order Variance Tolerance") THEN BEGIN

                        WITH SalesCreditHeaderL DO BEGIN
                            Clear(SalesPost);

                            SalesPost.RUN(SalesCreditHeaderL);
                            RefundPayment(WebIndexP);// MITL.SM.5442.20200727
                            WebToolbox.UpdateIndex(WebIndexP, 1, '');
                        END;
                    END ELSE BEGIN
                        WebToolbox.UpdateIndex(WebIndexP, 2, STRSUBSTNO('CreditMemo Value Incorrect %1 VS %2',
                                                SalesCreditHeaderL."Amount Including VAT", WebCreditHeaderL."Grand Total"));
                        SalesCreditHeaderL.DELETE(TRUE);
                    END;
                END;

            END;
        END;
    END;


    Local procedure CreateCreditMemoWithoutLinesforShippingCharges(WebCreditHeaderP: Record "WEB Credit Header")
    var
        SalesCreditHeaderL: Record "Sales Header";
        SalesCreditLineL: Record "Sales Line";
        WEBSetupL: Record "WEB Setup";
        MappingL: Record "WEB Mapping";
        CustomerL: Record Customer;
        SalesInvHeadL: Record "Sales Invoice Header";
        SalesInvLineL: Record "Sales Invoice Line";
    BEGIN
        // 5442.SM ++
        //CustomerL.Get(WebCreditHeaderP."Customer ID");
        WEBCheckCustomer(Customer);
        // 5442.SM --
        WEBSetupL.Get();
        IF WebCreditHeaderP."Shipping & Handling" <> 0 THEN BEGIN
            SalesInvHeadL.Reset();
            SalesInvHeadL.SetCurrentKey(WebIncrementID); // MITL.AJ.20200603 Indexing correction
            SalesInvHeadL.SetRange(WebIncrementID, WebCreditHeaderP."Order ID");
            IF SalesInvHeadL.FindFirst() THEN BEGIN
                SalesInvLineL.Reset();
                SalesInvLineL.SetCurrentKey("Document No.", Type, "No."); // MITL.AJ.20200603 Indexing correction
                SalesInvLineL.SetRange("Document No.", SalesInvHeadL."No.");
                SalesInvLineL.SetRange(Type, SalesInvLineL.Type::"G/L Account");
                SalesInvLineL.SetRange("No.", WEBSetupL."Shipping and Handling Code");
                IF SalesInvLineL.FindFirst() then BEGIN
                    SalesCreditHeaderL.INIT;
                    SalesCreditHeaderL.SetHideValidationDialog(TRUE);
                    SalesCreditHeaderL."No." := WebCreditHeaderP."Credit Memo ID";
                    SalesCreditHeaderL."Document Type" := SalesCreditHeader."Document Type"::"Credit Memo";
                    SalesCreditHeaderL.INSERT(TRUE);
                    SalesCreditHeaderL.VALIDATE("Order Date", WebCreditHeaderP."Credit Memo Date");
                    SalesCreditHeaderL.VALIDATE("Posting Date", WebCreditHeaderP."Credit Memo Date");
                    SalesCreditHeaderL.VALIDATE(WebIncrementID, WebCreditHeaderP."Order ID");
                    SalesCreditHeaderL.VALIDATE("Sell-to Customer No.", Customer."No.");
                    SalesCreditHeaderL."Your Reference" := WebCreditHeaderP."Customer Order No.";
                    MappingL.GET(WebCreditHeaderP."Payment Method");
                    SalesCreditHeaderL.VALIDATE("Payment Method Code", Mapping."Dynamics NAV Payment Method Co");
                    // MITL.5593.SM.05022020 ++
                    if CompanyName() = 'Walls and Floors' then
                        SalesCreditHeaderL.Validate("Shortcut Dimension 1 Code", WebCreditHeaderP."Dimension Code");
                    if CompanyName() = 'Tile Mountain' then
                        SalesCreditHeaderL.Validate("Shortcut Dimension 2 Code", WebCreditHeaderP."Dimension Code");
                    // MITL.5593.SM.05022020 --

                    SalesCreditHeaderL.MODIFY(TRUE);

                    IF WebCreditHeaderP."Shipping & Handling" <> 0 THEN BEGIN
                        WEBSetup.TESTFIELD("Shipping and Handling Code");
                        SalesCreditLineL.INIT;
                        SalesCreditLineL.SetHideValidationDialog(TRUE);
                        SalesCreditLineL."Document Type" := SalesCreditHeaderL."Document Type";
                        SalesCreditLineL."Document No." := SalesCreditHeaderL."No.";
                        SalesCreditLineL."Line No." := 10000;
                        SalesCreditLineL.Type := SalesCreditLineL.Type::"G/L Account";
                        SalesCreditLineL.INSERT(TRUE);
                        SalesCreditLineL.VALIDATE("No.", WEBSetup."Shipping and Handling Code");
                        SalesCreditLineL.VALIDATE(Quantity, 1);
                        SalesCreditLineL.VALIDATE("Qty. to Ship", 0);
                        SalesCreditLineL.VALIDATE("Unit Price", (WebCreditHeaderP."Shipping & Handling" + WebCreditHeaderP.VAT - TotalVATLines));
                        // MITL.5593.SM.05022020 ++
                        if CompanyName() = 'Walls and Floors' then
                            SalesCreditLineL.Validate("Shortcut Dimension 1 Code", WebCreditHeaderP."Dimension Code");
                        if CompanyName() = 'Tile Mountain' then
                            SalesCreditLineL.Validate("Shortcut Dimension 2 Code", WebCreditHeaderP."Dimension Code");
                        // MITL.5593.SM.05022020 --
                        SalesCreditLineL.MODIFY(TRUE);
                    end;
                END;
            END;
        END;
    End;

    Local procedure CreateCreditMemoWithoutLines(WebCreditHeaderP: Record "WEB Credit Header")
    var
        SalesCreditHeaderL: Record "Sales Header";
        SalesCreditLineL: Record "Sales Line";
        WEBSetupL: Record "WEB Setup";
        MappingL: Record "WEB Mapping";
        CustomerL: Record Customer;
    BEGIN
        // 5442.SM ++
        // CustomerL.Get(WebCreditHeaderP."Customer ID");
        WEBCheckCustomer(Customer);
        // 5442.SM --
        WEBSetupL.Get();
        SalesCreditHeaderL.INIT;
        SalesCreditHeaderL.SetHideValidationDialog(TRUE);
        SalesCreditHeaderL."No." := WebCreditHeaderP."Credit Memo ID";
        SalesCreditHeaderL."Document Type" := SalesCreditHeader."Document Type"::"Credit Memo";
        SalesCreditHeaderL.INSERT(TRUE);
        SalesCreditHeaderL.VALIDATE("Order Date", WebCreditHeaderP."Credit Memo Date");
        SalesCreditHeaderL.VALIDATE("Posting Date", WebCreditHeaderP."Credit Memo Date");
        SalesCreditHeaderL.VALIDATE(WebIncrementID, WebCreditHeaderP."Order ID");
        SalesCreditHeaderL.VALIDATE("Sell-to Customer No.", Customer."No.");
        SalesCreditHeaderL."Your Reference" := WebCreditHeaderP."Customer Order No.";
        MappingL.GET(WebCreditHeaderP."Payment Method");
        SalesCreditHeaderL.VALIDATE("Payment Method Code", Mapping."Dynamics NAV Payment Method Co");
        // MITL.5593.SM.05022020 ++
        if CompanyName() = 'Walls and Floors' then
            SalesCreditHeaderL.Validate("Shortcut Dimension 1 Code", WebCreditHeaderP."Dimension Code");
        if CompanyName() = 'Tile Mountain' then
            SalesCreditHeaderL.Validate("Shortcut Dimension 2 Code", WebCreditHeaderP."Dimension Code");
        // MITL.5593.SM.05022020 --

        SalesCreditHeaderL.MODIFY(TRUE);

        IF WebCreditHeaderP."Shipping & Handling" <> 0 THEN BEGIN
            WEBSetup.TESTFIELD("Shipping and Handling Code");
            SalesCreditLineL.INIT;
            SalesCreditLineL.SetHideValidationDialog(TRUE);
            SalesCreditLineL."Document Type" := SalesCreditHeaderL."Document Type";
            SalesCreditLineL."Document No." := SalesCreditHeaderL."No.";
            SalesCreditLineL."Line No." := 10000;
            SalesCreditLineL.Type := SalesCreditLineL.Type::"G/L Account";
            SalesCreditLineL.INSERT(TRUE);
            SalesCreditLineL.VALIDATE("No.", WEBSetup."Shipping and Handling Code");
            SalesCreditLineL.VALIDATE(Quantity, 1);
            SalesCreditLineL.VALIDATE("Qty. to Ship", 0);
            SalesCreditLineL.VALIDATE("Unit Price", (WebCreditHeaderP."Shipping & Handling" + WebCreditHeaderP.VAT - TotalVATLines));
            // MITL.5593.SM.05022020 ++
            if CompanyName() = 'Walls and Floors' then
                SalesCreditLineL.Validate("Shortcut Dimension 1 Code", WebCreditHeaderP."Dimension Code");
            if CompanyName() = 'Tile Mountain' then
                SalesCreditLineL.Validate("Shortcut Dimension 2 Code", WebCreditHeaderP."Dimension Code");
            // MITL.5593.SM.05022020 --
            SalesCreditLineL.MODIFY(TRUE);
        end;

        IF WebCreditHeaderP."Adjustment Refund Amount" <> 0 THEN BEGIN
            WEBSetup.TESTFIELD("Credit Memo Discount Account");
            SalesCreditLineL.INIT;
            SalesCreditLineL.SetHideValidationDialog(TRUE);
            SalesCreditLineL."Document Type" := SalesCreditHeaderL."Document Type";
            SalesCreditLineL."Document No." := SalesCreditHeaderL."No.";
            SalesCreditLineL."Line No." := 2;
            SalesCreditLineL.Type := SalesCreditLineL.Type::"G/L Account";
            SalesCreditLineL.INSERT(TRUE);
            SalesCreditLineL.VALIDATE("No.", WEBSetup."Credit Memo Discount Account");
            SalesCreditLineL.VALIDATE(Quantity, 1);
            SalesCreditLineL.VALIDATE("Qty. to Ship", 0);
            SalesCreditLineL.VALIDATE("Unit Price", (WebCreditHeaderP."Adjustment Refund Amount" - WebCreditHeaderP."Adjustment Fee Amount"));
            // MITL.5593.SM.05022020 ++
            if CompanyName() = 'Walls and Floors' then
                SalesCreditLineL.Validate("Shortcut Dimension 1 Code", WebCreditHeaderP."Dimension Code");
            if CompanyName() = 'Tile Mountain' then
                SalesCreditLineL.Validate("Shortcut Dimension 2 Code", WebCreditHeaderP."Dimension Code");
            // MITL.5593.SM.05022020 --
            SalesCreditLineL.MODIFY(TRUE);
        end;
    End;
    //MITL4523 ** //MITL.AJ.19Dec2019 **

    //MITL5442 ++
    procedure CheckMultipleInvoiceAndShippingCharges(WebIndexP: Record "WEB Index")
    var
        WebCreditHeaderL: Record "WEB Credit Header";
        CustLedgerEntryL: Record "Cust. Ledger Entry";
        SalesCreditHeaderL: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
    begin
        WebCreditHeaderL.Reset();
        WebCreditHeaderL.SetRange("Index No.", Format(WebIndexP."Line no."));
        IF WebCreditHeaderL.FindFirst() THEN BEGIN
            IF WebCreditHeaderL."Order ID" <> '' then BEGIN
                CustLedgerEntryL.Reset();
                CustLedgerEntryL.SetCurrentKey(WebIncrementID); // MITL.AJ.20200603 Indexing correction
                CustLedgerEntryL.SetRange(WebIncrementID, WebCreditHeaderL."Order ID");
                CustLedgerEntryL.SetRange("Document Type", CustLedgerEntryL."Document Type"::Invoice);
                IF CustLedgerEntryL.FindSet() THEN BEGIN
                    IF (CustLedgerEntryL.Count() <> 0) THEN BEGIN
                        CreateCreditMemoshippedItems(WebIndexP, WebCreditHeaderL);
                        // IF (CustLedgerEntryL.Count() > 1) then // MITL.10-Feb-2020
                        // IF (CustLedgerEntryL.Count() > 1) and (WebCreditHeaderL."Shipping & Handling" <> 0) then // MITL.10-Feb-2020
                        //     CreateCreditMemoforShippingCharges(WebCreditHeaderL, WebIndexP)
                        // Else
                        //     CreateCreditMemoshippedItems(WebIndexP, WebCreditHeaderL);
                    END;
                END;
                CustLedgerEntryL.SetRange("Document Type", CustLedgerEntryL."Document Type"::Payment);
                // CustLedgerEntryL.SetRange(Open, true);//MITL/5442.SM.20200514
                IF CustLedgerEntryL.FindSet() THEN BEGIN
                    RefundPayment(WebIndexP);
                end;
            END;
        END;
    end;

    procedure CreateCreditMemoforShippingCharges(WEBCreditHeadP: Record "WEB Credit Header"; WebIndexLP: Record "WEB Index")
    var
        SalesCreditHeaderL: Record "Sales Header";
        SalesCreditLineL: Record "Sales Line";
        SalesCrMemoLineL: Record "Sales Line";  //MITL5442.AJ.03Mar2020
        WEBSetupL: Record "WEB Setup";
        MappingL: Record "WEB Mapping";
        CustomerL: Record Customer;
        SalesInvHeadL: Record "Sales Invoice Header";
        SalesInvLineL: Record "Sales Invoice Line";
        ShippingChargeAmtL: Decimal; //MITL5442.AJ.03Mar2020
        LineNoL: Integer;  //MITL5442.AJ.03Mar2020
        SalesHeaderL: Record "Sales Header"; //MITL.AJ.26Mar2020
                                             // IsWhseReqL: Boolean; //MITL2995
                                             // WebReturnPostL: Codeunit "WEB Handling Sales Return Post"; //MITL2995
    BEGIN
        // 5442.SM ++
        //CustomerL.Get(WEBCreditHeadP."Customer ID");
        WEBCheckCustomer(Customer);
        // 5442.SM --
        WEBSetupL.Get();
        ShippingChargeAmtL := WEBCreditHeadP."Shipping & Handling"; //MITL5442.AJ.03Mar2020
        IF WEBCreditHeadP."Shipping & Handling" <> 0 THEN BEGIN
            SalesInvHeadL.Reset();
            SalesInvHeadL.SetCurrentKey(WebIncrementID); // MITL.AJ.20200603 Indexing correction
            SalesInvHeadL.SetRange(WebIncrementID, WEBCreditHeadP."Order ID");
            // IF SalesInvHeadL.FindFirst() THEN //MITL5442.AJ.03Mar2020
            IF SalesInvHeadL.FindSet() THEN //MITL5442.AJ.03Mar2020
                Repeat
                    SalesInvLineL.Reset();
                    SalesInvLineL.SetCurrentKey("Document No.", Type, "No."); // MITL.AJ.20200603 Indexing correction
                    SalesInvLineL.SetRange("Document No.", SalesInvHeadL."No.");
                    SalesInvLineL.SetRange(Type, SalesInvLineL.Type::"G/L Account");
                    SalesInvLineL.SetRange("No.", WEBSetupL."Shipping and Handling Code");
                    IF SalesInvLineL.FindFirst() then BEGIN
                        SalesCreditHeaderL.INIT;
                        SalesCreditHeaderL.SetHideValidationDialog(TRUE);
                        SalesCreditHeaderL."No." := WEBCreditHeadP."Credit Memo ID";
                        // // MITL2995 ++
                        // IsWhseReqL := CheckWhseLoc(WebCreditHeader);
                        // if not IsWhseReqL then
                        //     SalesCreditHeaderL."Document Type" := SalesCreditHeaderL."Document Type"::"Credit Memo"
                        // else
                        //     SalesCreditHeaderL."Document Type" := SalesCreditHeaderL."Document Type"::"Return Order";  
                        // // MITL2995 --

                        SalesCreditHeaderL."Document Type" := SalesCreditHeaderL."Document Type"::"Credit Memo";
                        SalesCreditHeaderL.INSERT(TRUE);
                        SalesCreditHeaderL.VALIDATE("Order Date", WEBCreditHeadP."Credit Memo Date");
                        SalesCreditHeaderL.VALIDATE("Posting Date", WEBCreditHeadP."Credit Memo Date");
                        SalesCreditHeaderL.VALIDATE(WebIncrementID, WEBCreditHeadP."Order ID");
                        SalesCreditHeaderL.VALIDATE("Sell-to Customer No.", Customer."No.");
                        SalesCreditHeaderL."Your Reference" := WEBCreditHeadP."Customer Order No.";
                        MappingL.GET(WEBCreditHeadP."Payment Method");
                        SalesCreditHeaderL.VALIDATE("Payment Method Code", Mapping."Dynamics NAV Payment Method Co");
                        // MITL.5593.SM.05022020 ++
                        if CompanyName() = 'Walls and Floors' then
                            SalesCreditHeaderL.Validate("Shortcut Dimension 1 Code", WebCreditHeader."Dimension Code"); // SM_Business Channel
                        if CompanyName() = 'Tile Mountain' then
                            SalesCreditHeaderL.Validate("Shortcut Dimension 2 Code", WebCreditHeader."Dimension Code");
                        // MITL.5593.SM.05022020 --

                        SalesCreditHeaderL.MODIFY(TRUE);
                        //MITL5442.AJ.03Mar2020 ++ 
                        SalesCrMemoLineL.Reset();
                        SalesCrMemoLineL.SetRange("Document Type", SalesCreditHeaderL."Document Type");
                        SalesCrMemoLineL.SetRange("Document No.", SalesCreditHeaderL."No.");
                        IF SalesCrMemoLineL.FindLast() then
                            LineNoL := SalesCrMemoLineL."Line No." + 10000
                        ELSE
                            LineNoL := 10000;
                        //MITL5442.AJ.03Mar2020 **
                        // IF WEBCreditHeadP."Shipping & Handling" <> 0 THEN BEGIN //MITL5442.AJ.03Mar2020
                        IF (ShippingChargeAmtL - SalesInvLineL."Amount Including VAT") >= 0 Then BEGIN
                            WEBSetup.TESTFIELD("Shipping and Handling Code");
                            SalesCreditLineL.INIT;
                            SalesCreditLineL.SetHideValidationDialog(TRUE);
                            SalesCreditLineL."Document Type" := SalesCreditHeaderL."Document Type";
                            SalesCreditLineL."Document No." := SalesCreditHeaderL."No.";
                            // SalesCreditLineL."Line No." := 1;  //MITL5442.AJ.03Mar2020
                            SalesCreditLineL."Line No." := LineNoL; //MITL5442.AJ.03Mar2020
                            SalesCreditLineL.Type := SalesCreditLineL.Type::"G/L Account";
                            SalesCreditLineL.INSERT(TRUE);
                            SalesCreditLineL.VALIDATE("No.", WEBSetup."Shipping and Handling Code");
                            SalesCreditLineL.VALIDATE(Quantity, 1);
                            SalesCreditLineL.VALIDATE("Qty. to Ship", 0);
                            // SalesCreditLineL.VALIDATE("Unit Price", (WEBCreditHeadP."Shipping & Handling" + WEBCreditHeadP.VAT));  //MITL5442.AJ.03Mar2020
                            SalesCreditLineL.VALIDATE("Unit Price", SalesInvLineL."Amount Including VAT");  //MITL5442.AJ.03Mar2020
                            // MITL.5593.SM.05022020 ++
                            if CompanyName() = 'Walls and Floors' then
                                SalesCreditHeaderL.Validate("Shortcut Dimension 1 Code", WEBCreditHeadP."Dimension Code");
                            if CompanyName() = 'Tile Mountain' then
                                SalesCreditHeaderL.Validate("Shortcut Dimension 2 Code", WEBCreditHeadP."Dimension Code");
                            // MITL.5593.SM.05022020 --
                            SalesCreditLineL.MODIFY(TRUE);
                        end;
                        ShippingChargeAmtL := ShippingChargeAmtL - SalesInvLineL."Amount Including VAT"; //MITL5442.AJ.03Mar2020
                    END;
                Until SalesInvHeadL.Next() = 0;
        END;

        //MITL.AJ.26Mar2020 ++
        IF SalesHeaderL.GET(SalesHeaderL."Document Type"::Order, WEBCreditHeadP."Order ID") then BEGIN
            SalesHeaderL.Delete(true);
            RefundPayment(WebIndexLP);
        END;
        //MITL.AJ.26Mar2020 **
    End;

    // procedure GetWebCreditLinesLineAmt(SalesCrMemoHeaderP: Record "Sales Header"): Decimal
    // var
    //     SalesLineL: Record "Sales Line";
    //     WebcreditLinesL: Record "WEB Credit Lines";
    //     WebcreditHeadL: Record "WEB Credit Header";
    //     SalesCreditLinesL: Record "Sales Line";
    //     CustL: Record Customer;
    //     VATAmtL: Decimal;
    //     TotalAmountL: Decimal;
    //     QtyL: Integer;
    //     ItemL: Record Item; //MITL.AJ.23012020
    //     VatPostingSetupL: Record "VAT Posting Setup"; //MITL.AJ.23012020
    // begin
    //     TotalAmountL := 0;
    //     VATAmtL := 0;
    //     CustL.Get(SalesCrMemoHeaderP."Sell-to Customer No.");
    //     SalesCreditLinesL.Reset();
    //     SalesCreditLinesL.SetCurrentkey("Document Type", "Document No.", Type);  // MITL.AJ.20200603 Indexing correction
    //     SalesCreditLinesL.SetRange("Document Type", SalesCrMemoHeaderP."Document Type");
    //     SalesCreditLinesL.SetRange("Document No.", SalesCrMemoHeaderP."No.");
    //     SalesCreditLinesL.SetRange(Type, SalesCreditLinesL.Type::Item);
    //     If SalesCreditLinesL.FindSet() THEN
    //         repeat
    //             WebcreditLinesL.Reset();
    //             WebcreditLinesL.SetRange("Credit Memo ID", SalesCreditLinesL."Document No.");
    //             WebcreditLinesL.SetRange(Sku, SalesCreditLinesL."No.");
    //             IF WebcreditLinesL.FindFirst() then BEGIN
    //                 IF ItemL.Get(SalesCreditLinesL."No.") THEN; //MITL.AJ.23012020
    //                 IF VatPostingSetupL.GET(SalesCrMemoHeaderP."VAT Bus. Posting Group", ItemL."VAT Prod. Posting Group") THEN; //MITL.AJ.23012020
    //                 IF Evaluate(QtyL, WebcreditLinesL.QTY) THEN begin
    //                     if CustL."Prices Including VAT" then
    //                         VATAmtL := ((QtyL * WebcreditLinesL."Unit Price") * VatPostingSetupL."VAT %") / 100 //MITL.AJ.23012020                            
    //                     else
    //                         VATAmtL := 0;
    //                     TotalAmountL += (QtyL * WebcreditLinesL."Unit Price") + VATAmtL;
    //                 End;
    //             END;
    //         Until SalesCreditLinesL.Next() = 0;

    //     SalesCreditLinesL.Reset();
    //     SalesCreditLinesL.SetRange("Document Type", SalesCrMemoHeaderP."Document Type");
    //     SalesCreditLinesL.SetRange("Document No.", SalesCrMemoHeaderP."No.");
    //     SalesCreditLinesL.SetRange(Type, SalesCreditLinesL.Type::"G/L Account");
    //     If SalesCreditLinesL.FindFirst() THEN BEGIN
    //         WebcreditHeadL.Reset();
    //         WebcreditHeadL.SetRange("Credit Memo ID", SalesCreditLinesL."Document No.");
    //         WebcreditHeadL.SetFilter("Shipping & Handling", '<>%1', 0);
    //         IF WebcreditHeadL.FindFirst() then
    //             TotalAmountL += WebcreditHeadL."Shipping & Handling" + (WebcreditHeadL.VAT - VATAmtL);
    //     END;
    //     exit(TotalAmountL);
    // end;

    procedure DeleteOrderLines(WebCreditHeaderP: Record "WEB Credit Header") OrderLinesDeleted: Boolean
    var
        Qty: Decimal;
        ItemNo: Code[20];
        CrossRefNo: Code[20];
        SalesLine: Record "Sales Line";
        TotalCredited: Decimal;
        NewSalesLine: Record "Sales Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        ModifiedLines: Boolean;
        ShippingErrors: Text;
        WEBCreditLinesL: Record "WEB Credit Lines";
        SalesOrderHeaderL: Record "Sales Header";
        SalesOrderLineL: Record "Sales Line";
        SalesLineL: Record "Sales Line";
        WebOrderHeaderL: Record "WEB Order Header";
        NotshippedLineL: Boolean; //MITL5442.AJ.22012020
    begin

        TotalCredited := 0;
        OrderLinesDeleted := FALSE;
        SalesOrderHeaderL.RESET;
        SalesOrderHeaderL.SETRANGE("Document Type", SalesOrderHeaderL."Document Type"::Order);
        SalesOrderHeaderL.SETRANGE("No.", WebCreditHeaderP."Order ID");
        IF SalesOrderHeaderL.FINDSET THEN BEGIN
            SalesOrderLineL.RESET;
            SalesOrderLineL.SetCurrentKey("Document Type", "Document No.", "Quantity Shipped"); // MITL.AJ.20200603 Indexing correction
            SalesOrderLineL.SETRANGE("Document Type", SalesOrderHeaderL."Document Type"::Order);
            SalesOrderLineL.SETRANGE("Document No.", SalesOrderHeaderL."No.");
            SalesOrderLineL.SETFILTER("Quantity Shipped", '<>%1', 0);

            WebOrderHeaderL.SETRANGE("Order ID", WebCreditHeaderP."Order ID");
            WebOrderHeaderL.SETFILTER("LineType", '<>%1', WebOrderHeaderL."LineType"::Delete);
            IF NOT WebOrderHeaderL.FINDLAST THEN
                WebOrderHeaderL.INIT;

            IF SalesOrderLineL.ISEMPTY AND (WebCreditHeaderP."Grand Total" = WebOrderHeaderL."Grand Total") THEN BEGIN // if no lines shipped and totals agree then delete order
                SalesOrderHeaderL.UpdateRoxLog(STRSUBSTNO(SalesOrderDelTxt, SalesOrderHeaderL."No."), SalesOrderHeaderL.WebIncrementID, SalesOrderHeaderL."Web Shipment Increment Id");
                SalesOrderHeaderL.DELETE(TRUE);
                OrderLinesDeleted := TRUE;
            END ELSE BEGIN
                WEBCreditLinesL.RESET;
                WEBCreditLinesL.SETRANGE("Credit Memo ID", WebCreditHeaderP."Credit Memo ID");
                WEBCreditLinesL.SETRANGE("Date Time", WebCreditHeaderP."Date Time");
                WEBCreditLinesL.SETRANGE("LineType", WebCreditHeaderP."LineType");
                IF WEBCreditLinesL.FINDSET THEN
                    REPEAT
                        EVALUATE(Qty, WEBCreditLinesL.QTY);

                        SalesOrderLineL.SETRANGE(Type, SalesOrderLineL.Type::Item);
                        CrossRefNo := WebFunc.ReturnCrossReference(WEBCreditLinesL.Sku);
                        IF CrossRefNo = '' THEN
                            ItemNo := WEBCreditLinesL.Sku
                        ELSE
                            ItemNo := WebFunc.ReturnItemNo(WEBCreditLinesL.Sku);

                        SalesOrderLineL.SETRANGE("No.", ItemNo);
                        SalesOrderLineL.SETRANGE("Quantity Shipped", 0);
                        IF SalesOrderLineL.FINDFIRST THEN BEGIN

                            IF SalesOrderLineL.Quantity > Qty THEN BEGIN
                                TotalCredited := TotalCredited + SalesOrderLineL."Unit Price" * Qty;
                                WarehouseActivityLine.SETRANGE("Source No.", SalesOrderLineL."Document No.");
                                WarehouseActivityLine.SETRANGE("Source Line No.", SalesOrderLineL."Line No.");
                                IF WarehouseActivityLine.FINDSET THEN
                                    WarehouseActivityLine.DELETEALL(TRUE);
                                ModifiedLines := TRUE;
                                SalesOrderLineL.SuspendStatusCheck(true); //MITL.AJ.14012020 //MITL5442
                                SalesOrderLineL.VALIDATE(Quantity, SalesOrderLineL.Quantity - Qty);

                                SalesOrderLineL.MODIFY(TRUE);
                            END ELSE BEGIN
                                TotalCredited := TotalCredited + SalesOrderLineL."Unit Price" * SalesOrderLineL.Quantity;
                                SalesOrderHeaderL.UpdateRoxLog(STRSUBSTNO(SalesOrderLineDelTxt, SalesOrderHeaderL."No.", SalesOrderLineL."Line No."),
                                  SalesOrderHeaderL.WebIncrementID, SalesOrderHeaderL."Web Shipment Increment Id");
                                SalesOrderLineL.DELETE(TRUE);
                            END;

                            OrderLinesDeleted := TRUE;
                        END;
                    UNTIL WEBCreditLinesL.NEXT = 0;

                //delete order shipping lines
                WEBSetup.GET;
                SalesLineL.RESET;
                SalesLineL.SetCurrentKey("Document Type", "Document No.", "No.", "Unit Price", "Qty. Shipped (Base)"); // MITL.AJ.20200603 Indexing correction
                SalesLineL.SETRANGE(SalesLineL."Document Type", SalesLineL."Document Type"::Order);
                SalesLineL.SETRANGE(SalesLineL."Document No.", SalesOrderHeaderL."No.");
                SalesLineL.SETRANGE(SalesLineL."No.", WEBSetup."Shipping and Handling Code");
                SalesLineL.SETRANGE(SalesLineL."Unit Price", WebCreditHeaderP."Grand Total" - TotalCredited);
                SalesLineL.SETFILTER(SalesLineL."Qty. Shipped (Base)", '0');
                IF SalesLineL.FINDFIRST THEN
                    SalesLineL.DELETE(TRUE);
                //delete order shipping lines


                SalesOrderLineL.RESET;
                SalesOrderLineL.SETRANGE("Document Type", SalesOrderHeaderL."Document Type"::Order);
                SalesOrderLineL.SETRANGE("Document No.", SalesOrderHeaderL."No.");
                IF SalesOrderLineL.ISEMPTY THEN BEGIN
                    SalesOrderHeaderL.UpdateRoxLog(STRSUBSTNO(SalesOrderDelTxt, SalesOrderHeaderL."No."), SalesOrderHeaderL.WebIncrementID, SalesOrderHeaderL."Web Shipment Increment Id");
                    SalesOrderHeaderL.DELETE(TRUE);
                END;

                //MITL5442.AJ.22012020 ++
                IF Not UnshippedLinesFound(SalesOrderHeaderL."No.") then BEGIN
                    SalesOrderHeaderL.UpdateRoxLog(STRSUBSTNO(SalesOrderDelTxt, SalesOrderHeaderL."No."), SalesOrderHeaderL.WebIncrementID, SalesOrderHeaderL."Web Shipment Increment Id");
                    SalesOrderHeaderL.DELETE(TRUE);
                END;
                //MITL5442.AJ.22012020 **

            END;
        END;

        IF ModifiedLines THEN BEGIN
            WebFunc.SalesOrderReleaseManagement(SalesOrderHeaderL, ShippingErrors, FALSE);
        END;

        EXIT(OrderLinesDeleted);

    end;
    //MITL5442.AJ.22012020 ++
    local procedure UnshippedLinesFound(SalesOrderNoP: Code[20]): Boolean
    var
        SalesOrderLineL: Record "Sales Line";
        NotshippedLineL: Boolean;
    begin
        SalesOrderLineL.RESET;
        SalesOrderLineL.SETRANGE("Document Type", SalesOrderLineL."Document Type"::Order);
        SalesOrderLineL.SETRANGE("Document No.", SalesOrderNoP);
        IF SalesOrderLineL.FindSet() THEN
            repeat
                IF (SalesOrderLineL."Qty. Shipped Not Invd. (Base)" = 0) AND (SalesOrderLineL."Quantity Invoiced" = 0) THEN
                    NotshippedLineL := true;
            until (SalesOrderLineL.Next() = 0) or (NotshippedLineL);
        Exit(NotshippedLineL);
    end;
    //MITL5442.AJ.22012020 **
    //MITL5442 **   
    //MITL.5442.SM.20201405 New Function for UndoShipment
    procedure UndoShipment(WebIndexP: Record "WEB Index")
    var
        WebCreditLinesL: Record "WEB Credit Lines";
        SalesShipLinesL: Record "Sales Shipment Line";
        WebCreditHdrL: Record "WEB Credit Header";
        UndoShipmentCU: Codeunit "Undo Sales Shipment Line";
        SalesHdrL: Record "Sales Header";
    begin
        SalesShipHeader.RESET;
        SalesShipHeader.SETCURRENTKEY("Order No.");
        SalesShipHeader.SETRANGE("Order No.", WebCreditHeader."Order ID");
        IF SalesShipHeader.IsEmpty() THEN BEGIN
            SalesShipHeader.SETRANGE("Order No.");
            SalesShipHeader.SETRANGE(SalesShipHeader.WebIncrementID, WebCreditHeader."Order ID");
            IF not SalesShipHeader.IsEmpty() THEN BEGIN
                WebCreditLinesL.Reset();
                WebCreditLinesL.SetCurrentKey("Credit Memo ID", "Date Time");
                WebCreditLinesL.SetRange("Credit Memo ID", WebCreditHeader."Credit Memo ID");
                WebCreditLinesL.SetRange("Date Time", WebCreditHeader."Date Time");
                IF WebCreditLinesL.FindSet() THEN
                    repeat
                        SalesShipLinesL.Reset();
                        SalesShipLinesL.SetCurrentKey("Order No.", "No.", "Quantity Invoiced");
                        SalesShipLinesL.SetRange("Order No.", WebCreditHeader."Order ID");
                        SalesShipLinesL.SetRange("No.", WebCreditLinesL.Sku);
                        SalesShipLinesL.Setfilter("Quantity Invoiced", '=%1', 0);
                        IF SalesShipLinesL.FindFirst() then begin
                            Clear(UndoShipmentCU);
                            UndoShipmentCU.SetHideDialog(true);
                            UndoShipmentCU.Run(SalesShipLinesL);
                            // CODEUNIT.RUN(CODEUNIT::"Undo Sales Shipment Line", SalesShipLinesL);
                        end;
                    until (WebCreditLinesL.Next() = 0);
            END;
        END ELSE BEGIN
            SalesShipHeader.FindLast();
            WebCreditLinesL.Reset();
            WebCreditLinesL.SetCurrentKey("Credit Memo ID", "Date Time");
            WebCreditLinesL.SetRange("Credit Memo ID", WebCreditHeader."Credit Memo ID");
            WebCreditLinesL.SetRange(WebCreditLinesL."Date Time", WebCreditHeader."Date Time");
            IF WebCreditLinesL.FindSet() THEN
                repeat
                    SalesShipLinesL.Reset();
                    SalesShipLinesL.SetCurrentKey("Order No.", "No.", "Quantity Invoiced");
                    SalesShipLinesL.SetRange("Order No.", WebCreditHeader."Order ID");
                    SalesShipLinesL.SetRange(SalesShipLinesL."No.", WebCreditLinesL.Sku);
                    SalesShipLinesL.Setfilter("Quantity Invoiced", '=%1', 0);
                    IF SalesShipLinesL.FindFirst() then begin
                        Clear(UndoShipmentCU);
                        UndoShipmentCU.SetHideDialog(true);
                        UndoShipmentCU.Run(SalesShipLinesL);
                        // CODEUNIT.RUN(CODEUNIT::"Undo Sales Shipment Line", SalesShipLinesL);
                    end;
                until (WebCreditLinesL.Next() = 0);
            SalesHdrL.Reset();
            if SalesHdrL.get(SalesHdrL."Document Type"::Order, WebCreditHeader."Order ID") then
                SalesHdrL.Delete(true);

        end;
    end;
    //MITL_VS_20200601 ++
    local procedure PartialCrCancel() PartialCheckR: Boolean
    var
        WebCreditLinesL: Record "WEB Credit Lines";
        SalesOrder: Record "Sales Header";
        SalesOrderLine: Record "Sales Line";
        // PartialCheck: Boolean;
        QtyL: Decimal;
    begin
        PartialCheckR := false;
        If SalesOrder.Get(SalesOrder."Document Type"::Order, WebCreditHeader."Order ID") then begin
            WebCreditLinesL.Reset;
            WebCreditLinesL.SetCurrentKey("Credit Memo ID", "Date Time");
            WebCreditLinesL.SetRange("Credit Memo ID", WebCreditHeader."Credit Memo ID");
            WebCreditLinesL.SetRange("Date Time", WebCreditHeader."Date Time");
            IF WebCreditLinesL.FindSet() THEN
                repeat
                    SalesOrderLine.Reset;
                    SalesOrderLine.SetRange(SalesOrderLine."Document Type", SalesOrder."Document Type");
                    SalesOrderLine.SetRange("Document No.", SalesOrder."No.");
                    SalesOrderLine.SetRange("No.", WebCreditLinesL.Sku);
                    if SalesOrderLine.FindFirst() then
                        Evaluate(QtyL, WebCreditLinesL.QTY);
                    IF SalesOrderLine.Quantity <> QtyL then
                        PartialCheckR := true;
                Until (WebCreditLinesL.next = 0) or (PartialCheckR);
        End;
    end;
    //MITL_VS_20200707++
    local procedure CheckPartialShippedQty(WebCrLines: Record "WEB Credit Lines") PartialQtyR: Decimal
    var
        SalesShipmentHeaderL: Record "Sales Shipment Header";
        SalesShipmentLineL: Record "Sales Shipment Line";
        Qty: Decimal;
        SalesInvHdrL: Record "Sales Invoice Header";
    begin
        PartialQtyR := 0;
        PartialRefundAmtG := 0;
        SalesShipmentHeaderL.Reset();
        SalesShipmentHeaderL.SetRange("Order No.", WebCrLines."Order ID");
        if SalesShipmentHeaderL.FindSet() then begin
            SalesShipmentLineL.Reset();
            SalesShipmentLineL.SetRange("Document No.", SalesShipmentHeaderL."No.");
            SalesShipmentLineL.SetRange(Type, SalesShipmentLineL.Type::Item);
            SalesShipmentLineL.SetRange("No.", WebCrLines.Sku);
            if SalesShipmentLineL.FindFirst then begin
                Evaluate(Qty, WebCrLines.QTY);
                if Qty <> SalesShipmentLineL.Quantity then
                    PartialQtyR := SalesShipmentLineL.Quantity;
            end;
        end;
        if PartialQtyR <> 0 then begin
            SalesInvHdrL.Reset();
            SalesInvHdrL.SetRange(WebIncrementID, WebCrLines."Order ID");
            if SalesInvHdrL.FindFirst() then begin
                SalesInvHdrL.CalcFields("Amount Including VAT");
                PartialRefundAmtG := SalesInvHdrL."Amount Including VAT";
            end;
        end;
    end;
    //MITL_VS_20200707--
    //mitl.vs.20200708++
    procedure FullOrderCancelCheck(WebCrLines: Record "WEB Credit Lines")
    var
        SalesLineL: Record "Sales Line";//mitl.vs.20200708
        WebQtyL: Decimal;//mitl.vs.20200708
    begin
        FullCancelOrderG := false;
        SalesLineL.RESET;
        SalesLineL.SetCurrentKey("Document Type", "Document No.", Type, "No.");
        SalesLineL.SETRANGE("Document Type", SalesLineL."Document Type"::Order);
        SalesLineL.SETRANGE("Document No.", WebCrLines."Order ID");
        SalesLineL.SetRange(Type, SalesLineL.Type::Item);
        SalesLineL.SetRange("No.", WebCrLines.Sku);
        IF SalesLineL.FINDFIRST THEN begin
            Evaluate(WebQtyL, WebCrLines.QTY);
            if SalesLineL.Quantity = WebQtyL then
                FullCancelOrderG := true;
        end;
    end;
    //mitl.vs.20200708--   
    //mitl.vs.20200709++
    local procedure SOOutstandQtyMovement(WebCreditLine: Record "WEB Credit Lines"; PQty: Decimal)
    var
        SalesHeaderL: Record "Sales Header";
        SalesLineL: Record "Sales Line";
        PickedQty: Decimal;
        ShipQty: Decimal;
        MoveQty: Decimal;
        CreditQty: Decimal;
        WhseActLineL: Record "Registered Whse. Activity Line";
    begin
        SalesLineL.Reset();
        SalesLineL.SetRange("Document Type", SalesLineL."Document Type"::Order);
        SalesLineL.SetRange("Document No.", WebCreditLine."Order ID");
        SalesLineL.SetRange(Type, SalesLineL.Type::Item);
        SalesLineL.SetRange("No.", WebCreditLine.Sku);
        SalesLineL.SetFilter("Outstanding Quantity", '>%1', 0); // MITL.SM.20200714
        if SalesLineL.FindFirst() then; //begin
                                        //     /* 20200728++
                                        //     //MITL.SM.5442.20200727 ++
                                        //     if (PQty > 0) and (PQty < SalesLineL."Outstanding Quantity") then
                                        //         SalesLineL.CreateMovementLinesPartialQty(PQty)
                                        //     else
                                        //         //MITL.SM.5442.20200727 --
                                        //         SalesLineL.CreateMovementLinesPartialQty(SalesLineL."Outstanding Quantity");
                                        //     */ //20200728-- Code Commented 
                                        //     //Mitl.vs.20200728++
                                        //     WhseActLineL.Reset();
                                        //     WhseActLineL.SETRANGE("Source Document", WhseActLineL."Source Document"::"Sales Order");
                                        //     WhseActLineL.SETRANGE("Source No.", SalesLineL."Document No.");
                                        //     WhseActLineL.SETRANGE("Source Line No.", SalesLineL."Line No.");
                                        //     WhseActLineL.SETRANGE("Action Type", WhseActLineL."Action Type"::Take);
                                        //     IF WhseActLineL.FindFirst() THEN
                                        //         PickedQty := WhseActLineL.Quantity;

        //     Evaluate(CreditQty, WebCreditLine.QTY);

        //     if (CreditQty <= PickedQty) AND (SalesLineL."Quantity Shipped" <> 0) then
        //         MoveQty := PickedQty - SalesLineL."Quantity Shipped";

        //     if MoveQty > 0 then
        //         SalesLineL.CreateMovementLinesPartialQty(MoveQty);
        // end;
        // //Mitl.vs.20200728--
        // SM 20200729 Testing ++
        // if FullCancelOrderG then
        //     SalesLineL.CreateMovementLinesPartialQty(SalesLineL."Outstanding Quantity")
        // else
        // SM 20200729 Testing --
        CreateMovement(WebCreditLine);
    end;
    //mitl.vs.20200709--

    //MITL.VS.20200728>>
    local procedure CreateMovement(WebCrLinesP: Record "WEB Credit Lines")
    var
        SalesHeaderL: Record "Sales Header";
        SalesLineL: Record "Sales Line";
        RegisteredPickLineL: Record "Registered Whse. Activity Line";
        CreditQtyL: Decimal;
        PickedQtyL: Decimal;
        MoveQtyL: Decimal;
        DelQtyL: Decimal;
        ShipQtyL: Decimal;
    begin
        CreditQtyL := 0;
        PickedQtyL := 0;
        MoveQtyL := 0;
        DelQtyL := 0;
        ShipQtyL := 0;
        MovementCreated := false;
        Evaluate(CreditQtyL, WebCrLinesP.QTY);

        SalesLineL.Reset();
        SalesLineL.SetRange("Document Type", SalesLineL."Document Type"::Order);
        SalesLineL.SetRange("Document No.", WebCrLinesP."Order ID");
        SalesLineL.SetRange(Type, SalesLineL.Type::Item);
        SalesLineL.SetRange("No.", WebCrLinesP.Sku);
        if SalesLineL.FindFirst() then begin
            //Picked Qty check
            RegisteredPickLineL.Reset();
            RegisteredPickLineL.SETRANGE("Source Document", RegisteredPickLineL."Source Document"::"Sales Order");
            RegisteredPickLineL.SETRANGE("Source No.", SalesLineL."Document No.");
            RegisteredPickLineL.SETRANGE("Source Line No.", SalesLineL."Line No.");
            RegisteredPickLineL.SETRANGE("Action Type", RegisteredPickLineL."Action Type"::Take);
            IF RegisteredPickLineL.FindSet() THEN begin
                RegisteredPickLineL.CalcSums(Quantity);// MITL.SM.5442.20200730
                PickedQtyL := RegisteredPickLineL.Quantity;
            end;


            DelQtyL := SalesLineL.Quantity - PickedQtyL;
            if DelQtyL < CreditQtyL then begin
                if SalesLineL."Quantity Shipped" = 0 then
                    MoveQtyL := CreditQtyL - DelQtyL
                else begin
                    ShipQtyL := PickedQtyL - SalesLineL."Quantity Shipped";
                    if ShipQtyL > 0 then begin

                        // if CreditQtyL <= ShipQtyL then
                        //     MoveQtyL := CreditQtyL - DelQtyL
                        // else begin
                        CreditQtyL := CreditQtyL - DelQtyL;
                        if CreditQtyL <= ShipQtyL then
                            MoveQtyL := CreditQtyL
                        else
                            MoveQtyL := ShipQtyL
                        // end;
                    end
                    else
                        MoveQtyL := 0;
                end;
            end;
            //Movement Creation
            if MoveQtyL > 0 then begin
                SalesLineL.CreateMovementLinesPartialQty(MoveQtyL);
                MovementCreated := true;
            end;

        end;
    end;
    //MITL.VS.20200728<<
    local procedure CreateWorkSheetLines()
    var
        WhseWkshLineL: Record "Whse. Worksheet Line";
        GetWhseWkshLineL: Record "Whse. Worksheet Line";
        LocationRecL: Record Location;
        NextLineNo: Integer;
        SalesOrder: Record "Sales Header";
        SalesOrderLine: Record "Sales Line";
        WebCreditMemoLineL: Record "WEB Credit Lines";
    begin
        // WebCreditMemoLineL.Reset();
        // WebCreditMemoLineL.SetCurrentKey("Credit Memo ID","Date Time");
        // WebCreditMemoLineL.SetRange("Credit Memo ID", WebCreditHeader."Credit Memo ID");
        // WebCreditMemoLineL.SetRange("Date Time",WebCreditHeader."Date Time");
        // if WebCreditMemoLineL.FindSet then
        // repeat
        //     SalesOrder.Get(SalesOrder."Document Type"::Order, WebCreditHeader."Order ID");
        //     SalesOrderLine.Reset();
        //     SalesOrderLine.SetRange("Document Type", SalesOrder."Document Type");
        //     SalesOrderLine.SetRange("Document No.", SalesOrder."No.");
        //     SalesOrderLine.SetRange("No.",WEBCreditLines.Sku);
        //     if SalesOrderLine.FindFirst() then;
        // until WebCreditMemoLineL.Next() = 0;

        // GetWhseWkshLineL.RESET;
        // GetWhseWkshLineL.SETRANGE("Worksheet Template Name", LocationRecL."Auto Pick Template Name");
        // GetWhseWkshLineL.SETRANGE(Name, LocationRecL."Auto Pick Batch Name");
        // IF GetWhseWkshLineL.FINDLAST THEN
        //     NextLineNo := GetWhseWkshLineL."Line No." + 10000
        // ELSE
        //     NextLineNo := 10000;

        // WhseWkshLineL.INIT;
        // WhseWkshLineL."Worksheet Template Name" := LocationRecL."Auto Pick Template Name";
        // WhseWkshLineL.Name := LocationRecL."Auto Pick Batch Name";
        // WhseWkshLineL."Location Code" := StockAvailRecL."Location Code";
        // WhseWkshLineL."Line No." := NextLineNo;
        // WhseWkshLineL."From Bin Code" := StockAvailRecL."Bin Code";
        // WhseWkshLineL."From Zone Code" := StockAvailRecL."Zone Code";
        // WhseWkshLineL."From Unit of Measure Code" := StockAvailRecL."Unit of Measure Code";
        // WhseWkshLineL."Qty. per From Unit of Measure" := StockAvailRecL."Qty. per Unit of Measure";

        // WhseWkshLineL."To Bin Code" := BinRecL.Code;
        // WhseWkshLineL."To Zone Code" := BinRecL."Zone Code";
        // WhseWkshLineL."Unit of Measure Code" := SummaryBufferRecL."Unit of Measure Code";
        // WhseWkshLineL."Qty. per Unit of Measure" := SummaryBufferRecL."Qty. per Unit of Measure";
        // WhseWkshLineL."Item No." := StockAvailRecL."Item No.";
        // WhseWkshLineL.VALIDATE("Variant Code", StockAvailRecL."Variant Code");
        // WhseWkshLineL.VALIDATE(Quantity, ROUND(MovementQtyBase / StockAvailRecL."Qty. per Unit of Measure", 0.00001));

        // WhseWkshLineL."Qty. (Base)" := MovementQtyBase;
        // WhseWkshLineL."Qty. Outstanding (Base)" := MovementQtyBase;
        // WhseWkshLineL."Qty. to Handle (Base)" := MovementQtyBase;
        // WhseWkshLineL."Qty. Handled (Base)" := MovementQtyBase;

        // WhseWkshLineL."Whse. Document Type" := WhseWkshLineL."Whse. Document Type"::"Whse. Mov.-Worksheet";
        // WhseWkshLineL."Whse. Document No." := LocationRecL."Auto Pick Batch Name";
        // WhseWkshLineL."Whse. Document Line No." := WhseWkshLineL."Line No.";
        // WhseWkshLineL.INSERT;

        // NextLineNo := NextLineNo + 10000;


    end;
    //MITL_VS_20200601
    //MITL.SM.20200714 ++
    procedure UpdateQtyonSalesLine(SalesOrderLine_P: Record "Sales Line"; QtyP: Decimal)
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WhseShipLinesL: Record "Warehouse Shipment Line"; //MITL5442
    begin
        WarehouseActivityLine.SETRANGE("Source No.", SalesOrderLine_P."Document No.");
        WarehouseActivityLine.SETRANGE("Source Line No.", SalesOrderLine_P."Line No.");
        IF WarehouseActivityLine.FINDSET THEN
            WarehouseActivityLine.DELETEALL(TRUE);

        //MITL4552 ++  //MITL.AJ.14012020
        WhseShipLinesL.Reset();
        WhseShipLinesL.SetRange("Source Type", 37);
        WhseShipLinesL.SetRange(WhseShipLinesL."Source No.", SalesOrderLine_P."Document No.");
        WhseShipLinesL.SetRange(WhseShipLinesL."Item No.", SalesOrderLine_P."No.");
        // WhseShipLinesL.Setfilter(WhseShipLinesL."Qty. Shipped", '%1', 0); MITL.SM.5442.20200727
        IF WhseShipLinesL.FindFirst() then begin //MITL.AJ.21012020 //MITL5442
            WhseShipLinesL.SuspendStatusCheck(True); //MITL.AJ.21012020 //MITL5442
            WhseShipLinesL.Delete(True);
        END; //MITL.AJ.21012020 //MITL5442
             //MITL5442 ** //MITL.AJ.14012020
             // ModifiedLines := TRUE;
        SalesOrderLine_P.SuspendStatusCheck(True); //MITL.AJ.14012020 //MITL5442
        SalesOrderLine_P.VALIDATE(Quantity, SalesOrderLine_P.Quantity - QtyP);
        SalesOrderLine_P.MODIFY(TRUE);
    end;
    //MITL.SM.20200714 --
    //MITL.VS.20200714++
    local procedure CheckOnlyShipped() OnlyShipR: Boolean
    var
        SalesShipHeader: Record "Sales Shipment Header";
        SalesShipLinesL: Record "Sales Shipment Line";
        WebCreditLinesL: Record "WEB Credit Lines";
    begin
        OnlyShipR := false;
        SalesShipHeader.RESET;
        SalesShipHeader.SETRANGE(SalesShipHeader.WebIncrementID, WebCreditHeader."Order ID");
        if SalesShipHeader.FindFirst() then begin
            WebCreditLinesL.Reset();
            WebCreditLinesL.SetCurrentKey("Credit Memo ID", "Date Time");
            WebCreditLinesL.SetRange("Credit Memo ID", WebCreditHeader."Credit Memo ID");
            WebCreditLinesL.SetRange("Date Time", WebCreditHeader."Date Time");
            IF WebCreditLinesL.FindSet() THEN
                repeat
                    SalesShipLinesL.Reset();
                    SalesShipLinesL.SetCurrentKey("Order No.", "No.", "Quantity Invoiced");
                    SalesShipLinesL.SetRange("Order No.", WebCreditHeader."Order ID");
                    SalesShipLinesL.SetRange("No.", WebCreditLinesL.Sku);
                    SalesShipLinesL.SetRange("Quantity Invoiced", 0);
                    IF SalesShipLinesL.FindFirst() then
                        OnlyShipR := true;
                until (WebCreditLinesL.Next() = 0) or OnlyShipR;
        End;
    end;
    //MITL.VS.20200714--

    // MITL.SM.5442.20200717 ++
    procedure IsPickRegisteredPartially(SalesLineP: Record "Sales Line"): Boolean
    var
        RegisteredWhseActivityLineL: Record "Registered Whse. Activity Line";
    begin
        RegisteredWhseActivityLineL.RESET;
        RegisteredWhseActivityLineL.SETRANGE("Source Document", RegisteredWhseActivityLineL."Source Document"::"Sales Order");
        RegisteredWhseActivityLineL.SETRANGE("Source No.", SalesLineP."Document No.");
        RegisteredWhseActivityLineL.SETRANGE("Source Line No.", SalesLineP."Line No.");
        RegisteredWhseActivityLineL.SETRANGE("Action Type", RegisteredWhseActivityLineL."Action Type"::Take);
        //RegisteredWhseActivityLineL.SetRange(Quantity, SalesLineP.Quantity);
        IF RegisteredWhseActivityLineL.FindSet() THEN begin
            RegisteredWhseActivityLineL.CalcSums(Quantity);
            if RegisteredWhseActivityLineL.Quantity = SalesLineP.Quantity then
                exit(false)
            else
                exit(true);
        end;
        exit(false);
    end;
    // MITL.SM.5442.20200717 --

}