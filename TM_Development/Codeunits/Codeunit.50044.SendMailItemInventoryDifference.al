codeunit 50044 SendMailItemInventoryDiff
{//Code Unite to run the Job for Item Inventory Difference Repor (50025)
    //MITLDJ 17june2020++
    trigger OnRun()
    begin
        SMTPSetp.Get();
        UserSetup.Reset();
        UserSetup.SetRange(SendInvtDiff, true);
        If UserSetup.FindSet() then
            repeat
                UserSetup.TestField("E-Mail");
                FileName := 'G:\Attachment Path\' + 'Item Inventory Difference' + '.pdf';
                Clear(ItemInvenDiff);
                ItemInvenDiff.UseRequestPage(false);
                TempBlob.CreateOutStream(OutputStream);
                //ItemInvenDiff.SaveAsPdf(FileName);
                ItemInvenDiff.SaveAs(FileName, ReportFormat::Pdf, OutputStream);
                Clear(ItemInvenDiff);
                Clear(SMTPMail);
                SMTPMail.CreateMessage(SMTPSetp."User ID", SMTPSetp."User ID", UserSetup."E-Mail", 'Item Inventory Differenc Report For ' + CompanyName, '', TRUE);
                /*
                IF FILE.EXISTS(FileName) then begin
                    SMTPMail.AddAttachment(FileName, '');
                    SMTPMail.Send;
                    FILE.ERASE(FileName);
                end;
                */
                TempBlob.CreateInStream(InputStream);
                if TempBlob.HasValue() then begin
                    SMTPMail.AddAttachmentStream(InputStream, FileName);
                    SMTPMail.Send();
                    Clear(TempBlob);
                end;
            until UserSetup.Next = 0;
    end;

    var
        SMTPMail: Codeunit "SMTP Mail";
        SMTPSetp: Record "SMTP Mail Setup";
        UserSetup: Record "User Setup";
        ItemInvenDiff: Report "Item Inventory Difference";
        FileName: Text;
        TempBlob: Codeunit "Temp Blob";
        InputStream: InStream;
        OutputStream: OutStream;
}
//MITLDJ 17june2020--