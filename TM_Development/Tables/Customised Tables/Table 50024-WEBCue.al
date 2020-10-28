table 50024 "WEB Cue"
{
    // version R4311

    // R4311 - RM - 09.12.2015
    // Added field "No. Of Unreconciled Records"
    CaptionML = ENU = 'WEB Cue', ENG = 'WEB Cue';

    fields
    {
        field(1; "Code"; Code[20])
        {
            CaptionML = ENU = 'Code', ENG = 'Code';
        }
        field(2; "Last Entry Received"; DateTime)
        {
            CaptionML = ENU = 'Last Entry Received', ENG = 'Last Entry Received';
        }
        field(3; "No. Of Orders Today"; Integer)
        {
            CaptionML = ENU = 'No. Of Orders Today', ENG = 'No. Of Orders Today';
            CalcFormula = Count ("WEB Order Header" WHERE ("Order Date" = FIELD ("Date Filter")));
            FieldClass = FlowField;

        }
        field(4; "No. Of Item Today"; Integer)
        {
            CaptionML = ENU = 'No. Of Item Today', ENG = 'No. Of Item Today';
            CalcFormula = Count ("WEB Item" WHERE ("Date Time" = FIELD ("DateTime Filter")));
            FieldClass = FlowField;
        }
        field(5; "No. of Shipments Today"; Integer)
        {
            CaptionML = ENU = 'No. of Shipments Today', ENG = 'No. of Shipments Today';
            CalcFormula = Count ("WEB Shipment Header" WHERE ("Shipment Date" = FIELD ("Date Filter")));
            FieldClass = FlowField;
        }
        field(6; "No. Of Credits Today"; Integer)
        {
            CaptionML = ENU = 'No. Of Credits Today', ENG = 'No. Of Credits Today';
            CalcFormula = Count ("WEB Credit Header" WHERE ("Credit Memo Date" = FIELD ("Date Filter")));
            FieldClass = FlowField;
        }
        field(7; "No. Of Customers Today"; Integer)
        {
            CaptionML = ENU = 'No. Of Customers Today', ENG = 'No. Of Customers Today';
            CalcFormula = Count ("WEB Customer" WHERE ("Date Time" = FIELD ("DateTime Filter")));
            FieldClass = FlowField;
        }
        field(10; "Date Filter"; Date)
        {
            CaptionML = ENU = 'Date Filter', ENG = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(11; "DateTime Filter"; DateTime)
        {
            CaptionML = ENU = 'DateTime Filter', ENG = 'DateTime Filter';
            FieldClass = FlowFilter;
        }
        field(12; "Last Orders"; DateTime)
        {
            CaptionML = ENU = 'Last Orders', ENG = 'Last Orders';
            CalcFormula = Max ("WEB Order Header"."Date Time");
            FieldClass = FlowField;
        }
        field(13; "Last Item"; DateTime)
        {
            CaptionML = ENU = 'Last Item', ENG = 'Last Item';
            CalcFormula = Max ("WEB Item"."Date Time");
            FieldClass = FlowField;
        }
        field(14; "Last Shipments"; DateTime)
        {
            CaptionML = ENU = 'Last Shipments', ENG = 'Last Shipments';
            CalcFormula = Max ("WEB Shipment Header"."Date Time");
            FieldClass = FlowField;
        }
        field(15; "Last Credits"; DateTime)
        {
            CaptionML = ENU = 'Last Credits', ENG = 'Last Credits';
            CalcFormula = Max ("WEB Credit Header"."Date Time");
            FieldClass = FlowField;
        }
        field(16; "Last Customers"; DateTime)
        {
            CaptionML = ENU = 'Last Customers', ENG = 'Last Customers';
            CalcFormula = Max ("WEB Customer"."Date Time");
            FieldClass = FlowField;
        }
        field(17; "No. Of Errors Today"; Integer)
        {
            CaptionML = ENU = 'No. Of Errors Today', ENG = 'No. Of Errors Today';
            CalcFormula = Count ("WEB Index" WHERE (Status = CONST (Error),
                                "DateTime Inserted" = FIELD ("DateTime Filter")));
            FieldClass = FlowField;
        }
        field(18; "WEB Requests Outstanding"; Integer)
        {
            CaptionML = ENU = 'WEB Requests Outstanding', ENG = 'WEB Requests Outstanding';
            CalcFormula = Count ("WEB Requests" WHERE ("Magento Completed" = CONST (false)));
            FieldClass = FlowField;
        }
        field(19; "No. Of Errors Today - Customer"; Integer)
        {
            CaptionML = ENU = 'No. Of Errors Today - Customer', ENG = 'No. Of Errors Today - Customer';
            CalcFormula = Count ("WEB Index" WHERE (Status = CONST (Error),
                                "Table No." = CONST (50009),
                                "DateTime Inserted" = FIELD ("DateTime Filter")));
            FieldClass = FlowField;
        }
        field(20; "No. Of Errors Today - Order"; Integer)
        {
            CaptionML = ENU = 'No. Of Errors Today - Order', ENG = 'No. Of Errors Today - Order';
            CalcFormula = Count ("WEB Index" WHERE (Status = CONST (Error),
                                "Table No." = CONST (50010),
                                "DateTime Inserted" = FIELD ("DateTime Filter")));
            FieldClass = FlowField;
        }
        field(21; "No. Of Errors Today - Item"; Integer)
        {
            CaptionML = ENU = 'No. Of Errors Today - Item', ENG = 'No. Of Errors Today - Item';
            CalcFormula = Count ("WEB Index" WHERE (Status = CONST (Error),
                                "Table No." = CONST (50016),
                                "DateTime Inserted" = FIELD ("DateTime Filter")));
            FieldClass = FlowField;
        }
        field(22; "No. Of Errors Today - Shipment"; Integer)
        {
            CaptionML = ENU = 'No. Of Errors Today - Shipment', ENG = 'No. Of Errors Today - Shipment';
            CalcFormula = Count ("WEB Index" WHERE (Status = CONST (Error),
                                "Table No." = CONST (50014),
                                "DateTime Inserted" = FIELD ("DateTime Filter")));
            FieldClass = FlowField;
        }
        field(23; "No. Of Errors Today - Credit"; Integer)
        {
            CaptionML = ENU = 'No. Of Errors Today - Credit', ENG = 'No. Of Errors Today - Credit';
            CalcFormula = Count ("WEB Index" WHERE (Status = CONST (Error),
                                "Table No." = CONST (50018), "DateTime Inserted" = FIELD ("DateTime Filter")));
            FieldClass = FlowField;
        }
        field(24; "No. Of Errors - Customer"; Integer)
        {
            CaptionML = ENU = 'No. Of Errors - Customer', ENG = 'No. Of Errors - Customer';
            CalcFormula = Count ("WEB Index" WHERE (Status = CONST (Error),
                                "Table No." = CONST (50009)));
            FieldClass = FlowField;
        }
        field(25; "No. Of Errors - Order"; Integer)
        {
            CaptionML = ENU = 'No. Of Errors - Order', ENG = 'No. Of Errors - Order';
            CalcFormula = Count ("WEB Index" WHERE (Status = CONST (Error),
                                "Table No." = CONST (50010)));
            FieldClass = FlowField;
        }
        field(26; "No. Of Errors - Item"; Integer)
        {
            CaptionML = ENU = 'No. Of Errors - Item', ENG = 'No. Of Errors - Item';
            CalcFormula = Count ("WEB Index" WHERE (Status = CONST (Error),
                                "Table No." = CONST (50016)));
            FieldClass = FlowField;
        }
        field(27; "No. Of Errors - Shipment"; Integer)
        {
            CaptionML = ENU = 'No. Of Errors - Shipment', ENG = 'No. Of Errors - Shipment';
            CalcFormula = Count ("WEB Index" WHERE (Status = CONST (Error),
                                "Table No." = CONST (50014)));
            FieldClass = FlowField;
        }
        field(28; "No. Of Errors - Credit"; Integer)
        {
            CaptionML = ENU = 'No. Of Errors - Credit', ENG = 'No. Of Errors - Credit';
            CalcFormula = Count ("WEB Index" WHERE (Status = CONST (Error),
                                "Table No." = CONST (50018)));
            FieldClass = FlowField;
        }
        field(29; "No. Of Errors"; Integer)
        {
            CaptionML = ENU = 'No. Of Errors', ENG = 'No. Of Errors';
            CalcFormula = Count ("WEB Index" WHERE (Status = CONST (Error)));
            FieldClass = FlowField;
        }
        field(30; "No. Of Unreconciled Records"; Integer)
        {
            CaptionML = ENU = 'No. Of Unreconciled Records', ENG = 'No. Of Unreconciled Records';
            CalcFormula = Count ("WEB Daily Reconciliation" WHERE ("Reconciliation Complete" = CONST (false)));
            Description = 'R4311';
            FieldClass = FlowField;
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

