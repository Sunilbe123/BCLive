table 50018 "WEB Credit Header"
{
    // version R4561,R4564

    // R4561 - RM - 10.02.2016
    // Added key "Index No."
    // 
    // R4564 - RM - 14.02.2016
    // Added key "Order ID"

    CaptionML = ENU = 'WEB Credit Header', ENG = 'WEB Credit Header';

    DrillDownPageID = "WEB Credit List";
    LookupPageID = "WEB Credit List";

    fields
    {
        field(1; "Credit Memo Date"; Date)
        {
            CaptionML = ENU = 'Credit Memo Date', ENG = 'Credit Memo Date';
        }
        field(2; "Credit Memo ID"; Text[100])
        {
            CaptionML = ENU = 'Credit Memo ID', ENG = 'Credit Memo ID';
        }
        field(3; Store; Text[100])
        {
            CaptionML = ENU = 'Store', ENG = 'Store';
        }
        field(4; "Shipping Method"; Text[100])
        {
            CaptionML = ENU = 'Shipping Method', ENG = 'Shipping Method';
        }
        field(5; "Shipping Description"; Text[250])
        {
            CaptionML = ENU = 'Shipping Description', ENG = 'Shipping Description';
        }
        field(6; "Discount Code"; Text[100])
        {
            CaptionML = ENU = 'Discount Code', ENG = 'Discount Code';
        }
        field(7; Subtotal; Decimal)
        {
            CaptionML = ENU = 'Subtotal', ENG = 'Subtotal';
        }
        field(8; "Shipping & Handling"; Decimal)
        {
            CaptionML = ENU = 'Shipping & Handling', ENG = 'Shipping & Handling';
        }
        field(9; "Discount Amount"; Decimal)
        {
            CaptionML = ENU = 'Discount Amount', ENG = 'Discount Amount';
        }
        field(10; VAT; Decimal)
        {
            CaptionML = ENU = 'VAT', ENG = 'VAT';
        }
        field(11; "Grand Total"; Decimal)
        {
            CaptionML = ENU = 'Grand Total', ENG = 'Grand Total';
        }
        field(12; "Customer Comments"; Text[100])
        {
            CaptionML = ENU = 'Customer Comments', ENG = 'Customer Comments';
        }
        field(13; "Payment Method"; Text[100])
        {
            CaptionML = ENU = 'Payment Method', ENG = 'Payment Method';
        }
        field(14; "Customer ID"; Code[20])
        {
            CaptionML = ENU = 'Customer ID', ENG = 'Customer ID';
        }
        field(15; "Customer Email"; Text[100])
        {
            CaptionML = ENU = 'Customer Email', ENG = 'Customer Email';
        }
        field(16; "Order ID"; Text[100])
        {
            CaptionML = ENU = 'Order ID', ENG = 'Order ID';
        }
        field(17; "Adjustment Refund Amount"; Decimal)
        {
            CaptionML = ENU = 'Adjustment Refund Amount', ENG = 'Adjustment Refund Amount';
        }
        field(18; "Adjustment Fee Amount"; Decimal)
        {
            CaptionML = ENU = 'Adjustment Fee Amount', ENG = 'Adjustment Fee Amount';
        }
        field(19; "LineType"; Option)
        {
            CaptionML = ENU = 'Type', ENG = 'Type';
            OptionMembers = Insert,Modify,Delete;
        }
        field(20; "Date Time"; DateTime)
        {
            CaptionML = ENU = 'DateTime', ENG = 'DateTime';
        }
        field(21; "Index No."; Code[20])
        {
            CaptionML = ENU = 'Index No.', ENG = 'Index No.';
        }
        field(22; "Shipment ID"; Text[30])
        {
            CaptionML = ENU = 'Shipment ID', ENG = 'Shipment ID';
        }
        field(23; Receipted2; DateTime)
        {
            CaptionML = ENU = 'Receipted2', ENG = 'Receipted2';
        }
        field(50000; "Dimension Code"; Code[20])
        {
            CaptionML = ENU = 'Dimension Code', ENG = 'Dimension Code';
            Description = 'Business Channel Dimension';
        }
        field(50001; "Customer Order No."; Text[50])
        {
            CaptionML = ENU = 'Your Reference', ENG = 'Your Reference';
            Description = 'Customer Order No.';
        }
    }

    keys
    {
        key(Key1; "Credit Memo ID", "LineType", "Date Time")
        {
        }
        key(Key2; "Index No.")
        {
        }
        key(Key3; "Order ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Index No." := WF.InsertIndex(50018, "Credit Memo ID", FORMAT("LineType"), FORMAT("Date Time"), '', '', "Order ID");
        Receipted2 := CURRENTDATETIME;
        "Customer Email" := LOWERCASE("Customer Email");
    end;

    var
        WF: Codeunit "WEB Functions";
}

