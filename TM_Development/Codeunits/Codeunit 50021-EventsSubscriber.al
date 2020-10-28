codeunit 50021 Events_Subscribers
{
    Permissions = tabledata 454 = rimd;//MITL_VS_Continia_26.05.20
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeDeleteEvent', '', false, false)]
    Local procedure DeleteWarehouseEntries(VAR Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        WhseActiLineL: Record "Warehouse Activity Line";
        WhseActiHeadL: Record "Warehouse Activity Header";
        LocationL: Record Location;
        WhseShptLineL: Record "Warehouse Shipment Line";
        ReleaseWhseShptDocL: Codeunit "Whse.-Shipment Release";
        WhseShptHeadL: Record "Warehouse Shipment Header";
        WhseShptHeadDelL: Record "Warehouse Shipment Header";
    begin
        WhseActiLineL.Reset();
        WhseActiLineL.SetCurrentKey("Source Document", "Source No.", "Whse. Document Type", "Action Type"); // MITL.SM.20200503 Indexing correction
        WhseActiLineL.SetRange("Source Document", WhseActiLineL."Source Document"::"Sales Order");
        WhseActiLineL.SETRANGE("Source No.", Rec."Document No.");
        WhseActiLineL.SetRange("Whse. Document Type", WhseActiLineL."Whse. Document Type"::Shipment);
        WhseActiLineL.SetRange("Action Type", WhseActiLineL."Activity Type"::Pick);
        IF WhseActiLineL.FINDSET THEN begin
            repeat
                IF WhseActiHeadL.Get(WhseActiLineL."Action Type", WhseActiLineL."No.") THEN
                    WhseActiHeadL.Delete(TRUE);
            until WhseActiLineL.Next() = 0;
        End;

        // CASE 13601
        IF (Rec.Quantity = Rec."Outstanding Quantity") AND (Rec.Type = Rec.Type::Item) THEN
            IF LocationL.GET(Rec."Location Code") THEN begin
                IF LocationL."Auto Movement for Credit Memo" THEN
                    Rec.CreateMovementLines;
                // Rec.PostMovementLines(); // MITL2879
            End;

        Rec.SuspendStatusCheck(true);

        IF (Rec.Quantity <> 0) AND Rec.ItemExists(Rec."No.") THEN BEGIN
            WhseShptLineL.SETCURRENTKEY(
                "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Assemble to Order"); // MITL.SM.20200503 Indexing correction
            WhseShptLineL.SETRANGE("Source Type", 37);
            WhseShptLineL.SETRANGE("Source Subtype", 1);
            WhseShptLineL.SETRANGE("Source No.", Rec."Document No.");
            WhseShptLineL.SETRANGE("Source Line No.", Rec."Line No.");
            IF WhseShptLineL.FINDFIRST THEN
                repeat
                    IF WhseShptHeadL.Get(WhseShptLineL."No.") THEN
                        ReleaseWhseShptDocL.Reopen(WhseShptHeadL);
                    WhseShptLineL.DELETE();
                Until WhseShptLineL.Next() = 0;
            // MITL.5442.SM.240120202 ++
            WhseShptLineL.Reset();
            WhseShptLineL.SetRange("No.", WhseShptHeadL."No.");
            if WhseShptLineL.IsEmpty() then begin

                if WhseShptHeadDelL.Get(WhseActiHeadL."No.") then begin
                    ReleaseWhseShptDocL.Reopen(WhseShptHeadDelL);
                    IF WhseShptHeadDelL.Delete(true) THEN;
                end
                else
                    if WhseShptHeadDelL.Get(WhseShptHeadL."No.") then begin
                        ReleaseWhseShptDocL.Reopen(WhseShptHeadDelL);
                        IF WhseShptHeadDelL.Delete(true) THEN;
                    end;
                // MITL.5442.SM.24012020 --
            END;
            // CASE 13601
        end;

    end;
    //MITL1600 ++
    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'No.', False, False)]
    Local procedure UpdateItemSize(VAR Rec: Record "Purchase Line"; VAR xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        ItemL: Record Item;
    begin
        IF Rec.Type = Rec.Type::Item then begin
            IF (Rec."No." <> '') AND (Rec."No." <> xRec."No.") then
                IF ItemL.Get(Rec."No.") then
                    Rec.Size := ItemL.Size;
        End;
    end;
    //MITL1600 **

    //MITL3772 ++
    [EventSubscriber(ObjectType::Table, 271, 'OnAfterCopyFromGenJnlLine', '', False, False)]
    Local procedure UpdateBankAccLedgerDescription(VAR BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        CustL: Record Customer;
    Begin
        IF BankAccountLedgerEntry.Description = '' then
            IF GenJournalLine.Description <> '' THEN
                BankAccountLedgerEntry.Description := GenJournalLine.Description
            ELSE BEGIN
                IF CustL.Get(GenJournalLine."Account No.") then
                    BankAccountLedgerEntry.Description := CustL.Name;
            END;
    End;
    //MITL3772 **
    //MITL.AJ.03032020 On request of MATT stock values will be read from SQL now. ++
    // [EventSubscriber(ObjectType::Table, 7312, 'OnAfterInsertEvent', '', False, False)]
    // Local procedure UpdateBinDataTbl(VAR Rec: Record "Warehouse Entry"; RunTrigger: Boolean)
    // var
    //     BinDataTbl: Record "Bin Data Update";
    //     BinContenTbl: Record "Bin Content";
    //     TotalStockInBin: Decimal;
    //     TotalStockInPutAway: Decimal;
    //     AvailableStock: Decimal;
    // begin
    //     IF Rec.IsTemporary then
    //         exit;

    //     TotalStockInBin := 0;
    //     TotalStockInPutAway := 0;
    //     AvailableStock := 0;

    //     BinContenTbl.Reset;
    //     BinContenTbl.SETCURRENTKEY("Item No.");
    //     BinContenTbl.SetRange("Item No.", Rec."Item No.");
    //     BinContenTbl.SetFilter("Bin Code", '<>%1', 'SHIPPING'); //MITL2144
    //     if BinContenTbl.FindFirst then begin
    //         repeat
    //             BinContenTbl.CalcFields("Pick Qty.", "Put-away Qty.");
    //             TotalStockInBin += BinContenTbl."Pick Qty.";
    //             TotalStockInPutAway += BinContenTbl."Put-away Qty.";
    //             AvailableStock += BinContenTbl.CalcQtyAvailToTakeUOM;
    //         until BinContenTbl.Next = 0;
    //     end;

    //     InsertBinData(Rec."Item No.", TotalStockInBin, TotalStockInPutAway, AvailableStock);

    //     TotalStockInBin := 0;
    //     TotalStockInPutAway := 0;
    //     AvailableStock := 0;

    // end;


    // [EventSubscriber(ObjectType::Table, 7312, 'OnAfterModifyEvent', '', False, False)]
    // Local procedure UpdateBinDataTbl2(VAR Rec: Record "Warehouse Entry"; VAR xRec: Record "Warehouse Entry"; RunTrigger: Boolean)
    // var
    //     BinDataTbl: Record "Bin Data Update";
    //     BinContenTbl: Record "Bin Content";
    //     TotalStockInBin: Decimal;
    //     TotalStockInPutAway: Decimal;
    //     AvailableStock: Decimal;
    // begin
    //     IF Rec.IsTemporary then
    //         exit;

    //     TotalStockInBin := 0;
    //     TotalStockInPutAway := 0;
    //     AvailableStock := 0;

    //     BinContenTbl.Reset;
    //     BinContenTbl.SETCURRENTKEY("Item No.");
    //     BinContenTbl.SetRange("Item No.", Rec."Item No.");
    //     BinContenTbl.SetFilter("Bin Code", '<>%1', 'SHIPPING'); //MITL2144
    //     if BinContenTbl.FindFirst then begin
    //         repeat
    //             BinContenTbl.CalcFields("Pick Qty.", "Put-away Qty.");
    //             TotalStockInBin += BinContenTbl."Pick Qty.";
    //             TotalStockInPutAway += BinContenTbl."Put-away Qty.";
    //             AvailableStock += BinContenTbl.CalcQtyAvailToTakeUOM;
    //         until BinContenTbl.Next = 0;
    //     end;

    //     InsertBinData(Rec."Item No.", TotalStockInBin, TotalStockInPutAway, AvailableStock);

    //     TotalStockInBin := 0;
    //     TotalStockInPutAway := 0;
    //     AvailableStock := 0;
    // end;

    // [EventSubscriber(ObjectType::Table, 5767, 'OnAfterInsertEvent', '', False, False)]
    // Local procedure UpdateBinDataTbl3(VAR Rec: Record "Warehouse Activity Line"; RunTrigger: Boolean)
    // var
    //     BinDataTbl: Record "Bin Data Update";
    //     BinContenTbl: Record "Bin Content";
    //     TotalStockInBin: Decimal;
    //     TotalStockInPutAway: Decimal;
    //     AvailableStock: Decimal;
    // begin
    //     IF Rec.IsTemporary then
    //         exit;

    //     TotalStockInBin := 0;
    //     TotalStockInPutAway := 0;
    //     AvailableStock := 0;

    //     BinContenTbl.Reset;
    //     BinContenTbl.SETCURRENTKEY("Item No.");
    //     BinContenTbl.SetRange("Item No.", Rec."Item No.");
    //     BinContenTbl.SetFilter("Bin Code", '<>%1', 'SHIPPING'); //MITL2144
    //     if BinContenTbl.FindFirst then begin
    //         repeat
    //             BinContenTbl.CalcFields("Pick Qty.", "Put-away Qty.");
    //             TotalStockInBin += BinContenTbl."Pick Qty.";
    //             TotalStockInPutAway += BinContenTbl."Put-away Qty.";
    //             AvailableStock += BinContenTbl.CalcQtyAvailToTakeUOM;
    //         until BinContenTbl.Next = 0;
    //     end;

    //     InsertBinData(Rec."Item No.", TotalStockInBin, TotalStockInPutAway, AvailableStock);

    //     TotalStockInBin := 0;
    //     TotalStockInPutAway := 0;
    //     AvailableStock := 0;
    // end;


    // [EventSubscriber(ObjectType::Table, 5767, 'OnAfterModifyEvent', '', False, False)]
    // Local procedure UpdateBinDataTbl4(VAR Rec: Record "Warehouse Activity Line"; VAR xRec: Record "Warehouse Activity Line"; RunTrigger: Boolean)
    // var
    //     BinDataTbl: Record "Bin Data Update";
    //     BinContenTbl: Record "Bin Content";
    //     TotalStockInBin: Decimal;
    //     TotalStockInPutAway: Decimal;
    //     AvailableStock: Decimal;
    // begin
    //     IF Rec.IsTemporary then
    //         exit;

    //     TotalStockInBin := 0;
    //     TotalStockInPutAway := 0;
    //     AvailableStock := 0;

    //     BinContenTbl.Reset;
    //     BinContenTbl.SETCURRENTKEY("Item No.");
    //     BinContenTbl.SetRange("Item No.", Rec."Item No.");
    //     BinContenTbl.SetFilter("Bin Code", '<>%1', 'SHIPPING'); //MITL2144
    //     if BinContenTbl.FindFirst then begin
    //         repeat
    //             BinContenTbl.CalcFields("Pick Qty.", "Put-away Qty.");
    //             TotalStockInBin += BinContenTbl."Pick Qty.";
    //             TotalStockInPutAway += BinContenTbl."Put-away Qty.";
    //             AvailableStock += BinContenTbl.CalcQtyAvailToTakeUOM;
    //         until BinContenTbl.Next = 0;
    //     end;

    //     InsertBinData(Rec."Item No.", TotalStockInBin, TotalStockInPutAway, AvailableStock);

    //     TotalStockInBin := 0;
    //     TotalStockInPutAway := 0;
    //     AvailableStock := 0;
    // end;

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
    //         BinDataTbl."Modified DateTime" := CurrentDateTime();
    //         BinDataTbl."Magento Update" := false;
    //         BinDataTbl.Insert(true);
    //     end else begin
    //         BinDataTbl."Total Stock In Picking Bins" := TotalStockInBinP;
    //         BinDataTbl."Total Stock In Put-Away Bins" := TotalStockInPutAwayP;
    //         BinDataTbl."Available Stock" := AvailableStockP;
    //         BinDataTbl."Modified DateTime" := CurrentDateTime();
    //         BinDataTbl."Magento Update" := false;
    //         BinDataTbl.Modify(True);
    //     end;
    // end;
    //MITL.AJ.03032020 On request of MATT stock values will be read from SQL now. **
    //MITL2147 ++
    [EventSubscriber(ObjectType::Table, 5800, 'OnAfterValidateEvent', 'Type', false, false)]
    local procedure CheckChargeTypeValue(VAR Rec: Record "Item Charge"; VAR xRec: Record "Item Charge"; CurrFieldNo: Integer)
    var
        ItemChargeL: Record "Item Charge";
        Text50100L: TextConst ENU = 'You can not insert same item charge type again.', ENG = 'You can not insert same item charge type again.';
    begin
        ItemChargeL.Reset();
        ItemChargeL.SetRange("Type", Rec."Type");
        IF ItemChargeL.FindFirst() then begin
            IF Rec."Type" <> Rec."Type"::" " then
                Error(Text50100L);
        End;
    end;
    //MITL2147 **

    //MITL2277 ++
    [EventSubscriber(ObjectType::Page, 54, 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure CheckUnitCostLCY_Value(VAR Rec: Record "Purchase Line"; VAR xRec: Record "Purchase Line")
    var
        ItemL: Record "Item";
        Text50101L: TextConst ENU = 'Unit Cost(LCY) can not be 0. Do you want to enter the Unit Cost?', ENG = 'Unit Cost(LCY) can not be 0. Do you want to enter the Unit Cost?';
        Text50102L: TextConst ENU = 'Unit Cost(LCY) can not be 0 it should have a value for Item %1 and Line %2.', ENG = 'Unit Cost(LCY) can not be 0 it should have a value for Item %1 and Line %2';
    begin
        IF (Rec.Type = Rec.Type::Item) AND (Rec."No." <> '') then begin
            IF Rec."Unit Cost (LCY)" = 0 then begin
                IF ItemL.GET(Rec."No.") then begin
                    IF ItemL."Unit Cost" = 0 then
                        IF NOT Confirm(Text50101L) then
                            Error(Text50102L, Rec."No.", Rec."Line No.");
                End Else
                    exit;
            END;
        end;
    END;

    [EventSubscriber(ObjectType::Page, 54, 'OnAfterValidateEvent', 'Unit Cost (LCY)', false, false)]

    local procedure CheckUnitCostValueAgain(VAR Rec: Record "Purchase Line"; VAR xRec: Record "Purchase Line")
    var
        Text50103L: TextConst ENU = 'Unit Cost(LCY) can not be 0. Do you want to enter the Unit Cost?', ENG = 'Unit Cost(LCY) can not be 0. Do you want to enter the Unit Cost?';
    begin
        IF Rec."Unit Cost (LCY)" = 0 then
            Error(Text50103L);
    end;

    [EventSubscriber(ObjectType::Codeunit, 415, 'OnBeforeReleasePurchaseDoc', '', false, false)]
    Local procedure CheckUnitBlankUnitInPurchaseLine(VAR PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    var
        PurchaseLineL: Record "Purchase Line";
        Text50103L: TextConst ENU = 'Unit Cost(LCY) can not be 0 it should have a value for Item %1 and Line %2.', ENG = 'Unit Cost(LCY) can not be 0 it should have a value for Item %1 and Line %2';
    Begin
        PurchaseLineL.Reset();
        PurchaseLineL.SetRange("Document Type", PurchaseLineL."Document Type"::Order);
        PurchaseLineL.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLineL.SetFilter("Unit Cost", '%1', 0);
        IF PurchaseLineL.FindFirst() then
            Error(Text50103L, PurchaseLineL."No.", PurchaseLineL."Line No.");
    End;
    //MITL2277 **
    // MITL14350 ++
    [EventSubscriber(ObjectType::Table, 83, 'OnAfterValidateEvent', 'Reason Code', False, false)]
    local procedure UpdateGenBusPostingGrp(VAR Rec: Record "Item Journal Line"; VAR xRec: Record "Item Journal Line"; CurrFieldNo: Integer)
    var
        ReasonCodeL: Record "Reason Code";
    begin
        IF ReasonCodeL.GET(Rec."Reason Code") THEN
            Rec."Gen. Bus. Posting Group" := ReasonCodeL."Gen. Bus. Posting Group";
    end;
    // MITL14350 **
    //This code will update the return reason code value in ILE with the Reason Code value of Item Journal Line
    [EventSubscriber(ObjectType::Codeunit, 22, 'OnAfterInitItemLedgEntry', '', False, false)]
    local procedure UpdateReturnReasonCodeInILE(VAR NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; VAR ItemLedgEntryNo: Integer)
    var
        ReasonCodeL: Record "Reason Code";
    begin
        IF NewItemLedgEntry."Return Reason Code" = '' THEN
            NewItemLedgEntry."Return Reason Code" := ItemJournalLine."Reason Code";
    end;
    //MITL14137 ++

    //MITL14137 **
    //R2414 >>
    [EventSubscriber(ObjectType::Table, 232, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckPaymentMethodTemplate(VAR Rec: Record "Gen. Journal Batch"; RunTrigger: Boolean)
    var
        PayMethMapL: Record "Payment Method Template MAP";
        BatchInUseTextL: TextConst ENU = '%1 %2 is in use by %3';
    Begin
        PayMethMapL.SETRANGE("Sales Pmt. Jnl Template Name", Rec."Journal Template Name");
        PayMethMapL.SETRANGE("Sales Pmt. Jnl Batch Name", Rec.Name);
        IF NOT PayMethMapL.ISEMPTY THEN
            ERROR(BatchInUseTextL, Rec."Journal Template Name", Rec.Name, PayMethMapL.TABLECAPTION);
    End;
    //R2414 <<

    //R2415 >>
    [EventSubscriber(ObjectType::Table, 5404, 'OnAfterInsertEvent', '', false, false)]
    local procedure InsertWebItemUpdates(VAR Rec: Record "Item Unit of Measure"; RunTrigger: Boolean)
    var
        WEBFunctionsL: Codeunit "WEB Functions";
    Begin
        WEBFunctionsL.WEBItemUpdates(Rec."Item No.", 'Item Unit of Measure');
    End;

    [EventSubscriber(ObjectType::Table, 5404, 'OnAfterModifyEvent', '', false, false)]
    local procedure ModifyWebItemUpdates(VAR Rec: Record "Item Unit of Measure"; RunTrigger: Boolean)
    var
        WEBFunctionsL: Codeunit "WEB Functions";
    Begin
        WEBFunctionsL.WEBItemUpdates(Rec."Item No.", 'Item Unit of Measure');
    End;
    //R2415 <<

    //MITL247 ++
    [EventSubscriber(ObjectType::Codeunit, 7312, 'OnAfterWhseActivLineInsert', '', false, false)]
    local procedure UpdateSourceDocOnPickHeader(VAR WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        WhseActivHeader: Record "Warehouse Activity Header";
    begin
        IF WhseActivHeader.Get(WarehouseActivityLine."Action Type", WarehouseActivityLine."No.") THEN BEGIN
            IF (WhseActivHeader."Source Document" = WhseActivHeader."Source Document"::" ") AND (WhseActivHeader."Source No." = '') THEN BEGIN
                WhseActivHeader."Source No." := WarehouseActivityLine."Source No.";
                WhseActivHeader."Source Document" := WarehouseActivityLine."Source Document";
                WhseActivHeader.MODIFY;
            END;
        END;
    end;
    //MITL247 **

    //MITL ++
    [EventSubscriber(ObjectType::Table, 81, 'OnAfterCopyGenJnlLineFromSalesHeader', '', false, false)]
    local procedure PassWebIncrementIDtoGenJnlLine(SalesHeader: Record "Sales Header"; VAR GenJournalLine: Record "Gen. Journal Line")
    var
    Begin
        GenJournalLine.WebIncrementID := SalesHeader.WebIncrementID;
        GenJournalLine."Invoice Disc. Facility Availed" := SalesHeader."Invoice Disc. Facility Availed";
    End;

    [EventSubscriber(ObjectType::Table, 81, 'OnAfterCopyGenJnlLineFromSalesHeaderApplyTo', '', false, false)]
    local procedure SetAppliesToIdInGenJnlLine(SalesHeader: Record "Sales Header"; VAR GenJournalLine: Record "Gen. Journal Line")
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    Begin
        //Commented the code as it is creating issue in invoice posting and giving error of Applies to doc no. must be blank in GenJnlLine
        //R2173 >>
        // IF SalesHeader."Document Type" <> SalesHeader."Document Type"::"Credit Memo" THEN BEGIN //MITL_WAF_T3
        IF (SalesHeader.WebIncrementID <> '0') AND (SalesHeader."Document Type" IN [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Credit Memo"]) THEN BEGIN
            CustLedgEntry.SETCURRENTKEY(WebIncrementID);
            CustLedgEntry.SETRANGE(WebIncrementID, SalesHeader.WebIncrementID);
            IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN
                CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Payment)
            ELSE
                CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Refund);
            CustLedgEntry.SetRange(Open, true); // MITL 20200526
            IF CustLedgEntry.FINDFIRST THEN BEGIN
                IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN
                    GenJournalLine."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type"::Payment
                ELSE
                    GenJournalLine."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type"::Refund;
                GenJournalLine."Applies-to Doc. No." := CustLedgEntry."Document No.";
            END;
        END;
        // END; //MITL_WAF_T3
        //R2173 << 
    End;



    [EventSubscriber(ObjectType::Codeunit, 12, 'OnAfterInitBankAccLedgEntry', '', false, false)]
    local procedure PassWebIncrementIDtoBankAccLedger(VAR BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
    Begin
        BankAccountLedgerEntry.WebIncrementID := GenJournalLine.WebIncrementID;
    End;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnAfterInitCustLedgEntry', '', false, false)]
    local procedure PassWebIncrementIDtoCustLedger(VAR CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
    Begin
        CustLedgerEntry.WebIncrementID := GenJournalLine.WebIncrementID;
        CustLedgerEntry."Invoice Disc. Facility Availed" := GenJournalLine."Invoice Disc. Facility Availed";
    End;

    //MITL.SP.W&F
    [EventSubscriber(ObjectType::Page, 425, 'OnModifyRecordEvent', '', False, False)]
    Local procedure ModifyFieldValue(VAR Rec: Record "Vendor Bank Account"; VAR xRec: Record "Vendor Bank Account"; VAR AllowModify: Boolean)
    var
        RecVendor: Record Vendor;
        CompanyInfo: Record "Company Information";
    begin
        IF CompanyInfo.GET THEN;
        IF CompanyInfo.Name = 'Walls and Floors Limited' THEN begin
            IF NOT RecVendor.GET(Rec."Vendor No.") THEN
                EXIT;
            RecVendor."Vend. Bank Acc. Modified" := TRUE;
            RecVendor.Blocked := RecVendor.Blocked::All;
            RecVendor.MODIFY;
        END;
    end;

    //MITL.SP.W&F
    [EventSubscriber(ObjectType::Table, 288, 'OnAfterModifyEvent', '', False, False)]
    Local procedure VendBankAccModifiedTable(VAR Rec: Record "Vendor Bank Account"; VAR xRec: Record "Vendor Bank Account"; RunTrigger: Boolean)
    var
        RecVendor: Record Vendor;
        CompanyInfo: Record "Company Information";
    begin
        IF CompanyInfo.GET THEN;
        IF CompanyInfo.Name = 'Walls and Floors Limited' THEN begin
            IF NOT RecVendor.GET(Rec."Vendor No.") THEN
                EXIT;
            RecVendor."Vend. Bank Acc. Modified" := TRUE;
            RecVendor.Blocked := RecVendor.Blocked::All;
            RecVendor.MODIFY;
        END;
    end;
    //MITL ++ - Sales Order Credit limit Approval workflow related, if the order is approved then Warehosue shipment should automatically created.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnApproveApprovalRequest', '', false, false)]
    local procedure CreateWhseShipmentforApprovedSalesOrders(VAR ApprovalEntry: Record "Approval Entry")
    var
        SalesHeader: Record "Sales Header";
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
        WEBLog: Record "WEB Log";
    begin
        IF ApprovalEntry."Document Type" = ApprovalEntry."Document Type"::Order then begin
            SalesHeader.Reset();
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            SalesHeader.SetRange("No.", ApprovalEntry."Document No.");
            IF SalesHeader.FindFirst() then Begin
                IF SalesHeader.Status = SalesHeader.Status::Released THEN BEGIN
                    IF NOT GetSourceDocOutbound.CreateFromSalesOrderHideDialog(SalesHeader) then begin
                        WEBLog."Line No." := 0;
                        WEBLog.Note := '11' + GETLASTERRORTEXT;
                        WEBLog."Order ID" := SalesHeader."No.";
                        WEBLog.INSERT(TRUE);
                    END;
                END;
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Whse. Calculate Inventory", 'OnAfterWhseJnlLineInsert', '', false, false)]
    local procedure WhseJnlLine(VAR WarehouseJournalLine: Record "Warehouse Journal Line")
    var
        Bincontent: Record "Bin Content";
    begin
        Bincontent.SetRange("Bin Code", WarehouseJournalLine."Bin Code");
        Bincontent.CalcFields("Odd-Even Bin Flag");
        Bincontent.SetRange("Odd-Even Bin Flag", Bincontent."Odd-Even Bin Flag");
    end;
    //MITL **
    //MITL.MF.5419++
    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterFillInvoicePostBuffer', '', False, False)]
    Local procedure UpdateLineDescription(VAR InvoicePostBuffer: Record "Invoice Post. Buffer"; PurchLine: Record "Purchase Line"; VAR TempInvoicePostBuffer: Record "Invoice Post. Buffer" temporary; CommitIsSupressed: Boolean)

    var
        recGenLedSetup_l: Record "General Ledger Setup";
    begin
        recGenLedSetup_l.Get();
        if recGenLedSetup_l.PurchaseInvoiceDescriptionUpdate then begin
            PurchLine.SetFilter("Document Type", '%1|%2', PurchLine."Document Type"::Invoice, PurchLine."Document Type"::"Credit Memo");
            PurchLine.SetRange("Document No.", PurchLine."Document No.");
            PurchLine.SetRange("No.", PurchLine."No.");
            PurchLine.SetRange(Type, PurchLine.Type::"G/L Account");
            if PurchLine.FindFirst() then
                InvoicePostBuffer.Description := PurchLine.Description;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforePostInvPostBuffer', '', False, False)]
    Local procedure UpdateLineGnJouDescription(VAR GenJnlLine: Record "Gen. Journal Line"; VAR InvoicePostBuffer: Record "Invoice Post. Buffer"; VAR PurchHeader: Record "Purchase Header"; VAR GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; CommitIsSupressed: Boolean)

    var
        GeneralLegSetup: Record "General Ledger Setup";
    begin
        GeneralLegSetup.Get;
        if GeneralLegSetup.PurchaseInvoiceDescriptionUpdate then
            if InvoicePostBuffer.Description <> '' then
                GenJnlLine.Description := InvoicePostBuffer.Description
            else
                GenJnlLine.Description := PurchHeader."Posting Description";
    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnBeforeInsertVATEntry', '', False, False)]
    Local procedure UpdateLineVatDescription(VAR VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
    begin
        VATEntry.Description := GenJournalLine.Description;
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforePostVendorEntry', '', false, false)]
    local procedure UpdateDescriptiononVendLedger(VAR GenJnlLine: Record "Gen. Journal Line"; VAR PurchHeader: Record "Purchase Header"; VAR TotalPurchLine: Record "Purchase Line"; VAR TotalPurchLineLCY: Record "Purchase Line"; PreviewMode: Boolean; CommitIsSupressed: Boolean)
    var
        recPurchLine_l: Record "Purchase Line";
        recGenLedgSetup_l: Record "General Ledger Setup";
    begin
        recGenLedgSetup_l.Get();
        if recGenLedgSetup_l.PurchaseInvoiceDescriptionUpdate then begin
            recPurchLine_l.Reset();
            recPurchLine_l.SetRange("Document Type", PurchHeader."Document Type");
            recPurchLine_l.SetRange("Document No.", PurchHeader."No.");
            recPurchLine_l.SetRange(Type, recPurchLine_l.Type::"G/L Account");
            if recPurchLine_l.FindFirst() then
                GenJnlLine.Description := recPurchLine_l.Description;
        end;
    end;

    //MITL.MF.5419--
    //MITL.6039.SM.20APR2020++
    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    procedure UpdatePostingNo(VAR SalesHeader: Record "Sales Header"; VAR GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean)
    begin
        with SalesHeader do begin
            if "Posting No." = '' then begin
                if (SalesHeader."Last Posting No." <> '') and (StrPos(SalesHeader."Last Posting No.", '-') > 0) then
                    SalesHeader."Posting No." := IncStr("Last Posting No.")
                else
                    SalesHeader."Posting No." := WebIncrementID + '-1';
                if SalesHeader.Modify() then;
            end;
        end;
    end;
    //MITL.6039.SM.20APR2020--
    //MITL.6532.SM.20200525 ++
    [EventSubscriber(ObjectType::Report, 5753, 'OnAfterCreateShptHeader', '', true, true)]
    procedure UpdateShipmentDate(VAR WarehouseShipmentHeader: Record "Warehouse Shipment Header"; WarehouseRequest: Record "Warehouse Request"; SalesLine: Record "Sales Line")
    begin
        WarehouseShipmentHeader."Shipment Date" := SalesLine."Shipment Date";
        WarehouseShipmentHeader.Modify(true);
    end;
    //MITL.6532.SM.20200525 --
    // MITL.5442.SM.20200731 ++
    [EventSubscriber(ObjectType::Codeunit, 7313, 'OnAfterWhseActivLineInsert', '', true, true)]
    procedure UpdateSourceNoforCreditMemo(VAR WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        WhseActHdr_L: Record "Warehouse Activity Header";
        WebCreditHeader_L: Record "WEB Credit Header";
    begin
        WhseActHdr_L.Get(WarehouseActivityLine."Activity Type", WarehouseActivityLine."No.");
        WebCreditHeader_L.Reset();
        WebCreditHeader_L.SetRange("Credit Memo ID", WarehouseActivityLine."Source No.");
        if WebCreditHeader_L.FindLast() then begin
            WhseActHdr_L."Source Document" := WarehouseActivityLine."Source Document";
            WhseActHdr_L."Source No." := WebCreditHeader_L."Order ID";
            WhseActHdr_L."Assigned User ID" := UserId;
            WhseActHdr_L.Modify();
        end;
    end;
    // MITL.5442.SM.20200731 ++

    // MITL.SM.Cornitor.20200817 ++
    [EventSubscriber(ObjectType::Codeunit, 448, 'OnAfterExecuteJob', '', true, true)]
    procedure MakeRequest(VAR JobQueueEntry: Record "Job Queue Entry"; WasSuccess: Boolean)
    var
        client: HttpClient;
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        contentHeaders: HttpHeaders;
        content: HttpContent;
        RequestFound: Boolean;
        CronitorAPI: Text;
        JobStatus: Text;
        recJobQueueEntry: Record "Job Queue Entry";
    begin
        if WasSuccess then begin

            RequestFound := false;
            CronitorAPI := 'https://cronitor.link/';
            JobStatus := '/complete';
            // Add the payload to the content
            // content.WriteFrom(payload);

            // Retrieve the contentHeaders associated with the content
            content.GetHeaders(contentHeaders);
            contentHeaders.Clear();
            contentHeaders.Add('Content-Type', 'application/json');

            // Assigning content to request.Content will actually create a copy of the content and assign it.
            // After this line, modifying the content variable or its associated headers will not reflect in 
            // the content associated with the request message
            request.Content := content;

            recJobQueueEntry.Reset();
            recJobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run");
            recJobQueueEntry.SetRange("Object ID to Run", JobQueueEntry."Object ID to Run");
            if recJobQueueEntry.FindFirst() then begin
                if recJobQueueEntry."Cronitor Function" <> '' then begin
                    request.SetRequestUri(CronitorAPI + recJobQueueEntry."Cronitor Function" + JobStatus);
                    request.Method := 'POST';
                    client.Send(request, response);
                end;
            end;

            // Read the response content as json.
            // response.Content().ReadAs(responseText);
        end;
    end;
    // MITL.SM.Cornitor.20200817 --
    //MITL.SM.STORE Premission.20200917 ++
    [EventSubscriber(ObjectType::Table, 38, 'OnAfterInitRecord', '', true, true)]
    procedure UpdateLocation(var PurchHeader: Record "Purchase Header")
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId) then
            if UserSetup."Default Location" <> '' then
                PurchHeader.Validate("Location Code", UserSetup."Default Location");
    end;
    //MITL.SM.STORE Premission.20200917 --
}