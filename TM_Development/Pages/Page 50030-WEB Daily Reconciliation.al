page 50030 "WEB Daily Reconciliation"
{
    // version R4540,R4580

    // R4540 - RM - 04.02.2016
    // Added field "Deleted by Credit Memo"
    // 
    // R4580 - RM - 14.02.2016
    // Added field "Cancelled Order"

    Editable = false;
    PageType = List;
    SourceTable = "WEB Daily Reconciliation";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Type"; "WEB Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(ID; ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Value"; "WEB Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Date"; "WEB Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Invoiced; Invoiced)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Invoiced Value"; "Invoiced Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Reconciliation Complete"; "Reconciliation Complete")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Error; Error)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Ordered; Ordered)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Ordered Value"; "Ordered Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shipment Created"; "Shipment Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shipment Quantities"; "Shipment Quantities")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shipment Quantities - Magento"; "Shipment Quantities - Magento")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Further Information"; "Further Information")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Deleted by Credit Memo"; "Deleted by Credit Memo")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Cancelled Order"; "Cancelled Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(WebAdminRecord)
            {
                Caption = 'Web Admin Record';
                Image = Line;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TableID: Integer;
                    WebAdminPage: Page "WEB Index Monitoring ADMIN";
                    WebIndex: Record "WEB Index";
                begin
                    CASE "WEB Type" OF
                        "WEB Type"::Shipment:
                            TableID := 50014;
                        "WEB Type"::Order:
                            TableID := 50010;
                        "WEB Type"::Credit:
                            TableID := 50018;
                    END;

                    WebIndex.SETRANGE("Table No.", TableID);
                    WebIndex.SETRANGE("Key Field 1", ID);
                    WebAdminPage.SETTABLEVIEW(WebIndex);
                    WebAdminPage.RUN;
                end;
            }
            action(NavSalesOrder)
            {
                Caption = 'Nav Sales Order';
                Image = "Order";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    WebShipmentHeader: Record "WEB Shipment Header";
                    SalesHeader: Record 36;
                    SalesOrderNo: Code[20];
                begin
                    CASE "WEB Type" OF
                        "WEB Type"::Shipment:
                            BEGIN
                                WebShipmentHeader.SETRANGE("Shipment ID", ID);
                                WebShipmentHeader.FINDFIRST;
                                SalesOrderNo := WebShipmentHeader."Order ID";
                            END;
                        "WEB Type"::Order:
                            SalesOrderNo := ID;

                    //  Type::Credit:
                    //    TableID := 50018;
                    END;

                    IF SalesOrderNo <> '' THEN BEGIN
                        SalesHeader.SETRANGE("No.", SalesOrderNo);
                        PAGE.RUN(42, SalesHeader);
                    END;
                end;
            }
        }
    }
}

