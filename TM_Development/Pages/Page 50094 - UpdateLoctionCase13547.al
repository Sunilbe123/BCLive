page 50094 "Update Loction Case13547"
{
    // version Case ID 13547

    PageType = List;
    SourceTable = SalesOrderProcessingBatch;
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Order No."; "Sales Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Shipped; Shipped)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Editable = false;
                }
                field(invoiced; invoiced)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Step 1 - Update Location Code")
            {
                Caption = 'Step 1 - Update Location Code';
                Image = "Report";
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    IF NOT CONFIRM('Do you want to update sales order') THEN
                        EXIT;
                    SalesOrdersProcessingBatch.RUN;

                end;
            }
            action("Step 2- Ship - Invoice SO")
            {
                Caption = 'Step 2- Ship - Invoice SO';
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    BatchPostSalesOrdersL: Report "Batch Post Sales Orders";
                    SalesSetupL: Record "Sales & Receivables Setup";
                    CalcInvDisc: Boolean;
                begin
                    IF NOT CONFIRM('Do you want to continue?') THEN
                        EXIT;
                    SalesSetupL.Get;
                    CalcInvDisc := SalesSetupL."Calc. Inv. Discount";
                    Clear(BatchPostSalesOrdersL);
                    BatchPostSalesOrdersL.InitializeRequest(true, true, 0D, false, false, CalcInvDisc);
                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SETRANGE(SalesHeader."Your Reference", 'C-13547');
                    SalesHeader.FindSet();
                    BatchPostSalesOrdersL.SetTableView(SalesHeader);
                    BatchPostSalesOrdersL.Run();

                end;
            }
        }
    }

    var
        SalesOrdersProcessingBatch: Report "Sales Order Processing Batch";
}

