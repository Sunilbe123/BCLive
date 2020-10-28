tableextension 50085 BinContentExt extends "Bin Content"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Odd-Even Bin Flag"; Option)
        {
            CaptionML = ENU = 'Odd-Even Bin Flag', ENG = 'Odd-Even Bin Flag';
            OptionMembers = " ",ODD,EVEN;
            OptionCaptionML = ENU = ' ,ODD,EVEN', ENG = ' ,ODD,EVEN';
            FieldClass = FlowField;
            CalcFormula = Lookup (Bin."Odd-Even Bin Flag" WHERE (Code = FIELD ("Bin Code")));
        }
    }

    var
        myInt: Integer;
}