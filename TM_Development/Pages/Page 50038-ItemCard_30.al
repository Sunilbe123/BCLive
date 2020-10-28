pageextension 50038 ItemCard extends "Item Card"
{
    //ver MITL2147,MITL2219
    //MITL2147 - Added action "Expected Item Charge Calculation".
    //MITL2219 - new field added for Scale integration
    layout
    {

        // Add changes to page layout here
        addafter(PreventNegInventoryDefaultNo)
        {
            field("Manufacturer Description"; "Manufacturer Description")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'R1666';
            }
            field("Manufacturer SKU"; "Manufacturer SKU")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'R1666';
            }
            field(Size; Size)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'R1666';
            }
            field("Qty Per SQM"; "Qty Per SQM")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Product Type"; "Product Type")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL13605';
            }
            field(Status; Status)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }
        // MITL17Jan2020 ++
        addafter("Item Category Code")
        {
            field("Landed Cost"; "Landed Cost")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }
        // MITL17Jan2020 --

        addafter("Gross Weight")
        {
            field("Item Weight Tolerence %"; "Item Weight Tolerence %")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL2219';
            }
            field(Height; Height)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field(Width; Width)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
        }


        addafter(Warehouse)
        {
            group("Web Data")
            {
                field(WebItemFlag; WebItemFlag)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(WebID; WebID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(WebProdType; WebProdType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(WebPriceType; WebPriceType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(WebTierPriceSyncFlag; WebTierPriceSyncFlag)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(WebSpecialPriceSyncFlag; WebSpecialPriceSyncFlag)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(WebSyncFlag; WebSyncFlag)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field(WebStockFlag; WebStockFlag)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    actions
    {
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

            action(BinData)
            {
                ApplicationArea = Warehouse;
                CaptionML = ENU = 'Bin Data', ENG = 'Bin Data';
                RunObject = page "Bin Data List";
                Image = BinLedger;
                RunPageLink = "Item No." = FIELD("No.");
            }
        }

        Modify("&Bin Contents")
        {
            Visible = false;
        }
        //MITL2193 **
    }

    var
        myInt: Integer;
}