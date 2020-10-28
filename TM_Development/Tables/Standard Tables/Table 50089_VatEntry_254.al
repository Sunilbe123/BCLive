tableextension 50089 VatEntry extends "VAT Entry"
{
    fields
    {
        field(50000; Description; Text[50])
        {
            CaptionML = ENU = 'Description', ENG = 'Description';
        }
        field(50010; "Customer Name"; Text[50])
        {
            //MITL.SM.20200210 Point 38
            FieldClass = FlowField;
            CalcFormula = lookup (Customer.Name where ("No." = field ("Bill-to/Pay-to No.")));
        }
        field(50011; "Vendor Name"; Text[50])
        {
            //MITL.SM.20200210 Point 38
            FieldClass = FlowField;
            CalcFormula = lookup (Vendor.Name where ("No." = field ("Bill-to/Pay-to No.")));
        }
        field(50090; "Old Transaction No."; Integer)
        {
            Description = 'MITL_TransNo';
        }
    }
}