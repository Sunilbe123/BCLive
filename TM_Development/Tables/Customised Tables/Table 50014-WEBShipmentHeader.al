table 50014 "WEB Shipment Header"
{
    // version RM 19082015,R4359,R4561

    // R4359 - RM - 18.12.2015
    // Added key Customer Email
    // 
    // R4561 - RM - 10.02.2016
    // Added key "Index No."
    CaptionML = ENU = 'WEB Shipment Header', ENG = 'WEB Shipment Header';

    DrillDownPageID = "WEB Shipment List";
    LookupPageID = "WEB Shipment List";

    fields
    {
        field(1; "Shipment Date"; Date)
        {
            CaptionML = ENU = 'Shipment Date', ENG = 'Shipment Date';
        }
        field(2; "Shipment ID"; Text[100])
        {
            CaptionML = ENU = 'Shipment ID', ENG = 'Shipment ID';
        }
        field(3; Store; Text[100])
        {
            CaptionML = ENU = 'Store', ENG = 'Store';
        }
        field(4; "Order ID"; Text[100])
        {
            CaptionML = ENU = 'Order ID', ENG = 'Order ID';
        }
        field(5; "Shipping Method"; Text[100])
        {
            CaptionML = ENU = 'Shipping Method', ENG = 'Shipping Method';
        }
        field(6; "Shipping Description"; Text[250])
        {
            CaptionML = ENU = 'Shipping Description', ENG = 'Shipping Description';
        }
        field(7; "Discount Code"; Text[100])
        {
            CaptionML = ENU = 'Discount Code', ENG = 'Discount Code';
        }
        field(8; Subtotal; Decimal)
        {
            CaptionML = ENU = 'Subtotal', ENG = 'Subtotal';
        }
        field(9; "Shipping & Handling"; Decimal)
        {
            CaptionML = ENU = 'Shipping & Handling', ENG = 'Shipping & Handling';
        }
        field(10; "Discount Amount"; Decimal)
        {
            CaptionML = ENU = 'Discount Amount', ENG = 'Discount Amount';
        }
        field(11; VAT; Decimal)
        {
            CaptionML = ENU = 'VAT', ENG = 'VAT';
        }
        field(12; "Grand Total"; Decimal)
        {
            CaptionML = ENU = 'Grand Total', ENG = 'Grand Total';
        }
        field(13; "Customer Comments"; Text[100])
        {
            CaptionML = ENU = 'Customer Comments', ENG = 'Customer Comments';
        }
        field(14; "Payment Method"; Text[100])
        {
            CaptionML = ENU = 'Payment Method', ENG = 'Payment Method';
        }
        field(15; "Customer ID"; Code[20])
        {
            CaptionML = ENU = 'Customer ID', ENG = 'Customer ID';
        }
        field(16; "Customer Email"; Text[100])
        {
            CaptionML = ENU = 'Customer Email', ENG = 'Customer Email';
        }
        field(17; "Tracking Carrier"; Text[100])
        {
            CaptionML = ENU = 'Tracking Carrier', ENG = 'Tracking Carrier';
        }
        field(18; "Tracking Number"; Text[100])
        {
            CaptionML = ENU = 'Tracking Number', ENG = 'Tracking Number';
        }
        field(19; Weight; Decimal)
        {
            CaptionML = ENU = 'Weight', ENG = 'Weight';
        }
        field(20; "LineType"; Option)
        {
            CaptionML = ENU = 'Type', ENG = 'Type';
            OptionMembers = Insert,Modify,Delete;
        }
        field(21; "Date Time"; DateTime)
        {
            CaptionML = ENU = 'DateTime', ENG = 'DateTime';
        }
        field(22; "Index No."; Code[20])
        {
            CaptionML = ENU = 'Index No.', ENG = 'Index No.';
        }
        field(23; "Order Exists"; Boolean)
        {
            CaptionML = ENU = 'Order Exists', ENG = 'Order Exists';
            CalcFormula = Exist ("WEB Order Header" WHERE ("Order ID" = FIELD ("Order ID")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(24; "Shipment Count"; Integer)
        {
            CaptionML = ENU = 'Shipment Count', ENG = 'Shipment Count';
            CalcFormula = Count ("WEB Shipment Header" WHERE ("Shipment ID" = FIELD ("Shipment ID")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(25; Receipted; DateTime)
        {
            CaptionML = ENU = 'Receipted', ENG = 'Receipted';
        }
    }

    keys
    {
        key(Key1; "Shipment ID", "LineType", "Date Time")
        {
        }
        key(Key2; "Customer Email")
        {
        }
        key(Key3; "Index No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Index No." := WF.InsertIndex(50014, "Shipment ID", FORMAT("LineType"), FORMAT("Date Time"), '', '', "Order ID");
        Receipted := CURRENTDATETIME;
        "Customer Email" := LOWERCASE("Customer Email");
    end;

    var
        WF: Codeunit "WEB Functions";
}

