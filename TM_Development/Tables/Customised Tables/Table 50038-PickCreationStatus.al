table 50038 "Pick Creation Status"
{
    // version CASE13605

    Caption = 'Pick Creation Status';

    fields
    {
        field(1; "No."; Integer)
        {
            Caption = 'No.';
            Editable = false;
        }
        field(3; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Editable = false;
        }
        field(4; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            Editable = false;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(6; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
        }
        field(7; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
            Editable = false;
        }
        field(9; "Source Document"; Option)
        {
            Caption = 'Source Document';
            Editable = false;
            OptionCaption = ',Sales Order,,,Sales Return Order,Purchase Order,,,Purchase Return Order,,Outbound Transfer,,,,,,,,Service Order';
            OptionMembers = ,"Sales Order",,,"Sales Return Order","Purchase Order",,,"Purchase Return Order",,"Outbound Transfer",,,,,,,,"Service Order";
        }
        field(10; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = ' ,Pick Created,Pick Pending Movement Created,Pick Pending No Stock,Skipped-Comb Pick,Update in-Progress';
            OptionMembers = " ","Pick Created","Pick Pending Movement Created","Pick Pending No Stock","Skipped-Comb Pick","Update in-Progress";
        }
        field(11; "No Stock Items 1"; Text[250])
        {
            Caption = 'No Stock Items';
        }
        field(12; "No Stock Items 2"; Text[250])
        {
            Caption = 'No Stock Items';
        }
        field(13; "No Stock Items 3"; Text[250])
        {
            Caption = 'No Stock Items';
        }
        field(14; "Web Order No."; Text[30])
        {
            Caption = 'Web Order No.';
        }
        field(15; "Creation Date Time"; DateTime)
        {
            Caption = 'Creation Date Time';
        }
        field(16; "Last modified Date Time"; DateTime)
        {
            Caption = 'Last modified Date Time';
        }
        field(17; "Last Status"; Option)
        {
            Caption = 'Last Status';
            OptionCaption = ' ,Pick Created,Pick Pending Movement Created,Pick Pending No Stock,Skipped-Comb Pick,Update in-Progress';
            OptionMembers = " ","Pick Created","Pick Pending Movement Created","Pick Pending No Stock","Skipped-Comb Pick","Update in-Progress";
        }
        field(18; "Pick No."; Code[20])
        {
            CaptionML = ENU = 'Pick No.';
            FieldClass = FlowField;
            CalcFormula = Lookup ("Warehouse Activity Header"."No." WHERE (Type = CONST (Pick), "Source Document" = FIELD ("Source Document"), "Source No." = FIELD ("Source No.")));
        }
        field(19; "Whse_Movement_No"; Code[20])
        {
            CaptionML = ENU = 'Movement No', ENG = 'Movement No';
        }

    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Source Document", "Source No.")
        {
        }
    }

    fieldgroups
    {
    }
}

