pageextension 50050 GLEntry extends "General Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter("G/L Account Name")
        {
            field(WebIncrementID; WebIncrementID)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Source Type"; "Source Type")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';

            }
            field("Source No."; "Source No.")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';

            }
            field("Customer Name"; "Customer Name")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                //MITL.SM.20200210 Point 38

            }
            field("Vendor Name"; "Vendor Name")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                //MITL.SM.20200210 Point 38
            }
        }

    }


    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetRecord()
    begin
        //MITL.SM.20200211 Point 38++
        if "Source Type" = "Source Type"::Vendor then
            "Customer Name" := '';
        if "Source Type" = "Source Type"::Customer then
            "Vendor Name" := '';
        //MITL.SM.20200211 Point 38--
    end;

    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        //MITL.SM.20200211 Point 38++
        if "Source Type" = "Source Type"::Vendor then
            "Customer Name" := '';
        if "Source Type" = "Source Type"::Customer then
            "Vendor Name" := '';
        //MITL.SM.20200211 Point 38--
    end;

    var
        myInt: Integer;
}