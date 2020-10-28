report 50006 "Pick Deletion"
{
    //Verison MITL2777 - Delete all the Picks
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Warehouse Activity Header"; "Warehouse Activity Header")
        {
            DataItemTableView = SORTING (Type, "No.") ORDER(Ascending) WHERE (Type = CONST (Pick));

            trigger OnPreDataItem()
            begin
                //MITL2777 ++
                IF SelectOption = SelectOption::"Pick Deletion" THEN BEGIN
                    WarehouseActivityHeader.RESET;
                    WarehouseActivityHeader.SETFILTER("Location Code", Location);
                    IF WarehouseActivityHeader.FINDSET THEN BEGIN
                        WarehouseActivityHeader.DELETEALL(TRUE);
                    END;
                END;
                //MITL2777 **
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field("Select Option"; SelectOption)
                    {
                        ApplicationArea = All;

                    }
                    field(Location; Location)
                    {
                        TableRelation = Location.Code;

                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    var
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        SelectOption: Option "","Pick Deletion";
        Location: Text;
}