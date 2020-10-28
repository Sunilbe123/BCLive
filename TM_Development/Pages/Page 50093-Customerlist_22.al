pageextension 50093 CustomerListExt extends "Customer List"
{
    layout
    {
        // Add changes to page layout here
        addafter("Phone No.")
        {
            field("E-Mail"; "E-Mail")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Wholesale Customer"; "Wholesale Customer")   //SM-17-02-2020
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';

            }
            field("Invoice Disc. Facility Availed"; "Invoice Disc. Facility Availed") //MITL.SP.W&F
            {
                Description = 'MITL.SP.W&F';
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }
        addbefore("Phone No.")
        {
            field(Address; Address)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITLP59.AJ.17MAR2020';
            }
            field("Address 2"; "Address 2")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITLP59.AJ.17MAR2020';
            }
            field(City; City)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITLP59.AJ.17MAR2020';
            }
        }

        addafter("Privacy Blocked")
        {
            field("No. of Orders"; "No. of Orders")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }

            field("No. of Invoices"; "No. of Invoices")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("No. of Pstd. Shipments"; "No. of Pstd. Shipments")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }

            field("No. of Pstd. Invoices"; "No. of Pstd. Invoices")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            //MITL.7403++
            field("Company Registration No."; "Company Registration No.")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL.7403';
            }
            //MITL.7403--
        }
        addafter(CustomerStatisticsFactBox)
        {
            part("Comment List"; "Comment List Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Comment List';
                SubPageLink = "Table Name" = Const(Customer), "No." = field("No.");
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        //MITL3895 ++
        addafter(Statement)
        {
            action("Custom Statement")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Image = Report;
                Caption = 'Custom Statement';

                trigger OnAction()
                begin
                    Report.RunModal(50020, true, false);
                end;
            }
            action("Send Statement as E-mail")

            {
                image = SendMail;
                Promoted = true;
                trigger OnAction()
                var
                    recStatSendQueue: Record "Statement Email Queue";
                    Customer: Record Customer;
                    Window: Dialog;
                    LastEntryNo: Integer;
                begin
                    // MITL.SM.Improvement in Statement Sending through e-mail ++
                    if Confirm('Do you want to add the selected Customers in Statement Send Queue?', true, false) then begin
                        Window.Open('Adding Customer #1#############');
                        CurrPage.SetSelectionFilter(Customer);
                        if Customer.FindSet() then
                            repeat
                                recStatSendQueue.Reset();
                                if recStatSendQueue.FindLast() then
                                    LastEntryNo := recStatSendQueue."Entry No."
                                else
                                    LastEntryNo := 0;
                                Window.Update(1, Customer."No.");
                                recStatSendQueue.Init();
                                recStatSendQueue."Entry No." := LastEntryNo + 1;
                                recStatSendQueue."Customer No." := Customer."No.";
                                recStatSendQueue."Created Data Time" := CurrentDateTime();
                                recStatSendQueue.Status := recStatSendQueue.Status::New;
                                recStatSendQueue.Insert();
                                Commit();
                            until Customer.Next() = 0;
                        Window.Close();
                        Message('Customer added to Queue');
                    end;
                    // MITL.SM.Improvement in Statement Sending through e-mail --
                end;
            }
            action("Print Statement")
            {
                image = Print;
                Promoted = true;
                trigger OnAction()
                var
                    StartDate: Date;
                    EndDate: Date;
                    Customer: Record Customer;
                    StandardStatement: Report StandardCustomerStatement;
                    RecRef: RecordRef;
                begin
                    if Confirm('Do you want to Print the Statements', true, false) then begin
                        StartDate := DMY2Date(01, 08, 2019);

                        EndDate := CALCDATE('<CM>', WORKDATE);
                        Customer.RESET;
                        Customer.SetRange("Statement/Reminder", Customer."Statement/Reminder"::Print);
                        if Customer.FindSet() then
                            RecRef.GETTABLE(Customer);
                        CLEAR(StandardStatement);
                        StandardStatement.USEREQUESTPAGE(FALSE);
                        StandardStatement.InitializeRequest(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, '1M+CM', 1, FALSE, StartDate, EndDate, Customer."No.");
                        StandardStatement.SETTABLEVIEW(Customer);
                        //StandardStatement.Print('', '', RecRef);
                        StandardStatement.Run();
                    end;
                end;
            }
        }
        //MITL3895 **
    }

    var
        myInt: Integer;
}