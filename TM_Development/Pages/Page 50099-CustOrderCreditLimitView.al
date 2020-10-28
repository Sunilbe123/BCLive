page 50099 CustOrderCreditLimitView
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Sales Header";
    SourceTableView = where(Status = const("Pending Approval"));
    Caption = 'Customer Credit Pending Approval Orders';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order Date"; "Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Customer Name"; CustomerG.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order Amount"; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order Online Paymemnt"; "Order Online Paymemnt")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Customer Credit Limit"; "Customer Credit Limit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Available Credit Limit"; CustomerG.CalcAvailableCredit())
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }

        }

    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';

                trigger OnAction()
                begin

                end;
            }
        }
    }


    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        IF CustomerG.Get("Sell-to Customer No.") THEN;

        ApprovalEntryG.Reset();
        ApprovalEntryG.SetRange("Table ID", 36);
        ApprovalEntryG.SetRange("Document Type", "Document Type");
        ApprovalEntryG.SetRange("Document No.", "No.");
        ApprovalEntryG.SetRange(Status, ApprovalEntryG.Status::Open);
        IF ApprovalEntryG.FindFirst() then
            ApproverIDG := ApprovalEntryG."Approver ID";
    end;

    var
        CustomerG: Record Customer;
        ApprovalEntryG: Record "Approval Entry";
        ApproverIDG: Text[50];

}