pageextension 50037 CustomerCard extends "Customer Card"
{
    layout
    {
        // Add changes to page layout here
        /*addafter(Name)//Already Defined in Base App
        {
            field("Name 2"; "Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL3895';
            }
        }*/

        addafter("Credit Limit (LCY)")
        {
            field("Invoice Disc. Facility Availed"; "Invoice Disc. Facility Availed")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }//MITL.SP.W&F
            field("Send Statement/Reminder"; "Statement/Reminder")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }//MITL.SP.W&F
            field("Send Invoice/Cr. Memo"; "Invoice/Cr. Memo")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }//MITL.SP.W&F
        }

        addafter("Disable Search by Name")
        {
            field("Our Account No."; "Our Account No.") //MITL
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }

        addafter(Invoicing)
        {
            group("Extended Address")
            {
                field("Import Name"; "Import Name") { }
                field("Import Address"; "Import Address") { }
                field("Import Address 2"; "Import Address 2") { }
                field("Import City"; "Import City") { }
                field("Import Post Code"; "Import Post Code") { }
                field("Import Phone No."; "Import Phone No.") { }
            }
        }
        //MITL_MF_5480++
        addafter("Disable Search by Name")
        {
            field("Wholesale Customer"; "Wholesale Customer")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }
        //MITL_MF_5480--
        //MITL.7403++
        addafter("VAT Registration No.")
        {
            field("Company Registration No."; "Company Registration No.")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL.7403';
            }
        }
        //MITL.7403
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}