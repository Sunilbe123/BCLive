query 50005 "Whse. Entry Qty"
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
                filter(Source_No_; "Source No.")
                {

                }
                filter(Source_Line_No_; "Source Line No.")
                {

                }
                filter(Location_Code; "Location Code")
                {

                }
                filter(Zone_Code; "Zone Code")
                {

                }
                filter(Source_Code; "Source Code")
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