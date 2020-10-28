query 50004 "BIN Inventory"
{
    QueryType = Normal;

    elements
    {
        dataitem(Item; Item)
        {
            DataItemTableFilter = Type = const(Inventory);
            dataitem(Whse_Entry; "Warehouse Entry")
            {
                DataItemLink = "Item No." = Item."No.";
                filter(Location_Code; "Location Code")
                {

                }
                filter(Zone_Code; "Zone Code")
                {

                }
                column(Quantity; Quantity)
                {
                    Method = Sum;
                }
            }

        }
    }

    var
        myInt: Integer;

    trigger OnBeforeOpen()
    begin

    end;
}