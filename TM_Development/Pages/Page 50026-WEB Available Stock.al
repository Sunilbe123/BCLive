page 50026 "WEB Available Stock"
{
    PageType = List;
    SourceTable = "WEB Available Stock";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(SKU; SKU)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Available Quantity"; "Available Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Shelf No."; RoxxapFunctions.ItemBin(Item."No."))
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Caption = 'Shelf No.';
                }
                field("Box Qty"; BoxQTY)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Caption = 'Box Qty';
                }
                field("Pallet Qty"; PalletQTY)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Caption = 'Pallet Qty';
                }
                field("Average Cost"; "Average Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        IF NOT Item.GET(SKU) THEN
            Item.INIT;

        IF BoxUOM.GET(SKU, 'BOX') THEN
            BoxQTY := BoxUOM."Qty. per Unit of Measure"
        ELSE
            BoxQTY := 0;


        IF PalletUOM.GET(SKU, 'PALLET') THEN
            PalletQTY := PalletUOM."Qty. per Unit of Measure"
        ELSE
            PalletQTY := 0;
    end;

    var
        Item: Record Item;
        BoxUOM: Record "Item Unit of Measure";
        PalletUOM: Record "Item Unit of Measure";
        BoxQTY: Decimal;
        PalletQTY: Decimal;
        RoxxapFunctions: Codeunit "Roxxap Functions";
}

