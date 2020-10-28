table 50028 "WEB Reconciliation"
{
    CaptionML = ENU = 'WEB Reconciliation', ENG = 'WEB Reconciliation';

    fields
    {
        field(1; "Reconciliation Date"; Date)
        {
            CaptionML = ENU = 'Date', ENG = 'Date';
        }
        field(2; "Sales Order ID"; Code[20])
        {
            CaptionML = ENU = 'Sales Order ID', ENG = 'Sales Order ID';
        }
        field(3; "Total Order Value"; Decimal)
        {
            CaptionML = ENU = 'Total Order Value', ENG = 'Total Order Value';
        }
        field(4; "Sales Shipment ID"; Code[20])
        {
            CaptionML = ENU = 'Sales Shipment ID', ENG = 'Sales Shipment ID';
        }
        field(5; "Total Quantity Shipped"; Decimal)
        {
            CaptionML = ENU = 'Total Quantity Shipped', ENG = 'Total Quantity Shipped';
        }
        field(6; "Sales Credit Memo ID"; Code[20])
        {
            CaptionML = ENU = 'Sales Credit Memo ID', ENG = 'Sales Credit Memo ID';
        }
        field(7; "Total Credit Value"; Decimal)
        {
            CaptionML = ENU = 'Total Credit Value', ENG = 'Total Credit Value';
        }
    }

    keys
    {
        key(Key1; "Reconciliation Date")
        {
        }
    }

    fieldgroups
    {
    }
}

