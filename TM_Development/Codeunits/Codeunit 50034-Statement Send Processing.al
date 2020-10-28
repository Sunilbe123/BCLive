// MITL.SM.Improvement in Statement Sending through e-mail
codeunit 50034 "Statement Send Processing"
{

    trigger OnRun()
    begin
        RecStatSendQueue_g.Reset();
        RecStatSendQueue_g.SetRange(Status, RecStatSendQueue_g.Status::New);
        if RecStatSendQueue_g.FindSet() then
            repeat
                ErrorText := '';
                if Not SendStatementMail() then begin
                    RecStatSendQueue_g.Status := RecStatSendQueue_g.Status::Error;
                    RecStatSendQueue_g."Error Details" := ErrorText;
                    RecStatSendQueue_g.Modify();
                end
                Else begin
                    RecStatSendQueue_g.Status := RecStatSendQueue_g.Status::Sent;
                    RecStatSendQueue_g."Statement Sent Date Time" := CurrentDateTime();
                    RecStatSendQueue_g.Modify();
                end;
            until RecStatSendQueue_g.Next() = 0;
    end;

    procedure SendStatementMail(): Boolean
    var
        StartDate: Date;
        EndDate: Date;
        SMTPSetup: Record "SMTP Mail Setup";
        FileName: Text;
        StandardStatement: Report 50020;
        Customer: Record Customer;
        SMTPMail: Codeunit "SMTP Mail";
        RecRef: RecordRef;
        FieldRefs: FieldRef;
        FieldValue: Option;
        MailSent: Boolean;
        TempBlob: Codeunit "Temp Blob";
        InputStream: InStream;
        OutputStream: OutStream;
    begin
        MailSent := false;
        StartDate := DMY2Date(01, 08, 2019);
        //StartDate := 010118D;
        // MITL.SM.Statement Report Correction 12.02.2020 ++ 
        // EndDate := CALCDATE('<CM>', WORKDATE);
        EndDate := CALCDATE('<-CM-1D>', WORKDATE);
        // MITL.SM.Changes in Calculation of End Date 06.03.2020 ++
        if (EndDate - CalcDate('<-CM', EndDate)) < 31 then
            EndDate := EndDate + (31 - (Date2DMY(EndDate, 1)));
        // MITL.SM.Changes in Calculation of End Date 06.03.2020 --
        // MITL.SM.Statement Report Correction 12.02.2020 --
        SMTPSetup.GET;
        Customer.Get(RecStatSendQueue_g."Customer No.");
        // Customer.RESET;
        //Customer.SETRANGE("No.",'C00000001');
        // Customer.SetRange("No.", "No.");//MITL_MF_13.01.20
        // CurrPage.SetSelectionFilter(Customer);//MITL.SM.Statement Report Correction 17.02.2020
        // Customer.SetRange("Statement/Reminder", Customer."Statement/Reminder"::Email);
        // IF Customer.FINDSET THEN
        //     REPEAT
        RecRef.GETTABLE(Customer);
        FieldRefs := RecRef.FIELD(50210);
        FieldValue := FieldRefs.VALUE;
        FileName := 'G:\Attachment Path\' + Customer."No." + '.pdf';
        CLEAR(StandardStatement);
        StandardStatement.USEREQUESTPAGE(FALSE);
        // StandardStatement.InitializeRequest(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, '1M+CM', 0, FALSE, StartDate, EndDate, Customer."No.");
        StandardStatement.InitializeRequest(FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, '1M+CM', 0, FALSE, StartDate, EndDate, Customer."No.");//MITL.7327.VS.20200901
        StandardStatement.SETTABLEVIEW(Customer);
        TempBlob.CreateOutStream(OutputStream);
        StandardStatement.SaveAs('', ReportFormat::Pdf, OutputStream);
        //StandardStatement.SAVEASPDF(FileName);
        CLEAR(SMTPMail);
        SMTPMail.CreateMessage(SMTPSetup."User ID", SMTPSetup."User ID", Customer."E-Mail", CompanyName() + ' Statement Of Account', '', TRUE);
        //MITL_MF_10.01.20
        SMTPMail.AppendBody('Dear Customer' + '<br><br>');
        SMTPMail.AppendBody('Please find statement attached.' + '<br><br>');
        SMTPMail.AppendBody('Should you have any queries please contact our sales ledger.' + '<br><br>');
        SMTPMail.AppendBody('Regards' + '<br><br>');
        SMTPMail.AppendBody('(01536) 314 737' + '<br><br>');
        SMTPMail.AppendBody('sales.ledger@wallsandfloors.co.uk' + '<br>');
        SMTPMail.AppendBody('www.wallsandfloorstrade.co.uk' + '<br>');
        //MITL_MF_10.01.20
        /*
        SMTPMail.AddAttachment('', '');
        IF FieldValue = 1 THEN
            IF FILE.EXISTS(FileName) THEN BEGIN
                SMTPMail.AddAttachment(FileName, '');
                if SMTPMail.TrySend() then
                    MailSent := true
                else
                    ErrorText := CopyStr(SMTPMail.GetLastSendMailErrorText(), 1, 250);

                FILE.ERASE(FileName);
            END;
        */
        SMTPMail.AddAttachmentStream(InputStream, FileName);
        //     UNTIL Customer.NEXT = 0;

        exit(MailSent);
    end;

    var
        RecStatSendQueue_g: Record "Statement Email Queue";
        ErrorText: Text[250];

}