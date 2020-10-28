pageextension 50094 VendorLedgerEntriesExt extends "Vendor Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter("Document Type")
        {
            field("Document Date"; "Document Date")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            /*field("Vendor Name"; "Vendor Name")//Already defined in base app
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                //MITL.SM.20200210 Point 38
            }*/

        }
        addafter("Vendor No.")
        {
            field("Buy-from Vendor No."; "Buy-from Vendor No.")
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