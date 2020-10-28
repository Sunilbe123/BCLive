pageextension 50107 PurchasInvoiceExt extends "Purchase Invoice"
{
    layout
    {
        // Add changes to page layout here
        modify(PayToOptions)
        {
            Editable = false;
            Description = 'MITLP58.AJ.17MAR2020';
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}