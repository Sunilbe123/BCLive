report 50008 "Isue Rem Ext"
{
    // version NAVW111.00.00.20348

    Caption = 'Issue Rem Ext';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Reminder Header"; "Reminder Header")
        {
            DataItemTableView = SORTING ("No.");
            RequestFilterFields = "No.";
            RequestFilterHeading = 'Reminder';

            trigger OnAfterGetRecord()
            begin
                RecordNo := RecordNo + 1;
                CLEAR(ReminderIssue);
                ReminderIssue.Set("Reminder Header", ReplacePostingDate, PostingDateReq);
                IF NoOfRecords = 1 THEN BEGIN
                    ReminderIssue.RUN;
                    MARK := FALSE;
                END ELSE BEGIN
                    NewDateTime := CURRENTDATETIME;
                    IF (NewDateTime - OldDateTime > 100) OR (NewDateTime < OldDateTime) THEN BEGIN
                        NewProgress := ROUND(RecordNo / NoOfRecords * 100, 1);
                        IF NewProgress <> OldProgress THEN BEGIN
                            Window.UPDATE(1, NewProgress * 100);
                            OldProgress := NewProgress;
                        END;
                        OldDateTime := CURRENTDATETIME;
                    END;
                    COMMIT;
                    MARK := NOT ReminderIssue.RUN;
                END;

                IF PrintDoc <> PrintDoc::" " THEN BEGIN
                    ReminderIssue.GetIssuedReminder(IssuedReminderHeader);
                    TempIssuedReminderHeader := IssuedReminderHeader;
                    TempIssuedReminderHeader.INSERT;
                END;
            end;

            trigger OnPostDataItem()
            var
                IssuedReminderHeaderPrint: Record "Issued Reminder Header";
                Custrec: Record Customer;
                ReportSelectionL: Record "Report Selections";
            begin
                Window.CLOSE;
                COMMIT;
                CalledFromAction := TRUE;
                IF PrintDoc <> PrintDoc::" " THEN
                    IF TempIssuedReminderHeader.FINDSET THEN
                        REPEAT
                            IssuedReminderHeaderPrint := TempIssuedReminderHeader;
                            IssuedReminderHeaderPrint.SETRECFILTER;
                            IF Custrec.GET(IssuedReminderHeaderPrint."Customer No.") THEN BEGIN
                                IF Custrec."Statement/Reminder" = Custrec."Statement/Reminder"::Email THEN begin
                                    HideDialog := true;
                                    PrintDoc := PrintDoc::Email;
                                    IssuedReminderHeaderPrint.PrintRecords(FALSE, PrintDoc = PrintDoc::Email, HideDialog);
                                END;
                                IF Custrec."Statement/Reminder" = Custrec."Statement/Reminder"::Print THEN begin
                                    HideDialog := true;
                                    PrintDoc := PrintDoc::Print;
                                    ReportSelectionL.PrintWithGUIYesNo(ReportSelectionL.Usage::Reminder, IssuedReminderHeaderPrint, FALSE, IssuedReminderHeaderPrint.FIELDNO("Customer No."));
                                end;
                            END;
                            //IssuedReminderHeaderPrint.PrintRecords(FALSE, PrintDoc = PrintDoc::Email, HideDialog);
                        UNTIL TempIssuedReminderHeader.NEXT = 0;

                MARKEDONLY := TRUE;
                IF FIND('-') THEN
                    IF CONFIRM(Text003, TRUE) THEN
                        PAGE.RUNMODAL(0, "Reminder Header");
            end;

            trigger OnPreDataItem()
            begin
                IF ReplacePostingDate AND (PostingDateReq = 0D) THEN
                    ERROR(Text000);
                NoOfRecords := COUNT;
                IF NoOfRecords = 1 THEN
                    Window.OPEN(Text001)
                ELSE BEGIN
                    Window.OPEN(Text002);
                    OldDateTime := CURRENTDATETIME;
                END;
                "Reminder Header".SETRANGE("Reminder Header"."Issue Reminder", TRUE);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PrintDoc; PrintDoc)
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Print';
                        Enabled = NOT IsOfficeAddin;
                        ToolTip = 'Specifies it you want to print or email the reminders when they are issued.';
                    }
                    field(ReplacePostingDate; ReplacePostingDate)
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Replace Posting Date';
                        ToolTip = 'Specifies if you want to replace the reminders'' posting date with the date entered in the field below.';
                    }
                    field(PostingDateReq; PostingDateReq)
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date. If you place a check mark in the check box above, the program will use this date on all reminders when you post.';
                    }
                    field(HideEmailDialog; HideDialog)
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Hide Email Dialog';
                        ToolTip = 'Specifies if you want to hide email dialog.';
                    }
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

    trigger OnInitReport()
    var
        OfficeMgt: Codeunit "Office Management";
    begin
        IsOfficeAddin := OfficeMgt.IsAvailable;
        IF IsOfficeAddin THEN
            PrintDoc := 2;
    end;

    var
        Text000: Label 'Enter the posting date.';
        Text001: Label 'Issuing reminder...';
        Text002: Label 'Issuing reminders @1@@@@@@@@@@@@@';
        Text003: Label 'It was not possible to issue some of the selected reminders.\Do you want to see these reminders?';
        IssuedReminderHeader: Record "Issued Reminder Header";
        TempIssuedReminderHeader: Record "Issued Reminder Header" temporary;
        ReminderIssue: Codeunit "Reminder-Issue";
        Window: Dialog;
        NoOfRecords: Integer;
        RecordNo: Integer;
        NewProgress: Integer;
        OldProgress: Integer;
        NewDateTime: DateTime;
        OldDateTime: DateTime;
        PostingDateReq: Date;
        ReplacePostingDate: Boolean;
        PrintDoc: Option " ",Print,Email;
        HideDialog: Boolean;
        [InDataSet]
        IsOfficeAddin: Boolean;
        CalledFromAction: Boolean;
        ReminderTxt: Label 'Issued Reminder';


    procedure CallFromAction(MakeTrue: Boolean)
    begin
        IF MakeTrue THEN
            CalledFromAction := MakeTrue
        ELSE
            CalledFromAction := FALSE;
    end;
}
