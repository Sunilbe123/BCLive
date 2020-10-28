codeunit 50025 Report_Schedular
{

    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        SendSalesInvoice();
        /*     SendSalesInvoice;
            Case Rec."Parameter String" of
                'A':
                    SendSalesInvoice();
                'B':
                    SendSalesCrMemo();
            end; */
    end;

    //MITL.SP.W&F
    local procedure SendSalesInvoice()
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        SalesInvH: Record "Sales Invoice Header";
        CustRec: Record Customer;
        CALCU50024: Codeunit CALEventSubscribers;
    begin
        SalesInvH.Reset();
        SalesInvH.SetRange("Posting Date", WorkDate());
        if SalesInvH.FindSet() then repeat
                                        CustRec.Reset();
                                        if CustRec.get(SalesInvH."Sell-to Customer No.") then begin
                                            if CustRec."Invoice/Cr. Memo" = CustRec."Invoice/Cr. Memo"::Email then
                                                //DocumentSendingProfile.SendCustomerRecords(DummyReportSelections.Usage::"S.Invoice", SalesInvH, 'Sales - Invoice', SalesInvH."Bill-to Customer No.", SalesInvH."No.", SalesInvH.FIELDNO("Bill-to Customer No."), SalesInvH.FIELDNO("No."));
                                                CALCU50024.SendDocument(DummyReportSelections.Usage::"S.Invoice", SalesInvH, SalesInvH."No.", SalesInvH."Sell-to Customer No.", 'Sales - Invoice', SalesInvH.FieldNo(SalesInvH."Sell-to Customer No."), SalesInvH.FieldNo(SalesInvH."No."));
                                            if CustRec."Invoice/Cr. Memo" = CustRec."Invoice/Cr. Memo"::Print then
                                                DummyReportSelections.PrintWithGUIYesNo(DummyReportSelections.Usage::"S.Invoice", SalesInvH, false, SalesInvH.FieldNo(SalesInvH."Sell-to Customer No."));
                                        end;
            until SalesInvH.Next() = 0;
    end;

    local procedure SendSalesCrMemo()
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        SalesCrMemoH: Record "Sales Cr.Memo Header";
        CustRec: Record Customer;
        CALCU50024: Codeunit CALEventSubscribers;
    begin
        SalesCrMemoH.Reset();
        SalesCrMemoH.SetRange("Posting Date", WorkDate());
        if SalesCrMemoH.FindSet() then repeat
                                           CustRec.Reset();
                                           if CustRec.get(SalesCrMemoH."Sell-to Customer No.") then begin
                                               if CustRec."Invoice/Cr. Memo" = CustRec."Invoice/Cr. Memo"::Email then
                                                   //DocumentSendingProfile.SendCustomerRecords(DummyReportSelections.Usage::"S.Cr.Memo", SalesCrMemoH, 'Sales - Credit Memo', SalesCrMemoH."Bill-to Customer No.", SalesCrMemoH."No.", SalesCrMemoH.FIELDNO("Bill-to Customer No."), SalesCrMemoH.FIELDNO("No."));
                                                   CALCU50024.SendDocument(DummyReportSelections.Usage::"S.Cr.Memo", SalesCrMemoH, SalesCrMemoH."No.", SalesCrMemoH."Sell-to Customer No.", 'Sales - Credit Memo', SalesCrMemoH.FieldNo(SalesCrMemoH."Sell-to Customer No."), SalesCrMemoH.FieldNo(SalesCrMemoH."No."));
                                               if CustRec."Invoice/Cr. Memo" = CustRec."Invoice/Cr. Memo"::Print then
                                                   DummyReportSelections.PrintWithGUIYesNo(DummyReportSelections.Usage::"S.Cr.Memo", SalesCrMemoH, false, SalesCrMemoH.FieldNo(SalesCrMemoH."Sell-to Customer No."));
                                           end;
            until SalesCrMemoH.Next() = 0;
    end;

    local procedure SendCustomerStatement()
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        CustRec: Record Customer;
    begin
        CustRec.Reset();
        CustRec.SetFilter(Balance, '>%1', 0);
        if CustRec.FindSet() then repeat
                                      //if CustRec."Invoice/Cr. Memo" = CustRec."Invoice/Cr. Memo"::Email then
                                      //DocumentSendingProfile.SendCustomerRecords(DummyReportSelections.Usage::"C.Statement", CustRec, 'Customer Statement', CustRec."No.", '', CustRec.FieldNo("No."), SalesCrMemoH.FIELDNO("No."));
                                      if CustRec."Invoice/Cr. Memo" = CustRec."Invoice/Cr. Memo"::Print then
                                          DummyReportSelections.PrintWithGUIYesNo(DummyReportSelections.Usage::"C.Statement", CustRec, false, CustRec.FieldNo("No."));

            until CustRec.Next() = 0;
    end;


}

