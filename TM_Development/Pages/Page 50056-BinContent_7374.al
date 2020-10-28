pageextension 50056 BinContentExt extends "Bin Contents"
{
    layout
    {
        // Add changes to page layout here
        addafter("Location Code")
        {
            field("Odd-Even Bin Flag"; "Odd-Even Bin Flag")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }
    }

    actions
    {

    }

    var
        myInt: Integer;
}