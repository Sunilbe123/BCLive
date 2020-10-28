page 50037 ProcessBulkRecords
{
    //Version MITL4192
    PageType = List;
    Caption = 'Process Bulk Records';
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = ProcessBulkRecord;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Order No."; "Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Caption = 'Order No.';
                    Description = 'MITL4192';
                }
                field("Whse. Shipment No."; "Whse. Shipment No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Caption = 'Whse. Shipment No.';
                    Description = 'MITL4192';
                }
                field(Processed; Processed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Caption = 'Processed';
                    Description = 'MITL4192';
                }
                field("Unposted Pick Nos."; "Unposted Pick Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Error; Error)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Caption = 'Error';
                    Description = 'MITL4192';
                }

                field("Sales Invoice No."; "Sales Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Caption = 'Sales Invoice No.';
                    Description = 'MITL4192';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Caption = 'Customer No.';
                    Description = 'MITL4192';
                }
            }
        }

        area(Factboxes)
        {

        }
    }


    actions
    {
        area(Processing)
        {
            action("Import Records")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = Import;
                RunObject = xmlport ImportBulkRecords;
                trigger OnAction();
                begin

                end;
            }
            action("Process Records")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = Process;

                trigger OnAction();
                var
                begin
                    if not Confirm('Have you clicked on button ''''Update missing Posting group''''') then
                        exit;
                    Codeunit.Run(50033);
                    CurrPage.Update();
                end;
            }
            action("Register Picks")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = RegisterPick;

                trigger OnAction();
                var
                    RegisterPick: Codeunit RegisterUnhandledPicks;
                    SalesHeaderL: Record "Sales Header";
                    ProcessBulkL: Record ProcessBulkRecord;
                begin
                    ProcessBulkL.Reset();
                    ProcessBulkL.SetRange(Processed, false);
                    ProcessBulkL.SetFilter("Order No.", '<>%1', '');
                    ProcessBulkL.SetFilter("Unposted Pick Nos.", '<>0');
                    if ProcessBulkL.FindSet() then
                        repeat
                            SalesHeaderL.Reset();
                            SalesHeaderL.SetRange("Document Type", SalesHeaderL."Document Type"::Order);
                            SalesHeaderL.SetRange("No.", ProcessBulkL."Order No.");
                            IF SalesHeaderL.FindFirst() THEN begin
                                RegisterPick.SetSalesOrder(SalesHeaderL);
                                if RegisterPick.Run() then;
                            END;
                        until ProcessBulkL.Next() = 0;
                end;
            }
            action("Update missing Gen. Posting Group on Sales Order")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = ProjectExpense;
                ToolTip = 'To resolve Gen. Product posting group missing error for G/L Account on Sales Order';

                trigger OnAction();
                var
                    SalesLinL: Record "Sales Line";
                    ProcessBulkL: Record ProcessBulkRecord;
                    GLAccL: Record "G/L Account";
                begin
                    ProcessBulkL.Reset();
                    ProcessBulkL.SetRange(Processed, false);
                    if ProcessBulkL.FindSet() then
                        repeat
                            SalesLinL.Reset();
                            SalesLinL.SetRange("Document Type", SalesLinL."Document Type"::Order);
                            SalesLinL.SetRange("Document No.", ProcessBulkL."Order No.");
                            SalesLinL.SetRange(Type, SalesLinL.Type::"G/L Account");
                            SalesLinL.SetRange("Quantity Shipped", 0);
                            SalesLinL.SetRange("Gen. Prod. Posting Group", '');
                            if SalesLinL.FindSet() then
                                repeat
                                    GLAccL.Reset();
                                    if GLAccL.Get(SalesLinL."No.") then begin
                                        if GLAccL."Gen. Prod. Posting Group" <> '' then begin
                                            SalesLinL.SetHideValidationDialog(true);
                                            SalesLinL.SuspendStatusCheck(true);
                                            SalesLinL.Validate("Gen. Prod. Posting Group", GLAccL."Gen. Prod. Posting Group");
                                            SalesLinL.Modify(true);
                                        end;
                                    end;
                                until SalesLinL.Next() = 0;
                        until ProcessBulkL.Next() = 0;
                    Message('Posting Group updated on Sales Orders.');
                    CurrPage.Update();
                end;
            }
        }
    }
}