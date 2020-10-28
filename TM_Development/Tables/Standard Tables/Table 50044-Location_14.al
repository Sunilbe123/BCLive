tableextension 50044 LocationExt extends Location
{
    //version CASE 13601,CASE13605
    fields
    {
        // Add changes to table fields here
        field(50000; "Auto Pick Template Name"; Code[10])
        {
            Description = 'MITL13605';
            Caption = 'Auto Pick Template Name';
            TableRelation = "Whse. Worksheet Template".Name WHERE (Type = FILTER (Movement));
        }
        field(50001; "Auto Pick Batch Name"; Code[10])
        {
            Description = 'MITL13605';
            Caption = 'Auto Pick Batch Name';
            TableRelation = "Whse. Worksheet Name".Name WHERE ("Location Code" = FIELD (Code), "Worksheet Template Name" = FIELD ("Auto Movement Template"));
        }
        field(50002; "Auto Movement Template"; Code[20])
        {
            Description = 'MITL13601';
            Caption = 'Auto Movement Template';
            TableRelation = "Whse. Worksheet Template".Name WHERE (Type = FILTER (Movement));
        }
        field(50003; "Auto Movement Batch Name"; Code[20])
        {
            Description = 'MITL13601';
            Caption = 'Auto Movement Template';
            TableRelation = "Whse. Worksheet Name".Name WHERE ("Location Code" = FIELD (Code), "Worksheet Template Name" = FIELD ("Auto Movement Template"));
        }
        field(50004; "Auto Movement for Credit Memo"; Boolean)
        {
            Description = 'MITL13601';
            Caption = 'Auto Movement for Credit Memo';
        }
    }

    var
        myInt: Integer;
}