report 50026 "Pending Whse Shipment"
{
    DefaultLayout = RDLC;
    RDLCLayout = '.\PendingWhseShipment.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableView = where ("Document Type" = const (Order));

            column(SalesOrderNo; "No.") { }
            column(WebIncrementID; WebIncrementID) { }
            column(Location_Code; "Location Code") { }
            column(OutstandQty; OutstandQty) { }

            trigger OnAfterGetRecord()
            var
                SalesLine: Record "Sales Line";
                WhseShipLine: Record "Warehouse Shipment Line";
                PostedWhseShipLine: Record "Posted Whse. Shipment Line";
                RegdPickLine: Record "Registered Whse. Activity Line";

            begin
                // Error('');
                PostedWhseShipLine.Reset();
                PostedWhseShipLine.SetRange("Source Type", 37);
                PostedWhseShipLine.SetRange("Source Subtype", 1);
                PostedWhseShipLine.SetRange("Source No.", "No.");
                if PostedWhseShipLine.FindFirst() then
                    CurrReport.Skip();

                RegdPickLine.Reset();
                RegdPickLine.SetRange("Source Type", 37);
                RegdPickLine.SetRange("Source Subtype", 1);
                RegdPickLine.SetRange("Source No.", "No.");
                If RegdPickLine.FindFirst() then
                    CurrReport.Skip();

                WhseShipLine.RESET;
                WhseShipLine.SETRANGE("Source Type", 37);
                WhseShipLine.SETRANGE("Source Subtype", 1);
                WhseShipLine.SETRANGE("Source No.", "No.");
                IF WhseShipLine.FINDFIRST THEN
                    CurrReport.Skip();

                OutstandQty := 0;
                SalesLine.RESET;
                SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SETRANGE("Document No.", "No.");
                SalesLine.SetRange(Type, SalesLine.Type::Item);
                SalesLine.SetRange("Location Code", 'TUNSTALL');
                SalesLine.SETFILTER("Outstanding Quantity", '>0');
                IF SalesLine.FINDSET THEN
                    REPEAT
                        OutstandQty := OutstandQty + SalesLine."Outstanding Quantity";
                    UNTIL SalesLine.NEXT = 0
                ELSE
                    CurrReport.SKIP;

            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    // field(Name; SourceExpression)
                    // {
                    //     ApplicationArea = All;

                    // }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    var
        OutstandQty: Decimal;
}