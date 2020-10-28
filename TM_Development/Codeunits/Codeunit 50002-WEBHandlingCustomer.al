codeunit 50002 "WEB Handling Customer"
{
    // version RM 17082015,R4359,230

    // RM 17.08.2015
    // Changes marked RM
    // 
    // R4359 - RM - 18.12.2015
    // Added functions ClearWebIndexErrorsForCustomer, ResetWebIndexError
    // MITL-SP  Case_230  06/08/18  Code Added
    //MITL3321 - Change the logic of insert customer function to use Customer ID as primary reference instead of email for customer creation.

    TableNo = "WEB Index";

    trigger OnRun()
    begin
        //RM 18.09.2015 >>
        HandleCustomer(Rec);
        //RM 18.09.2015 <<
    end;

    var
        WEBSetup: Record "WEB Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        WebToolbox: Codeunit "WEB Toolbox";

    procedure GetWEBSetup()
    begin
        WEBSetup.GET;
    end;

    procedure InsertCustomer(var WEBIndex: Record "WEB Index")
    var
        WebCustomer: Record "WEB Customer";
        Customer: Record Customer;
        CustTemplate: Record "Customer Template";
        CanContinue: Boolean;
    begin
        //MITL3321 ++
        CanContinue := TRUE;

        WebCustomer.Reset();
        WebCustomer.SetCurrentKey("Index No."); //MITL3321
        WebCustomer.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebCustomer.FINDFIRST THEN BEGIN
            // Customer.SETRANGE("E-Mail", UPPERCASE(WebCustomer.Email));
            IF WebCustomer."Customer ID" <> '' THEN BEGIN
                IF WebCustomer."Customer ID" = 'GUEST' THEN BEGIN
                    Customer.SETRANGE("Customer ID", WebCustomer."Customer ID");
                    IF Customer.FINDFIRST THEN BEGIN
                        IF (WEBIndex.Status <> WEBIndex.Status::Error) THEN BEGIN
                            Customer."Customer ID" := WebCustomer."Customer ID";
                            Customer."Wholesale Customer" := WebCustomer."Wholesale Customer";//MITL.MF.5480
                            //Customer."Invoice/Cr. Memo" := Customer."Invoice/Cr. Memo"::Email;//MITL.MF.5480
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
                            Customer."Prices Including VAT" := CustTemplate."Prices Including VAT"; //MITL704 - added as per customer request
                            Customer."Currency Code" := CustTemplate."Currency Code";
                            Customer."E-Mail" := UPPERCASE(WebCustomer.Email);
                            Customer.MODIFY(true);

                            WebToolbox.UpdateIndex(WEBIndex, 1, 'Modified Existing');
                        END;
                    END;
                END ELSE
                    IF (WebCustomer."Customer ID" <> 'GUEST') THEN BEGIN
                        Customer.SETRANGE("Customer ID", WebCustomer."Customer ID");
                        IF NOT Customer.FINDFIRST THEN BEGIN
                            IF (WEBIndex.Status <> WEBIndex.Status::Error) AND (CanContinue) THEN BEGIN
                                WEBSetup.TESTFIELD(WEBSetup."WEB Customer Template");
                                Customer.Init();
                                Customer."No." := WebCustomer."Customer ID";
                                Customer."Customer ID" := WebCustomer."Customer ID";
                                //MITL6040.AJ.20APR2020 ++
                                Customer."Wholesale Customer" := WebCustomer."Wholesale Customer";
                                IF WebCustomer."Wholesale Customer" THEN BEGIN  
                                    Customer."Invoice/Cr. Memo" := Customer."Invoice/Cr. Memo"::Email;
                                    Customer."Statement/Reminder" := Customer."Statement/Reminder"::Email; 
                                END; 
                                //MITL6040.AJ.20APR2020 --
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
                                Customer."Prices Including VAT" := CustTemplate."Prices Including VAT"; //MITL704 - added as per customer request
                                Customer."Currency Code" := CustTemplate."Currency Code";
                                Customer."E-Mail" := UPPERCASE(WebCustomer.Email);
                                Customer.INSERT(TRUE);
                            END;
                        END ELSE
                            WebToolbox.UpdateIndex(WEBIndex, 2, 'Customer Already Exists');
                    END;
                //R4359 >>
                ClearWebIndexErrorsForCustomer(WebCustomer);
                //R4359 <<
                WebToolbox.UpdateIndex(WEBIndex, 1, '');
            END ELSE
                WebToolbox.UpdateIndex(WEBIndex, 2, 'Record not found to update');
        END;
        //MITL3321 **
    end;

    procedure ModifyCustomer(var WEBIndex: Record "WEB Index")
    var
        WebCustomer: Record "WEB Customer";
        CustomerFound: Boolean;
        Customer: Record Customer;
        CustTemplate: Record "Customer Template";
    begin
        WebCustomer.Reset();
        WebCustomer.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebCustomer.FINDFIRST THEN BEGIN
            //RM 17.08.2015 >>
            Customer.Reset();
            Customer.SETRANGE("No.", WebCustomer."Customer ID"); //MITL3321 - changed the filter to look for customer "No." instead "Customer ID"
            CustomerFound := Customer.FINDFIRST;
            //RM 17.08.2015 <<
            IF NOT CustomerFound THEN BEGIN
                Customer.SETRANGE("E-Mail", UPPERCASE(WebCustomer.Email));
                IF Customer.FINDFIRST THEN
                    CustomerFound := TRUE;
            END;

            IF CustomerFound THEN BEGIN
                Customer."E-Mail" := UPPERCASE(WebCustomer.Email); //MITL3321
                Customer."Customer ID" := WebCustomer."Customer ID"; //MITL3321
                Customer."Wholesale Customer" := WebCustomer."Wholesale Customer"; //MITL.MF.5480
                                                                                   // Customer."Invoice/Cr. Memo" := Customer."Invoice/Cr. Memo"::Email; //MITL.MF.5480
                IF CustTemplate.GET(WEBSetup."WEB Customer Template") then
                    Customer.Validate("Prices Including VAT", CustTemplate."Prices Including VAT");
                Customer.MODIFY(TRUE);

                WebToolbox.UpdateIndex(WEBIndex, 1, '');
            END ELSE BEGIN
                WebToolbox.UpdateIndex(WEBIndex, 2, 'Customer not found');
            END;
        END ELSE
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Record not found to update');
        //RM 17.08.2015 <<
    end;

    procedure DeleteCustomer(var WEBIndex: Record "WEB Index")
    var
        WebCustomer: Record "WEB Customer";
    begin
        WebCustomer.Reset();
        WebCustomer.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebCustomer.FINDFIRST THEN BEGIN
            //RM 17.08.2015 >>
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Attempt to Delete customer');
        END ELSE
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Record not found to delete');
        //RM 17.08.2015 <<
    end;

    procedure HandleCustomer(var WEBIndex: Record "WEB Index")
    var
        WebCustomer: Record "WEB Customer";
    begin
        WebCustomer.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebCustomer.FINDFIRST THEN BEGIN
            GetWEBSetup;
            CASE WebCustomer."LineType" OF
                WebCustomer."LineType"::Insert:
                    InsertCustomer(WEBIndex);
                WebCustomer."LineType"::Modify:
                    ModifyCustomer(WEBIndex);
                WebCustomer."LineType"::Delete:
                    DeleteCustomer(WEBIndex);
            END;
        END;
    end;

    procedure ClearWebIndexErrorsForCustomer(WebCustomer: Record "WEB Customer")
    var
        WebOrder: Record "WEB Order Header";
        WebCustShipTo: Record "WEB Customer Ship-To";
        WebCustBillTo: Record "WEB Customer Bill-To";
        WebShip: Record "WEB Shipment Header";
    begin
        //R4359 >>
        WebOrder.Reset();
        WebOrder.SETCURRENTKEY("Customer Email");
        WebOrder.SETRANGE("Customer Email", WebCustomer.Email);
        IF WebOrder.FINDSET THEN
            REPEAT
                ResetWebIndexError(WebOrder."Index No.");
            UNTIL WebOrder.NEXT = 0;

        WebCustBillTo.Reset();
        WebCustBillTo.SETCURRENTKEY("Customer Email");
        WebCustBillTo.SETRANGE("Customer Email", WebCustomer.Email);
        IF WebCustBillTo.FINDSET THEN
            REPEAT
                ResetWebIndexError(WebCustBillTo."Index No.");
            UNTIL WebCustBillTo.NEXT = 0;

        WebCustShipTo.Reset();
        WebCustShipTo.SETCURRENTKEY("Customer Email");
        WebCustShipTo.SETRANGE("Customer Email", WebCustomer.Email);
        IF WebCustShipTo.FINDSET THEN
            REPEAT
                ResetWebIndexError(WebCustShipTo."Index No.");
            UNTIL WebCustShipTo.NEXT = 0;

        WebShip.Reset();
        WebShip.SETCURRENTKEY("Customer Email");
        WebShip.SETRANGE("Customer Email", WebCustomer.Email);
        IF WebShip.FINDSET THEN
            REPEAT
                ResetWebIndexError(WebShip."Index No.");
            UNTIL WebShip.NEXT = 0;
        //R4359 <<
    end;

    procedure ResetWebIndexError(IndexNo: Code[20])
    var
        LineNo: Integer;
        WebIndex: Record "WEB Index";
    begin
        //R4359 >>
        EVALUATE(LineNo, IndexNo);
        WebIndex.GET(LineNo);
        //MITL-SP-Case_230-060818-START
        IF (WebIndex.Status = WebIndex.Status::Error) AND (WebIndex."Table No." <> 50010) THEN
            WebToolbox.UpdateIndex(WebIndex, WebIndex.Status::" ", '')
        ELSE
            IF (WebIndex.Status = WebIndex.Status::Error) AND (WebIndex."Order Created" = FALSE) THEN
                WebToolbox.UpdateIndex(WebIndex, WebIndex.Status::" ", '');
        //MITL-SP-Case_230-060818-END;
        //R4359 <<
    end;
}

