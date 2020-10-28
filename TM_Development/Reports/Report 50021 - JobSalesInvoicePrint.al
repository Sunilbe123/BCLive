report 50021 JobSalesInvoicePrint
{
    //Version MITL3854
    //MITL3854 ++
    Caption = 'Job Sales Invoice Print';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    DefaultLayout = RDLC;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING (Number) WHERE (Number = CONST (1));
            // column(ColumnName; SourceFieldName)
            // {

            // }

            trigger OnAfterGetRecord()
            var
                SalesInvHeadL: Record "Sales Invoice Header";
                Customer: Record Customer;
            begin
                SalesInvHdr.RESET;
                if StartDateG = 0D then
                    SalesInvHdr.SETRANGE("Posting Date", CALCDATE('-7D', WORKDATE), WORKDATE)
                else
                    SalesInvHdr.SETRANGE("Posting Date", StartDateG, WORKDATE);
                IF CustomerFilterG <> '' THEN
                    SalesInvHdr.SETFILTER("Bill-to Customer No.", CustomerFilterG)
                ELSE
                    SalesInvHdr.SETFILTER("Bill-to Customer No.", '');
                SalesInvHdr.SETRANGE("No. Printed", 0);
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
                                Customer.RESET;
                                Customer.SETRANGE("No.", SalesInvHeadL."Bill-to Customer No.");
                                IF Customer.FINDFIRST THEN
                                    IF Customer."Invoice/Cr. Memo" = Customer."Invoice/Cr. Memo"::Print THEN
                                        ReportSelections.PrintWithGUIYesNo(ReportSelections.Usage, SalesInvHeadL, FALSE, SalesInvHeadL.FIELDNO("Bill-to Customer No."));
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
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(CustomerFilterG; CustomerFilterG)
                    {
                        Caption = 'Customer No.';
                        ApplicationArea = All;
                    }
                    field(StartDateG; StartDateG)
                    {
                        Caption = 'Start Date';
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    var

        ReportSelections: Record "Report Selections";
        CustomerFilterG: Text;
        SalesInvHdr: Record "Sales Invoice Header";
        StartDateG: Date;
        //MITL3854 **
}