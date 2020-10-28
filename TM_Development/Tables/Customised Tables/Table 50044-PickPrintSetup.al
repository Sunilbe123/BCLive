table 50044 "Pick Print Setup"
{
    //version MITL2235

    CaptionML = ENU = 'Pick Print Setup', ENG = 'Pick Print Setup';
    DrillDownPageID = "Pick Print Setup";
    LookupPageID = "Pick Print Setup";

    fields
    {
        field(1; "Printer ID"; Code[50])
        {

            CaptionML = ENU = 'Printer ID', ENG = 'Printer ID';
            Description = 'MITL2235';

        }
        field(2; "Server URL"; Text[250])
        {
            CaptionML = ENU = 'Server URL', ENG = 'Server URL';
            Description = 'MITL2235';

        }
        field(3; "Port"; Integer)
        {
            CaptionML = ENU = 'Port', ENG = 'Port';
            Description = 'MITL2235';
        }


        field(4; "Command"; Text[250])
        {
            CaptionML = ENU = 'Command', ENG = 'Command';
            Description = 'MITL2235';
        }


    }
    keys
    {
        key(PK; "Printer ID")
        {
            Clustered = true;
        }
    }


}