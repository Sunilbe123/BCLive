tableextension 50054 UserSetup extends "User Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Receive Only"; Boolean)
        {
            Description = 'R1585';
            CaptionML = ENU = 'Receive Only', ENG = 'Receive Only';
        }
        field(50001; "Get Sync.Warning Email"; Boolean)
        {
            Description = 'R4622';
            CaptionML = ENU = 'Get Sync.Warning Email', ENG = 'Get Sync.Warning Email';
        }

        field(50002; "Allow Bin Update on Picks"; Boolean)
        {
            Description = 'MITL3118.AJ.19MAR2020';
        }
        //Mitl.AK.24Mar2020 ++
        field(50003; "Show On Approval"; Boolean)
        {
            Caption = 'Super Approval';
            Description = 'MITL.Ak.24Mar2020';
        }
        //Mitl.AK.24Mar2020 ++

        //Mitl.DJ.17June2020 ++
        field(50004; "SendInvtDiff"; Boolean)
        {
            Caption = 'Send Invt Diff Report';
            Description = 'Mitl.DJ.17June2020 ++';
        }
        //Mitl.DJ.17June2020 --

        //Mitl.DJ.17July2020 ++
        field(50005; "SendInvtLoc"; Boolean)
        {
            Caption = 'Send Invt By Location Report';
            Description = 'Mitl.DJ.17June2020 ++';
        }
        //Mitl.DJ.17July2020 --
        field(50006; "Default Location"; Code[10])
        {
            Description = 'MITL.SM.STORE Premission.20200917';
            TableRelation = Location.Code;
        }

    }

    var
        myInt: Integer;
}