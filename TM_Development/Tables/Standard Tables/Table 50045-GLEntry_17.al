tableextension 50045 GLentry extends "G/L Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50001; WebIncrementID; Text[30])
        {
            Description = 'R1518';
            InitValue = '0';
        }
        field(50010; "Customer Name"; Text[50])
        {
            //MITL.SM.20200210 Point 38
            FieldClass = FlowField;
            CalcFormula = lookup (Customer.Name where ("No." = field ("Source No.")));
        }
        field(50011; "Vendor Name"; Text[50])
        {
            //MITL.SM.20200210 Point 38
            FieldClass = FlowField;
            CalcFormula = lookup (Vendor.Name where ("No." = field ("Source No.")));
        }
        field(50090; "Old Transaction No."; Integer)
        {
            Description = 'MITL_TransNo';
        }
    }

    var
        myInt: Integer;
}