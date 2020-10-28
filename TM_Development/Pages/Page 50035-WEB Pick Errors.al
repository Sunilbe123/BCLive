page 50035 "WEB Pick Errors"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Sales Line";
    SourceTableView = SORTING("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date")
                      WHERE("Document Type" = CONST(Order),
                            Type = CONST(Item));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Pick Line Qty"; "Pick Line Qty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Picked Line Qty"; "Picked Line Qty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Error Line"; ErrorLine)
                {
                    Caption = 'Error Line';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CALCFIELDS("Pick Line Qty", "Picked Line Qty");

        IF ("Pick Line Qty" + "Picked Line Qty") < Quantity THEN
            ErrorLine := 'TRUE'
        ELSE
            ErrorLine := '';
    end;

    trigger OnOpenPage()
    var
        WebSetpRecL: Record "WEB Setup";
    begin
        // MITL ++
        WebSetpRecL.GET;
        WebSetpRecL.TESTFIELD("Web Location");
        SETRANGE("Location Code", WebSetpRecL."Web Location");
        // MITL --
    end;

    var
        ErrorLine: Text;
}

