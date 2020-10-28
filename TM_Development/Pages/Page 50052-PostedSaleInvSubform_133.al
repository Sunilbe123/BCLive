pageextension 50052 PostedSalesInvSubform extends "Posted Sales Invoice Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("Shortcut Dimension 2 Code")
        {
            field(WebOrderItemID; WebOrderItemID)
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