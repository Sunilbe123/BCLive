report 50007 "Sales Order Processing Batch"
{
    // version Case ID 13547

    Caption = 'Batch Post Sales Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem(SalesOrderProcessingBatch; SalesOrderProcessingBatch)
        {
            DataItemTableView = SORTING ("Sales Order No.");
            dataitem(SalesHeader1; "Sales Header")
            {
                DataItemLink = "No." = FIELD ("Sales Order No.");
                DataItemTableView = SORTING ("Document Type", "No.")
                                    WHERE ("Document Type" = CONST (Order));
                dataitem("Warehouse Activity Line"; "Warehouse Activity Line")
                {
                    DataItemLink = "Source No." = FIELD ("No.");
                    DataItemTableView = SORTING ("Activity Type", "No.", "Line No.");
                    dataitem("Warehouse Activity Header"; "Warehouse Activity Header")
                    {
                        DataItemLink = "No." = FIELD ("No.");
                        DataItemTableView = SORTING (Type, "No.");

                        trigger OnAfterGetRecord()
                        begin
                            "Warehouse Activity Header".DELETE;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        "Warehouse Activity Line".DELETE;
                    end;
                }
                dataitem("Warehouse Shipment Line"; "Warehouse Shipment Line")
                {
                    DataItemLink = "Source No." = FIELD ("No.");
                    DataItemTableView = SORTING ("No.", "Line No.");
                    dataitem("Warehouse Shipment Header"; "Warehouse Shipment Header")
                    {
                        DataItemLink = "No." = FIELD ("No.");
                        DataItemTableView = SORTING ("No.");

                        trigger OnAfterGetRecord()
                        begin
                            "Warehouse Shipment Header".DELETE;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        "Warehouse Shipment Line".DELETE;
                    end;
                }
                dataitem("Sales Line"; "Sales Line")
                {
                    DataItemLink = "Document Type" = FIELD ("Document Type"),
                                   "Document No." = FIELD ("No.");
                    DataItemTableView = SORTING ("Document Type", "Document No.", "Line No.")
                                        WHERE ("Quantity Shipped" = FILTER (0));

                    trigger OnAfterGetRecord()
                    begin
                        "Sales Line".VALIDATE("Location Code", LocationCode);
                        "Sales Line".VALIDATE("Qty. to Ship", "Sales Line"."Outstanding Quantity");
                        "Sales Line".MODIFY;
                    end;

                    trigger OnPostDataItem()
                    var
                        ReleaseSalesDocument: Codeunit "Release Sales Document";
                    begin
                        ReleaseSalesDocument.PerformManualRelease(SalesHeader1);
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    ReleaseSalesDocument1: Codeunit "Release Sales Document";
                begin
                    IF SalesHeader1.Status <> SalesHeader1.Status::Open THEN BEGIN
                        ReleaseSalesDocument1.PerformManualReopen(SalesHeader1);
                        SalesHeader1."Location Code" := LocationCode;
                        SalesHeader1."Your Reference" := 'C-13547';
                        SalesHeader1.VALIDATE("Posting Date", PostingDateReq);
                        SalesHeader1.MODIFY;
                    END;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Counter1 := Counter1 + 1;
                Window.UPDATE(1, "Sales Order No.");
                Window.UPDATE(2, ROUND(Counter1 / CounterTotal1 * 10000, 1));
            end;

            trigger OnPostDataItem()
            var
                SalesHeader5: Record "Sales Header";
            begin
                Window.CLOSE;
            end;

            trigger OnPreDataItem()
            begin

                CounterTotal1 := COUNT;
                Window.OPEN(Text001);
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
                    field(Ship; ShipReq)
                    {
                        Caption = 'Ship';
                        Visible = false;
                    }
                    field(Invoice; InvReq)
                    {
                        Caption = 'Invoice';
                        Visible = false;
                    }
                    field(PostingDate; PostingDateReq)
                    {
                        Caption = 'Posting Date';
                    }
                    field(ReplacePostingDate; ReplacePostingDate)
                    {
                        Caption = 'Replace Posting Date';
                        Visible = false;

                        trigger OnValidate()
                        begin
                            IF ReplacePostingDate THEN
                                MESSAGE(Text003);
                        end;
                    }
                    field(ReplaceDocumentDate; ReplaceDocumentDate)
                    {
                        Caption = 'Replace Document Date';
                        Visible = false;
                    }
                    field(CalcInvDisc; CalcInvDisc)
                    {
                        Caption = 'Calc. Inv. Discount';
                        Visible = false;

                        trigger OnValidate()
                        begin
                            SalesSetup.GET;
                            SalesSetup.TESTFIELD("Calc. Inv. Discount", FALSE);
                        end;
                    }
                    field(LocationCode; LocationCode)
                    {
                        Caption = 'Location Code';
                        TableRelation = Location;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            SalesSetup.GET;
            CalcInvDisc := SalesSetup."Calc. Inv. Discount";
            ReplacePostingDate := FALSE;
            ReplaceDocumentDate := FALSE;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        IF PostingDateReq = 0D THEN
            ERROR('Posting Date cannot be blank');

        IF LocationCode = '' THEN
            ERROR('Location Code must have a value');
    end;

    var
        Text000: Label 'Enter the posting date.';
        Text001: Label 'Posting orders  #1########## @2@@@@@@@@@@@@@';
        Text002: Label '%1 orders out of a total of %2 have now been posted.';
        Text003: Label 'The exchange rate associated with the new posting date on the sales header will not apply to the sales lines.';
        SalesLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        SalesCalcDisc: Codeunit "Sales-Calc. Discount";
        SalesPost: Codeunit "Sales-Post";
        Window: Dialog;
        ShipReq: Boolean;
        InvReq: Boolean;
        PostingDateReq: Date;
        CounterTotal: Integer;
        Counter: Integer;
        CounterOK: Integer;
        ReplacePostingDate: Boolean;
        ReplaceDocumentDate: Boolean;
        CalcInvDisc: Boolean;
        SalesHeader: Record "Sales Header";
        CounterTotal1: Integer;
        Counter1: Integer;
        LocationCode: Code[20];
        BatchPostSalesOrders: Report "Batch Post Sales Orders";
}

