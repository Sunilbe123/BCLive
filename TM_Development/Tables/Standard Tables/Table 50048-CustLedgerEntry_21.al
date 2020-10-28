tableextension 50048 CustLedgerEntry extends "Cust. Ledger Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50001; WebIncrementID; Text[30])
        {
            Description = 'R1518';
            InitValue = '0';
        }

        field(50002; "Invoice Disc. Facility Availed"; Boolean)
        {
            CaptionML = ENU = 'Invoice Disc. Facility Availed', ENG = 'Invoice Disc. Facility Availed'; //MITL.SP.W&F
        }


        field(50003; "Invoice Disc. Avail on Customer"; Boolean)
        {
            CaptionML = ENU = 'Invoice Disc. Avail on Customer', ENG = 'Invoice Disc. Avail on Customer'; //MITL.SP.W&F
            FieldClass = FlowField;
            CalcFormula = lookup(Customer."Invoice Disc. Facility Availed" where("No." = field("Customer No.")));
        }
        field(50010; "Customer Name 1"; Text[50])
        {
            //MITL.SM.20200210 Point 38
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
        }
        field(50090; "Old Transaction No."; Integer)
        {
            Description = 'MITL_TransNo';
        }
    }

    keys
    {
        key(Key2; WebIncrementID)
        {
            Description = 'MITL.AJ.20200603 Indexing correction';
        }
    }

    var
        myInt: Integer;
}