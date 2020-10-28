tableextension 50081 BankAccountLedgerEntryExt extends "Bank Account Ledger Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50001; WebIncrementID; Text[30])
        {
            Description = 'R1518';
            Caption = 'WebIncrementID';
            InitValue = '0';
        }
        field(50090; "Old Transaction No."; Integer)
        {
            Description = 'MITL_TransNo';
        }
    }

    var
        myInt: Integer;
}