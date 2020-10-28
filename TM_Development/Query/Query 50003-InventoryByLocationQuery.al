query 50003 InventoryByLocationQuery
{
    QueryType = Normal;
    CaptionML = ENU = 'Inventory By Location Query';
    elements
    {
        dataitem(Item; Item)
        {
            DataItemTableFilter = "Type" = const (Inventory);

            filter("Type"; Type)
            { }
            dataitem(Item_Ledger_Entry; "Item Ledger Entry")
            {

                DataItemLink = "Item No." = Item."No.";

                column(Location_Code; "Location Code")
                {
                }
                column(Sum_Cost_Amount_Expected; "Cost Amount (Expected)")
                {
                    Method = Sum;
                }
                column(Sum_Cost_Amount_Actual; "Cost Amount (Actual)")
                {
                    Method = Sum;
                }
                column(Sum_Quantity; Quantity)
                {
                    Method = Sum;
                }
            }

        }
    }
}