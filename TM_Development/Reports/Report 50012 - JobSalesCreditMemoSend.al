//This report has been developed in CAL with ID 50012
report 50012 "Job SalesCredit Memo Send"
{
    // version MITL_W&F

    // MITL_MF 09.01.2020  Added code for sending mail with Email body

    Permissions = TableData 2158 = rim;
    ProcessingOnly = true;

    dataset
    {
        dataitem(DataItem1000000000; 2000000026)
        {
            DataItemTableView = SORTING(Number)
                                WHERE(Number = CONST(1));
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            var
                Customer: Record 18;
                SalesCredMemoHeadL: Record 114;
                RecRef: RecordRef;
                FieldRefs: FieldRef;
                FieldValue: Text;
            begin
                /*
                SMTPSetp.GET;
                SalesCrMemoHdr.RESET;
                IF SalesCrMemoHdr.FINDSET THEN
                SalesCrMemoHdr.SETRANGE("Posting Date",WORKDATE);
                IF SalesCrMemoHdr.FINDSET THEN
                  REPEAT
                    //RecRef.GETTABLE(SalesInvHdr);
                    //FieldRefs := RecRef.FIELD(50210);
                    //FieldValue := FieldRefs.VALUE;
                    IF Customer.GET(SalesCrMemoHdr."Sell-to Customer No.")THEN;
                    FileName := 'G:\TMDEV Server AL Extensions\Attachment Path\' +SalesCrMemoHdr."No."+'.pdf';
                    CLEAR(StandardCreditMemo);
                    StandardCreditMemo.USEREQUESTPAGE(FALSE);
                    StandardCreditMemo.InitializeRequest(TRUE,FALSE,SalesCrMemoHdr."No.");
                    StandardCreditMemo.SETTABLEVIEW(SalesCrMemoHdr);
                    StandardCreditMemo.SAVEASPDF(FileName);
                    CLEAR(SMTPMail);
                    SMTPMail.CreateMessage(SMTPSetp."User ID", SMTPSetp."User ID", Customer."E-Mail", '****Sales Credit Memo****', '', TRUE);
                    SMTPMail.AddAttachment('','');
                     IF FILE.EXISTS(FileName) THEN BEGIN
                        SMTPMail.AddAttachment(FileName,'');
                        SMTPMail.Send;
                        FILE.ERASE(FileName);
                     END;
                  UNTIL SalesCrMemoHdr.NEXT = 0;
                *///Code commented MITL_MF
                //<<MITL_MF ++
                SentEmail := FALSE;
                SalesCrMemoHdr.RESET;
                IF SalesCrMemoHdr.FINDSET THEN
                    SalesCrMemoHdr.SETRANGE("Posting Date", WORKDATE);
                //SalesCrMemoHdr.SETRANGE("No.",SalesCrMemoHdr."No.");
                CheckEntries();
                IF NOT SentEmail THEN BEGIN
                    IF SalesCrMemoHdr.FINDSET() THEN
                        REPEAT
                            SalesCredMemoHeadL.RESET;
                            SalesCredMemoHeadL.SETCURRENTKEY("No.");
                            SalesCredMemoHeadL.SETRANGE("No.", SalesCrMemoHdr."No.");
                            IF SalesCredMemoHeadL.FINDFIRST THEN BEGIN
                                CLEAR(ReportSelections);
                                ReportSelections.RESET;
                                ReportSelections.SETRANGE(Usage, ReportSelections.Usage::"S.Cr.Memo");
                                IF ReportSelections.FINDFIRST THEN BEGIN
                                    FieldValue := '';
                                    Customer.RESET;
                                    Customer.SETRANGE("No.", SalesCredMemoHeadL."Bill-to Customer No.");
                                    IF Customer.FINDFIRST THEN BEGIN
                                        RecRef.GETTABLE(Customer);
                                        FieldRefs := RecRef.FIELD(50220);
                                        FieldValue := FORMAT(FieldRefs.VALUE);
                                    END;
                                    IF FieldValue = 'Email' THEN BEGIN
                                        Customer.SETFILTER("E-Mail", '<>%1', '');
                                        IF Customer.FINDFIRST THEN BEGIN
                                            ReportSelections.SendEmailToCust(ReportSelections.Usage, SalesCredMemoHeadL, SalesCredMemoHeadL."No.", '', FALSE, SalesCredMemoHeadL."Bill-to Customer No.");
                                            CreateOffice365Entry(SalesCredMemoHeadL, TRUE);
                                        END ELSE
                                            CreateOffice365Entry(SalesCredMemoHeadL, FALSE);
                                        //        END ELSE IF FieldValue = 'Print' THEN BEGIN
                                        //          ReportSelections.PrintWithGUIYesNo(ReportSelections.Usage,SalesInvHeadL,FALSE,SalesInvHeadL.FIELDNO("Bill-to Customer No."));
                                    END;
                                END;
                            END;
                        UNTIL SalesCredMemoHeadL.NEXT = 0;
                END;
                //MITL_MF --

            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        SalesCrMemoHdr: Record 114;
        StandardCreditMemo: Report 1307;
        StartDate: Date;
        EndDate: Date;
        TempBlob: Record 99008535;
        EmailOutStream: OutStream;
        EmailInstream: InStream;
        SMTPMail: Codeunit 400;
        xmlparameter: Text;
        SMTPSetp: Record 409;
        RecRef: RecordRef;
        FieldRefs: FieldRef;
        FieldValue: Option;
        FileName: Text;
        ReportSelections: Record 77;
        O365DocumentSentHistoryG: Record 2158;
        SentEmail: Boolean;

    local procedure CreateOffice365Entry(var SalesCrMemoHdrP: Record 114; SentStatusP: Boolean)
    var
        O365DocumentSentHistoryL: Record 2158;
        InO365DocumentSentHistoryL: Record 2158;
    begin
        // Exist("O365 Document Sent History" WHERE (Document Type=CONST(Invoice),Document No.=FIELD(No.),Posted=CONST(Yes),Job Last Status=CONST(Finished)))
        // Document Type,Document No.,Posted,Created Date-Time

        O365DocumentSentHistoryL.RESET;
        O365DocumentSentHistoryL.SETCURRENTKEY("Document Type", "Document No.", Posted, "Created Date-Time");
        O365DocumentSentHistoryL.SETRANGE("Document Type", O365DocumentSentHistoryL."Document Type"::"Credit Memo");
        O365DocumentSentHistoryL.SETRANGE("Document No.", SalesCrMemoHdrP."No.");
        O365DocumentSentHistoryL.SETRANGE("Created Date-Time", CURRENTDATETIME);
        IF NOT O365DocumentSentHistoryL.FINDFIRST THEN BEGIN
            InO365DocumentSentHistoryL.INIT;
            InO365DocumentSentHistoryL."Document Type" := InO365DocumentSentHistoryL."Document Type"::"Credit Memo";
            InO365DocumentSentHistoryL."Document No." := SalesCrMemoHdrP."No.";
            InO365DocumentSentHistoryL."Created Date-Time" := CURRENTDATETIME;
            InO365DocumentSentHistoryL."Source Type" := InO365DocumentSentHistoryL."Source Type"::Customer;
            InO365DocumentSentHistoryL."Source No." := SalesCrMemoHdrP."Bill-to Customer No.";
            IF SentStatusP THEN BEGIN
                InO365DocumentSentHistoryL.Posted := TRUE;
                InO365DocumentSentHistoryL."Job Last Status" := InO365DocumentSentHistoryL."Job Last Status"::Finished;
            END ELSE BEGIN
                InO365DocumentSentHistoryL.Posted := FALSE;
                InO365DocumentSentHistoryL."Job Last Status" := InO365DocumentSentHistoryL."Job Last Status"::Error;
            END;
            InO365DocumentSentHistoryL.INSERT;
        END;
        //MITL_MF ++
    end;

    local procedure CheckEntries()
    begin
        O365DocumentSentHistoryG.RESET;
        O365DocumentSentHistoryG.SETRANGE("Document Type", O365DocumentSentHistoryG."Document Type"::"Credit Memo");
        O365DocumentSentHistoryG.SETRANGE("Document No.", SalesCrMemoHdr."No.");
        O365DocumentSentHistoryG.SETRANGE(Posted, TRUE);
        O365DocumentSentHistoryG.SETRANGE("Job Last Status", O365DocumentSentHistoryG."Job Last Status"::Finished);
        IF O365DocumentSentHistoryG.FINDFIRST THEN
            SentEmail := TRUE;
        //MITL_MF --
    end;
}

