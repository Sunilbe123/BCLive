table 50006 "Rox Logging"
{
    // version R2675,R2799

    // RM - 09.12.2015
    // Added key WebIncrementID
    CaptionML = ENU = 'Rox Logging', ENG = 'Rox Logging';


    fields
    {
        field(1; "Web Shipment Increment Id"; Text[30])
        {
            CaptionML = ENU = 'Web Shipment Increment Id', ENG = 'Web Shipment Increment Id';
        }
        field(2; WebIncrementID; Text[30])
        {
            CaptionML = ENU = 'WebIncrementID', ENG = 'WebIncrementID';
        }
        field(3; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', ENG = 'Line No.';
        }
        field(4; ItemType; Text[80])
        {
            CaptionML = ENU = 'Type', ENG = 'Type';
        }
        field(5; "Date Time"; DateTime)
        {
            CaptionML = ENU = 'Date Time', ENG = 'Date Time';
        }
        field(6; "Shipment Exists"; Boolean)
        {
            CaptionML = ENU = 'Shipment Exists', ENG = 'Shipment Exists';
            CalcFormula = Exist ("Sales Shipment Header" WHERE (WebIncrementID = FIELD (WebIncrementID),
                            "Web Shipment Increment Id" = FIELD ("Web Shipment Increment Id")));
            FieldClass = FlowField;
        }
        field(7; OrderExists; Boolean)
        {
            CaptionML = ENU = 'OrderExists', ENG = 'OrderExists';
            CalcFormula = Exist ("Sales Header" WHERE (WebIncrementID = FIELD (WebIncrementID)));
            FieldClass = FlowField;
        }
        field(8; InvoiceExists; Boolean)
        {
            CaptionML = ENU = 'InvoiceExists', ENG = 'InvoiceExists';
            CalcFormula = Exist ("Sales Invoice Header" WHERE (WebIncrementID = FIELD (WebIncrementID)));
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
        }
        key(Key2; WebIncrementID)
        {
        }
    }

    fieldgroups
    {
    }
}

