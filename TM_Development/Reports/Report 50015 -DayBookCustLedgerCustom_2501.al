report 50015 "DayBookCustLedgerEntryCustom"
{
    // version NAVW113.05

    DefaultLayout = RDLC;
    RDLCLayout = './Day Book Cust. Ledger Entry.rdlc';
    ApplicationArea = All;
    Caption = 'Day Book Cust. Ledger Entry Custom';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(ReqCustLedgEntry; "Cust. Ledger Entry")
        {
            DataItemTableView = SORTING ("Document Type", "Customer No.", "Posting Date", "Currency Code");
            RequestFilterFields = "Document Type", "Customer No.", "Posting Date", "Currency Code";
            trigger OnPreDataItem()
            begin
                CurrReport.BREAK;
            end;

        }
        dataitem(Date; Date)
        {
            DataItemTableView = SORTING ("Period Type", "Period Start")
                                    WHERE ("Period Type" = CONST (Date));
            column(USERID; USERID)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PAGENO)
            {
            }
            column(FORMAT_TODAY_0_4_; FORMAT(TODAY, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DISPLAYNAME)
            {
            }
            column(All_amounts_are_in___GLSetup__LCY_Code_; STRSUBSTNO(AllAmountsAreInLbl, GLSetup."LCY Code"))
            {
            }
            column(GetAmountLCY; AmountLCY1)
            {
            }
            column(GetPmtDiscGiven; PmtDiscGiven1)
            {
            }
            column(GetVatBase; VatBase1)
            {
            }
            column(GetVatAmount; VatAmount1)
            {
            }
            column(G_L_Entry___Entry_No__; "G/L Entry"."Entry No.")
            {
            }
            column(CustLedgerEntry___Entry_No__; "Cust. Ledger Entry"."Entry No.")
            {
            }
            column(PrintCLDetails; PrintCLDetails)
            {
            }
            column(GetActualAmount; ActualAmount1)
            {
            }
            column(Cust__Ledger_Entry__TABLENAME__________CustLedgFilter; "Cust. Ledger Entry".TABLECAPTION + ': ' + CustLedgFilter)
            {
            }
            column(CustLedgFilter; CustLedgFilter)
            {
            }
            column(Total_for______Cust__Ledger_Entry__TABLENAME__________CustLedgFilter; STRSUBSTNO(TotalForCustLedgerEntryLbl, "Cust. Ledger Entry".TABLECAPTION, CustLedgFilter))
            {
            }
            column(VATAmount; VATAmount)
            {
                AutoFormatType = 1;
            }
            column(VATBase; VATBase)
            {
                AutoFormatType = 1;
            }
            column(ActualAmount; ActualAmount)
            {
                AutoFormatType = 1;
            }
            column(PmtDiscGiven; PmtDiscGiven)
            {
            }
            column(Cust__Ledger_Entry___Amount__LCY__; "Cust. Ledger Entry"."Amount (LCY)")
            {
                AutoFormatType = 1;
            }
            column(Date_Period_Type; "Period Type")
            {
            }
            column(Date_Period_Start; "Period Start")
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Day_Book_Cust__Ledger_EntryCaption; Day_Book_Cust__Ledger_EntryCaptionLbl)
            {
            }
            column(Cust__Ledger_Entry__Amount__LCY__Caption; Cust__Ledger_Entry__Amount__LCY__CaptionLbl)
            {
            }
            column(PmtDiscGiven_Control32Caption; PmtDiscGiven_Control32CaptionLbl)
            {
            }
            column(VATAmount_Control26Caption; VATAmount_Control26CaptionLbl)
            {
            }
            column(ActualAmount_Control39Caption; ActualAmount_Control39CaptionLbl)
            {
            }
            column(VATBase_Control29Caption; VATBase_Control29CaptionLbl)
            {
            }
            column(PmtDiscGiven_Control32Caption_Control33; PmtDiscGiven_Control32Caption_Control33Lbl)
            {
            }
            column(Customer_NameCaption; Customer_NameCaptionLbl)
            {
            }
            column(Cust__Ledger_Entry__Customer_No__Caption; Cust__Ledger_Entry__Customer_No__CaptionLbl)
            {
            }
            column(Cust__Ledger_Entry__External_Document_No__Caption; "Cust. Ledger Entry".FIELDCAPTION("External Document No."))
            {
            }
            column(Cust__Ledger_Entry__Document_No__Caption; "Cust. Ledger Entry".FIELDCAPTION("Document No."))
            {
            }
            column(Cust__Ledger_Entry__Amount__LCY__Caption_Control24; Cust__Ledger_Entry__Amount__LCY__Caption_Control24Lbl)
            {
            }
            column(VATAmount_Control26Caption_Control27; VATAmount_Control26Caption_Control27Lbl)
            {
            }
            column(VATBase_Control29Caption_Control30; VATBase_Control29Caption_Control30Lbl)
            {
            }
            column(ActualAmount_Control39Caption_Control35; ActualAmount_Control39Caption_Control35Lbl)
            {
            }
            dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
            {
                DataItemTableView = SORTING ("Document Type", "Customer No.", "Posting Date");
                column(Cust__Ledger_Entry__FIELDNAME__Posting_Date__________FORMAT_Date__Period_Start__0_4_; FIELDCAPTION("Posting Date") + ' ' + FORMAT(Date."Period Start", 0, 4))
                {
                }
                column(FIELDNAME__Document_Type___________FORMAT__Document_Type__; FIELDCAPTION("Document Type") + ' ' + FORMAT("Document Type"))
                {
                }
                column(Cust__Ledger_Entry__Document_No__; "Document No.")
                {
                }
                column(Cust__Ledger_Entry__External_Document_No__; "External Document No.")
                {
                }
                column(Cust__Ledger_Entry__Amount__LCY__; "Amount (LCY)")
                {
                    AutoFormatType = 1;
                }
                column(VATBase_Control29; VATBase)
                {
                    AutoFormatType = 1;
                }
                column(PmtDiscGiven_Control32; PmtDiscGiven)
                {
                }
                column(Customer_Name; Customer.Name)
                {
                }
                column(Cust__Ledger_Entry__Customer_No__; "Customer No.")
                {
                }
                column(ActualAmount_Control39; ActualAmount)
                {
                    AutoFormatType = 1;
                }
                column(VATAmount_Control26; VATAmount)
                {
                    AutoFormatType = 1;
                }
                column(Total_for___FIELDNAME__Document_Type_________FORMAT__Document_Type__; STRSUBSTNO(TotalForCustLedgerEntryLbl, FIELDCAPTION("Document Type"), FORMAT("Document Type")))
                {
                }
                column(VATAmount_Control19; VATAmount)
                {
                    AutoFormatType = 1;
                }
                column(VATBase_Control22; VATBase)
                {
                    AutoFormatType = 1;
                }
                column(ActualAmount_Control25; ActualAmount)
                {
                    AutoFormatType = 1;
                }
                column(PmtDiscGiven_Control38; PmtDiscGiven)
                {
                }
                column(Cust__Ledger_Entry__Amount__LCY___Control41; "Amount (LCY)")
                {
                    AutoFormatType = 1;
                }
                column(Total_for_____FORMAT_Date__Period_Start__0_4_; STRSUBSTNO(TotalForDatePeriodStartLbl, FORMAT(Date."Period Start", 0, 4)))
                {
                }
                column(Cust__Ledger_Entry__Amount__LCY___Control57; "Amount (LCY)")
                {
                    AutoFormatType = 1;
                }
                column(PmtDiscGiven_Control50; PmtDiscGiven)
                {
                }
                column(ActualAmount_Control49; ActualAmount)
                {
                    AutoFormatType = 1;
                }
                column(VATBase_Control48; VATBase)
                {
                    AutoFormatType = 1;
                }
                column(VATAmount_Control47; VATAmount)
                {
                    AutoFormatType = 1;
                }
                column(Cust__Ledger_Entry_Entry_No_; "Entry No.")
                {
                }
                column(Cust__Ledger_Entry_Document_Type; "Document Type")
                {
                }
                dataitem("G/L Entry"; "G/L Entry")
                {
                    DataItemTableView = SORTING ("Transaction No.");
                    column(G_L_Entry__G_L_Account_No__; "G/L Account No.")
                    {
                    }
                    column(GLAcc_Name; GLAcc.Name)
                    {
                    }
                    column(G_L_Entry_Amount; Amount)
                    {
                        AutoFormatType = 1;
                    }
                    column(G_L_Entry_Entry_No_; "Entry No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        IF "G/L Account No." <> GLAcc."No." THEN
                            IF NOT GLAcc.GET("G/L Account No.") THEN
                                GLAcc.INIT;

                        IF SecondStep THEN BEGIN
                            IF PrintGLDetails THEN BEGIN
                                AmountLCY1 := "Cust. Ledger Entry"."Amount (LCY)";
                                PmtDiscGiven1 := PmtDiscGiven;
                                ActualAmount1 := ActualAmount;
                                VatBase1 := VATBase;
                                VatAmount1 := VATAmount;
                            END;
                            SecondStep := FALSE;
                        END ELSE BEGIN
                            AmountLCY1 := 0;
                            PmtDiscGiven1 := 0;
                            ActualAmount1 := 0;
                            VatBase1 := 0;
                            VatAmount1 := 0;
                        END;
                    end;

                    trigger OnPreDataItem()
                    var
                        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
                        TransactionNoFilter: Text[250];
                    begin
                        IF NOT PrintGLDetails THEN
                            CurrReport.BREAK;

                        DtldCustLedgEntry.RESET;
                        DtldCustLedgEntry.SETRANGE("Cust. Ledger Entry No.", "Cust. Ledger Entry"."Entry No.");
                        DtldCustLedgEntry.SETFILTER("Entry Type", '<>%1', DtldCustLedgEntry."Entry Type"::Application);
                        IF DtldCustLedgEntry.FINDSET THEN BEGIN
                            TransactionNoFilter := FORMAT(DtldCustLedgEntry."Transaction No.");
                            WHILE DtldCustLedgEntry.NEXT <> 0 DO
                                TransactionNoFilter := TransactionNoFilter + '|' + FORMAT(DtldCustLedgEntry."Transaction No.");
                        END;
                        SETFILTER("Transaction No.", TransactionNoFilter);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    SecondStep := TRUE;

                    IF "Customer No." <> Customer."No." THEN
                        IF NOT Customer.GET("Customer No.") THEN
                            Customer.INIT;

                    VATAmount := 0;
                    VATBase := 0;
                    VATEntry.SETCURRENTKEY("Transaction No.");
                    VATEntry.SETRANGE("Transaction No.", "Transaction No.");
                    IF VATEntry.FINDSET THEN
                        REPEAT
                            VATAmount := VATAmount - VATEntry.Amount;
                            VATBase := VATBase - VATEntry.Base;
                        UNTIL VATEntry.NEXT = 0;

                    PmtDiscGiven := 0;
                    CustLedgEntry.SETCURRENTKEY("Closed by Entry No.");
                    CustLedgEntry.SETRANGE("Closed by Entry No.", "Entry No.");
                    IF CustLedgEntry.FIND('-') THEN
                        REPEAT
                            PmtDiscGiven := PmtDiscGiven - CustLedgEntry."Pmt. Disc. Given (LCY)";
                        UNTIL CustLedgEntry.NEXT = 0;

                    ActualAmount := "Amount (LCY)" - PmtDiscGiven;

                    IF NOT PrintGLDetails THEN BEGIN
                        AmountLCY1 := "Amount (LCY)";
                        PmtDiscGiven1 := PmtDiscGiven;
                        ActualAmount1 := ActualAmount;
                        VatBase1 := VATBase;
                        VatAmount1 := VATAmount;
                    END;
                end;

                trigger OnPreDataItem()
                begin
                    CurrReport.CREATETOTALS("Amount (LCY)", VATAmount, PmtDiscGiven, VATBase, ActualAmount);
                    COPYFILTERS(ReqCustLedgEntry);
                    SETRANGE("Posting Date", Date."Period Start");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                AmountLCY1 := 0;
                PmtDiscGiven1 := 0;
                ActualAmount1 := 0;
                VatBase1 := 0;
                VatAmount1 := 0;
            end;

            trigger OnPreDataItem()
            var
                PostingDateStart: Date;
                PostingDateEnd: Date;
            begin

                CurrReport.CREATETOTALS("Cust. Ledger Entry"."Amount (LCY)", VATAmount, PmtDiscGiven, VATBase, ActualAmount);
                ReqCustLedgEntry.COPYFILTER("Posting Date", "Period Start");

                IF ReqCustLedgEntry.GETFILTER("Posting Date") = '' THEN
                    ERROR(MissingDateRangeFilterErr);

                PostingDateStart := ReqCustLedgEntry.GETRANGEMIN("Posting Date");
                PostingDateEnd := CALCDATE('<+1Y>', PostingDateStart);

                IF ReqCustLedgEntry.GETRANGEMAX("Posting Date") > PostingDateEnd THEN
                    ERROR(MaxPostingDateErr);
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
                    field(PrintCustLedgerDetails; PrintCLDetails)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Cust. Ledger Details';
                        ToolTip = 'Specifies if Cust. Ledger Details is printed';

                        trigger OnValidate()
                        begin
                            PrintCLDetailsOnAfterValidate;
                        end;
                    }
                    field(PrintGLEntryDetails; PrintGLDetails)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print G/L Entry Details';
                        ToolTip = 'Specifies if G/L Entry Details are printed';

                        trigger OnValidate()
                        begin
                            PrintGLDetailsOnAfterValidate;
                        end;
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

    trigger OnPreReport()
    var
        CustLedgEntryL: Record "Cust. Ledger Entry";
    begin

        CustLedgFilter := ReqCustLedgEntry.GETFILTERS;
        GLSetup.GET;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        GLAcc: Record "G/L Account";
        Customer: Record Customer;
        CustomerG: Record Customer; //MITL
        CustLedgEntry: Record "Cust. Ledger Entry";
        VATEntry: Record "VAT Entry";
        CustLedgFilter: Text;
        PmtDiscGiven: Decimal;
        VATAmount: Decimal;
        ActualAmount: Decimal;
        VATBase: Decimal;
        AmountLCY1: Decimal;
        PmtDiscGiven1: Decimal;
        VatBase1: Decimal;
        VatAmount1: Decimal;
        PrintGLDetails: Boolean;
        PrintCLDetails: Boolean;
        SecondStep: Boolean;
        ActualAmount1: Decimal;
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Day_Book_Cust__Ledger_EntryCaptionLbl: Label 'Day Book Cust. Ledger Entry';
        Cust__Ledger_Entry__Amount__LCY__CaptionLbl: Label 'Ledger Entry Amount';
        PmtDiscGiven_Control32CaptionLbl: Label 'Payment Discount Given';
        VATAmount_Control26CaptionLbl: Label 'VAT Amount';
        ActualAmount_Control39CaptionLbl: Label 'Actual Amount';
        VATBase_Control29CaptionLbl: Label 'VAT Base';
        PmtDiscGiven_Control32Caption_Control33Lbl: Label 'Payment Discount Given';
        Customer_NameCaptionLbl: Label 'Name';
        Cust__Ledger_Entry__Customer_No__CaptionLbl: Label 'Account No.';
        Cust__Ledger_Entry__Amount__LCY__Caption_Control24Lbl: Label 'Ledger Entry Amount';
        VATAmount_Control26Caption_Control27Lbl: Label 'VAT Amount';
        VATBase_Control29Caption_Control30Lbl: Label 'VAT Base';
        ActualAmount_Control39Caption_Control35Lbl: Label 'Actual Amount';
        AllAmountsAreInLbl: Label 'All amounts are in %1.', Comment = 'All amounts are in GBP';
        TotalForCustLedgerEntryLbl: Label 'Total for  %1 : %2.', Comment = 'Total for Cust. Ledger Entry 3403  ';
        TotalForDatePeriodStartLbl: Label 'Total for %1.', Comment = 'Total for posting date 12122012';
        MissingDateRangeFilterErr: Label 'Posting Date filter must be set.';
        MaxPostingDateErr: Label 'Posting Date period must not be longer than 1 year.';

    local procedure PrintGLDetailsOnAfterValidate()
    begin
        IF PrintGLDetails THEN
            PrintCLDetails := TRUE;
    end;

    local procedure PrintCLDetailsOnAfterValidate()
    begin
        IF NOT PrintCLDetails THEN
            PrintGLDetails := FALSE;
    end;
}

