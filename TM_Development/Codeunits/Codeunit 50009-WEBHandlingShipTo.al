codeunit 50009 "WEB Handling ShipTo"
{
    // version RM 17082015

    // RM 17.08.2015
    // ModifyRecord and DeleteRecord removed. InsertRecord renamed as ModifyRecord

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
        WebRecord: Record "WEB Customer Ship-To";
        SalesOrder: Record "Sales Header";

    procedure ModifyRecord(var WEBIndex: Record "WEB Index")
    var
        Customer: Record Customer;
    begin
        GetWEBSetup; //RM 17.08.2015 line added

        WebRecord.SETRANGE("Index No.", FORMAT(WEBIndex."Line no."));
        IF WebRecord.FINDFIRST THEN BEGIN
            IF SalesOrder.GET(SalesOrder."Document Type"::Order, WebRecord."Order ID") THEN BEGIN
                SalesOrder."Ship-to Name 2" := COPYSTR(WebRecord."Ship-To Company", 1, 50);
                SalesOrder."Ship-to Name" := WebRecord."Ship-To First Name" + ' ' + WebRecord."Ship-To Last Name";
                SalesOrder."Ship-to Address" := COPYSTR(WebRecord."Ship-To Street 1", 1, 50);
                SalesOrder."Ship-to Address 2" := COPYSTR(WebRecord."Ship-To Street 2", 1, 50);
                SalesOrder."Ship-to City" := COPYSTR(WebRecord."Ship-To City", 1, 30);
                SalesOrder."Ship-to Post Code" := WebRecord."Ship-To Postcode";
                SalesOrder."Ship-to Country/Region Code" := WebRecord."Ship-To Country";
                SalesOrder.MODIFY;
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
            WebToolbox.UpdateIndex(WEBIndex, 2, 'Attempt to Delete Ship-to');
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
                //WebRecord."Type"::Insert : InsertRecord(WEBIndex);
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
}

