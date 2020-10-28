//This report has been developed in CAL with ID 50011
report 50031 "Job Remittance Advice"
{
    // version MITL_W&F

    DefaultLayout = RDLC;
    RDLCLayout = './Job Remittance Advice.rdlc';

    dataset
    {
        dataitem(DataItem1000000000; 2000000026)
        {
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            begin

                SMTPSetp.GET;
                GenJournalLine.RESET;
                GenJournalLine.SETRANGE("Account Type", GenJournalLine."Account Type"::Vendor);
                IF GenJournalLine.FINDSET THEN
                    REPEAT
                        ApprovalEntry.RESET;
                        ApprovalEntry.SETRANGE("Document No.", GenJournalLine."Document No.");
                        ApprovalEntry.SETRANGE(Status, ApprovalEntry.Status::Open);
                        IF NOT ApprovalEntry.FINDFIRST THEN
                            IF LastVendor <> GenJournalLine."Account No." THEN BEGIN
                                IF Vendor.GET(GenJournalLine."Account No.") THEN;
                                FileName := 'G:\TMDEV Server AL Extensions\Attachment Path\' + GenJournalLine."Document No." + GenJournalLine."Account No." + '.pdf';
                                CLEAR(RemittanceAdviceJournal);
                                RemittanceAdviceJournal.USEREQUESTPAGE(FALSE);
                                //RemittanceAdviceJournal.SetPostingDateFilter(WORKDATE);
                                RemittanceAdviceJournal.SETTABLEVIEW(GenJournalLine);
                                //RemittanceAdviceJournal.SAVEASPDF(FileName);
                                TempBlob.CreateOutStream(EmailOutStream);
                                RemittanceAdviceJournal.SaveAs('', ReportFormat::Pdf, EmailOutStream);
                                CLEAR(SMTPMail);
                                SMTPMail.CreateMessage(SMTPSetp."User ID", SMTPSetp."User ID", Vendor."E-Mail", '****Remittance Advice****', '', TRUE);
                                //SMTPMail.AddAttachment('', '');
                                IF TempBlob.HasValue() THEN BEGIN
                                    TempBlob.CreateInStream(EmailInstream);
                                    SMTPMail.AddAttachmentStream(EmailInstream, FileName);
                                    //SMTPMail.AddAttachment(FileName, '');
                                    SMTPMail.Send;
                                END;
                            END;
                        LastVendor := GenJournalLine."Account No.";
                    UNTIL GenJournalLine.NEXT = 0;
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
        GenJournalLine: Record 81;
        RemittanceAdviceJournal: Report 399;
        StartDate: Date;
        EndDate: Date;
        //TempBlob: Record 99008535;
        TempBlob: Codeunit "Temp Blob";
        EmailOutStream: OutStream;
        EmailInstream: InStream;
        SMTPMail: Codeunit 400;
        xmlparameter: Text;
        SMTPSetp: Record 409;
        RecRef: RecordRef;
        FieldRefs: FieldRef;
        FieldValue: Option;
        FileName: Text;
        Vendor: Record 23;
        LastVendor: Code[20];
        ApprovalEntry: Record 454;
}

