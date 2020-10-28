table 50003 "Cut Size Analysis"
{
    CaptionML = ENU = 'Cut Size Analysis', ENG = 'Cut Size Analysis';

    fields
    {
        field(1; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', ENG = 'Line No.';
        }
        field(2; "Customer No."; Code[20])
        {
            CaptionML = ENU = 'Customer No.', ENG = 'Customer No.';
        }
        field(3; "Item No."; Code[20])
        {
            CaptionML = ENU = 'Item No.', ENG = 'Item No.';
        }
        field(4; "Cut Size Qty"; Decimal)
        {
            CaptionML = ENU = 'Cut Size Qty', ENG = 'Cut Size Qty';
            FieldClass = FlowField;
            CalcFormula = Sum ("Sales Shipment Line".Quantity WHERE ("Sell-to Customer No." = FIELD ("Customer No."), "No." = FIELD ("Item No."), "Cut Size" = CONST (true)));
            Editable = false;
        }
        field(5; "Sales Qty"; Decimal)
        {
            CaptionML = ENU = 'Sales Qty', ENG = 'Sales Qty';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum ("Sales Shipment Line".Quantity WHERE ("Sell-to Customer No." = FIELD ("Customer No."), "No." = FIELD ("Item No."), "Cut Size" = CONST (false)));
        }
    }

    keys
    {
        key(PK; "Line No.")
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