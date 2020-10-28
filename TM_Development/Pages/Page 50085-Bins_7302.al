pageextension 50085 BinsExt extends Bins
{
    layout
    {
        // Add changes to page layout here
        addafter("Bin Type Code")
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
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}