table 50033 "WEB User Scan"
{
    CaptionML = ENU = 'WEB User Scan', ENG = 'WEB User Scan';

    fields
    {
        field(1; "User ID"; Code[50])
        {
            CaptionML = ENU = 'User ID', ENG = 'User ID';
        }
        field(2; "Start Scan"; DateTime)
        {
            CaptionML = ENU = 'Start Scan', ENG = 'Start Scan';
        }
        field(3; "End Time"; DateTime)
        {
            CaptionML = ENU = 'End Time', ENG = 'End Time';
        }
        field(4; "Order No"; Code[20])
        {
            CaptionML = ENU = 'Order No', ENG = 'Order No';
        }
        field(5; "Login Time"; DateTime)
        {
            CaptionML = ENU = 'Login Time', ENG = 'Login Time';
        }
        field(6; "Logout Time"; DateTime)
        {
            CaptionML = ENU = 'Logout Time', ENG = 'Logout Time';
        }
    }

    keys
    {
        key(Key1; "User ID")
        {
        }
    }

    fieldgroups
    {
    }
}

