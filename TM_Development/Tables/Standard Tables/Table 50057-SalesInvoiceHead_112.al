tableextension 50057 SalesInvoiceHead extends "Sales Invoice Header"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Payment Created"; Boolean)
        {
            Description = 'R1548';
        }
        field(50002; "Cut Size To-Do"; Code[20])
        {
            CaptionML = ENU = 'Cut Size To-Do', ENG = 'Cut Size To-Do';
        }
        field(50010; "Import Sell-to Cust. Name"; Text[60])
        {
            CaptionML = ENU = 'Import Sell-to Cust. Name', ENG = 'Import Sell-to Cust. Name';
            Description = 'R1671';
        }
        field(50020; "Import Sell-to Address"; Text[130])
        {
            CaptionML = ENU = 'Import Sell-to Address', ENG = 'Import Sell-to Address';
            Description = 'R1671';
        }
        field(50030; "Import Sell-to Address 2"; Text[80])
        {
            CaptionML = ENU = 'Import Sell-to Address 2', ENG = 'Import Sell-to Address 2';
            Description = 'R1671';
        }
        field(50040; "Import Sell-to City"; Text[30])
        {
            CaptionML = ENU = 'Import Sell-to City', ENG = 'Import Sell-to City';
            Description = 'R1671';
        }
        field(50050; "Import Sell-to County"; Text[30])
        {
            CaptionML = ENU = 'Import Sell-to County', ENG = 'Import Sell-to County';
            Description = 'R1671';
        }
        field(50060; "Import Sell-to Post Code"; Text[18])
        {
            CaptionML = ENU = 'Import Sell-to Post Code', ENG = 'Import Sell-to Post Code';
            Description = 'R1671';
        }
        field(50080; "Import Bill-to Name"; Text[60])
        {
            CaptionML = ENU = 'Import Bill-to Name', ENG = 'Import Bill-to Name';
            Description = 'R1671';
        }
        field(50090; "Import Bill-to Address"; Text[130])
        {
            CaptionML = ENU = 'Import Bill-to Address', ENG = 'Import Bill-to Address';
            Description = 'R1671';
        }
        field(50100; "Import Bill-to Address 2"; Text[80])
        {
            CaptionML = ENU = 'Import Bill-to Address 2', ENG = 'Import Bill-to Address 2';
            Description = 'R1671';
        }
        field(50110; "Import Bill-to City"; Text[30])
        {
            CaptionML = ENU = 'Import Bill-to City', ENG = 'Import Bill-to City';
            Description = 'R1671';
        }
        field(50120; "Import Bill-to County"; Text[30])
        {
            CaptionML = ENU = 'Import Bill-to County', ENG = 'Import Bill-to County';
            Description = 'R1671';
        }
        field(50130; "Import Bill-to Post Code"; Text[18])
        {
            CaptionML = ENU = 'Import Bill-to Post Code', ENG = 'Import Bill-to Post Code';
            Description = 'R1671';
        }
        field(50150; "Import Ship-to Name"; Text[60])
        {
            CaptionML = ENU = 'Import Ship-to Name', ENG = 'Import Ship-to Name';
            Description = 'R1671';
        }
        field(50160; "Import Ship-to Address"; Text[130])
        {
            CaptionML = ENU = 'Import Ship-to Address', ENG = 'Import Ship-to Address';
            Description = 'R1671';
        }
        field(50170; "Import Ship-to Address 2"; Text[80])
        {
            CaptionML = ENU = 'Import Ship-to Address 2', ENG = 'Import Ship-to Address 2';
            Description = 'R1671';
        }
        field(50180; "Import Ship-to City"; Text[30])
        {
            CaptionML = ENU = 'Import Ship-to City', ENG = 'Import Ship-to City';
            Description = 'R1671';
        }
        field(50190; "Import Ship-to County"; Text[30])
        {
            CaptionML = ENU = 'Import Ship-to County', ENG = 'Import Ship-to County';
            Description = 'R1671';
        }
        field(50200; "Import Ship-to Post Code"; Text[18])
        {
            CaptionML = ENU = 'Import Ship-to Post Code', ENG = 'Import Ship-to Post Code';
            Description = 'R1671';
        }
        field(50220; "Import Synched"; Boolean)
        {
            CaptionML = ENU = 'Import Synched', ENG = 'Import Synched';
            Description = 'R1671';
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
        field(50023; WebSyncFlag; code[1])
        {
            Description = 'R1518';
        }
        field(50024; WebOrderFlag; Boolean)
        {
            Description = 'R1518';
        }
        field(50025; "Web Payment Transaction Id"; Text[30])
        {
            Description = 'R1518';
        }
        field(50026; "Web Shipment Tracing No."; Text[30])
        {
            Description = 'R1518';
        }
        field(50027; "Web Shipment Carrier"; Text[30])
        {
            Description = 'R1518';
        }
        field(50028; "Web Payment Method Code"; Text[30])
        {
            Description = 'R1518';
        }
        field(50029; "Web Shipment Increment Id"; Text[30])
        {
            Description = 'R1518';
        }
        field(50031; "Web Invoice Increment Id"; Text[30])
        {
            Description = 'R1518';
        }
        field(50042; "PDF Created"; Boolean)
        {
            Description = 'MITL_VS_PDF_20200612';
            CaptionML = ENG = 'PDF Created', ENU = 'PDF Created';
        }
    }
    keys
    {
        key(Key2; WebIncrementID)
        {
            Description = 'MITL.AJ.20200603 Indexing correction';
        }
    }

    var
        myInt: Integer;
}