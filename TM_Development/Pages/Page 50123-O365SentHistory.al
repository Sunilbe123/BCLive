page 50123 "O365 Sent History"
{
    PageType = List;
    Permissions = TableData 2158 = rm;
    SourceTable = 2158;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type"; "Document Type")
                {
                }
                field("Document No."; "Document No.")
                {
                }
                field(Posted; Posted)
                {
                }
                field("Created Date-Time"; "Created Date-Time")
                {
                }
                field("Source Type"; "Source Type")
                {
                }
                field("Source No."; "Source No.")
                {
                }
                field("Job Last Status"; "Job Last Status")
                {
                }
                field("Job Completed"; "Job Completed")
                {
                }
            }
        }
    }

    actions
    {
    }
}

