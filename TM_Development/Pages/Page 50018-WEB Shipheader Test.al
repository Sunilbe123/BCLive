page 50018 "WEB Shipheader Test"
{
    SourceTable = "WEB Shipment Header";


    layout
    {
        area(content)
        {
            group(Group1)
            {
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shipment ID"; "Shipment ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order ID"; "Order ID")
                {

                    trigger OnAssistEdit()
                    var
                        WebOrderHeader: Record "WEB Order Header";
                    begin
                        WebOrderHeader.SETRANGE("Order ID", "Order ID");
                        PAGE.RUNMODAL(PAGE::"WEB Order Header", WebOrderHeader);
                    end;
                }
                field("Type"; "LineType")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("DateTime"; "Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Index No."; "Index No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Order Exists"; "Order Exists")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shipment Count"; "Shipment Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
            part("Web shiplines Test"; "WEB Shiplines Test")
            {
                SubPageLink = "Shipment ID" = FIELD("Shipment ID");
                SubPageView = SORTING("Order ID", "LineType", "Date Time", "Line No")
                              ORDER(Ascending);
            }
        }
    }

    actions
    {
    }
}

