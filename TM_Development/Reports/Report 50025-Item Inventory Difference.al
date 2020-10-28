report 50025 "Item Inventory Difference"
{
    DefaultLayout = RDLC;
    RDLCLayout = '.\ItemInventoryDiff.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Item Inventory Difference';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem(Item; Item)
        {
            column(No; "No.")
            {
            }
            column(Description; Description)
            {
            }
            column(BaseUnitofMeasure; "Base Unit of Measure")
            {
            }
            column(UnitPrice; "Unit Price")
            {
            }
            column(UnitCost; "Unit Cost")
            {
            }
            column(CostingMethod; "Costing Method")
            {
            }
            column(Inventory; Inventory)
            {
            }
            column(AmtDiff; AmtDiff)
            { }
            column(QtyDiff; QtyDiff)
            { }
            column(BinQty; BinQty)
            { }
            //MITLDJ 14July2020++
            column(companyInfo_Name; ReccompanyInfo.Name)
            { }
            column(Location; Location)
            { }
            column(BinADJQty; BinADJQty)
            { }
            column(VarInventory; VarInventory) { }
            //MITLDJ 14July2020--

            trigger OnPreDataItem()
            begin
                //MITLDJ 18jun2020++
                //Message(CompanyName);
                ReccompanyInfo.Get();
                if ReccompanyInfo.Name = 'Tile Mountain Ltd.' then
                    Item.SetFilter("Location Filter", 'HANLEY2|TUNSTALL')
                else begin
                    if ReccompanyInfo.Name = 'Walls and Floors Limited' then
                        Item.SetFilter("Location Filter", 'MAIN')
                end;

                CompanyName := ReccompanyInfo.Name; //MITLDJ 14July2020
                Location := Item.GetFilter("Location Filter");//MITLDJ 14July2020
                //MITLDJ 18jun2020--
            end;

            trigger OnAfterGetRecord()
            begin
                BinQty := 0;
                QtyDiff := 0;
                AmtDiff := 0;
                BinADJQty := 0;

                BinContRec.RESET;
                BinContRec.SETCURRENTKEY("Quantity (Base)");
                BinContRec.SETRANGE(BinContRec."Item No.", Item."No.");
                IF BinContRec.FIND('-') THEN BEGIN
                    REPEAT
                        BinContRec.CALCFIELDS("Quantity (Base)");
                        BinQty := BinQty + BinContRec."Quantity (Base)";

                    UNTIL BinContRec.NEXT = 0;
                END;

                //MITLDJ 14July2020++
                WHouseEntRec.Reset;
                WHouseEntRec.SetRange("Bin Code", 'ADJ');
                WHouseEntRec.SetFilter("Location Code", Location);
                WHouseEntRec.SetRange("Item No.", Item."No.");
                If WHouseEntRec.FindSet() then begin
                    repeat
                        BinADJQty := BinADJQty + WHouseEntRec."Qty. (Base)";
                    until WHouseEntRec.Next = 0;
                end;

                VarInventory := Item.Inventory - BinADJQty;
                QtyDiff := VarInventory - BinQty;
                AmtDiff := QtyDiff * Item."Unit Cost";

                //MITLDJ 14July2020--
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }

    var
        LocationRec: Record Location;
        BinContRec: Record "Bin Content";
        QtyDiff: Decimal;
        BinQty: Decimal;
        AmtDiff: Decimal;
        ReccompanyInfo: Record "Company Information";//MITLDJ 18Jun2020

        WHouseEntRec: Record "Warehouse Entry";//MITLDJ 14July2020
        BinADJQty: Decimal;//MITLDJ 14July2020

        VarInventory: Decimal;//MITLDJ 14July2020
        CompanyName: Text[50];
        Location: Text[30];
        QtyExADJ: Decimal;

}
