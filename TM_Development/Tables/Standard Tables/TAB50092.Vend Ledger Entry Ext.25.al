tableextension 50092 "Vend Ledger Entry Ext" extends "Vendor Ledger Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50011; "Vendor Name 1"; Text[50])
        {
            //MITL.SM.20200210 Point 38
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
        }
        field(50090; "Old Transaction No."; Integer)
        {
            Description = 'MITL_TransNo';
        }
    }

    var
        myInt: Integer;
}