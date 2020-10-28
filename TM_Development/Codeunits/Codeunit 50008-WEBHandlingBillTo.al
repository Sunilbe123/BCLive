codeunit 50008 "WEB Handling BillTo"
{
    // version RM 17082015,R4310

    // RM 17.08.2015
    // ModifyRecord and DeleteRecord removed. InsertRecord renamed as ModifyRecord
    // 
    // R4310 - RM - 10.12.2015
    // Added function UpdateGLAndCLEDescriptions to update description fields in cust. ledger entry and G/L entry
    //MITL3321 - Change in the connector code to use Customer ID instead of email.

    Permissions = TableData 17 = rimd,
                  TableData 21 = rimd;
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
        WebRecord: Record "WEB Customer Bill-To";
        SalesOrder: Record "Sales Header";
        Customer: Record Customer;
        CustLedgEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";

    procedure ModifyRecord(var WEBIndex: Record "WEB Index")
    var
        Customer: Record Customer;
    begin
        GetWEBSetup; //RM 17.08.2015 line added

        WebRecord.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebRecord.FINDFIRST THEN BEGIN
            IF SalesOrder.GET(SalesOrder."Document Type"::Order, WebRecord."Order ID") THEN BEGIN
                SalesOrder."Bill-to Name 2" := COPYSTR(WebRecord."Bill-To Company", 1, 50);
                SalesOrder."Bill-to Name" := WebRecord."Bill-To First Name" + ' ' + WebRecord."Bill-To Last Name";
                SalesOrder."Bill-to Address" := COPYSTR(WebRecord."Bill-To Street 1", 1, 50);
                SalesOrder."Bill-to Address 2" := COPYSTR(WebRecord."Bill-To Street 2", 1, 50);
                SalesOrder."Bill-to City" := COPYSTR(WebRecord."Bill-To City", 1, 30);
                SalesOrder."Bill-to Post Code" := WebRecord."Bill-To Postcode";
                SalesOrder."Bill-to Country/Region Code" := WebRecord."Bill-To Country";

                //sell to
                SalesOrder."Sell-to Customer Name 2" := COPYSTR(WebRecord."Bill-To Company", 1, 50);
                SalesOrder."Sell-to Customer Name" := WebRecord."Bill-To First Name" + ' ' + WebRecord."Bill-To Last Name";
                SalesOrder."Sell-to Address" := COPYSTR(WebRecord."Bill-To Street 1", 1, 50);
                SalesOrder."Sell-to Address 2" := COPYSTR(WebRecord."Bill-To Street 2", 1, 50);
                SalesOrder."Sell-to City" := COPYSTR(WebRecord."Bill-To City", 1, 30);
                SalesOrder."Sell-to Post Code" := WebRecord."Bill-To Postcode";
                SalesOrder."Sell-to Country/Region Code" := WebRecord."Bill-To Country";

                SalesOrder.MODIFY;

                UpdateCustomerRecord(WEBIndex); //RM 14.10.2015
                UpdateGLAndCLEDescriptions(WEBIndex); //R4310

                WebToolbox.UpdateIndex(WEBIndex, 1, '');
            END ELSE
                WebToolbox.UpdateIndex(WEBIndex, 2, 'Order Not Found');

        END ELSE
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Record Not Found');
    end;

    procedure DeleteRecord(var WEBIndex: Record "WEB Index")
    begin
        //RM 19/08/2015 >>
        WebRecord.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebRecord.FINDFIRST THEN
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Attempt to Delete Bill-to');
        //RM 19/08/2015 <<
    end;

    procedure HandleRecord(var WEBIndex: Record "WEB Index")
    var
        WebOrder: Record "WEB Order Header";
    begin
        WebRecord.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebRecord.FINDFIRST THEN BEGIN
            GetWEBSetup;
            CASE WebRecord."LineType" OF
                //RM 19.08.2015 >>
                WebRecord."LineType"::Insert:
                    ModifyRecord(WEBIndex);
                //WebRecord."LineType"::Insert : InsertRecord(WEBIndex);
                //RM 19.08.2015 <<
                WebRecord."LineType"::Modify:
                    ModifyRecord(WEBIndex);
                WebRecord."LineType"::Delete:
                    DeleteRecord(WEBIndex);
            END;
        END;
    end;

    procedure GetWEBSetup()
    begin
        WEBSetup.GET;
    end;

    procedure UpdateCustomerRecord(var WEBIndex: Record "WEB Index")
    var
        CustFound: Boolean;
    begin
        //RM 14.10.2015 >>
        Customer.RESET;

        CustFound := FALSE;
        // IF WebRecord."Customer ID" <> '0' THEN BEGIN  //MITL3321
        // IF WebRecord."Customer ID" <> '' THEN BEGIN  //MITL3321
        //     Customer.SETCURRENTKEY("Customer ID");
        //     Customer.SETRANGE("Customer ID", WebRecord."Customer ID");  // MITL need to replace the customer id with No.
        //     CustFound := Customer.FINDFIRST;
        // END;
        //Below code need to be commented to stop address modification based on email id.
        // IF NOT CustFound THEN BEGIN
        //     Customer.SETRANGE("Customer ID");
        //     Customer.SETCURRENTKEY("E-Mail");
        //     Customer.SETRANGE("E-Mail", UPPERCASE(WebRecord."Customer Email"));
        //     CustFound := Customer.FINDFIRST;
        // END;

        //MITL3321 ++
        IF WebRecord."Customer ID" <> '' THEN BEGIN
            IF WebRecord."Customer ID" = 'GUEST' then begin
                Customer.SetCurrentKey("Customer ID");
                Customer.SETRANGE("Customer ID", WebRecord."Customer ID");
            END ELSE
                Customer.SETRANGE("No.", WebRecord."Customer ID");
            CustFound := Customer.FINDFIRST;
        END;
        //MITL3321 **

        IF CustFound THEN
            UpdateCustomerAddress
        ELSE
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Customer Not Found');
        //RM 14.10.2015 <<
    end;

    procedure UpdateCustomerAddress()
    begin
        //RM 14.10.2015 >>

        Customer.Name := COPYSTR(WebRecord."Bill-To First Name" + ' ' + WebRecord."Bill-To Last Name", 1, MAXSTRLEN(Customer.Name));
        Customer."Name 2" := COPYSTR(WebRecord."Bill-To Company", 1, MAXSTRLEN(Customer."Name 2"));
        Customer.Address := COPYSTR(WebRecord."Bill-To Street 1", 1, MAXSTRLEN(Customer.Address));
        Customer."Address 2" := COPYSTR(WebRecord."Bill-To Street 2", 1, MAXSTRLEN(Customer.Address));
        Customer.City := COPYSTR(WebRecord."Bill-To City", 1, MAXSTRLEN(Customer.City));
        Customer."Post Code" := COPYSTR(WebRecord."Bill-To Postcode", 1, MAXSTRLEN(Customer."Post Code"));
        Customer."Country/Region Code" := COPYSTR(WebRecord."Bill-To Country", 1, MAXSTRLEN(Customer."Country/Region Code"));
        Customer."Phone No." := COPYSTR(WebRecord."Bill-To Telephone", 1, MAXSTRLEN(Customer."Phone No."));

        Customer."Import Name" := COPYSTR(WebRecord."Bill-To First Name" + ' ' + WebRecord."Bill-To Last Name", 1, MAXSTRLEN(Customer."Import Name"));
        Customer."Import Address" := COPYSTR(WebRecord."Bill-To Street 1", 1, MAXSTRLEN(Customer."Import Address"));
        Customer."Import Address 2" := COPYSTR(WebRecord."Bill-To Street 2", 1, MAXSTRLEN(Customer."Import Address 2"));
        Customer."Import City" := COPYSTR(WebRecord."Bill-To City", 1, MAXSTRLEN(Customer."Import City"));
        Customer."Import Post Code" := COPYSTR(WebRecord."Bill-To Postcode", 1, MAXSTRLEN(Customer."Import Post Code"));
        Customer."Import Phone No." := COPYSTR(WebRecord."Bill-To Telephone", 1, MAXSTRLEN(Customer."Import Phone No."));

        Customer.MODIFY(TRUE);
        //RM 14.10.2015 <<
    end;

    procedure UpdateGLAndCLEDescriptions(var WEBIndex: Record "WEB Index")
    begin
        //R4310 >>
        Customer.RESET;
        WebRecord.SetCurrentKey("Index No."); // MITL.AJ.20200603 Indexing correction
        WebRecord.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebRecord.FINDFIRST THEN BEGIN
            CustLedgEntry.SETCURRENTKEY(WebIncrementID);
            CustLedgEntry.SETRANGE(WebIncrementID, WebRecord."Order ID");
            CustLedgEntry.SETFILTER("Document Type", '%1|%2', CustLedgEntry."Document Type"::Payment, CustLedgEntry."Document Type"::Refund);
            CustLedgEntry.SETFILTER(Description, '%1', '');
            IF CustLedgEntry.FINDFIRST THEN BEGIN
                IF Customer.GET(CustLedgEntry."Customer No.") THEN BEGIN
                    CustLedgEntry.Description := Customer.Name;
                    CustLedgEntry.MODIFY;

                    GLEntry.SETCURRENTKEY("Document No.", "Posting Date");
                    GLEntry.SETRANGE("Document No.", CustLedgEntry."Document No.");
                    GLEntry.SETRANGE(WebIncrementID, WebRecord."Order ID");
                    GLEntry.SETFILTER("Document Type", '%1|%2', GLEntry."Document Type"::Payment, GLEntry."Document Type"::Refund);
                    GLEntry.SETFILTER(Description, '%1', '');
                    IF GLEntry.FINDSET THEN
                        REPEAT
                            GLEntry.Description := Customer.Name;
                            GLEntry.MODIFY;
                        UNTIL GLEntry.NEXT = 0;
                END;
            END;
        END;
        //R4310 <<
    end;
}

