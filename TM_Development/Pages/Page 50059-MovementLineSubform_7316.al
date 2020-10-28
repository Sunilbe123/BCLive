pageextension 50059 MovementLinesSubform extends "Warehouse Movement Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("Action Type")
        {
            field("Movement No."; "No.")
            {
                Editable = false;
            }
        }

        addafter(Cubage)
        {
            field("Source No."; "Source No.")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Source Line No."; "Source Line No.")
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