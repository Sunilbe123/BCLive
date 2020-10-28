pageextension 50041 UserSetup extends "User Setup"
{
    layout
    {
        // Add changes to page layout here
        addafter(Email)
        {
            field("Get Sync.Warning Email"; "Get Sync.Warning Email") { }

            field("Allow Bin Update on Picks"; "Allow Bin Update on Picks")
            {
                Description = 'MITL3118.AJ.19MAR2020';
            }
            //MITL DJ 17June2020++
            field(SendInvtDiff; SendInvtDiff)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            //MITL DJ 17June2020++

            //MITL DJ 16June2020++
            field(SendInvtLoc; SendInvtLoc)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            //MITL DJ 16June2020++
            field("Default Location"; "Default Location")
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