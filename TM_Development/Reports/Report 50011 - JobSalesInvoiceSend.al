//This report has been developed in CAL with ID 50010
report 50032 "Job Sales Invoice Send"
{
    // version MITL_W&F

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
                SalesInvHeadL: Record 112;
                RecRef: RecordRef;
                FieldRefs: FieldRef;
                FieldValue: Text;
            begin
                SalesInvHdr.RESET;
                // IF StartDateG <> 0D THEN
                //  SalesInvHdr.SETRANGE("Posting Date",StartDateG, WORKDATE)
                // ELSE
                SalesInvHdr.SETRANGE("Posting Date", DMY2DATE(17, 1, 2020), TODAY);
                IF CustomerFilterG <> '' THEN
                    SalesInvHdr.SETFILTER("Bill-to Customer No.", CustomerFilterG)
                ELSE
                    SalesInvHdr.SETFILTER("Bill-to Customer No.", '');
                SalesInvHdr.SETRANGE("Sent as Email", FALSE);
                IF SalesInvHdr.FINDSET THEN
                    REPEAT

                        SalesInvHeadL.RESET;
                        SalesInvHeadL.SETCURRENTKEY("No.");
                        SalesInvHeadL.SETRANGE("No.", SalesInvHdr."No.");
                        IF SalesInvHeadL.FINDFIRST THEN BEGIN
                            CLEAR(ReportSelections);
                            ReportSelections.RESET;
                            ReportSelections.SETRANGE(Usage, ReportSelections.Usage::"S.Invoice");
                            IF ReportSelections.FINDFIRST THEN BEGIN
                                FieldValue := '';
                                Customer.RESET;
                                Customer.SETRANGE("No.", SalesInvHeadL."Bill-to Customer No.");
                                IF Customer.FINDFIRST THEN BEGIN
                                    RecRef.GETTABLE(Customer);
                                    FieldRefs := RecRef.FIELD(50220);
                                    FieldValue := FORMAT(FieldRefs.VALUE);
                                END;
                                IF FieldValue = 'Email' THEN BEGIN
                                    Customer.SETFILTER("E-Mail", '<>%1', '');
                                    IF Customer.FINDFIRST THEN BEGIN
                                        ReportSelections.SendEmailToCust(ReportSelections.Usage, SalesInvHeadL, SalesInvHeadL."No.", '', FALSE, SalesInvHeadL."Bill-to Customer No.");
                                        CreateOffice365Entry(SalesInvHeadL, TRUE);
                                    END ELSE
                                        CreateOffice365Entry(SalesInvHeadL, FALSE);
                                    //        END ELSE IF FieldValue = 'Print' THEN BEGIN
                                    //          ReportSelections.PrintWithGUIYesNo(ReportSelections.Usage,SalesInvHeadL,FALSE,SalesInvHeadL.FIELDNO("Bill-to Customer No."));
                                END;
                            END;
                        END;
                    UNTIL SalesInvHdr.NEXT = 0;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(CustomerFilterG; CustomerFilterG)
                {
                    Caption = 'Customer No.';
                }
                field(StartDateG; StartDateG)
                {
                    Caption = 'Start Date';
                    Visible = false;

                    trigger OnValidate()
                    var
                        Text001L: Label 'You can not enter Start Date greater %1';
                    begin
                        IF StartDateG > WORKDATE THEN
                            ERROR(STRSUBSTNO(Text001L, WORKDATE));
                    end;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        SalesInvHdr: Record 112;
        ReportSelections: Record 77;
        CustomerFilterG: Text;
        StartDateG: Date;
        EndDateG: Date;

    local procedure CreateOffice365Entry(var SalesInvHeadP: Record 112; SentStatusP: Boolean)
    var
        O365DocumentSentHistoryL: Record 2158;
        InO365DocumentSentHistoryL: Record 2158;
    begin
        // Exist("O365 Document Sent History" WHERE (Document Type=CONST(Invoice),Document No.=FIELD(No.),Posted=CONST(Yes),Job Last Status=CONST(Finished)))
        // Document Type,Document No.,Posted,Created Date-Time

        O365DocumentSentHistoryL.RESET;
        O365DocumentSentHistoryL.SETCURRENTKEY("Document Type", "Document No.", Posted, "Created Date-Time");
        O365DocumentSentHistoryL.SETRANGE("Document Type", O365DocumentSentHistoryL."Document Type"::Invoice);
        O365DocumentSentHistoryL.SETRANGE("Document No.", SalesInvHeadP."No.");
        O365DocumentSentHistoryL.SETRANGE("Created Date-Time", CURRENTDATETIME);
        IF NOT O365DocumentSentHistoryL.FINDFIRST THEN BEGIN
            InO365DocumentSentHistoryL.INIT;
            InO365DocumentSentHistoryL."Document Type" := InO365DocumentSentHistoryL."Document Type"::Invoice;
            InO365DocumentSentHistoryL."Document No." := SalesInvHeadP."No.";
            InO365DocumentSentHistoryL."Created Date-Time" := CURRENTDATETIME;
            InO365DocumentSentHistoryL."Source Type" := InO365DocumentSentHistoryL."Source Type"::Customer;
            InO365DocumentSentHistoryL."Source No." := SalesInvHeadP."Bill-to Customer No.";
            IF SentStatusP THEN BEGIN
                InO365DocumentSentHistoryL.Posted := TRUE;
                InO365DocumentSentHistoryL."Job Last Status" := InO365DocumentSentHistoryL."Job Last Status"::Finished;
            END ELSE BEGIN
                InO365DocumentSentHistoryL.Posted := FALSE;
                InO365DocumentSentHistoryL."Job Last Status" := InO365DocumentSentHistoryL."Job Last Status"::Error;
            END;
            InO365DocumentSentHistoryL.INSERT;
        END;
    end;
}

