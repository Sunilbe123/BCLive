table 50010 "WEB Order Header"
{
    // version R4359

    // R4359 - RM - 18.12.2015
    // Added key Customer Email
    //SM_Business Channel - New field created in Web Order Header and Line for passing the value of Business Channel from Magento to NAV Dimensions.s
    CaptionML = ENU = 'WEB Order Header', ENG = 'WEB Order Header';

    DrillDownPageID = "WEB Order List";
    LookupPageID = "WEB Order List";

    fields
    {
        field(1; "Order Date"; Date)
        {
            CaptionML = ENU = 'Order Date', ENG = 'Order Date';
        }
        field(2; "Order ID"; Text[100])
        {
            CaptionML = ENU = 'Order ID', ENG = 'Order ID';
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
        field(16; "LineType"; Option)
        {
            CaptionML = ENU = 'Type', ENG = 'Type';
            OptionMembers = Insert,Modify,Delete;
        }
        field(17; "Date Time"; DateTime)
        {
            CaptionML = ENU = 'DateTime', ENG = 'DateTime';
        }
        field(18; "Index No."; Code[20])
        {
            CaptionML = ENU = 'Index No.', ENG = 'Index No.';
        }
        field(19; Receipted; DateTime)
        {
            CaptionML = ENU = 'Receipted', ENG = 'Receipted';
        }
        field(20; "Picking Notes"; Text[250])
        {
            CaptionML = ENU = 'Picking Notes', ENG = 'Picking Notes';
        }
        field(21; "Combined Pick"; Boolean)
        {
            CaptionML = ENU = 'Combined Pick', ENG = 'Combined Pick';
        }
        field(22; "Latest Dispatch Date"; Date)
        {
            CaptionML = ENU = 'Latest Dispatch Date', ENG = 'Latest Dispatch Date';
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
        key(Key1; "Order ID", "LineType", "Date Time")
        {
        }
        key(Key2; "Customer Email")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Customer Email" := LOWERCASE("Customer Email");
        "Index No." := WF.InsertIndex(50010, "Order ID", FORMAT("LineType"), FORMAT("Date Time"), '', '', "Order ID");
        Receipted := CURRENTDATETIME;
    end;

    var
        WF: Codeunit "WEB Functions";
}

