table 50012 "Posted Pick Audit"
{
    CaptionML = ENU = 'Posted Pick Audit', ENG = 'Posted Pick Audit';

    fields
    {
        field(1; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', ENG = 'Line No.';
            AutoIncrement = true;
        }
        field(2; "Sales Order No."; Code[20])
        {
            CaptionML = ENU = 'Sales Order No.', ENG = 'Sales Order No.';
        }
        field(3; USERID; Code[50])
        {
            CaptionML = ENU = 'USERID', ENG = 'USERID';
        }
        field(4; "Customer Name"; Text[50])
        {
            CaptionML = ENU = 'Customer Name', ENG = 'Customer Name';
            CalcFormula = Lookup (Customer.Name WHERE ("No." = FIELD ("Sell-To Customer No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Sell-To Customer No."; Code[20])
        {
            CaptionML = ENU = 'Sell-To Customer No.', ENG = 'Sell-To Customer No.';
            TableRelation = Customer;
        }
        field(6; WebIncrementID; Text[30])
        {
            CaptionML = ENU = 'WebIncrementID', ENG = 'WebIncrementID';
        }
        field(7; "Date Time"; DateTime)
        {
            CaptionML = ENU = 'Date Time', ENG = 'Date Time';
        }
        field(8; "Magento Complete"; Boolean)
        {
            CaptionML = ENU = 'Magento Complete', ENG = 'Magento Complete';
        }
        field(9; Start; Boolean)
        {
            CaptionML = ENU = 'Start', ENG = 'Start';
        }
        field(10; "Start Time"; Time)
        {
            CaptionML = ENU = 'Start Time', ENG = 'Start Time';
        }
        field(11; "End Time"; Time)
        {
            CaptionML = ENU = 'End Time', ENG = 'End Time';
        }
        field(12; "End DateTime"; DateTime)
        {
            CaptionML = ENU = 'End DateTime', ENG = 'End DateTime';
        }
        field(13; "Sales Shipment Line Exists"; Boolean)
        {
            CaptionML = ENU = 'Sales Shipment Line Exists', ENG = 'Sales Shipment Line Exists';
            CalcFormula = Exist ("Sales Shipment Line" WHERE ("Order No." = FIELD ("Sales Order No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "To Print"; Boolean)
        {
            CaptionML = ENU = 'To Print', ENG = 'To Print';
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

