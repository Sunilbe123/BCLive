pageextension 50040 SalesOrderSubform extends "Sales Order Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter(Quantity)
        {
            field("Cut Size"; "Cut Size")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Pick Line Qty"; "Pick Line Qty")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Picked Line Qty"; "Picked Line Qty")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }



        }
        addafter("Deferral Code")
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