pageextension 50057 VendorList extends "Vendor List"
{
    layout
    {
        // Add changes to page layout here
        addafter(Name)
        {
            field(City; City)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("E-Mail"; "E-Mail")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
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