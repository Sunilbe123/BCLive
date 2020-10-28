tableextension 50063 SalesReceivableSetup extends "Sales & Receivables Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Sales Pmt. Jnl Template Name"; Code[10])
        {
            Description = 'R1548';
            CaptionML = ENU = 'Sales Pmt. Jnl Template Name', ENG = 'Sales Pmt. Jnl Template Name';
            TableRelation = "Gen. Journal Template";
        }
        field(50001; "Sales Pmt. Jnl Batch Name"; Code[10])
        {
            Description = 'R1548';
            CaptionML = ENU = 'Sales Pmt. Jnl Batch Name', ENG = 'Sales Pmt. Jnl Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE ("Journal Template Name" = FIELD ("Sales Pmt. Jnl Template Name"));
        }
        field(50002; "Last Payment Creation"; DateTime)
        {
            Description = 'R2340';
            CaptionML = ENU = 'Last Payment Creation', ENG = 'Last Payment Creation';
            Editable = false;
        }
        field(50003; "Returns Location"; Code[10])
        {
            Description = 'R2173';
            CaptionML = ENU = 'Returns Location', ENG = 'Returns Location';
            TableRelation = Location;
        }
        field(50004; "Credit Memo Discount Account"; Code[10])
        {
            Description = 'R2173';
            CaptionML = ENU = 'Credit Memo Discount Account', ENG = 'Credit Memo Discount Account';
            TableRelation = "G/L Account";
        }
        field(50005; "Credit File URL"; Text[250])
        {
            Description = 'R2173';
            CaptionML = ENU = 'Credit File URL', ENG = 'Credit File URL';
        }
        field(50006; "Excel Sheet Name"; Text[30])
        {
            Description = 'R2173';
            CaptionML = ENU = 'Excel Sheet Name', ENG = 'Excel Sheet Name';
        }
        field(50007; "Skip Header Row"; Boolean)
        {
            Description = 'R2173';
            CaptionML = ENU = 'Skip Header Row', ENG = 'Skip Header Row';
        }
        field(50008; "Print Mobile Pick Label"; Boolean)
        {
            Description = 'R5179';
            CaptionML = ENU = 'Print Mobile Pick Label', ENG = 'Print Mobile Pick Label';
        }
        field(50010; PickCreationCalc; DateFormula)
        {
            Description = 'Pick Creation Calculation mitl_6532';
            CaptionML = ENU = 'Pick Creation Calculation', ENG = 'Pick Creation Calculation';
        }
        field(50011; FromDt; Date)
        {
            CaptionML = ENG = 'Failed Shipment From Date', ENU = 'Failed Shipment From Date';
            Description = 'MITL_6702_VS';
        }
        field(50012; Todate; Date)
        {
            CaptionML = ENG = 'Failed Shipment To Date', ENU = 'Failed Shipment To Date';
            Description = 'MITL_6702_VS';
        }
    }

    var
        myInt: Integer;
}