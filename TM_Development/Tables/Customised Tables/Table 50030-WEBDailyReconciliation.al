table 50030 "WEB Daily Reconciliation"
{
    // version R4540,R4580

    // R4540 - RM - 04.02.2016
    // Added field "Deleted by Credit Memo"
    // 
    // R4580 - RM - 14.02.2016
    // Added field "Cancelled Order"
    CaptionML = ENU = 'WEB Daily Reconciliation', ENG = 'WEB Daily Reconciliation';
    DrillDownPageID = "WEB Daily Reconciliation";
    LookupPageID = "WEB Daily Reconciliation";

    fields
    {
        field(1; "WEB Type"; Option)
        {
            CaptionML = ENU = 'Type', ENG = 'Type';
            OptionMembers = "Order",Shipment,Credit;
        }
        field(2; ID; Code[20])
        {
            CaptionML = ENU = 'ID', ENG = 'ID';
        }
        field(3; "WEB Value"; Decimal)
        {
            CaptionML = ENU = 'Value', ENG = 'Value';
        }
        field(4; "WEB Date"; Date)
        {
            CaptionML = ENU = 'Date', ENG = 'Date';
        }
        field(5; Invoiced; Boolean)
        {
            CaptionML = ENU = 'Invoiced', ENG = 'Invoiced';
        }
        field(6; "Invoiced Value"; Decimal)
        {
            CaptionML = ENU = 'Invoiced Value', ENG = 'Invoiced Value';
        }
        field(7; "Reconciliation Complete"; Boolean)
        {
            CaptionML = ENU = 'Reconciliation Complete', ENG = 'Reconciliation Complete';
        }
        field(8; Error; Boolean)
        {
            CaptionML = ENU = 'Error', ENG = 'Error';
        }
        field(9; Ordered; Boolean)
        {
            CaptionML = ENU = 'Ordered', ENG = 'Ordered';
        }
        field(10; "Ordered Value"; Decimal)
        {
            CaptionML = ENU = 'Ordered Value', ENG = 'Ordered Value';
        }
        field(11; "Shipment Created"; Boolean)
        {
            CaptionML = ENU = 'Shipment Created', ENG = 'Shipment Created';
        }
        field(12; "Shipment Quantities"; Decimal)
        {
            CaptionML = ENU = 'Shipment Quantities', ENG = 'Shipment Quantities';
        }
        field(13; "Shipment Quantities - Magento"; Decimal)
        {
            CaptionML = ENU = 'Shipment Quantities - Magento', ENG = 'Shipment Quantities - Magento';
        }
        field(14; "Further Information"; Text[20])
        {
            CaptionML = ENU = 'Further Information', ENG = 'Further Information';
        }
        field(15; "Deleted by Credit Memo"; Boolean)
        {
            CaptionML = ENU = 'Deleted by Credit Memo', ENG = 'Deleted by Credit Memo';
            Description = 'R4540';
        }
        field(16; "Cancelled Order"; Boolean)
        {
            CaptionML = ENU = 'Cancelled Order', ENG = 'Cancelled Order';
            Description = 'R4580';
        }
    }

    keys
    {
        key(Key1; "WEB Type", ID, "WEB Date")
        {
        }
    }

    fieldgroups
    {
    }
}

