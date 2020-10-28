pageextension 50058 ItemList extends "Item List"
{
    //MITL2147 - Added action "Expected Item Charge Calculation".
    layout
    {
        // Add changes to page layout here
        addafter(Description)

        {
            field(Size; Size)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Qty Per SQM"; "Qty Per SQM")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field(Status; Status) { }
            field("Net Weight"; "Net Weight")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Gross Weight"; "Gross Weight")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            // MITL17Jan2020 ++
            field("Landed Cost"; "Landed Cost")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            // MITL17Jan2020 --
        }

        addafter(InventoryField)
        {
            field("Qty. on Sales Order"; "Qty. on Sales Order") { }
            field("Qty. on Purch. Order"; "Qty. on Purch. Order") { }
        }
    }

    actions
    {
        // Add changes to page actions here
        //MITL2147 ++
        addafter(Purchases)
        {
            action("Expected Item Charge Calculation")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                CaptionML = ENU = 'Expected Item Charge Calculation', ENG = 'Expected Item Charge Calculation';
                Image = ItemCosts;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page ItemChargeCalculation;
                RunPageLink = "Item No." = field("No.");

                trigger OnAction()
                begin

                end;
            }
        }
        //MITL2147 **

        //MITL2193 ++
        addafter("Stockkeepin&g Units")
        {
            action(BinContentsCustom)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Bin Contents', ENG = 'Bin Contents';
                Image = BinContent;
                RunObject = page "Bin Contents";
                RunPageView = sorting("Item No.");
                RunPageLink = "Item No." = field("No.");

                trigger OnAction()
                begin

                end;
            }
        }

        Modify("&Bin Contents")
        {
            Visible = false;
        }
        //MITL2193 **
    }

    var
    //MITL.AJ.03032020 no use of variables.
    // myInt: Integer;
    // BinDataTbl: Record "Bin Data Update";
    // BinContenTbl: Record "Bin Content";
    // TotalStockInBin: Decimal;
    // TotalStockInPutAway: Decimal;
    // AvailableStock: Decimal;
    // RecItem: Record Item;
}