table 50047 ProcessBulkRecord
{
    //Version MITL4192
    Caption = 'Process Bulk Record';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            InitValue = 0;
            AutoIncrement = true;
        }
        field(2; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(3; "Whse. Shipment No."; Code[20])
        {
            Caption = 'Warehouse Shipment No.';
        }
        field(4; "Processed"; Boolean)
        {
            Caption = 'Processed';
        }
        field(5; "Sales Invoice No."; Code[20])
        {
            Caption = 'Sales Invoice No.';
        }
        field(6; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }

        field(7; "Error"; Text[250])
        {
            Caption = 'Error';
        }
        field(8; "Unposted Pick Nos."; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count ("Warehouse Activity Line" WHERE ("Action Type" = const (Take), "Activity Type" = CONST (Pick), "Source Type" = CONST (37), "Source No." = FIELD ("Order No."), "Source Document" = CONST ("Sales Order")));
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}