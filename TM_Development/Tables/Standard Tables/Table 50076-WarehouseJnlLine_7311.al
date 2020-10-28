tableextension 50076 WarehouseJnlLineExt extends "Warehouse Journal Line"
{
    //Version MITL14137
    //MITL14137 180118 New secondary key added with "Whse. Document No." and "Registering Date".
    fields
    {
        field(50010; "Int. Register No."; Integer)
        {

        }
    }

    var
        myInt: Integer;
}