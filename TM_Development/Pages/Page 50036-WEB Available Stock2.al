page 50036 "WEB Available Stock2"
{
    PageType = List;
    SourceTable = "WEB Available Stock";

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
                field("Shelf No."; BinContent."Bin Code")
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
    var
        WebSetupRecL: Record "WEB Setup";
    begin
        IF NOT Item.GET(SKU) THEN
            Item.INIT;

        BinContent.RESET;
        // MITL ++
        // BinContent.SETRANGE("Location Code",'HANLEY2');
        WebSetupRecL.GET;
        WebSetupRecL.TESTFIELD("Web Location");
        BinContent.SETRANGE("Location Code", WebSetupRecL."Web Location");
        // MITL --BinContent.SETRANGE("Item No.",Item."No.");
        BinContent.SETRANGE("Bin Type Code", 'PUTPICK');
        IF BinContent.COUNT > 1 THEN
            BinContent.SETRANGE(Default, TRUE);
        IF NOT BinContent.FINDFIRST THEN
            BinContent.INIT;

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
        BinContent: Record "Bin Content";
        BoxQTY: Decimal;
        PalletQTY: Decimal;
}

