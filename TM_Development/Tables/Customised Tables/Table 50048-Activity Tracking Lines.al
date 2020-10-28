//MITL-2146++
table 50048 "Activity Tracking Lines"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Activity No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Order No."; code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(4; "Bin Code"; Code[30])
        {
            DataClassification = ToBeClassified;

        }
        field(5; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(6; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(7; "Device ID"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(8; "User ID"; Code[30])
        {
            DataClassification = ToBeClassified;

        }
        field(9; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(10; "Start Time"; DateTime)
        {
            DataClassification = ToBeClassified;

        }
        field(11; "End Time"; DateTime)
        {
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(PK; "Activity No.", "Order No.", "Item No.", "Bin Code", "Line No.")
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
//MITL-2146--