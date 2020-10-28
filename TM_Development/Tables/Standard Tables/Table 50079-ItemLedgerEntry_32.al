tableextension 50079 ItemLedgerEntryExt extends "Item Ledger Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Orig. Sales Order No."; Code[20])
        {
            Description = 'R1907';
            CaptionML = ENU = 'Orig. Sales Order No.', ENG = 'Orig. Sales Order No.';
            FieldClass = FlowField;
            CalcFormula = Lookup ("Sales Shipment Header"."Order No." WHERE ("No." = FIELD ("Document No.")));
        }
        field(50001; "Orig. Purch. Order No."; Code[20])
        {
            Description = 'R2142';
            CaptionML = ENU = 'Orig. Purch. Order No.', ENG = 'Orig. Purch. Order No.';
            FieldClass = FlowField;
            CalcFormula = Lookup ("Purch. Rcpt. Header"."Order No." WHERE ("No." = FIELD ("Document No.")));
        }
    }

    var
        myInt: Integer;
}