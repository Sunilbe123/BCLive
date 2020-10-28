tableextension 50070 ValueEntryExt extends "Value Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50001; "Orig. Sales Order No."; Code[20])
        {
            Description = 'MITL1577';
            CaptionML = ENU = 'Orig. Sales Order No.', ENG = 'Orig. Sales Order No.';
            FieldClass = FlowField;
            CalcFormula = lookup ("Sales Invoice Header".WebIncrementID where ("No." = field ("Document No.")));
        }

    }

    var
        myInt: Integer;
}