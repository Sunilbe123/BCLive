// MITL.SM.Improvement in Statement Sending through e-mail
table 50051 "Statement Email Queue"
{

    DrillDownPageId = 50038;
    LookupPageId = 50038;
    CaptionML = ENU = 'Statement Send Queue', ENG = 'Statement Send Queue';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Editable = false;
        }
        field(2; "Customer No."; Code[20])
        {
            TableRelation = Customer;
            Editable = false;
        }
        field(3; "Created Data Time"; DateTime)
        {
            Editable = false;
        }
        field(4; "Statement Sent Date Time"; DateTime)
        {
            Editable = false;
        }
        field(5; Status; Option)
        {
            OptionMembers = New,Error,Sent;
            OptionCaption = 'New,Error,Sent';
            Editable = false;
        }
        field(6; "Error Details"; Text[250])
        {
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}