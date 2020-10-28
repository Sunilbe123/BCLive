table 50043 ItemChgCalculation
{
    //MITL2147 - Created a new table as per the specification.
    CaptionML = ENU = 'Item Charge Calculation', ENG = 'Item Charge Calculation';
    fields
    {
        field(1; "Item No."; Code[20])
        {
            CaptionML = ENU = 'Item No.', ENG = 'Item No.';
            Description = 'MITL2147';
            TableRelation = Item;
            Editable = false;
        }
        field(2; "Item Charge"; Code[20])
        {
            CaptionML = ENU = 'Item Charge', ENG = 'Item Charge';
            Description = 'MITL2147';
            TableRelation = "Item Charge";
        }
        field(3; "Calculation Method"; Option)
        {
            CaptionML = ENU = 'Calculation Method', ENG = 'Calculation Method';
            Description = 'MITL2147';
            OptionMembers = Percentage,"Per Quantity","Net Weight","Gross Weight";
            OptionCaptionML = ENU = 'Percentage,"Per Quantity","Net Weight","Gross Weight"', ENG = 'Percentage,"Per Quantity","Net Weight","Gross Weight"';
        }
        field(4; "Calculation Value"; Decimal)
        {
            CaptionML = ENU = 'Calculation Value', ENG = 'Calculation Value';
            Description = 'MITL2147';

            trigger OnValidate()
            var
                CalculationValueErrorL: TextConst ENU = 'The Calculation value must not be negative.', ENG = 'The Calculation value must not be negative.';
            begin
                IF "Calculation Value" < 0 then
                    Error(CalculationValueErrorL);
            end;
        }
    }

    keys
    {
        key(PK; "Item No.", "Item Charge")
        {
            Clustered = true;
        }
    }

    var
    // myInt: Integer;

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