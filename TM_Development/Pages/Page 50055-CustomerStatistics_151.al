page 50055 CustomerStatistics
{
    PageType = List;
    Caption = 'Customer Statistics';
    UsageCategory = Tasks;
    SourceTable = Customer;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Customer No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Customer Name"; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Payment Terms"; "Payment Terms Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Balance (LCY)"; "Balance (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Outstanding Orders (LCY)"; "Outstanding Orders (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shipped Not Invoiced (LCY)"; "Shipped Not Invoiced (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Outstanding Invoices (LCY)"; "Outstanding Invoices (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Outstanding Serv. Orders (LCY)"; "Outstanding Serv. Orders (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Serv Shipped Not Invoiced(LCY)"; "Serv Shipped Not Invoiced(LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Outstanding Serv.Invoices(LCY)"; "Outstanding Serv.Invoices(LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Credit Limit (LCY)"; "Credit Limit (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    actions
    {
    }

    var
        myInt: Integer;

}