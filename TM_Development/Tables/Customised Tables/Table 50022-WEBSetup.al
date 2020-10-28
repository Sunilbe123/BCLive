table 50022 "WEB Setup"
{
    // version RM 05112015,R4424,R4561,R4622

    // RM - 05.11.2015
    // Added Credit Memo Discount Account and Returns Location
    // 
    // R4424 - RM - 13.1.2015
    // Added fields: -
    // 15 Error Start Date    Date
    // 16 Show Inserts only   Boolean
    // 
    // R4561 - RM - 09.02.2016
    // Added Default Customer
    CaptionML = ENU = 'WEB Setup', ENG = 'WEB Setup';

    fields
    {
        field(1; "Code"; Code[10])
        {
            CaptionML = ENU = 'Code', ENG = 'Code';
        }
        field(2; "WEB Customer Template"; Code[20])
        {
            CaptionML = ENU = 'WEB Customer Template', ENG = 'WEB Customer Template';
            TableRelation = "Customer Template";
        }
        field(3; "WB Guest Customer Nos"; Code[20])
        {
            CaptionML = ENU = 'WB Guest Customer Nos', ENG = 'WB Guest Customer Nos';
            TableRelation = "No. Series";
        }
        field(4; "WEB Item Template"; Code[20])
        {
            CaptionML = ENU = 'WEB Item Template', ENG = 'WEB Item Template';
            TableRelation = "Config. Template Header" WHERE ("Table ID" = CONST (27));
        }
        field(5; "Payment Journal Template"; Code[20])
        {
            CaptionML = ENU = 'Payment Journal Template', ENG = 'Payment Journal Template';
            TableRelation = "Gen. Journal Template".Name;
        }
        field(6; "Payment Journal Batch"; Code[20])
        {
            CaptionML = ENU = 'Payment Journal Batch', ENG = 'Payment Journal Batch';
            TableRelation = "Gen. Journal Batch".Name WHERE ("Journal Template Name" = FIELD ("Payment Journal Template"));
        }
        field(7; "Shipping and Handling Code"; Code[20])
        {
            CaptionML = ENU = 'Shipping and Handling Code', ENG = 'Shipping and Handling Code';
            TableRelation = "G/L Account";
        }
        field(8; "Receive Stock on Cr. Memo"; Boolean)
        {
            CaptionML = ENU = 'Receive Stock on Cr. Memo', ENG = 'Receive Stock on Cr. Memo';
        }
        field(9; "Order Variance Tolerance"; Decimal)
        {
            CaptionML = ENU = 'Order Variance Tolerance', ENG = 'Order Variance Tolerance';
        }
        field(10; "Credit Memo Discount Account"; Code[20])
        {
            CaptionML = ENU = 'Credit Memo Discount Account', ENG = 'Credit Memo Discount Account';
            Description = 'RM 05.11.2015';
            TableRelation = "G/L Account"."No.";
        }
        field(11; "Returns Location"; Code[10])
        {
            CaptionML = ENU = 'Returns Location', ENG = 'Returns Location';
            Description = 'RM 05.11.2015';
            TableRelation = Location;
        }
        field(12; "Last Item Ledg. Entry"; Integer)
        {
            CaptionML = ENU = 'Last Item Ledg. Entry', ENG = 'Last Item Ledg. Entry';
        }
        field(13; "Order Status Update"; Date)
        {
            CaptionML = ENU = 'Order Status Update', ENG = 'Order Status Update';
        }
        field(14; "Order Status Update DateTime"; DateTime)
        {
            CaptionML = ENU = 'Order Status Update DateTime', ENG = 'Order Status Update DateTime';
        }
        field(15; "Error Start Date"; DateTime)
        {
            CaptionML = ENU = 'Error Start Date', ENG = 'Error Start Date';
            Description = 'R4424';
        }
        field(16; "Show Inserts only"; Boolean)
        {
            CaptionML = ENU = 'Show Inserts only', ENG = 'Show Inserts only';
            Description = 'R4424';
        }
        field(17; "Default Customer"; Code[20])
        {
            CaptionML = ENU = 'Default Customer', ENG = 'Default Customer';
            Description = 'R4561';
            TableRelation = Customer;
        }
        field(18; "Alert Email From Address"; Text[250])
        {
            CaptionML = ENU = 'Alert Email From Address', ENG = 'Alert Email From Address';
            Description = 'R4622';
        }
        field(19; "Stock Write Off Batch"; Code[20])
        {
            CaptionML = ENU = 'Stock Write Off Batch', ENG = 'Stock Write Off Batch';
            TableRelation = "Item Journal Batch".Name WHERE ("Journal Template Name" = const ('ITEM'));
        }
        field(20; "Stock Write Reason Code"; Code[20])
        {
            CaptionML = ENU = 'Stock Write Reason Code', ENG = 'Stock Write Reason Code';
            TableRelation = "Reason Code";
        }
        field(21; "Web Location"; Code[10])
        {
            CaptionML = ENU = 'Web Location', ENG = 'Web Location';
            Description = 'MITL';
            TableRelation = Location;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

