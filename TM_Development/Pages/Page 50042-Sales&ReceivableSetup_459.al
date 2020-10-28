pageextension 50042 Sales_ReceivaleSetup extends "Sales & Receivables Setup"
{
    layout
    {
        // Add changes to page layout here
        addafter("Reverse Charge")
        {
            group(Returns)
            {
                field("Returns Location"; "Returns Location") { }
            }
        }
	addlast(General)
        {
            field(FromDt; FromDt)
            {
                ApplicationArea = Basic, Suite;
                Description = 'MITL_6702_VS';
            }
            field(Todate; Todate)
            {
                ApplicationArea = Basic, Suite;
                Description = 'MITL_6702_VS';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}