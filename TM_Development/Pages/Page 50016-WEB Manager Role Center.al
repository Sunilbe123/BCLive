page 50016 "WEB Manager Role Center"
{
    // version NAVW17.10


    Caption = 'Role Center';
    PageType = RoleCenter;


    layout
    {
        area(rolecenter)
        {
            group(Group1)
            {
                part("WEB Processor Activities"; 50015)
                {
                    ApplicationArea = All;
                }
            }
            group(Group2)
            {
                part("My Customers"; 9150)
                {
                    ApplicationArea = All;
                }
                part("My Items"; 9152)
                {
                    ApplicationArea = All;
                }
                // part("Connect Online";9175)
                // {
                //     Visible = false;
                // }
                systempart(MyNotes; MyNotes)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(reporting)
        {
            action("Customer - &Order Summary")
            {
                Caption = 'Customer - &Order Summary';
                Image = "Report";
                RunObject = Report 107;
            }
            action("Customer - &Top 10 List")
            {
                Caption = 'Customer - &Top 10 List';
                Image = "Report";
                RunObject = Report 111;
            }


        }
        area(embedding)
        {
            action("Sales Orders")
            {
                Caption = 'Sales Orders';
                Image = "Order";
                RunObject = Page 9305;
            }
            action("Open Sales Order List")
            {
                Caption = 'Open';
                Image = Edit;
                RunObject = Page 9305;
                RunPageView = WHERE(Status = FILTER(Open));
                ShortCutKey = 'Return';
            }
            action("Sales Invoices")
            {
                Caption = 'Sales Invoices';
                Image = Invoice;
                RunObject = Page 9301;
            }
            action("Open Sales Invoice List")
            {
                Caption = 'Open';
                Image = Edit;
                RunObject = Page 9301;
                RunPageView = WHERE(Status = FILTER(Open));
                ShortCutKey = 'Return';
            }
            action(Items)
            {
                Caption = 'Items';
                Image = Item;
                RunObject = Page 31;
            }
            action(Customers)
            {
                Caption = 'Customers';
                Image = Customer;
                RunObject = Page 22;
            }
            action("WEB Admin")
            {
                RunObject = Page 50014;
            }
            action("WEB Daily Reconcilliation")
            {
                RunObject = Page 50030;
            }
            action("WEB Write Offs")
            {
                RunObject = Page 50033;
            }
            action("WEB Combined Picks")
            {
                RunObject = Page 50032;
            }
            action("WEB User Scan")
            {
                RunObject = Page 50034;
            }
        }
        area(processing)
        {
        }
    }
}

