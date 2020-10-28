pageextension 50048 GenJnlLineext extends "General Journal"
{
    layout
    {
        // Add changes to page layout here
        addafter("Document No.")
        {
            field(WebIncrementID; WebIncrementID)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }
        addafter("Document Date")
        {
            field("Due Date"; "Due Date")
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