tableextension 50053 GenJnlLines extends "Gen. Journal Line"
{
    fields
    {
        // Add changes to table fields here
        field(50001; WebIncrementID; Text[30])
        {
            Description = 'R1518';
            InitValue = '0';
        }
        field(50003; "Invoice Disc. Facility Availed"; Boolean)
        {
            CaptionML = ENU = 'Invoice Disc. Facility Availed', ENG = 'Invoice Disc. Facility Availed'; //MITL.SP.W&F
        }
    }

    var
        myInt: Integer;
}