pageextension 50098 BankAccLedgerEntries extends "Bank Account Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter("Entry No.")
        {
            field(WebIncrementID; WebIncrementID)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }

        modify(Open)
        {
            Visible = true;
        }

        addafter(Open)
        {
            field("External Document No."; "External Document No.")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }

        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}