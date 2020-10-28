//MITL_VS_PDF_20200612++
report 50027 "SalesInvCreditPDFGenerate"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    CaptionML = ENG = 'Sales Invoice & Cr.Note PDF Creator',
                ENU = 'Sales Invoice & Cr.Note PDF Creator';
    Permissions = tabledata 112 = rim, tabledata 114 = rim;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = where(Number = const(1));

            trigger OnAfterGetRecord()
            var
                CustomerL: Record Customer;
                SalesInvoiceHdrL: Record "Sales Invoice Header";
            begin
                SalesInvHeader.Reset();
                // SalesInvHeader.SetFilter("No.", '%1..%2', 'SINV1065917', 'SINV1065943');
                SalesInvHeader.SetRange("PDF Created", false);
                if PostingDtFilter <> 0D then
                    SalesInvHeader.SetRange("Posting Date", PostingDtFilter, WorkDate)
                else
                    SalesInvHeader.SetRange("Posting Date", WorkDate);

                if SalesInvHeader.FindSet then
                    repeat
                        CustomerL.Get(SalesInvHeader."Bill-to Customer No.");
                        // if CustomerL."Invoice/Cr. Memo" <> CustomerL."Invoice/Cr. Memo"::" " then begin
                        Clear(SalesInvoiceHdrL);
                        SalesInvoiceHdrL := SalesInvHeader;
                        if InvoiceFilePath <> '' then
                            FileName1 := '' + InvoiceFilePath + '' + SalesInvHeader."No." + '.pdf';

                        Clear(SalesInvoiceReport);
                        SalesInvoiceReport.UseRequestPage(false);
                        SalesInvoiceReport.InitializeRequest(true, false, SalesInvHeader."No.");
                        SalesInvoiceReport.SetTableView(SalesInvHeader);
                        TempBlob.CreateOutStream(OutputStream);
                        //SalesInvoiceReport.SaveAsPdf(FileName1);
                        SalesInvoiceReport.SaveAs(FileName1, ReportFormat::Pdf, OutputStream);

                        if SalesInvoiceHdrL.Get(SalesInvHeader."No.") then begin
                            SalesInvoiceHdrL."PDF Created" := true;
                            SalesInvoiceHdrL.Modify();
                        end;
                    // end;
                    until SalesInvHeader.Next = 0;
            end;
        }
        dataitem(SalesCreditNote; Integer)
        {
            DataItemTableView = where(Number = const(1));

            trigger OnAfterGetRecord()
            var
                CustomerL: Record Customer;
                SalesCreditMemoHeaderL: Record "Sales Cr.Memo Header";
            begin
                SalesCrMemoHeader.Reset();
                SalesCrMemoHeader.SetRange("PDF Created", false);
                if PostingDtFilter <> 0D then
                    SalesCrMemoHeader.SetRange("Posting Date", PostingDtFilter, WorkDate)
                else
                    SalesCrMemoHeader.SetRange("Posting Date", WorkDate);

                if SalesCrMemoHeader.FindSet then
                    repeat
                        CustomerL.Get(SalesCrMemoHeader."Bill-to Customer No.");
                        // if CustomerL."Invoice/Cr. Memo" <> CustomerL."Invoice/Cr. Memo"::" " then begin
                        Clear(SalesCreditMemoHeaderL);
                        SalesCreditMemoHeaderL := SalesCrMemoHeader;
                        if CrNoteFilePath <> '' then
                            FileName2 := '' + CrNoteFilePath + '' + SalesCrMemoHeader."No." + '.pdf';

                        Clear(SalesCreditNoteReport);
                        SalesCreditNoteReport.UseRequestPage(false);
                        SalesCreditNoteReport.InitializeRequest(true, false, SalesCrMemoHeader."No.");
                        SalesCreditNoteReport.SetTableView(SalesCrMemoHeader);
                        //SalesCreditNoteReport.SaveAsPdf(FileName2);
                        TempBlob.CreateOutStream(OutputStream);

                        if SalesCreditMemoHeaderL.get(SalesCrMemoHeader."No.") then begin
                            SalesCreditMemoHeaderL."PDF Created" := True;
                            SalesCreditMemoHeaderL.Modify();
                        end
                    // end;
                    until SalesCrMemoHeader.Next = 0;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(InvoiceFilePath; InvoiceFilePath)
                    {
                        ApplicationArea = All;
                        Caption = 'Invoice File Path';
                    }
                    field(CrNoteFilePath; CrNoteFilePath)
                    {
                        ApplicationArea = All;
                        Caption = 'Cr. Note File Path';
                    }
                    field(PostingDtFilter; PostingDtFilter)
                    {
                        ApplicationArea = all;
                        Caption = 'Date Filter';
                    }

                }
            }
        }

    }

    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvoiceReport: Report StandardSalesInvoiceCustom;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCreditNoteReport: Report "StandardSalesCredit Memo";
        FileName1: Text;
        FileName2: Text;
        InvoiceFilePath: Text;
        CrNoteFilePath: Text;
        PostingDtFilter: Date;
        TempBlob: Codeunit "Temp Blob";
        InputStream: InStream;
        OutputStream: OutStream;
}
//MITL_VS_PDF_20200612--