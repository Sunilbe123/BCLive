tableextension 50072 WhseShptHeader extends "Warehouse Shipment Header"
{
    //Version MITL332
    fields
    {
        // Add changes to table fields here
        field(50001; "Latest Dispatch Date"; Date)
        {
            CaptionML = ENU = 'Latest Dispatch Date', ENG = 'Latest Dispatch Date';
            Description = 'MITL332';
        }
    }

    var
        myInt: Integer;
}