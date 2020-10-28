pageextension 50049 CustLedgerEntry extends "Customer Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field(WebIncrementID; WebIncrementID)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Document Date"; "Document Date")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            /*field("Customer Name"; "Customer Name")//Already defined in bease app
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                //MITL.SM.20200210 Point 38

            }*/
        }
        addafter(Amount)
        {
            field("Invoice Disc. Avail on Customer"; "Invoice Disc. Avail on Customer")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';    //MITL_W&F
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