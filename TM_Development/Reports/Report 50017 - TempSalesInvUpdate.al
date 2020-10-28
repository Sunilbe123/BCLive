report 50017 UpdateYourRefInSaleInv
{
    UsageCategory = Administration;
    ApplicationArea = All;
    Permissions = TableData "Sales Invoice Header" = RIMD;
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            column(No_; "No.")
            {

            }
            trigger OnPreDataItem()
            var
            begin
                IF "Sales Invoice Header".GET(SalesInvNoG) then begin
                    "Sales Invoice Header"."Your Reference" := YourRefG;
                    "Sales Invoice Header".Modify();
                end Else
                    exit;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
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

    procedure SetInvoiceNo(SaleInvNo: Code[20]; YourRefL: Text[100])
    var
        myInt: Integer;
    begin
        SalesInvNoG := SaleInvNo;
        YourRefG := YourRefL;
    end;

    var
        SalesInvNoG: Code[20];
        YourRefG: Text[100];
}