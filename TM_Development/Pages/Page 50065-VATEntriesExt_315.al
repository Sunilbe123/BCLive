pageextension 50065 VATEntries extends "VAT Entries"
{
    layout
    {
        addafter("Document No.")
        {
            field(Description; Description)
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
    trigger OnAfterGetRecord()
    begin
        //MITL.SM.20200211 Point 38++
        if Type = Type::Purchase then
            "Customer Name" := '';
        if Type = Type::Sale then
            "Vendor Name" := '';
        //MITL.SM.20200211 Point 38--
    end;

    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        //MITL.SM.20200211 Point 38++
        if Type = Type::Purchase then
            "Customer Name" := '';
        if Type = Type::Sale then
            "Vendor Name" := '';
        //MITL.SM.20200211 Point 38--
    end;

}
