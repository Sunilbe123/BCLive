tableextension 50059 SalesCrMemoHead extends "Sales Cr.Memo Header"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Payment Created"; Boolean)
        {
            Description = 'R1548';
            CaptionML = ENU = 'Payment Created', ENG = 'Payment Created';
        }
        field(50001; "Latest Dispatch Date"; Date)
        {
            Description = 'MITL332';
            FieldClass = FlowField;
            CalcFormula = Lookup ("WEB Order Header"."Latest Dispatch Date" WHERE ("Order ID" = FIELD (WebOrderID)));
        }
        field(50010; "Import Sell-to Cust. Name"; Text[60])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Sell-to Cust. Name', ENG = 'Import Sell-to Cust. Name';
        }

        field(50020; "Import Sell-to Address"; Text[130])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Sell-to Address', ENG = 'Import Sell-to Address';
        }
        field(50030; "Import Sell-to Address 2"; Text[80])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Sell-to Address 2', ENG = 'Import Sell-to Address 2';
        }
        field(50040; "Import Sell-to City"; Text[30])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Sell-to Address', ENG = 'Import Sell-to Address';
        }
        field(50050; "Import Sell-to County"; Text[30])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Sell-to County', ENG = 'Import Sell-to County';
        }
        field(50060; "Import Sell-to Post Code"; Text[18])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Sell-to Post Code', ENG = 'Import Sell-to Post Code';
        }
        field(50080; "Import Bill-to Name"; Text[60])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Bill-to Name', ENG = 'Import Bill-to Name';
        }

        field(50090; "Import Bill-to Address"; Text[130])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Bill-to Address', ENG = 'Import Bill-to Address';
        }
        field(50100; "Import Bill-to Address 2"; Text[80])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Bill-to Address 2', ENG = 'Import Bill-to Address 2';
        }
        field(50110; "Import Bill-to City"; Text[30])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Bill-to City', ENG = 'Import Bill-to City';
        }
        field(50120; "Import Bill-to County"; Text[30])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Bill-to County', ENG = 'Import Bill-to County';
        }
        field(50130; "Import Bill-to Post Code"; Text[18])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Bill-to Post Code', ENG = 'Import Bill-to Post Code';
        }
        field(50150; "Import Ship-to Name"; Text[60])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Ship-to Name', ENG = 'Import Ship-to Name';
        }

        field(50160; "Import Ship-to Address"; Text[130])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Ship-to Address', ENG = 'Import Ship-to Address';
        }
        field(50170; "Import Ship-to Address 2"; Text[80])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Ship-to Address 2', ENG = 'Import Ship-to Address 2';
        }
        field(50180; "Import Ship-to City"; Text[30])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Ship-to City', ENG = 'Import Ship-to City';
        }
        field(50190; "Import Ship-to County"; Text[30])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Ship-to County', ENG = 'Import Ship-to County';
        }
        field(50200; "Import Ship-to Post Code"; Text[18])
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Ship-to Post Code', ENG = 'Import Ship-to Post Code';
        }
        field(50220; "Import Synched"; Boolean)
        {
            Description = 'R1671';
            CaptionML = ENU = 'Import Synched', ENG = 'Import Synched';
        }
        field(50021; WebIncrementID; Text[30])
        {
            Description = 'R1518';
            InitValue = '0';
        }
        field(50022; WebOrderID; Text[30])
        {
            Description = 'R1518';
            InitValue = '0';
        }
        field(50034; WebCustomerFlag; Boolean)
        {
            Description = 'R1518';
        }
        field(50035; WebCustomerGender; Code[30])
        {
            Description = 'R1518';
        }
        field(50036; WebCustomerGroup; Code[100])
        {
            Description = 'R1518';
        }
        field(50037; WebSiteCode; Text[100])
        {
            Description = 'R1518';
        }
        field(50038; WebCustomerID; Text[30])
        {
            Description = 'R1518';
            InitValue = '0';
        }
        field(50039; WebBillToAddressID; Text[30])
        {
            Description = 'R1518';
        }
        field(50041; WebSyncFlag; Code[1])
        {
            Description = 'R1518';
        }
        field(50042; "PDF Created"; Boolean)
        {
            Description = 'MITL_VS_PDF_20200612';
            CaptionML = ENG = 'PDF Created', ENU = 'PDF Created';
        }
    }

    var
        myInt: Integer;
}