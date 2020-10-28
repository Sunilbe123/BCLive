codeunit 50045 SendMailInventByLocation
{


    //Code Unite to run the Job for Inventory By Location Report (50028)
    //MITLDJ 16July2020++
    trigger OnRun()
    begin
        SMTPSetp.Get();
        UserSetup.Reset();
        UserSetup.SetRange(SendInvtLoc, true);
        If UserSetup.FindSet() then begin
            FileName := 'G:\Attachment Path\' + 'Inventory By Location' + '.pdf';
            SuspectStockFile := 'G:\Attachment Path\' + 'Suspect Inventory' + '.pdf';
            Clear(InvtByLoc);
            InvtByLoc.UseRequestPage(false);
            //InvtByLoc.SaveAsPdf(FileName);
            TempBlob.CreateOutStream(OutputStream);
            TempBlob1.CreateOutStream(OutputStream1);
            InvtByLoc.SaveAs(FileName, ReportFormat::Pdf, OutputStream);
            Clear(InvtByLoc);
            Clear(SuspectInventoy);
            SuspectInventoy.UseRequestPage(false);
            //SuspectInventoy.SaveAsPdf(SuspectStockFile);
            SuspectInventoy.SaveAs(SuspectStockFile, ReportFormat::Pdf, OutputStream1);
            Clear(SuspectInventoy);
            TempBlob.CreateInStream(InputStream);
            TempBlob1.CreateInStream(InputStream1);
            repeat
                UserSetup.TestField("E-Mail");

                Clear(SMTPMail);
                SMTPMail.CreateMessage(SMTPSetp."User ID", SMTPSetp."User ID", UserSetup."E-Mail", 'Inventory By Location Report For ' + CompanyName, '', TRUE);
                if TempBlob.HasValue() then begin
                    SMTPMail.AddAttachmentStream(InputStream, FileName);
                    if TempBlob1.HasValue() then begin
                        SMTPMail.AddAttachmentStream(InputStream1, FileName)
                    end;
                end;
            /*
            IF FILE.EXISTS(FileName) then begin
                SMTPMail.AddAttachment(FileName, '');
                IF FILE.EXISTS(SuspectStockFile) then
                    SMTPMail.AddAttachment(SuspectStockFile, '');
                SMTPMail.Send;
            end;
            */
            until UserSetup.Next = 0;
            if TempBlob.HasValue() then
                Clear(TempBlob);
            if TempBlob1.HasValue() then
                Clear(TempBlob1);
            /*
            IF FILE.EXISTS(FileName) then
                FILE.ERASE(FileName);
            IF FILE.EXISTS(SuspectStockFile) then
                FILE.ERASE(SuspectStockFile);
            */
        end;
    end;

    var
        SMTPMail: Codeunit "SMTP Mail";
        SMTPSetp: Record "SMTP Mail Setup";
        UserSetup: Record "User Setup";
        InvtByLoc: Report "Inventory by Location";
        FileName: Text;
        SuspectStockFile: Text;
        SuspectInventoy: Report "Suspect Inventory";
        TempBlob: Codeunit "Temp Blob";
        TempBlob1: Codeunit "Temp Blob";
        InputStream: InStream;
        InputStream1: InStream;
        OutputStream: OutStream;
        OutputStream1: OutStream;
}
//MITLDJ 17june2020--