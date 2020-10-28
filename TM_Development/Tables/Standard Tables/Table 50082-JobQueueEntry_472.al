tableextension 50082 JobQueueEntryExt extends "Job Queue Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Duration Process Max"; Integer)
        {
            Description = 'MITLCASE251';
            CaptionML = ENU = 'Duration Process Max', ENG = 'Duration Process Max';
        }
        field(50001; "Cronitor Function"; Text[50])
        {
            Description = 'MITL Cronitor Integration';
            CaptionML = ENU = 'Cronitor Function', ENG = 'Cronitor Function';
        }
    }

    var
        myInt: Integer;
}