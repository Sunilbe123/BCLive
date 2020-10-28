table 50005 "Unplanned Counts Registrations"
{
    CaptionML = ENU = 'Unplanned Counts Registrations', ENG = 'Unplanned Counts Registrations';

    fields
    {
        field(1; "Item No"; Code[20])
        {
            CaptionML = ENU = 'Item No', ENG = 'Item No';
        }
        field(2; Qty; Decimal)
        {
            CaptionML = ENU = 'Quantity', ENG = 'Quantity';
        }
        field(3; "Registration Date"; Date)
        {
            CaptionML = ENU = 'Registration Date', ENG = 'Registration Date';
        }
        field(4; "User/Device"; Code[50])
        {
            CaptionML = ENU = 'User/Device', ENG = 'User/Device';
        }
        field(5; "Line No."; Integer)
        {
            CaptionML = ENU = 'Line No.', ENG = 'Line No.';
            AutoIncrement = true;
        }
        field(6; "Item Description"; Text[50])
        {
            CaptionML = ENU = 'Item Description', ENG = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup (Item.Description WHERE ("No." = FIELD ("Item No")));
        }
        field(7; "Shelf No."; Code[25])
        {
            CaptionML = ENU = 'Shelf No.', ENG = 'Shelf No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup (Item."Shelf No." WHERE ("No." = FIELD ("Item No")));
        }
        field(8; "Pallet Qty"; Decimal)
        {
            CaptionML = ENU = 'Pallet Qty', ENG = 'Pallet Qty';
        }
        field(9; "Loose Tiles"; Decimal)
        {
            CaptionML = ENU = 'Loose Tiles', ENG = 'Loose Tiles';
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