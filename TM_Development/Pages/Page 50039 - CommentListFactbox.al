page 50039 "Comment List Factbox"
{
    Caption = 'Comments';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;  //MITL-SA - we should only use ListPart type as List will be obsolete in next versin
    SourceTable = "Comment Line";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Date&Time"; "Date&Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Attachement; "File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }

    }

    var
        NoOfComments: Integer;

}