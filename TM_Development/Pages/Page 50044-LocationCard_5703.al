pageextension 50044 LocationCard extends "Location Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Cross-Dock Due Date Calc.")
        {
            field("Auto Movement for Pick Template Name"; "Auto Pick Template Name")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Auto Movement for Pick Batch Name"; "Auto Pick Batch Name")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }

            group("Create Movement for SO Cancellation")
            {
                field("Create Movement for Web Credits"; "Auto Movement for Credit Memo")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Movement Template"; "Auto Movement Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Movement Batch"; "Auto Movement Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }

            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}