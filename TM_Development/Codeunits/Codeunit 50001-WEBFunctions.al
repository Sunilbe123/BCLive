codeunit 50001 "WEB Functions"
{
    // version R4476,R4501,R4523,R4561,R4564,R4622,LOC,CASE13605

    // R4476 - RM - 29.01.2016
    // Added function ReturnCrossReference, ReturnMagentoSKU, ReturnItemNo
    // 
    // R4501 - RM - 29.01.2016
    // Added function to detect duplicate transactions already completed and flag error
    // 
    // R4523 - RM - 08.02.2016
    // Modded CompletedDuplicateInsertExists
    // 
    // R4561 - RM - 10.02.2016
    // Added functions ReturnDefaultCustomer, UseDefaultCustomerForCredit, SetWebIndexOrigOrdFilter
    // 
    // R4564 - RM - 14.02.2016
    // If credit memo has already been placed at the same value as before (grand total) and the order is already fully credited then ignore the
    // second one. Do this for payment method Paypal only
    // 
    // R4580 - RM - 14.02.2016
    // Added TransactionCancelled Function for orders & credit memos
    // 
    // R4622 - RM - 24.02.2016
    // Added function AlertSyncDelays
    //MITL3321- Change in the connector code to use customer id instead of email.


    trigger OnRun()
    begin
        WW.SETFILTER(Status, '%1', WW.Status::Error);
        WW.SETFILTER(WW.Error, 'Order Not Found *');
        WW.MODIFYALL(WW.Status, WW.Status::" ");
    end;

    var
        WEBSetup: Record "WEB Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        WW: Record "WEB Index";
        InsertText: Label 'Insert';
        WebToolbox: Codeunit "WEB Toolbox";
        DuplicateText: Label 'Insert has already been completed';
        OrigWebOrderNotFound: Label 'The Original Web Order cant be found for index %1';
        CredtNotFoundTxt: Label 'WEB Credit Header not found for index %1';
        PayPalTxt: Label 'PAYPAL';

    procedure InsertIndex(TableNo: Integer; KF1: Text; KF2: Text; KF3: Text; KF4: Text; KF5: Text; OrderID: Code[20]): Code[20]
    var
        IndexTable: Record "WEB Index";
    begin
        IndexTable."Line no." := 0;
        IndexTable."Table No." := TableNo;
        IndexTable."Table Name" := GetTableName(TableNo);
        IndexTable."Key Field 1" := KF1;
        IndexTable."Key Field 2" := KF2;
        IndexTable."Key Field 3" := KF3;
        IndexTable."Key Field 4" := KF4;
        IndexTable."Key Field 5" := KF5;
        IndexTable."Order ID" := OrderID; //MITL.AJ.19Dec2019
        IndexTable."DateTime Inserted" := CURRENTDATETIME;
        IndexTable.INSERT(TRUE);
        EXIT(FORMAT(IndexTable."Line no."));
    end;

    procedure WEBCustomerUpdate(var WEBIndex: Record "WEB Index")
    var
        WEBCustomer: Record "WEB Customer";
        Customer: Record Customer;
        CustTemplate: Record "Customer Template";
    begin
        GetWEBSetup;
        WEBCustomer.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        WEBCustomer.FINDFIRST;
        CASE WEBCustomer."LineType" OF
            WEBCustomer."LineType"::Insert:
                BEGIN
                    WEBSetup.TESTFIELD(WEBSetup."WEB Customer Template");
                    // IF WEBCustomer."Customer ID" <> '0' THEN //MITL3321
                    IF WEBCustomer."Customer ID" <> '' THEN begin //MITL3321
                        Customer."No." := WEBCustomer."Customer ID";
                        Customer."Wholesale Customer" := WEBCustomer."Wholesale Customer";//MITL_MF_5480
                        //Customer."Invoice/Cr. Memo" := Customer."Invoice/Cr. Memo"::Email;//MITL_MF_5480
                    end
                    ELSE BEGIN
                        WEBSetup.TESTFIELD("WB Guest Customer Nos");
                        Customer."No." := NoSeriesMgt.GetNextNo(WEBSetup."WB Guest Customer Nos", TODAY, TRUE);
                    END;
                    CustTemplate.GET(WEBSetup."WEB Customer Template");
                    Customer."Wholesale Customer" := WEBCustomer."Wholesale Customer";//MITL_MF_5480
                    //Customer."Invoice/Cr. Memo" := Customer."Invoice/Cr. Memo"::Email; //MITL_MF_5480
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
                    Customer."Prices Including VAT" := CustTemplate."Prices Including VAT"; //MITL
                    Customer."Currency Code" := CustTemplate."Currency Code";
                    Customer."E-Mail" := UPPERCASE(WEBCustomer.Email);
                    Customer.INSERT(TRUE);
                    WEBIndex.Status := WEBIndex.Status::Complete;
                    WEBIndex.MODIFY;
                END;
        END;
    end;

    procedure GetWEBSetup()
    begin
        WEBSetup.GET;
    end;

    procedure WEBOrder(var WEBIndex: Record "WEB Index")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        WebOrderHeader: Record "WEB Order Header";
        WEBOrderLines: Record "WEB Order Lines";
    begin
        GetWEBSetup;
        WEBSetup.TESTFIELD("WEB Item Template");
        WebOrderHeader.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        WebOrderHeader.FINDFIRST;
        CASE WebOrderHeader."LineType" OF
            WebOrderHeader."LineType"::Insert:
                BEGIN
                    IF WEBCheckOrderLines(WebOrderHeader."Order ID", WebOrderHeader."Date Time") = '' THEN BEGIN
                        SalesHeader.INIT;
                        SalesHeader."No." := WebOrderHeader."Order ID";
                        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                        SalesHeader.VALIDATE("Order Date", WebOrderHeader."Order Date");
                        SalesHeader.VALIDATE("Posting Date", WebOrderHeader."Order Date");
                        SalesHeader.VALIDATE("Sell-to Customer No.", WebOrderHeader."Customer ID");
                        SalesHeader.CalcFields(Latest_Dispatch_Date);
                        SalesHeader.INSERT(TRUE);
                        WEBOrderLines.SETRANGE("Order ID");
                        WEBOrderLines.SETRANGE(WEBOrderLines."Date Time", WebOrderHeader."Date Time");
                        IF WEBOrderLines.FINDSET THEN
                            REPEAT
                                SalesLine."Document Type" := SalesHeader."Document Type";
                                SalesLine."Document No." := SalesHeader."No.";
                                SalesLine."Line No." := WEBOrderLines."Line No";
                                SalesLine.Type := SalesLine.Type::Item;
                                SalesLine.INSERT(TRUE);
                                SalesLine.VALIDATE("No.", WEBOrderLines.Sku);
                                EVALUATE(SalesLine.Quantity, WEBOrderLines.QTY);
                                SalesLine.VALIDATE(Quantity);
                                SalesLine.VALIDATE("Unit Price", WEBOrderLines."Unit Price");
                                SalesLine.VALIDATE("Line Discount Amount", WEBOrderLines."Discount Amount");
                                SalesLine.MODIFY(TRUE);
                            UNTIL WEBOrderLines.NEXT = 0;

                        WEBIndex.Status := WEBIndex.Status::Complete;
                        WEBIndex.MODIFY;
                    END ELSE BEGIN
                        WEBIndex.Status := WEBIndex.Status::Error;
                        WEBIndex.Error := WEBCheckOrderLines(WebOrderHeader."Order ID", WebOrderHeader."Date Time");
                        WEBIndex.MODIFY;
                    END;
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

    procedure WEBCheckOrderLines(OrderID: Code[20]; "Date Time": DateTime): Text
    var
        WEBOrderLines: Record "WEB Order Lines";
    begin
        WEBOrderLines.SETRANGE("Order ID", OrderID);
        WEBOrderLines.SETRANGE("Date Time", "Date Time");
        IF WEBOrderLines.ISEMPTY THEN
            EXIT('No Lines Exist');
        IF WEBOrderLines.FINDSET THEN
            REPEAT
                IF NOT WEBItemExists(WEBOrderLines.Sku) THEN
                    EXIT('Item does not exist');
            UNTIL WEBOrderLines.NEXT = 0;
    end;

    procedure ShowWebDocument(WebIndex: Record "WEB Index")
    var
        WebOrderHeader: Record "WEB Order Header";
        WebShipHeader: Record "WEB Shipment Header";
        WebCreditHeader: Record "WEB Credit Header";
        WebCustomer: Record "WEB Customer"; //MITL3321
        WebCustomerBillTo: Record "WEB Customer Bill-To"; //MITL3321
        WebCustomerShipTo: Record "WEB Customer Ship-To"; //MITL3321
        WebItem: Record "WEB Item"; //MITL3321
        WebItemAttribute: Record "WEB Item Attribute"; //MITL3321
    begin
        //RM 05.11.2015 >>
        CASE WebIndex."Table No." OF
            50010:
                BEGIN
                    WebOrderHeader.SETRANGE("Order ID", WebIndex."Key Field 1");
                    //MITL.6532.SM.20200522 ++                 
                    WebOrderHeader.SetRange("Index No.", format(WebIndex."Line no."));
                    //MITL.6532.SM.20200522 --
                    PAGE.RUNMODAL(PAGE::"WEB User  - Order Header", WebOrderHeader);
                END;
            50014:
                BEGIN
                    WebShipHeader.SETRANGE("Shipment ID", WebIndex."Key Field 1");
                    //MITL.6532.SM.20200522 ++                 
                    WebShipHeader.SetRange("Index No.", format(WebIndex."Line no."));
                    //MITL.6532.SM.20200522 --
                    PAGE.RUNMODAL(PAGE::"WEB Shipment Header", WebShipHeader);
                END;
            50018:
                BEGIN
                    WebCreditHeader.SETRANGE("Credit Memo ID", WebIndex."Key Field 1");
                    //MITL.6532.SM.20200522 ++                 
                    WebCreditHeader.SetRange("Index No.", format(WebIndex."Line no."));
                    //MITL.6532.SM.20200522 --
                    PAGE.RUNMODAL(PAGE::"WEB Credit Memo Header", WebCreditHeader);
                END;
            //MITL3321 ++
            50009:
                BEGIN
                    WebCustomer.SETRANGE("Customer ID", WebIndex."Key Field 1");
                    //MITL.6532.SM.20200522 ++                 
                    WebCustomer.SetRange("Index No.", format(WebIndex."Line no."));
                    //MITL.6532.SM.20200522 --
                    PAGE.RUNMODAL(PAGE::"WEB Customer", WebCustomer);
                END;
            50027:
                BEGIN
                    WebCustomerBillTo.SETRANGE("Customer ID", WebIndex."Key Field 1");
                    //MITL.6532.SM.20200522 ++                 
                    WebCustomerBillTo.SetRange("Index No.", format(WebIndex."Line no."));
                    //MITL.6532.SM.20200522 --
                    PAGE.RUNMODAL(PAGE::"WEB Order Bill-To", WebCustomerBillTo);
                END;
            50013:
                BEGIN
                    WebCustomerShipTo.SETRANGE("Customer ID", WebIndex."Key Field 1");
                    //MITL.6532.SM.20200522 ++                 
                    WebCustomerShipTo.SetRange("Index No.", format(WebIndex."Line no."));
                    //MITL.6532.SM.20200522 --
                    PAGE.RUNMODAL(PAGE::"WEB Order Ship-To", WebCustomerShipTo);
                END;
            50016:
                BEGIN
                    WebItem.SETRANGE(SKU, WebIndex."Key Field 1");
                    //MITL.6532.SM.20200522 ++                 
                    WebItem.SetRange("Index No.", format(WebIndex."Line no."));
                    //MITL.6532.SM.20200522 --
                    PAGE.RUNMODAL(PAGE::"WEB Item", WebItem);
                END;
            50017:
                BEGIN
                    WebItemAttribute.SETRANGE(SKU, WebIndex."Key Field 1");
                    //MITL.6532.SM.20200522 ++                 
                    WebItemAttribute.SetRange("Index No.", format(WebIndex."Line no."));
                    //MITL.6532.SM.20200522 --
                    PAGE.RUNMODAL(PAGE::"WEB Item Attribute", WebItemAttribute);
                END;
        //MITL3321 **
        END;
        //RM 05.11.2015 <<
    end;

    procedure ReturnCrossReference(CrossReferenceNo: Code[20]) CrossRefNo: Code[20]
    var
        ItemCrossReference: Record "Item Cross Reference";
        ItemCrossRefNo: Code[20]; // SM
    begin
        //R4476 >>
        ItemCrossRefNo := CopyStr(CrossReferenceNo + '-MAG', 1, 20); // SM
        ItemCrossReference.Reset();
        ItemCrossReference.SETCURRENTKEY("Cross-Reference No.");
        ItemCrossReference.SETRANGE("Cross-Reference No.", ItemCrossRefNo);// SM
        IF ItemCrossReference.FINDFIRST THEN
            CrossRefNo := ItemCrossReference."Cross-Reference No."
        ELSE
            CrossRefNo := '';

        EXIT(CrossRefNo);
        //R4476 <<
    end;

    procedure ReturnMagentoSKU(CrossRefNo: Code[20]) MagentoSKU: Code[20]
    var
        MAGpos: Integer;
    begin
        //R4476 >>
        IF CrossRefNo <> '' THEN BEGIN
            MAGpos := STRPOS(CrossRefNo, '-MAG');
            MagentoSKU := COPYSTR(CrossRefNo, 1, MAGpos - 1);
        END ELSE
            MagentoSKU := CrossRefNo;

        EXIT(MagentoSKU);
        //R4476 <<
    end;

    procedure ReturnItemNo(CrossReferenceNo: Code[20]) ItemNo: Code[20]
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        //R4476 >>
        ItemCrossReference.Reset();
        ItemCrossReference.SETCURRENTKEY("Cross-Reference No.");
        ItemCrossReference.SETRANGE("Cross-Reference No.", CrossReferenceNo + '-MAG');
        IF ItemCrossReference.FINDFIRST THEN
            ItemNo := ItemCrossReference."Item No."
        ELSE
            ItemNo := '';

        EXIT(ItemNo);
        //R4476 <<
    end;

    procedure FlagDuplicateTransactions(var WEBIndex: Record "WEB Index")
    var
        OptionStatus: Option " ",Complete,Error,Ignored,"Awaiting Information Request";
    begin
        //R4564 >>
        WITH WEBIndex DO BEGIN
            IF "Table No." IN [50009, 50013, 50027] THEN BEGIN
                IF "Key Field 4" <> InsertText THEN
                    EXIT;
            END ELSE
                IF WEBIndex."Table No." IN [50016, 50017] THEN BEGIN
                    IF "Key Field 3" <> InsertText THEN
                        EXIT;
                END ELSE
                    IF "Key Field 2" <> InsertText THEN
                        EXIT;
        END;
        //R4564 <<

        //R4501 >>
        IF CompletedDuplicateInsertExists(WEBIndex) THEN
            WebToolbox.UpdateIndex(WEBIndex, OptionStatus::Ignored, DuplicateText);
        //R4501 <<
    end;

    procedure CompletedDuplicateInsertExists(var WEBIndex: Record "WEB Index") CompletedDuplicateFound: Boolean
    var
        WEBIndex2: Record "WEB Index";
        WEBShipmentHeader: Record "WEB Shipment Header";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        WEBCreditHeader: Record "WEB Credit Header";
        WEBCreditHeader2: Record "WEB Credit Header";
        WEBOrderHeader: Record "WEB Order Header";
        OptionStatus: Option " ",Complete,Error,Ignored,"Awaiting Information Request";
    begin
        //R4501 >>
        WEBIndex2.Reset();
        WEBIndex2.SETCURRENTKEY("Table No.", "Key Field 1", "Key Field 2", "Key Field 3");
        WEBIndex2.SETRANGE("Table No.", WEBIndex."Table No.");
        WEBIndex2.SETRANGE("Key Field 1", WEBIndex."Key Field 1");

        IF WEBIndex."Table No." IN [50009, 50013, 50027] THEN
            WEBIndex2.SETRANGE("Key Field 4", InsertText)
        ELSE
            IF WEBIndex."Table No." IN [50016, 50017] THEN
                WEBIndex2.SETRANGE("Key Field 3", InsertText)
            ELSE
                WEBIndex2.SETRANGE("Key Field 2", InsertText);

        WEBIndex2.SETFILTER("Line no.", '<>%1', WEBIndex."Line no.");
        WEBIndex2.SETRANGE(Status, WEBIndex2.Status::Complete);
        CompletedDuplicateFound := NOT WEBIndex2.ISEMPTY;

        //R4523 >>
        IF (WEBIndex."Table No." = 50014) AND NOT CompletedDuplicateFound THEN BEGIN
            WEBShipmentHeader.Reset();
            WEBShipmentHeader.SETRANGE("Shipment ID", WEBIndex."Key Field 1");
            IF WEBShipmentHeader.FINDFIRST THEN
                IF NOT SalesHeader.GET(SalesHeader."Document Type"::Order, WEBShipmentHeader."Order ID") THEN BEGIN
                    SalesInvoiceHeader.SETCURRENTKEY(WebIncrementID);
                    SalesInvoiceHeader.SETRANGE(WebIncrementID, WEBShipmentHeader."Order ID");
                    CompletedDuplicateFound := NOT SalesInvoiceHeader.ISEMPTY;
                END;
        END;
        //R4523 <<

        //R4564 >>
        IF (WEBIndex."Table No." = 50018) THEN BEGIN
            WEBCreditHeader.Reset();
            WEBCreditHeader.SETCURRENTKEY("Index No.");
            WEBCreditHeader.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
            IF WEBCreditHeader.FINDFIRST AND (STRPOS(UPPERCASE(WEBCreditHeader."Payment Method"), PayPalTxt) <> 0) THEN BEGIN

                WEBOrderHeader.SETRANGE("Order ID", WEBCreditHeader."Order ID");
                IF WEBOrderHeader.FINDFIRST AND (WEBOrderHeader."Grand Total" = WEBCreditHeader."Grand Total") THEN BEGIN

                    WEBCreditHeader2.Reset();
                    WEBCreditHeader2.SETCURRENTKEY("Order ID");
                    WEBCreditHeader2.SETRANGE("Order ID", WEBCreditHeader."Order ID");
                    WEBCreditHeader2.SETFILTER("Credit Memo ID", '<>%1', WEBCreditHeader."Credit Memo ID");
                    IF WEBCreditHeader2.FINDFIRST THEN BEGIN
                        IF (WEBCreditHeader2."Grand Total" = WEBCreditHeader."Grand Total") THEN BEGIN
                            WEBIndex2.RESET;
                            WEBIndex2.SETFILTER("Line no.", WEBCreditHeader2."Index No.");
                            IF WEBIndex2.FINDSET AND (WEBIndex2.Status = WEBIndex2.Status::Complete) THEN
                                CompletedDuplicateFound := TRUE;
                        END;
                    END;
                END;
                //R4595 >>
            END;
            //END ELSE
            //WebToolbox.UpdateIndex(WEBIndex, OptionStatus::Error, STRSUBSTNO(CredtNotFoundTxt, WEBIndex."Line no."));
            //R4595 <<
        END;
        //R4564 <<

        EXIT(CompletedDuplicateFound);
        //R4501 <<
    end;

    procedure ReturnDefaultCustomer(): Code[20]
    begin
        //R4561 >>
        WEBSetup.GET;
        WEBSetup.TESTFIELD("Default Customer");
        EXIT(WEBSetup."Default Customer");
        //R4561 <<
    end;

    procedure UseDefaultCustomerForCredit(IndexNo: Code[20]): Boolean
    var
        WEBCreditHeader: Record "WEB Credit Header";
        WEBOrderHeader: Record "WEB Order Header";
        WEBIndex2: Record "WEB Index";
    begin
        //R4561 >>
        WEBCreditHeader.Reset();
        WEBCreditHeader.SETCURRENTKEY("Index No.");
        WEBCreditHeader.SETRANGE("Index No.", IndexNo);
        IF WEBCreditHeader.FINDFIRST THEN BEGIN
            SetWebIndexOrigOrdFilter(WEBIndex2, WEBCreditHeader."Order ID");

            IF WEBIndex2.FINDFIRST THEN BEGIN
                WEBOrderHeader.SETRANGE("Index No.", FORMAT(WEBIndex2."Line no."));
                IF WEBOrderHeader.FINDFIRST THEN BEGIN
                    EXIT((WEBOrderHeader."Customer ID" IN ['', 'GUEST']) AND (WEBOrderHeader."Customer Email" = ''));
                END ELSE
                    ERROR(OrigWebOrderNotFound, WEBIndex2."Line no.");
            END;
        END;

        EXIT(FALSE);
        //R4561 <<
    end;

    local procedure SetWebIndexOrigOrdFilter(var WEBIndex2: Record "WEB Index"; OrderID: Code[20]): Boolean
    begin
        //R4561 >>
        WEBIndex2.SETCURRENTKEY("Table No.", "Key Field 1", "Key Field 2", "Key Field 3");
        WEBIndex2.SETRANGE("Table No.", 50010);
        WEBIndex2.SETRANGE("Key Field 1", OrderID);
        WEBIndex2.SETRANGE(Status, WEBIndex2.Status::Complete);
        WEBIndex2.SETRANGE("Key Field 2", 'Insert');
        //R4561 <<
    end;

    procedure TransactionCancelled(OrderID: Code[20]; TableID: Integer): Boolean
    var
        WebIndex: Record "WEB Index";
    begin
        //R4580 >> - transaction must be credit, TableID = 50018 or order, TableID - 50010
        WebIndex.Reset();
        WebIndex.SETCURRENTKEY("Table No.", "Key Field 1", "Key Field 2", "Key Field 3");
        WebIndex.SETRANGE("Table No.", TableID);
        WebIndex.SETRANGE("Key Field 1", OrderID);
        WebIndex.SETRANGE("Key Field 2", 'Delete');

        EXIT(NOT WebIndex.ISEMPTY);
        //R4580 <<
    end;

    procedure AlertSyncDelays()
    var
        WEBIndex: Record "WEB Index";
        CurrDateTime: DateTime;
        NoHoursSinceOrder: Decimal;
        NoHoursSinceShipmentCredit: Decimal;
        NoHoursSinceTransactProcessed: Decimal;
        CurrTime: Time;
        CurrDate: Date;
        ErrorLine: array[3] of Text[250];
        SMTP: Codeunit "SMTP Mail";
        ICount: Integer;
        FromEmail: Text[250];
        UserSetup: Record "User Setup";
        CRLF: Text[10];
        EmailList: List of [Text];
    begin
        //R4622 >>
        //"No orders are received in the reception tables for 60 minutes (This should function 24/7)
        //"No shipments/credits are received in the reception tables for 60 minutes (This should function between 8am to 5pm Monday - Saturday)
        //"No transactions (orders/shipments/credits) have been processed in NAV for 60 minutes (This should function 24/7)
        CurrDateTime := CURRENTDATETIME;
        CurrTime := TIME;
        CurrDate := TODAY;

        WITH WEBIndex DO BEGIN
            SETCURRENTKEY("Table No.");
            SETRANGE("Table No.", 50010);
            IF FINDLAST THEN BEGIN
                NoHoursSinceOrder := (CurrDateTime - WEBIndex."DateTime Inserted") / 3600000;
            END;

            SETFILTER("Table No.", '50014|50018');
            IF FINDLAST THEN BEGIN
                NoHoursSinceShipmentCredit := (CurrDateTime - WEBIndex."DateTime Inserted") / 3600000;
            END;

            RESET;
            SETCURRENTKEY(Status);
            SETRANGE(Status, Status::Complete);
            SETFILTER("Table No.", '50010|50014|50018');
            IF FINDLAST THEN BEGIN
                NoHoursSinceTransactProcessed := (CurrDateTime - WEBIndex."DateTime Inserted") / 3600000;
            END;
        END;

        IF NoHoursSinceOrder >= 1 THEN
            ErrorLine[1] := 'Orders have not been received for 60 mins or longer';

        IF (NoHoursSinceShipmentCredit >= 1) AND (DATE2DWY(CurrDate, 1) IN [1, 2, 3, 4, 5]) AND ((CurrTime >= 080000T) AND (CurrTime <= 170000T)) THEN
            ErrorLine[2] := 'No shipments or credits have been received for 60 mins or longer';

        IF NoHoursSinceTransactProcessed >= 1 THEN
            ErrorLine[3] := 'No orders/shipments or credits have been processed in NAV for 60 mins or longer';

        IF (ErrorLine[1] <> '') OR (ErrorLine[2] <> '') OR (ErrorLine[3] <> '') THEN BEGIN
            CRLF[1] := 10;
            CRLF[2] := 13;

            WEBSetup.GET;
            WEBSetup.TESTFIELD("Alert Email From Address");

            SMTP.CreateMessage('SYNC ERROR', WEBSetup."Alert Email From Address", '', 'NAV Order Sync Error', '', FALSE);

            UserSetup.SETRANGE("Get Sync.Warning Email", TRUE);
            Clear(EmailList);
            IF UserSetup.FINDSET THEN
                REPEAT
                    UserSetup.TESTFIELD("Get Sync.Warning Email");
                    EmailList.Add(UserSetup."E-Mail");
                UNTIL UserSetup.NEXT = 0;
            SMTP.AddRecipients(EmailList);

            FOR ICount := 1 TO 3 DO BEGIN
                IF ErrorLine[ICount] <> '' THEN BEGIN
                    SMTP.AppendBody(' ');
                    SMTP.AppendBody(ErrorLine[ICount] + CRLF);
                END;
            END;
            SMTP.Send;
        END;
        //R4622 <<
    end;

    procedure WEBItemUpdates(SKU: Code[20]; ReasonForUpdate: Text)
    var
        WEBItemUpdates: Record "WEB Item Updates";
        WEBAvail: Record "WEB Available Stock";
        Item: Record Item;
    begin
        WEBItemUpdates.INIT;
        WEBItemUpdates.SKU := SKU;
        WEBItemUpdates."Reason for Update" := ReasonForUpdate;
        WEBItemUpdates.Completed := TRUE;
        WEBItemUpdates.INSERT;

        WEBAvail.INIT;
        WEBAvail.SKU := SKU;
        Item.GET(SKU);
        Item.CALCFIELDS(Item.Inventory, Item."Qty. on Sales Order");
        WEBAvail."Line No." := 0;
        WEBAvail."Available Quantity" := Item.Inventory - Item."Qty. on Sales Order";
        WEBAvail.INSERT;
    end;

    procedure SalesOrderReleaseManagement(var SalesHeader: Record "Sales Header"; var Errors: Text[50]; CombinedPick: Boolean)
    var
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
        CheckCreditLimit: Page "Check Credit Limit";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        SalesLine: Record "Sales Line";
        WhseShipmentRelease: Codeunit "Whse.-Shipment Release";
        WEBLog: Record "WEB Log";
        WebSetupRecL: Record "WEB Setup";
        ItemRecL: Record Item;
        ApprovalsMgmtL: Codeunit "Approvals Mgmt.";
        ApprovalEntryL: Record "Approval Entry";
        CustomerL: Record Customer;
        WebOrder: Record "WEB Order Header"; //MITL_W&F
        WebMapping: Record "WEB Mapping"; //MITL_W&F
        ReleaseSalesDocumentCU: CODEUNIT "Release Sales Document"; //MITL_W&F
        SalesHeader2: Record "Sales Header"; //MITL3832
    begin
        //MITL_W&F_Customer Credit Limit Check ++
        WebOrder.SetRange(WebOrder."Order ID", SalesHeader."No.");
        IF WebOrder.FindFirst() then
            WebMapping.Get(WebOrder."Payment Method");
        IF CustomerL.GET(SalesHeader."Sell-to Customer No.") THEN;
        IF (WebMapping."Online Payment" = true) THEN begin
            ReleaseSalesDocumentCU.SetSkipCheckReleaseRestrictions;
            ReleaseSalesDocumentCU.Run(SalesHeader);
        END ELSE begin
            IF ApprovalsMgmtL.IsSalesApprovalsWorkflowEnabled(SalesHeader) THEN begin
                IF ApprovalsMgmtL.CheckSalesApprovalPossible(SalesHeader) THEN
                    ApprovalsMgmtL.OnSendSalesDocForApproval(SalesHeader);
            END else begin
                ReleaseSalesDocumentCU.SetSkipCheckReleaseRestrictions;
                ReleaseSalesDocumentCU.Run(SalesHeader);
            End;
        END;
        //MITL_W&F_Customer Credit Limit Check --
        COMMIT;
        SELECTLATESTVERSION;

        WEBLog."Line No." := 0;
        WEBLog.Note := '1 Released';
        WEBLog."Order ID" := SalesHeader."No.";
        WEBLog.INSERT(TRUE);

        //MITL3832 ++
        Clear(SalesHeader2);
        SalesHeader2.Get(SalesHeader."Document Type", SalesHeader."No.");
        // GetSourceDocOutbound.CreateFromSalesOrderHideDialog(SalesHeader); //MITL1927
        //MITL1927 ++
        // IF SalesHeader.Status = SalesHeader.Status::Released THEN BEGIN //MITL3832 ++
        //     IF NOT GetSourceDocOutbound.CreateFromSalesOrderHideDialog(SalesHeader) then begin //MITL3832 ++
        IF SalesHeader2.Status = SalesHeader2.Status::Released THEN BEGIN //MITL3832 ++
            IF NOT GetSourceDocOutbound.CreateFromSalesOrderHideDialog(SalesHeader2) then begin  //MITL3832 ++
                WEBLog."Line No." := 0;
                WEBLog.Note := '11' + GETLASTERRORTEXT;
                // WEBLog."Order ID" := SalesHeader."No."; //MITL3832 ++
                WEBLog."Order ID" := SalesHeader2."No."; //MITL3832 ++
                WEBLog.INSERT(TRUE);
            END;
            COMMIT;
            SELECTLATESTVERSION;
        END; //MITL_W&F

        //MITLUpgrade ++
        WarehouseShipmentLine.Reset();
        WarehouseShipmentLine.SETRANGE(WarehouseShipmentLine."Source Document", WarehouseShipmentLine."Source Document"::"Sales Order");
        WarehouseShipmentLine.SETRANGE(WarehouseShipmentLine."Source No.", SalesHeader."No.");
        IF WarehouseShipmentLine.FindSet() THEN
            repeat
                WarehouseShipmentLine."Combined Pick" := CombinedPick;
                ItemRecL.RESET;
                IF ItemRecL.GET(WarehouseShipmentLine."Item No.") THEN
                    WarehouseShipmentLine."Product Type" := ItemRecL."Product Type";
                WarehouseShipmentLine."Shipment Date" := SalesHeader."Shipment Date";//MITL.6532.SM.20200527
                WarehouseShipmentLine.Modify();
            Until WarehouseShipmentLine.Next() = 0;

        If WarehouseShipmentLine.FindLast() then begin
            WarehouseShipmentHeader.GET(WarehouseShipmentLine."No.");
            WarehouseShipmentHeader.Status := WarehouseShipmentHeader.Status::Released;
            WarehouseShipmentHeader.MODIFY;
        End;
        //MITLUpgrade --

        // WEBLog."Line No." := 0;
        // WEBLog.Note := '10' + GETLASTERRORTEXT;
        // WEBLog."Order ID" := SalesHeader."No.";
        // WEBLog.INSERT(TRUE);

        // COMMIT;
        // SELECTLATESTVERSION;
        //MITL1927 **
        WarehouseShipmentLine.Reset();
        WarehouseShipmentLine.SETRANGE(WarehouseShipmentLine."Source Document", WarehouseShipmentLine."Source Document"::"Sales Order");
        WarehouseShipmentLine.SETRANGE(WarehouseShipmentLine."Source No.", SalesHeader."No.");
        IF WarehouseShipmentLine.FINDLAST THEN BEGIN
            WarehouseShipmentLine.SetHideValidationDialog(TRUE);
            WarehouseShipmentHeader.GET(WarehouseShipmentLine."No.");
            WEBLog."Line No." := 0;
            WEBLog.Note := '13' + GETLASTERRORTEXT;
            WEBLog."Order ID" := SalesHeader."No.";

            COMMIT;
            SELECTLATESTVERSION;

            WhseShipmentRelease.Release(WarehouseShipmentHeader);

            WEBLog."Line No." := 0;
            WEBLog.Note := '12' + GETLASTERRORTEXT;
            WEBLog."Order ID" := SalesHeader."No.";
            WEBLog.INSERT(TRUE);

            COMMIT;
            SELECTLATESTVERSION;

            // Commented because, picks will created from new batch MITL 13605
            //    IF NOT CombinedPick THEN
            //      WarehouseShipmentLine.CreatePickDoc(WarehouseShipmentLine,WarehouseShipmentHeader);

            // WEBLog."Line No." := 0;
            // WEBLog.Note := '11' + GETLASTERRORTEXT;
            // WEBLog."Order ID" := SalesHeader."No.";
            // WEBLog.INSERT(TRUE);

            // COMMIT;
            // SELECTLATESTVERSION;

        END;

        WEBLog."Line No." := 0;
        WEBLog.Note := '3' + GETLASTERRORTEXT;
        WEBLog."Order ID" := SalesHeader."No.";
        WEBLog.INSERT(TRUE);

        COMMIT;
        SELECTLATESTVERSION;

        WEBLog."Line No." := 0;
        WEBLog.Note := '4' + GETLASTERRORTEXT;
        WEBLog."Order ID" := SalesHeader."No.";
        WEBLog.INSERT(TRUE);


        COMMIT;
        SELECTLATESTVERSION;

    end;

    procedure CreateTransferOrderCredits()
    var
        HeaderCreated: Boolean;
        TransferLine: Record "Transfer Line";
        TransferHeader: Record "Transfer Header";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        Item: Record Item;
        i: Integer;
        ItemLedgerEntry: Record "Item Ledger Entry";
        WebSetupRecL: Record "WEB Setup";
    begin
        SalesReceivablesSetup.GET;
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SETFILTER("Entry No.", '369922..');
        ItemLedgerEntry.SETFILTER("Location Code", SalesReceivablesSetup."Returns Location");
        IF ItemLedgerEntry.FINDSET THEN
            REPEAT

                IF NOT TransferHeader.GET(ItemLedgerEntry."Document No.") THEN
                    HeaderCreated := FALSE
                ELSE
                    HeaderCreated := TRUE;
                IF NOT HeaderCreated THEN BEGIN
                    TransferHeader.INIT;
                    TransferHeader."No." := ItemLedgerEntry."Document No.";
                    TransferHeader.INSERT(TRUE);
                    TransferHeader.VALIDATE("Transfer-from Code", SalesReceivablesSetup."Returns Location");
                    // MITL ++
                    //    TransferHeader.VALIDATE("Transfer-to Code",'HANLEY2');
                    WebSetupRecL.GET;
                    WebSetupRecL.TESTFIELD("Web Location");
                    TransferHeader.VALIDATE("Transfer-to Code", WebSetupRecL."Web Location");
                    // MITL --
                    TransferHeader.VALIDATE("In-Transit Code", 'TRANSIT');
                    TransferHeader.MODIFY(TRUE);
                    HeaderCreated := TRUE;
                END;
                i := i + 1;
                TransferLine.INIT;
                TransferLine."Document No." := TransferHeader."No.";
                TransferLine."Line No." := i;
                TransferLine.INSERT(TRUE);
                TransferLine.VALIDATE("Item No.", ItemLedgerEntry."Item No.");
                TransferLine.VALIDATE(Quantity, ItemLedgerEntry.Quantity);
                TransferLine.MODIFY(TRUE);
            UNTIL ItemLedgerEntry.NEXT = 0;
    end;

    procedure GetTableName(TableNo: Integer): Text
    Begin
        case TableNo of
            50009:
                Exit('WEB Customer');
            50010:
                exit('WEB Order Header');
            50011:
                exit('WEB Order Lines');
            50013:
                exit('WEB Customer Ship-To');
            50014:
                exit('WEB Shipment Header');
            50015:
                exit('WEB Shipment Lines');
            50016:
                exit('WEB Item');
            50017:
                exit('WEB Item Attribute');
            50018:
                exit('WEB Credit Header');
            50019:
                exit('WEB Credit Lines');
            50027:
                exit('WEB Customer Bill-To');
            50021:
                exit('WEB Mapping');

        end;
    End;
}

