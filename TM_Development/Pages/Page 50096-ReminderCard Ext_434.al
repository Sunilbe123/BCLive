pageextension 50096 ReminderCardExt extends Reminder
{
    layout
    {
        // Add changes to page layout here
        addafter("Assigned User ID")
        {
            field("Issue Reminder"; "Issue Reminder")//MITL.SP.W&F
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }

        }
    }

    actions
    {
        // Add changes to page actions here
        addafter(Issue)
        {
            action("Custom Reminder Issue")
            {
                ApplicationArea = "#Basic,#Suite";
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                CaptionML = ENU = 'Custom Reminder Issue', ENG = 'Custom Reminder Issue';//MITL.SP.W&F

                trigger OnAction()
                begin
                    CurrPage.SETSELECTIONFILTER(ReminderHeader);
                    REPORT.RUNMODAL(50008, TRUE, TRUE, ReminderHeader);
                    CurrPage.UPDATE(FALSE);
                end;


            }


        }
    }

    var
        myInt: Integer;
        ReminderHeader: Record "Reminder Header";

}