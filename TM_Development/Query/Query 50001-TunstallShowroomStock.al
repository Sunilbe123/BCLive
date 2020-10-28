query 50001 "Tunstall Showroom Stock"
{
    TopNumberOfRows = 5000;
    CaptionML = ENU = 'Tunstall Showroom Stock', ENG = 'Tunstall Showroom Stock';
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
                ColumnFilter = Location_Filter = CONST ('SHOP');
            }
        }
    }
}

