query 50002 "Stockport Showroom Stock"
{
    TopNumberOfRows = 5000;
    CaptionML = ENU = 'Stockport Showroom Stock', ENG = 'Stockport Showroom Stock';
    QueryType = Normal;
    elements
    {
        dataitem(Item; Item)
        {
            column(No; "No.")
            {
            }
            column(Description; Description)
            {
            }
            column(Inventory; Inventory)
            {
            }
            filter(Location_Filter; "Location Filter")
            {
                ColumnFilter = Location_Filter = CONST ('STOCKPORT');
            }
        }
    }
}

