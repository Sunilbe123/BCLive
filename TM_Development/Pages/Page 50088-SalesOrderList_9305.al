pageextension 50088 SalesOrderList extends "Sales Order List"
{
    layout
    {
        // Add changes to page layout here
        addafter("No.")
        {
            field(WebOrderID; WebOrderID)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field(WebIncrementID; WebIncrementID)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }
    }

    actions
    {

    }

    var

}