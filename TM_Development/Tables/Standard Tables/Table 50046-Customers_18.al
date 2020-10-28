tableextension 50046 CustomerExt extends Customer
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Customer ID"; Text[100])
        {
            Description = 'R1671';
        }
        field(50000; "Import Name"; Text[100])
        {
            Description = 'R1671';
        }
        field(50010; "Import Address"; Text[150])
        {
            Description = 'R1671';
        }
        field(50020; "Import Address 2"; Text[150])
        {
            Description = 'R1671';
        }
        field(50030; "Import City"; Text[100])
        {
            Description = 'R1671';
        }
        field(50040; "Import County"; Text[100])
        {
            Description = 'R1671';
        }
        field(50050; "Import Post Code"; Text[100])
        {
            Description = 'R1671';
        }
        field(50060; "Import Phone No."; Text[100])
        {
            Description = 'R1671';
        }
        field(50070; "Import Search Name"; Text[100])
        {
            Description = 'R1671';
        }
        field(50080; "Import Email"; Text[100])
        {
            Description = 'R1671';
        }
        field(50090; "Import Synched"; Boolean)
        {
            Description = 'R1671';
        }
        field(50110; "WebCustomerFlag"; Boolean)
        {
            Description = 'INS1.1';
        }
        field(50120; "WebCustomerGender"; Code[30])
        {
            Description = 'INS1.1';
        }
        field(50130; "WebCustomerGroup"; Code[100])
        {
            Description = 'INS1.1';
        }
        field(50140; "WebSiteCode"; Text[100])
        {
            Description = 'INS1.1';
        }
        field(50150; "WebCustomerID"; Text[30])
        {
            Description = 'INS1.1';
        }
        field(50160; "WebBillToAddressID"; Text[30])
        {
            Description = 'INS1.1';
        }
        field(50170; "WebSyncFlag"; Code[1])
        {
            Description = 'INS1.1';
        }
        field(50180; "WebCustomerGuestID"; Text[30])
        {
            Description = 'INS1.1';
        }
        field(50190; "IsWebGuest"; Boolean)
        {
            Description = 'INS1.1';
        }

        field(50200; "Invoice Disc. Facility Availed"; Boolean)
        {
            CaptionML = ENU = 'Invoice Disc. Facility Availed', ENG = 'Invoice Disc. Facility Availed'; //MITL.SP.W&F
        }

        field(50210; "Statement/Reminder"; Option)
        {
            CaptionML = ENU = 'Statement/Reminder', ENG = 'Statement/Reminder'; //MITL.SP.W&F
            OptionMembers = " ",Email,Print;
            OptionCaptionML = ENU = ' ,Email,Print', ENG = ' ,Email,Print';
        }

        field(50220; "Invoice/Cr. Memo"; Option)
        {
            CaptionML = ENU = 'Invoice/Cr. Memo', ENG = 'Invoice/Cr. Memo'; //MITL.SP.W&F
            OptionMembers = " ",Email,Print;
            OptionCaptionML = ENU = ' ,Email,Print', ENG = ' ,Email,Print';
        }
        //MITL_MF_5480 ++
        field(50230; "Wholesale Customer"; Boolean)
        {
            CaptionML = ENU = 'Wholesale Customer', ENG = 'Wholesale Customer';
        }
        //MITL_MF_5480--

        //MITL.7403++
        field(50240; "Company Registration No."; Text[25])
        {
            CaptionML = ENG = 'Company Registration No.', ENU = 'Company Registration No.';
            trigger OnValidate()
            begin
                "Company Registration No." := UpperCase("Company Registration No.");
            end;
        }
        //MITL.7403--
    }

    var
        myInt: Integer;
}