tableextension 50086 BinExt extends Bin
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Odd-Even Bin Flag"; Option)
        {
            CaptionML = ENU = 'Odd-Even Bin Flag', ENG = 'Odd-Even Bin Flag';
            OptionMembers = " ",ODD,EVEN;
            OptionCaptionML = ENU = ' ,ODD,EVEN', ENG = ' ,ODD,EVEN';
        }
    }

    var
        myInt: Integer;
}