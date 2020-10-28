tableextension 50071 ItemChargeAssignmentPurch extends "Item Charge Assignment (Purch)"
{
    //MITL2147 - Added 2 flow fields "Calculation Method" & "Calculation Value" and 4 general fields.
    fields
    {
        // Add changes to table fields here
        field(50000; "Net Weight"; Decimal)
        {
            Description = 'MITL2147';
            CaptionML = ENU = 'Applies-to Doc. Weight', ENG = 'Applies-to Doc. Weight';
            Editable = false;
        }
        field(50001; "Gross Weight"; Decimal)
        {
            Description = 'MITL2147';
            CaptionML = ENU = 'Gross Weight', ENG = 'Gross Weight';
            Editable = false;
        }
        field(50002; "Expected Amount"; Decimal)
        {
            Description = 'MITL2147';
            CaptionML = ENU = 'Expected Amount', ENG = 'Expected Amount';
        }
        field(50003; "Expected Gross Weight"; Decimal)
        {
            Description = 'MITL2147';
            CaptionML = ENU = 'Expected Gross Weight', ENG = 'Expected Gross Weight';
        }
        field(50004; "Expected Net Weight"; Decimal)
        {
            Description = 'MITL2147';
            CaptionML = ENU = 'Expected Net Weight', ENG = 'Expected Net Weight';
        }
        field(50005; "Expected Quantity"; Decimal)
        {
            Description = 'MITL2147';
            CaptionML = ENU = 'Expected Quantity', ENG = 'Expected Quantity';
        }
        field(50006; "Calculation Method"; Option)
        {
            Description = 'MITL2147';
            FieldClass = FlowField;
            CalcFormula = Lookup (ItemChgCalculation."Calculation Method" WHERE ("Item No." = FIELD ("Item No."), "Item Charge" = FIELD ("Item Charge No.")));
            CaptionML = ENU = 'Calculation Method', ENG = 'Calculation Method';
            OptionMembers = Percentage,"Per Quantity","Net Weight","Gross Weight";
            OptionCaptionML = ENU = 'Percentage,"Per Quantity","Net Weight","Gross Weight"', ENG = 'Percentage,"Per Quantity","Net Weight","Gross Weight"';
            Editable = false;
        }
        field(50007; "Calculation Value"; Decimal)
        {
            Description = 'MITL2147';
            FieldClass = FlowField;
            CalcFormula = Lookup (ItemChgCalculation."Calculation Value" WHERE ("Item No." = FIELD ("Item No."), "Item Charge" = FIELD ("Item Charge No.")));
            CaptionML = ENU = 'Calculation Value', ENG = 'Calculation Value';
            Editable = false;
        }

    }

    var
        myInt: Integer;
}