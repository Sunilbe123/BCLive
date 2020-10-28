//MITL.MF.5419 Added field 30/01/2020
tableextension 50091 GeneralLedgerSetup extends "General Ledger Setup"
{
    fields
    {
        field(50000; PurchaseInvoiceDescriptionUpdate; Boolean)
        {
            Description = 'MITL Case 5419';
        }
    }

    var
        myInt: Integer;
}