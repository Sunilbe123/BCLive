table 50100 ScaleExternalSqlTable
{
    // version MITL2219

    DrillDownPageID = 50122;
    //ExternalName = 'LLOP_Weight';
    //ExternalSchema = 'dbo';
    LookupPageID = 50122;
    //TableType = ExternalSQL;

    fields
    {
        field(1; LLOP_ID; Integer)
        {
            DataClassification = ToBeClassified;
            //ExternalName = 'LLOP_ID';
        }
        field(2; Current_Weight; Decimal)
        {
            DataClassification = ToBeClassified;
            //ExternalName = 'Current_Weight';
        }
        field(3; Device_ID; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; Device_ID)
        {
        }
    }

    fieldgroups
    {
    }
}

