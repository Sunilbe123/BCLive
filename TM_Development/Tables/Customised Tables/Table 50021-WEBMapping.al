table 50021 "WEB Mapping"
{
    CaptionML = ENU = 'WEB Mapping', ENG = 'WEB Mapping';
    fields
    {
        field(1; "Magento Payment Method Code"; Code[50])
        {
            CaptionML = ENU = 'Magento Payment Method Code', ENG = 'Magento Payment Method Code';
        }
        field(2; "Dynamics NAV Payment Method Co"; Code[20])
        {
            CaptionML = ENU = 'Dynamics NAV Payment Method Co', ENG = 'Dynamics NAV Payment Method Co';
            TableRelation = "Payment Method";
        }
        field(3; "Online Payment"; Boolean)
        {
            CaptionML = ENU = 'Online Payment', ENG = 'Online Payment';
        }
    }

    keys
    {
        key(Key1; "Magento Payment Method Code")
        {
        }
    }

    fieldgroups
    {
    }
}

