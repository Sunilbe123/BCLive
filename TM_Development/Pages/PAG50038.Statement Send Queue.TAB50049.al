// MITL.SM.Improvement in Statement Sending through e-mail
page 50038 "Statement Send Queue"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Statement Email Queue";

    layout
    {
        area(Content)
        {
            repeater(Data)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';

                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';

                }
                field("Created Data Time"; Rec."Created Data Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Statement Sent Date Time"; Rec."Statement Sent Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Error Details"; Rec."Error Details")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Reset Error Status")
            {
                ApplicationArea = All;

                trigger OnAction()

                begin
                    if Status = Status::Error then begin
                        Status := Status::New;
                        "Error Details" := '';
                        Modify();
                        CurrPage.Update();
                    end;
                end;
            }
            action("Send Statement")
            {
                Image = Email;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = codeunit "Statement Send Processing";
            }
        }
    }

    var
        myInt: Integer;
}