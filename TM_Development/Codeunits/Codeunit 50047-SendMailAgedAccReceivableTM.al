//MITL.7446.VS++
codeunit 50047 SendMailAccReceivableTM
{
    trigger OnRun()
    begin
        SMTPSetup.GET;
        SalesPerson.Reset();
        SalesPerson.SetFilter("E-Mail", '<>%1', '');
        if SalesPerson.FindSet() then
            repeat
                Customer.RESET();
                Customer.SETRANGE("Wholesale Customer", TRUE);
                Customer.SETRANGE("Salesperson Code", SalesPerson.Code);
                Customer.FINDSET;

                FileName := 'G:\Attachment Path\' + 'Aged Acc. Receivable' + '.xlsx';

                Evaluate(PeriodLength, '<1M>');

                clear(AgedAccReceivable);
                AgedAccReceivable.UseRequestPage(FALSE);
                AgedAccReceivable.InitializeRequest(WORKDATE, 0, PeriodLength, FALSE, FALSE, 0, FALSE);
                AgedAccReceivable.SetTableView(Customer);
                TempBlob.CreateOutStream(OutputStream);
                AgedAccReceivable.SaveAs(FileName, ReportFormat::Excel, OutputStream);
                //AgedAccReceivable.SaveAsExcel(FileName);

                CLEAR(SMTPMail);
                SMTPMail.CreateMessage(SMTPSetup."User ID", SMTPSetup."User ID", SalesPerson."E-Mail", CompanyName() + ' - Aged Accounts Receivables', '', TRUE);
                if SalesPerson."Line Manager" <> '' then begin
                    CCReceipientsList.Add(SalesPerson."Line Manager");
                    SMTPMail.AddCC(CCReceipientsList);
                end;
                /*
                IF FILE.EXISTS(FileName) THEN BEGIN
                    SMTPMail.AddAttachment(FileName, '');
                    SMTPMail.Send();
                    FILE.Erase(FileName);
                END;
                */
                TempBlob.CreateInStream(InputStream);
                if TempBlob.HasValue() then begin
                    SMTPMail.AddAttachmentStream(InputStream, FileName);
                    SMTPMail.Send();
                    Clear(TempBlob);
                end;
            until SalesPerson.Next() = 0;
    end;

    var
        SalesPerson: Record "Salesperson/Purchaser";
        SMTPMail: Codeunit "SMTP Mail";
        SMTPSetup: Record "SMTP Mail Setup";
        Customer: Record Customer;
        FileName: Text;
        AgedAccReceivable: Report "Aged Accounts Receivable -TM";
        PeriodLength: DateFormula;
        TempBlob: Codeunit "Temp Blob";
        InputStream: InStream;
        OutputStream: OutStream;
        CCReceipientsList: List of [Text];
}
//MITL.7446.VS--