pageextension 50089 BankAccountListExt extends "Bank Account List"
{
    layout
    {
        // Add changes to page layout here
        addafter("Language Code")
        {
            field(Balance; Balance)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Balance (LCY)"; "Balance (LCY)")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Net Change"; "Net Change")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Net Change (LCY)"; "Net Change (LCY)")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }

            field("Balance at Date"; "Balance at Date")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Balance at Date (LCY)"; "Balance at Date (LCY)")
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