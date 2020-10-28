table 50002 "Payment Method Template MAP"
{
    // version R1631,R2558

    // R2558 - RM - 25.02.2015
    // Added field "Create No Payment"
    Caption = 'Payment Method Template MAP';

    fields
    {
        field(1; "Payment Method Code"; Code[20])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
            Description = 'R1631';
        }
        field(2; "Sales Pmt. Jnl Template Name"; Code[10])
        {
            CaptionML = ENU = 'Sales Pmt. Jnl Template Name', ENG = 'Sales Pmt. Jnl Template Name';
            Description = 'R1631';
            TableRelation = "Gen. Journal Template";
        }
        field(3; "Sales Pmt. Jnl Batch Name"; Code[10])
        {
            CaptionML = ENU = 'Sales Pmt. Jnl Batch Name', ENG = 'Sales Pmt. Jnl Batch Name';
            Description = 'R1631';
            TableRelation = "Gen. Journal Batch".Name WHERE ("Journal Template Name" = FIELD ("Sales Pmt. Jnl Template Name"));
        }
        field(4; "Create No Payment"; Boolean)
        {
            Caption = 'Create No Payment';
            Description = 'R2558';
        }
    }

    keys
    {
        key(Key1; "Payment Method Code")
        {
        }
    }

    fieldgroups
    {
    }
}

