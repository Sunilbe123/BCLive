page 50073 "Bin Data Updation"
{
    PageType = List;
    SourceTable = "Bin Data Update";
    UsageCategory = Tasks;
    Caption = 'Bin Data Updation';
    ApplicationArea = All;
    layout
    {
        // Add changes to page layout here
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Modified DateTime"; "Modified DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        area(Processing)
        {
            action("Update Historical Bin Data")
            {
                AccessByPermission = TableData 50001 = RIM;
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Visible = false; //MITL.AJ.03032020 On request of MATT stock values will be read from SQL now.
                // trigger OnAction();
                // begin
                //     RecItem.Reset;
                //     If RecItem.FindFirst then begin
                //         repeat
                //             TotalStockInBin := 0;
                //             TotalStockInPutAway := 0;
                //             AvailableStock := 0;

                //             BinContenTbl.Reset;
                //             BinContenTbl.SetRange("Item No.", RecItem."No.");
                //             BinContenTbl.SetFilter("Bin Code", '<>%1', 'SHIPPING'); //MITL2144
                //             if BinContenTbl.FindFirst then begin
                //                 repeat
                //                     BinContenTbl.CalcFields("Pick Qty.", "Put-away Qty.");
                //                     TotalStockInBin += BinContenTbl."Pick Qty.";
                //                     TotalStockInPutAway += BinContenTbl."Put-away Qty.";
                //                     AvailableStock += BinContenTbl.CalcQtyAvailToTakeUOM;
                //                 until BinContenTbl.Next = 0;
                //             end;

                //             InsertBinData(RecItem."No.", TotalStockInBin, TotalStockInPutAway, AvailableStock);

                //             TotalStockInBin := 0;
                //             TotalStockInPutAway := 0;
                //             AvailableStock := 0;

                //         until RecItem.Next = 0;
                //         Message('Bin Data update is finished');
                //     end;
                // end;
                //MITL.AJ.03032020 On request of MATT stock values will be read from SQL now.
            }
        }
    }

    //MITL.AJ.03032020 On request of MATT stock values will be read from SQL now.
    // local procedure InsertBinData(ItemNoL: Code[20]; TotalStockInBinP: Decimal; TotalStockInPutAwayP: Decimal; AvailableStockP: Decimal)
    // var
    //     BinDataTbl: Record "Bin Data Update";
    //     BinDataNewTbl: Record "Bin Data Update";
    //     EntryNo: Integer;
    // begin
    //     BinDataTbl.Reset;
    //     BinDataTbl.SetRange("Item No.", ItemNoL);
    //     BinDataTbl.SetRange("Magento Update", false);
    //     if not BinDataTbl.FindFirst then begin
    //         BinDataNewTbl.Reset;
    //         if BinDataNewTbl.FindLast then
    //             EntryNo := BinDataNewTbl."Entry No." + 1
    //         else
    //             EntryNo := 1;

    //         BinDataTbl.Init;
    //         BinDataTbl."Entry No." := EntryNo;
    //         BinDataTbl."Item No." := ItemNoL;
    //         BinDataTbl."Total Stock In Picking Bins" := TotalStockInBinP;
    //         BinDataTbl."Total Stock In Put-Away Bins" := TotalStockInPutAwayP;
    //         BinDataTbl."Available Stock" := AvailableStockP;
    //         BinDataTbl."Magento Update" := false;
    //         BinDataTbl."Modified DateTime" := CurrentDateTime();
    //         BinDataTbl.Insert;
    //         Commit;
    //     end else begin
    //         BinDataTbl."Total Stock In Picking Bins" := TotalStockInBinP;
    //         BinDataTbl."Total Stock In Put-Away Bins" := TotalStockInPutAwayP;
    //         BinDataTbl."Available Stock" := AvailableStockP;
    //         BinDataTbl."Magento Update" := false;
    //         BinDataTbl."Modified DateTime" := CurrentDateTime();
    //         BinDataTbl.Modify;
    //         Commit;
    //     end;
    // end;
    //MITL.AJ.03032020 On request of MATT stock values will be read from SQL now. **
    var
    //MITL.AJ.03032020 variables not used.
    // myInt: Integer;
    // BinDataTbl: Record "Bin Data Update";
    // BinDataTbl1: Record "Bin Data Update";
    // BinContenTbl: Record "Bin Content";
    // TotalStockInBin: Decimal;
    // TotalStockInPutAway: Decimal;
    // AvailableStock: Decimal;
    // RecItem: Record Item;
    // EntryNo: Integer;
}