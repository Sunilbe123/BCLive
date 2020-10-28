table 50008 "Item Attributes"
{
    CaptionML = ENU = 'Item Attributes', ENG = 'Item Attributes';
    fields
    {
        field(1; "Item No."; Code[20])
        {
            CaptionML = ENU = 'Item No.', ENG = 'Item No.';
        }
        field(2; Attribute; Text[100])
        {
            CaptionML = ENU = 'Attribute', ENG = 'Attribute';
        }
        field(3; "Attribute Value"; Text[250])
        {
            CaptionML = ENU = 'Attribute Value', ENG = 'Attribute Value';
        }
    }

    keys
    {
        key(Key1; "Item No.", Attribute)
        {
        }
    }

    fieldgroups
    {
    }
}

