page 50095 PostBulkPicks
{
    PageType = List;
    Caption = 'Post Bulk Picks';
    ApplicationArea = Basic, Suite;
    UsageCategory = Tasks;
    SourceTable = "Miniform Header";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Registered; Registered)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action("Register Picks")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Image = Register;
                Visible = true;
                trigger OnAction();
                var
                    RegisterPick: Codeunit RegisterUnhandledPicks;
                    SalesHeaderL: Record "Sales Header";
                begin
                    repeat
                        SalesHeaderL.Reset();
                        SalesHeaderL.SetRange("Document Type", SalesHeaderL."Document Type"::Order);
                        SalesHeaderL.SetRange("No.", Code);
                        IF SalesHeaderL.FindFirst() THEN begin
                            RegisterPick.SetSalesOrder(SalesHeaderL);
                            RegisterPick.Run();
                            Registered := true;
                        END;
                    until Next() = 0;
                    Message('Done');
                end;
            }
        }
    }
    var
        Registered: Boolean;
}