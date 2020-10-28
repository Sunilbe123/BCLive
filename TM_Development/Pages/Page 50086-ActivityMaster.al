page 50086 "Activity Master"
{
    Caption = 'Activity Master';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Activity Master";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Activity Code"; "Activity Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                    Caption = 'Credit Memo ID';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                    Caption = 'Payment Method';
                }
                field("Activity Barcode"; "Activity Barcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                    Visible = false;
                }
                field("Activity Type"; "Activity Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL13989';
                    Visible = false;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdatePaymentMethodInCredits)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Caption = 'Update Payment Method in WEB Credits';

                trigger OnAction()
                var
                    WebCrditHeader: Record "WEB Credit Header";
                begin
                    repeat
                        WebCrditHeader.Reset();
                        WebCrditHeader.SetRange("Credit Memo ID", "Activity Code");
                        IF WebCrditHeader.FindFirst() then begin
                            WebCrditHeader."Payment Method" := Description;
                            WebCrditHeader.Modify();
                        ENd;
                    until Next() = 0;
                    Message('Done');
                end;
            }

            action(UpdateYourRefInPostedInv)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Caption = 'Update Your Reference in Posted Invoices';

                trigger OnAction()
                var
                    UpdateYourRef: Report UpdateYourRefInSaleInv;
                begin
                    repeat
                        UpdateYourRef.SetInvoiceNo("Activity Code", Description);
                        UpdateYourRef.Run();
                        Clear(UpdateYourRef);
                    until Next() = 0;
                    Message('Done');
                end;
            }
        }
    }

    var
        myInt: Integer;
}