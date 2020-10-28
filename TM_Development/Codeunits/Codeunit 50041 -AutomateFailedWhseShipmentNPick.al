//MITL_6702_VS++
codeunit 50041 "AutomateFailedWhseShipmnt&Pick"
{
    trigger OnRun()
    var
        ShippingError: Text;
        BinStockQty: Decimal;
        SalesReceiveSetupL: Record "Sales & Receivables Setup";
        LocationL: Record Location;
        ReqStock: Decimal;//mitl.vs.20200907
        WebShipQty: Decimal;
    begin
        // Error('');
        checkG := false;
        if NOT ApplyDatefilter then begin
            StartDtTime := CreateDateTime(WorkDate, 0T);
            EndDttime := CreateDateTime(Workdate, 235900T);
        end else begin
            SalesReceiveSetupL.Get;
            if (SalesReceiveSetupL.FromDt = 0D) OR (SalesReceiveSetupL.Todate = 0D) then begin
                StartDtTime := CreateDateTime(WorkDate, 0T);
                EndDttime := CreateDateTime(Workdate, 235900T);
            end else begin
                StartDtTime := CreateDateTime(SalesReceiveSetupL.FromDt, 0T);
                EndDttime := CreateDateTime(SalesReceiveSetupL.Todate, 235900T);
            end;
        end;
        //Web shipment filter with StartDttime & EndDtTime
        //MITL.VS.20200825++
        WebIndex.Reset();
        WebIndex.SetRange("Table No.", 50014);
        WebIndex.SetRange("DateTime Inserted", StartDtTime, EndDttime);
        // WebIndex.SetRange(Status, WebIndex.Status::Error);//for testing 20200904
        if WebIndex.FindSet then
            repeat
                //MITL.VS.20200825--
                WebShipmentHeader.Reset();
                WebShipmentHeader.SetRange("Shipment ID", WebIndex."Key Field 1");
                // WebShipmentHeader.SetRange("Date Time", StartDtTime, EndDttime);
                if WebShipmentHeader.FindSet then Begin
                    // repeat
                    //     //mitl.vs.20200729++
                    //     if CheckWebShipErrorOnWebIndex(WebShipmentHeader."Shipment ID") then begin
                    // web index
                    //mitl.vs.20200729--
                    //WebIndex.Reset();
                    //WebIndex.SetRange("Table No.", 50014);
                    //WebIndex.SetRange("Key Field 1", WebShipmentHeader."Shipment ID");
                    //WebIndex.SetFilter(Status, '%1|%2', WebIndex.Status::" ", WebIndex.Status::Error);
                    //if WebIndex.FindFirst() then;

                    if CheckQtyPickedShippedInvoiced(WebShipmentHeader."Shipment ID") then begin//MITL.VS.20200904
                        if SalesOrderHeader.Get(SalesOrderHeader."Document Type"::Order, WebShipmentHeader."Order ID") then begin
                            // if Not CheckPostedWhseShip(SalesOrderHeader."No.") then begin//MITL.VS.20200729 code comment
                            // if not CheckRegdPick(SalesOrderHeader."No.") then begin//MITL.VS.20200729 code comment

                            //MITL.VS.20200729++
                            CrossRefNo := '';
                            ItemNo := '';
                            WebShipQty := 0;//mitl.vs.20200907
                            WebShipLines.Reset();
                            WebShipLines.SetRange("Shipment ID", WebShipmentHeader."Shipment ID");
                            if WebShipLines.FindSet() then
                                repeat
                                    CrossRefNo := WebFunc.ReturnCrossReference(WebShipLines.Sku);
                                    IF CrossRefNo = '' THEN
                                        ItemNo := WebShipLines.Sku
                                    ELSE
                                        ItemNo := WebFunc.ReturnItemNo(WebShipLines.Sku);
                                    //MITL.VS.20200729--

                                    BinStockQty := 0;
                                    SalesOrderLines.Reset();
                                    SalesOrderLines.SetRange("Document Type", SalesOrderLines."Document Type"::Order);
                                    SalesOrderLines.SetRange("Document No.", SalesOrderHeader."No.");
                                    SalesOrderLines.SetRange(Type, SalesOrderLines.Type::Item);
                                    SalesOrderLines.SetRange("No.", ItemNo);
                                    if SalesOrderLines.FindSet then begin
                                        ReqStock := 0;//mitl.vs.20200907
                                        WebShipQty := 0;//mitl.vs.20200910
                                                        // repeat//mit.vs.20200729++
                                        if NOT (CheckPostedWhseShipLine(SalesOrderLines, WebShipLines.QTY) OR
                                            CheckRegisteredPickLine(SalesOrderLines, WebShipLines.QTY))
                                    then begin
                                            //mit.vs.20200729--
                                            LocationL.get(SalesOrderLines."Location Code");
                                            if LocationL."Directed Put-away and Pick" then begin
                                                BinStockQty := CheckBinStock(SalesOrderLines."No.",
                                                                            SalesOrderLines."Location Code",
                                                                            SalesOrderLines."Unit of Measure Code");
                                                //mit.vs.20200729++
                                                //Check for the combine pick 
                                                if CheckCombinePick(SalesOrderLines."Document No.") then
                                                    DeleteCombinePickLine(SalesOrderLines."Document No.", SalesOrderLines."No.");
                                                //mit.vs.20200729--
                                                Evaluate(WebShipQty, WebShipLines.QTY);//MITL.vs.20200908
                                                IF BinStockQty >= 0 then begin
                                                    if (SalesOrderLines."Quantity (Base)" > BinStockQty) AND
                                                                    // NOT CheckPick(SalesOrderHeader."No.")//MITL.VS.20200821
                                                                    not CheckPickExistsLinewise(SalesOrderLines)
                                                     then begin
                                                        //mitl.vs.20200910++
                                                        WebShipQty := WebShipQty + CheckAlreadyPickedWebShipQty(SalesOrderLines."Document No.", SalesOrderLines."No.");
                                                        if WebShipQty <= SalesOrderLines.Quantity then
                                                            ReqStock := WebShipQty - (BinStockQty + GetPickedQty(SalesOrderLines))
                                                        else
                                                            ReqStock := (SalesOrderLines.Quantity - (BinStockQty + GetPickedQty(SalesOrderLines)));
                                                        //mitl.vs.20200910--
                                                        CreateWhseAdj(SalesOrderLines."No.",
                                                                        SalesOrderLines."Unit of Measure Code",
                                                                        SalesOrderLines."Location Code",
                                                                                    // (SalesOrderLines.Quantity - BinStockQty));//mitl.vs.20200910
                                                                                    ReqStock);//mitl.vs.20200910
                                                        RegisterWhseJnl();
                                                        // CheckBlankBinCodePickLine(SalesOrderLines."Document No.");//MITL.VS.20200730
                                                    end else begin
                                                        IF (SalesOrderLines."Quantity (Base)" > BinStockQty) AND
                                                            CheckPickExistsLinewise(SalesOrderLines)
                                                        then begin
                                                            //mit.vs.20200907++
                                                            WebShipQty := WebShipQty + CheckAlreadyPickedWebShipQty(SalesOrderLines."Document No.", SalesOrderLines."No.");
                                                            if WebShipQty <= SalesOrderLines.Quantity then
                                                                ReqStock := WebShipQty - (BinStockQty + GetPickedQty(SalesOrderLines))
                                                            else
                                                                ReqStock := (SalesOrderLines.Quantity - (BinStockQty + GetPickedQty(SalesOrderLines)));
                                                            //mitl.vs.20200907--
                                                            CreateWhseAdj(SalesOrderLines."No.",
                                                                        SalesOrderLines."Unit of Measure Code",
                                                                        SalesOrderLines."Location Code",
                                                                        // (SalesOrderLines.Quantity - (BinStockQty + GetPickedQty(SalesOrderLines))));//mitl.vs.20200907 commented
                                                                        ReqStock);//mitl.vs.20200907 
                                                            RegisterWhseJnl();
                                                        end;
                                                    end;
                                                end
                                                //MITL.VS.20200821++
                                                else begin
                                                    // if (SalesOrderLines."Quantity (Base)" > (BinStockQty + SalesOrderLines."Quantity (Base)")) AND
                                                    if (SalesOrderLines."Quantity (Base)" > BinStockQty) and
                                                        CheckPickExistsLinewise(SalesOrderLines)
                                                    then begin
                                                        //MITL.vs.20200908++
                                                        WebShipQty := WebShipQty + CheckAlreadyPickedWebShipQty(SalesOrderLines."Document No.", SalesOrderLines."No.");
                                                        if WebShipQty <= SalesOrderLines.Quantity then
                                                            ReqStock := WebShipQty - GetPickedQty(SalesOrderLines);

                                                        if ReqStock < 0 then
                                                            ReqStock := SalesOrderLines.Quantity - GetPickedQty(SalesOrderLines);
                                                        //MITL.vs.20200908--

                                                        CreateWhseAdj(SalesOrderLines."No.",
                                                                    SalesOrderLines."Unit of Measure Code",
                                                                    SalesOrderLines."Location Code",
                                                                    // (SalesOrderLines.Quantity - GetPickedQty(SalesOrderLines)));//MITL.VS.20200824//commented 20200908
                                                                    ReqStock);//mitl.vs.20200908

                                                        // (SalesOrderLines.Quantity - (BinStockQty + SalesOrderLines."Quantity (Base)")));//comment 20200824
                                                        RegisterWhseJnl();

                                                        // CheckBlankBinCodePickLine(SalesOrderLines."Document No.");//MITL.VS.20200730
                                                    end
                                                end;
                                                //MITL.VS.20200821--
                                                CheckBlankBinCodePickLine(SalesOrderLines."Document No.");//MITL.VS.20200826
                                            end;//Location begin close
                                        end;//checkRegPick & PostedWhseShip Begin--end//20200810
                                    end;//SOLine begin close
                                        // until SalesOrderLines.Next = 0;//mitl.vs.20200729
                                until WebShipLines.Next = 0;//MITL.VS.20200729

                            // end;//20200810
                            //Register/Post the Whse. Jnl line created
                            // RegisterWhseJnl();

                            if NOT CheckWhseShipment(SalesOrderHeader."No.") then begin
                                WebFunc.SalesOrderReleaseManagement(SalesOrderHeader, ShippingError, False);
                                CreatePicks(SalesOrderHeader."No.");
                            end else
                                // if NOT CheckPick(SalesOrderHeader."No.") AND
                                //     NOT CheckRegdPick(SalesOrderHeader."No.")//MITL.VS.20200821
                                if CheckPick(SalesOrderHeader."No.", WebShipmentHeader."Shipment ID") then//MITL.VS.20200821
                                    CreatePicks(SalesOrderHeader."No.");
                            //Qty to handle on pick 
                            QtyHandleOnPick(SalesOrderHeader."No.", WebShipmentHeader."Shipment ID");

                            //Register the pick    
                            RegisterPick(SalesOrderHeader."No.");

                            CheckAlreadyPickRegistered(WebShipmentHeader."Shipment ID");//MITL.VS.20200821
                            if checkG then
                                WebToolBox.UpdateIndex(WebIndex, 0, '');

                            //Warehouse Shipment post
                            // WhseShipmentPost(SalesOrderHeader."No.");
                        end;//SOHeader Begin --end 20200810
                            //     end;//checkerror begin--end 20200810
                            //end
                            // until WebShipmentHeader.Next = 0;
                    end;//MITL.VS.20200825
                end;//MITL.VS.20200904
            until WebIndex.Next = 0;//MITL.VS.20200825
    end;

    local procedure CheckPostedWhseShip(SalesOrderNoP: Code[20]): Boolean
    var
        PostedWhseShipLine: Record "Posted Whse. Shipment Line";
        RegdPickLine: Record "Registered Whse. Activity Line";
    begin
        PostedWhseShipLine.Reset();
        PostedWhseShipLine.SetRange("Source Type", 37);
        PostedWhseShipLine.SetRange("Source Subtype", 1);
        PostedWhseShipLine.SetRange("Source No.", SalesOrderNoP);
        if PostedWhseShipLine.FindFirst() then
            exit(true);

    end;

    local procedure CheckRegdPick(SalesOrderNoP: Code[20]): Boolean
    var
        RegdPickLine: Record "Registered Whse. Activity Line";
    begin
        RegdPickLine.Reset();
        RegdPickLine.SetRange("Activity Type", RegdPickLine."Activity Type"::Pick);
        RegdPickLine.SetRange("Source Type", 37);
        RegdPickLine.SetRange("Source Subtype", 1);
        RegdPickLine.SetRange("Source No.", SalesOrderNoP);
        If RegdPickLine.FindFirst() then
            exit(true);
    end;

    local procedure CheckWhseShipment(SalesOrderNoP: Code[20]): Boolean
    var
        WhseShipLineL: Record "Warehouse Shipment Line";
    begin
        WhseShipLineL.RESET;
        WhseShipLineL.SETRANGE("Source Type", 37);
        WhseShipLineL.SETRANGE("Source Subtype", 1);
        WhseShipLineL.SETRANGE("Source No.", SalesOrderNoP);
        IF WhseShipLineL.FINDFIRST THEN
            exit(true);
    end;

    local procedure CheckPick(SalesOrderNo: Code[20]; WebShipmentIdP: Code[20]): Boolean
    var
        PickLines: Record "Warehouse Activity Line";
        WebShipLineL: Record "WEB Shipment Lines";
        SalesLineL: Record "Sales Line";
        CheckL: Boolean;
    begin
        CheckL := false;
        WebShipLineL.Reset();
        WebShipLineL.SetRange("Shipment ID", WebShipmentIdP);
        if WebShipLineL.FindSet() then
            repeat
                SalesLineL.Reset();
                SalesLineL.SetRange("Document Type", SalesLineL."Document Type"::Order);
                SalesLineL.SetRange("Document No.", SalesOrderNo);
                SalesLineL.SetRange(Type, SalesLineL.Type::Item);
                SalesLineL.SetRange("No.", WebShipLineL.Sku);
                if SalesLineL.FindSet() then begin
                    PickLines.Reset();
                    PickLines.SetRange("Activity Type", PickLines."Activity Type"::Pick);
                    PickLines.SetRange("Source Type", 37);
                    PickLines.SetRange("Source Subtype", 1);
                    PickLines.SetRange("Source No.", SalesLineL."Document No.");
                    PickLines.SetRange("Source Line No.", SalesLineL."Line No.");
                    PickLines.SetRange("Item No.", SalesLineL."No.");
                    if NOT PickLines.FindFirst() then
                        CheckL := true;
                end
            until (WebShipLineL.Next() = 0) OR CheckL;

        if CheckL then
            exit(true)
    end;

    local procedure CheckBinStock(ItemNoP: Code[20]; LocCodeP: Code[20]; UoMP: Code[10]) QtyAvailToPickR: Decimal
    var
        BinContent: Record "Bin Content";
        BinTypeFilterL: Text;
    begin
        //MITL_VS_30.06.20++
        BinTypeFilterL := '';
        BinTypeFilterL := GetBinTypeFilter(3);
        QtyAvailToPickR := 0;
        //MITL_VS_30.06.20--
        BinContent.RESET;
        BinContent.SETCURRENTKEY("Bin Type Code");
        BinContent.SETRANGE("Location Code", LocCodeP);
        BinContent.SETRANGE("Item No.", ItemNoP);
        BinContent.SETRANGE("Unit of Measure Code", UoMP);
        IF BinTypeFilterL <> '' THEN//MITL_VS_30.06.20
            BinContent.SetFilter("Bin Type Code", BinTypeFilterL);//MITL_VS_30.06.20
        IF BinContent.FINDSET THEN
            REPEAT
                QtyAvailToPickR += BinContent.CalcQtyAvailToPick(0);//MITL_VS_30.06.20
            UNTIL BinContent.NEXT = 0;
    end;
    //MITL_VS_30.06.20++
    procedure GetBinTypeFilter(Type: Option Receive,Ship,"Put Away",Pick): Text[1024]
    var
        BinType: Record "Bin Type";
        BinFilter: Text[1024];
    begin
        WITH BinType DO BEGIN
            CASE Type OF
                Type::Receive:
                    SETRANGE(Receive, TRUE);
                Type::Ship:
                    SETRANGE(Ship, TRUE);
                Type::"Put Away":
                    SETRANGE("Put Away", TRUE);
                Type::Pick:
                    SETRANGE(Pick, TRUE);
            END;
            IF FINDSET(FALSE, FALSE) THEN
                REPEAT
                    BinFilter := STRSUBSTNO('%1|%2', BinFilter, BinType.Code);
                UNTIL NEXT = 0;
            IF BinFilter <> '' THEN
                BinFilter := COPYSTR(BinFilter, 2);
        END;
        EXIT(BinFilter);
    end;
    //MITL_VS_30.06.20

    //MITL.VS.20200714<<
    //Update the blank "Take" line bin code from Picking Bin field
    local procedure UpdateBlankPickLines(SalesOrderNoP: Code[20])
    var
        PickLines: Record "Warehouse Activity Line";
    begin
        PickLines.Reset();
        PickLines.SetRange("Activity Type", PickLines."Activity Type"::Pick);
        PickLines.SetRange("Source Type", 37);
        PickLines.SetRange("Source Subtype", 1);
        PickLines.SetRange("Source No.", SalesOrderNoP);
        PickLines.SetRange("Action Type", PickLines."Action Type"::Take);
        PickLines.SetRange("Bin Code", '');
        if PickLines.FindSet then
            repeat
                If PickLines."Picking Bin" <> '' then begin
                    PickLines."Bin Code" := PickLines."Picking Bin";
                    PickLines.Modify();
                end;
            until PickLines.Next = 0;
    end;
    //MITL.VS.20200714>>
    local procedure CheckPutAwayBinStock(ItemNoP: Code[20]; LocCodeP: Code[20]; UoMP: Code[10]) QtyAvailToPutAwayR: Decimal
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.RESET;
        BinContent.SETCURRENTKEY("Bin Type Code");
        BinContent.SETRANGE("Location Code", LocCodeP);
        BinContent.SETRANGE("Item No.", ItemNoP);
        BinContent.SETRANGE("Unit of Measure Code", UoMP);
        BinContent.SETFILTER("Bin Type Code", 'Put Away');
        IF BinContent.FINDSET THEN
            REPEAT
                QtyAvailToPutAwayR += BinContent.CalcQtyAvailToTake(0);
            UNTIL BinContent.NEXT = 0;
    end;

    local procedure CreatePicks(SalesOrderNoP: Code[20])
    var
        WarehouseShipmentLineL: Record "Warehouse Shipment Line";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        RegisterPick: Codeunit RegisterUnhandledPicks;
    begin
        WarehouseShipmentLineL.SetCurrentKey("Source Document", "Qty. Picked", "Zone Code", "Bin Code"); // MITL.SM.20200503 Indexing correction
        WarehouseShipmentLineL.SETRANGE("Source Document", WarehouseShipmentLineL."Source Document"::"Sales Order");
        WarehouseShipmentLineL.SETRANGE("Source No.", SalesOrderHeader."No.");
        // WarehouseShipmentLineL.SETRANGE("Qty. Picked", 0);//MITL.VS.20200821
        WarehouseShipmentLineL.SETRANGE("Pick Qty.", 0);
        IF WarehouseShipmentLineL.FINDSET THEN begin
            CheckAndRelease;
            WarehouseShipmentHeader.Get(WarehouseShipmentLineL."No.");
            WarehouseShipmentLineL.SetHideValidationDialogCustom(TRUE);
            WarehouseShipmentLineL.CreatePickDocCustom(WarehouseShipmentLineL, WarehouseShipmentHeader);
        End;
    end;

    local procedure RegisterPick(SalesOrderNoP: Code[20])
    var
        RegisterPick: Codeunit RegisterUnhandledPicks;
        SalesOrder: Record "Sales Header";
        PickLines: Record "Warehouse Activity Line";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
    begin
        //mitl.vs.20200713<<
        CheckG := false;
        if CompanyName() = 'Walls and Floors' then begin
            UpdateBlankPickLines(SalesOrderNoP);
        end;
        //mitl.vs.20200713>> 
        Commit();
        // if SalesOrder.get(SalesOrder."Document Type"::Order, SalesOrderNoP) then begin
        //     RegisterPick.SetSalesOrder(SalesOrder);
        //     if RegisterPick.Run() then begin
        //         Clear(RegisterPick);
        //     end;
        // end;
        //MITL.VS.20200730++
        PickLines.Reset();
        PickLines.SetRange("Activity Type", PickLines."Activity Type"::Pick);
        PickLines.SetRange("Source Type", 37);
        PickLines.SetRange("Source Subtype", 1);
        PickLines.SetRange("Source No.", SalesOrderNoP);
        PickLines.SetFilter("Qty. to Handle", '>0');
        if PickLines.FindSet then begin
            WhseActivityRegister.ShowHideDialog(true);
            IF WhseActivityRegister.RUN(PickLines) THEN begin
                Clear(WhseActivityRegister);
                CheckG := true;
                //MITL.VS.20200819+
                WebIndex."Pick Processed" := true;
                WebIndex.Modify();
                //MITL.VS.20200819--
            end;
        end;
        //MITL.VS.20200730--
    end;

    local procedure CheckAndRelease()
    var
        WhseShipLineRecL: Record "Warehouse Shipment Line";
        WhseShipHeadRecL: Record "Warehouse Shipment Header";
        ReleaseWhseShptDoc: Codeunit "Whse.-Shipment Release";
        WhseDocNo: Code[20];
    begin
        WhseDocNo := '';
        WhseShipLineRecL.RESET;
        WhseShipLineRecL.SETCURRENTKEY("No.", "Source Document", "Source No.");
        WhseShipLineRecL.SETRANGE("Source Document", WhseShipLineRecL."Source Document"::"Sales Order");
        WhseShipLineRecL.SETRANGE("Source No.", SalesOrderHeader."No.");
        IF WhseShipLineRecL.FINDSET THEN
            REPEAT
                IF WhseDocNo <> WhseShipLineRecL."No." THEN BEGIN
                    WhseShipHeadRecL.RESET;
                    WhseShipHeadRecL.SETRANGE("No.", WhseShipLineRecL."No.");
                    WhseShipHeadRecL.SETRANGE(Status, WhseShipHeadRecL.Status::Open);
                    IF WhseShipHeadRecL.FINDFIRST THEN BEGIN
                        ReleaseWhseShptDoc.Release(WhseShipHeadRecL);
                    END;
                    WhseDocNo := WhseShipLineRecL."No.";
                END;
            UNTIL WhseShipLineRecL.NEXT = 0;
    end;

    local procedure CreateWhseAdj(ItemNoP: Code[20]; UoMP: Code[10]; LocP: code[20]; QtyP: Decimal)
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        NextLineNo: Integer;
        WhseJnlBatch: Record "Warehouse Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        LocationL: Record Location;
        BinContentL: Record "Bin Content";
        BinType: Record "Bin Type";
        BinCode: Code[20];
        Bin: Record Bin;
        ErrorText: Text;
    begin
        BinCode := '';
        LocationL.Get(Locp);
        if not LocationL."Directed Put-away and Pick" then
            Exit;
        // BinType.Reset();
        // BinType.SetRange(Pick, true);
        // BinType.FindFirst();

        BinContentL.Reset();
        BinContentL.SetRange("Location Code", LocationL.Code);
        BinContentL.SetRange("Item No.", ItemNoP);
        // BinContentL.SetRange("Bin Type Code", BinType.Code);
        BinContentL.SetRange(Default, true);
        if BinContentL.FindFirst then
            BinCode := BinContentL."Bin Code"
        else begin
            // Bin.Reset();
            // Bin.SetRange("Location Code", LocationL.Code);
            // Bin.SetRange("Zone Code", 'PICK');
            // If Bin.FindFirst() then
            //     BinCode := Bin.Code;
            //commented MITL.VS.20200820++
            // ErrorText := 'Default bin does not exists for Item No. ' + BinContentL."Item No.";
            // WebToolBox.UpdateIndex(WebIndex, 2, ErrorText);
            //commented MITL.VS.20200820--
            BinCode := 'FAILEDSHIP';////MITL.VS.20200820//suggested by matt
        end;
        IF (BinCode <> '') AND (QtyP > 0) THEN BEGIN //MITL.VS.20200820
            WhseJnlLine.SETRANGE(WhseJnlLine."Journal Batch Name", 'WHSE JNLFS');
            if CompanyName = 'Tile Mountain' then
                WhseJnlLine.SETRANGE(WhseJnlLine."Journal Template Name", 'ADJMT');
            if CompanyName() = 'Walls and Floors' then
                WhseJnlLine.SETRANGE(WhseJnlLine."Journal Template Name", 'ITEM');
            IF WhseJnlLine.FINDLAST THEN
                NextLineNo := WhseJnlLine."Line No." + 1000
            ELSE
                NextLineNo := 1000;
            WhseJnlLine.Reset();//30.06.20
            WhseJnlLine.INIT;
            WhseJnlLine."Journal Batch Name" := 'WHSE JNLFS';
            if CompanyName = 'Tile Mountain' then
                WhseJnlLine."Journal Template Name" := 'ADJMT';
            if CompanyName() = 'Walls and Floors' then
                WhseJnlLine."Journal Template Name" := 'ITEM';

            WhseJnlLine."Line No." := NextLineNo;
            WhseJnlLine."Registering Date" := TODAY;

            IF WhseJnlBatch.GET(WhseJnlLine."Journal Template Name", WhseJnlLine."Journal Batch Name", LocationL.Code) THEN BEGIN
                WhseJnlBatch.TESTFIELD("No. Series");
                CLEAR(NoSeriesMgt);
                WhseJnlLine."Whse. Document No." :=
                  NoSeriesMgt.GetNextNo(WhseJnlBatch."No. Series", WhseJnlLine."Registering Date", FALSE);
            END;

            WhseJnlLine.VALIDATE("Location Code", LocationL.code);
            WhseJnlLine.VALIDATE(WhseJnlLine."Item No.", ItemNoP);
            WhseJnlLine.INSERT(TRUE);

            // WhseJnlLine.VALIDATE("Zone Code", BinContent."Zone Code");
            WhseJnlLine.VALIDATE("Bin Code", BinCode);
            WhseJnlLine.VALIDATE(WhseJnlLine.Quantity, QtyP);
            WhseJnlLine."From Bin Code" := LocationL."Adjustment Bin Code";
            WhseJnlLine."From Zone Code" := 'ADJUSTMENT';
            WhseJnlLine."From Bin Type Code" := 'QC';
            // WhseJnlLine."To Bin Code" := ;
            // WhseJnlLine."To Zone Code" := ;
            WhseJnlLine."Reason Code" := 'FAILEDSHIP';
            WhseJnlLine."Int. Register No." := GetWhseReg();
            WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::"Positive Adjmt.";
            WhseJnlLine.MODIFY(TRUE);
        END;//MITL.VS.20200820
    end;

    local procedure RegisterWhseJnl()
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        WhseJnlRegister: Codeunit "Whse. Jnl.-Register";
        RegisterWhseJnlLine: Codeunit "Whse. Jnl.-Register Line";
        WhseReg: Record "Warehouse Register";
    begin
        WhseJnlLine.Reset();
        WhseJnlLine.SETRANGE(WhseJnlLine."Journal Batch Name", 'WHSE JNLFS');
        if CompanyName = 'Tile Mountain' then
            WhseJnlLine.SETRANGE(WhseJnlLine."Journal Template Name", 'ADJMT');
        if CompanyName() = 'Walls and Floors' then
            WhseJnlLine.SETRANGE(WhseJnlLine."Journal Template Name", 'ITEM');
        if WhseJnlLine.FindSet() then begin
            repeat
                Commit();//commits warehouse journal 

                // WhseJnlRegister.EnablePostItemJnl(true);
                // if WhseJnlRegister.Run(WhseJnlLine) then
                //     Clear(WhseJnlRegister);

                if RegisterWhseJnlLine.Run(WhseJnlLine) then begin
                    PostItemJournal(WhseJnlLine);
                end;
                WhseJnlLine.Delete();//30.06.20
            until WhseJnlLine.next = 0;
        end;
    end;

    local procedure PostItemJournal(Var WhseJnlLine: Record "Warehouse Journal Line")
    var
        CalcWhseAdj: Report "Calc Whse. Adj. with Reason";
        ItemJnlLine: Record "Item Journal Line";
        Item: Record Item;
        ItemNoFilter: Text;
        lWhseJnlLine: Record "Warehouse Journal Line";
        DocumentNo: Code[20];
        DocumentDate: date;
        ItemJnlPost: Codeunit "Item Jnl.-Post Batch";
    begin
        ItemNoFilter := '';
        lWhseJnlLine.SETRANGE("Journal Template Name", WhseJnlLine."Journal Template Name");
        lWhseJnlLine.SETRANGE("Journal Batch Name", WhseJnlLine."Journal Batch Name");
        IF lWhseJnlLine.FINDSET THEN
            REPEAT
                IF ItemNoFilter <> '' THEN
                    ItemNoFilter += '|';
                ItemNoFilter += lWhseJnlLine."Item No.";
            UNTIL lWhseJnlLine.NEXT = 0;

        DocumentNo := lWhseJnlLine."Whse. Document No.";
        DocumentDate := lWhseJnlLine."Registering Date";

        COMMIT; // Commit the warehouse journal

        IF ItemNoFilter <> '' THEN BEGIN
            ItemJnlLine.SETRANGE("Journal Template Name", 'ITEM');
            ItemJnlLine.SETRANGE("Journal Batch Name", 'WHSE JNLFS');
            IF ItemJnlLine.FINDSET THEN
                ItemJnlLine.DELETEALL(TRUE);
            COMMIT;
            Item.Reset();
            Item.SETFILTER("No.", ItemNoFilter);

            ItemJnlLine."Journal Template Name" := 'ITEM';
            ItemJnlLine."Journal Batch Name" := 'WHSE JNLFS';

            CalcWhseAdj.SetItemJnlLine(ItemJnlLine);
            CalcWhseAdj.InitializeRequest(DocumentDate, DocumentNo);
            CalcWhseAdj.InitializeLocation(WhseJnlLine."Location Code");
            CalcWhseAdj.SetInternalRegNo(0);
            if WhseJnlLine."Reason Code" <> '' then
                CalcWhseAdj.SetReasonCodeFilter(WhseJnlLine."Reason Code", true, DMY2Date(01, 05, 2020));
            CalcWhseAdj.SETTABLEVIEW(Item);
            CalcWhseAdj.USEREQUESTPAGE := FALSE;
            CalcWhseAdj.SetHideValidationDialog(TRUE);
            CalcWhseAdj.RUNMODAL;
            COMMIT;

            ItemJnlPost.Run(ItemJnlLine)

        end;

    end;

    local procedure GetWhseReg(): Integer
    var
        WhseReg: Record "Warehouse Register";
    begin
        //Int. Register No. Update
        WhseReg.Reset();
        if WhseReg.FindLast() then
            exit(WhseReg."No." + 1);
        exit(0);
    end;

    local procedure WhseShipmentPost(SalesOrderNoP: Code[20])
    var
        WhseShipPost: codeunit "Whse.-Post Shipment";
        WarehouseShipLine: Record "Warehouse Shipment Line";
    begin
        WarehouseShipLine.Reset();
        WarehouseShipLine.SetRange("Source Type", 37);
        WarehouseShipLine.SetRange("Source Subtype", 1);
        WarehouseShipLine.SetRange("Source No.", SalesOrderNoP);
        if WarehouseShipLine.FindSet then begin
            WhseShipPost.SetPostingSettings(true);
            WhseShipPost.SetPrint(false);
            if WhseShipPost.Run(WarehouseShipLine) then begin
                clear(WhseShipPost);
                Commit();
                PostSalesOrder(SalesOrderNoP);
            end
        end;
    end;

    local procedure PostSalesOrder(SalesOrderNoP: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesPost: Codeunit "Sales-Post";
        LocationL: Record Location;
    begin

        if SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderNoP) then begin
            SalesLine.reset;
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SetRange("Document No.", SalesOrderNoP);
            if SalesLine.FindSet() then
                repeat
                    LocationL.Get(SalesLine."Location Code");
                    if Not LocationL."Directed Put-away and Pick" then
                        if (SalesLine."Qty. to Ship" = 0) OR (SalesLine."Qty. to Invoice" = 0) then begin
                            SalesLine."Qty. to Ship" := SalesLine.Quantity;
                            SalesLine."Qty. to Invoice" := SalesLine.Quantity;
                        end;
                until SalesLine.Next = 0;
            SalesLine.Modify();

            SalesHeader.Ship := true;
            SalesHeader.Invoice := True;
            SalesHeader.Modify();

            Clear(SalesPost);
            if SalesPost.Run(SalesHeader) then
                WebToolBox.UpdateIndex(WebIndex, 1, '');
        end;
    end;

    Procedure SetDateFilter(DatefilterP: Boolean)
    begin
        ApplyDatefilter := DatefilterP;
    end;

    //MITL.VS.20200721++
    local procedure CheckPostedWhseShipLine(SalesLineP: Record "Sales Line"; WebShipQtyP: Text): Boolean
    var
        PostedWhseShipLine: Record "Posted Whse. Shipment Line";
        QtyL: Decimal;
        PostedQtyL: Decimal;
    begin
        //20200826**
        QtyL := 0;
        PostedQtyL := 0;
        Evaluate(QtyL, WebShipQtyP);
        //**20200826
        PostedWhseShipLine.Reset();
        PostedWhseShipLine.SetRange("Source Type", 37);
        PostedWhseShipLine.SetRange("Source Subtype", 1);
        PostedWhseShipLine.SetRange("Source No.", SalesLineP."Document No.");
        PostedWhseShipLine.SetRange("Item No.", SalesLineP."No.");
        PostedWhseShipLine.SetRange("Source Line No.", SalesLineP."Line No.");
        if PostedWhseShipLine.FindSet then
            //20200826***
            repeat
                PostedQtyL += PostedWhseShipLine."Qty. (Base)";
            until PostedWhseShipLine.Next() = 0;
        //mitl.vs.20200908++
        if PostedQtyL >= QtyL then//mitl.vs.20200910
            QtyL += CheckAlreadyPickedWebShipQty(SalesLineP."Document No.", SalesLineP."No.");
        //mitl.vs.20200908--
        if (PostedQtyL >= QtyL) then
            //***20200826
            exit(true);
        exit(false);
    end;

    local procedure CheckRegisteredPickLine(SalesLine: Record "Sales Line"; WebShipQtyP: Text): Boolean
    var
        RegisteredPickLine: Record "Registered Whse. Activity Line";
        QtyL: Decimal;
        PickedQtyL: Decimal;
    begin
        //20200826**
        PickedQtyL := 0;
        QtyL := 0;
        Evaluate(QtyL, WebShipQtyP);
        //**20200826
        // RegisteredPickLine.Reset();
        // RegisteredPickLine.SetRange("Source Type", 37);
        // RegisteredPickLine.SetRange("Source Subtype", 1);
        // RegisteredPickLine.SetRange("Source No.", SalesLine."Document No.");
        // RegisteredPickLine.SetRange("Item No.", SalesLine."No.");
        // if RegisteredPickLine.FindFirst then
        //     exit(true);
        // exit(false);
        //20200826****
        PickedQtyL := GetPickedQty(SalesLine);

        //mitl.vs.20200908++
        if PickedQtyL >= QtyL then //mitl.vs.20200910
            QtyL += CheckAlreadyPickedWebShipQty(SalesLine."Document No.", SalesLine."No.");
        //mitl.vs.20200908--

        if PickedQtyL >= QtyL then
            exit(true);
        exit(false);
        //***20200826
    end;

    local procedure CheckCombinePick(SalesOrderNoP: Code[20]): Boolean
    var
        WhseShipLineL: Record "Warehouse Shipment Line";
    begin
        WhseShipLineL.Reset();
        WhseShipLineL.RESET;
        WhseShipLineL.SETRANGE("Source Type", 37);
        WhseShipLineL.SETRANGE("Source Subtype", 1);
        WhseShipLineL.SETRANGE("Source No.", SalesOrderNoP);
        WhseShipLineL.SetRange("Combined Pick", true);
        IF WhseShipLineL.FINDFIRST THEN
            exit(true);
    end;

    local procedure DeleteCombinePickLine(SalesOrderNoP: Code[20]; ItemP: Code[20])
    var
        PickLinesL: Record "Warehouse Activity Line";
        PickHeaderL: Record "Warehouse Activity Header";
    begin
        PickLinesL.Reset();
        PickLinesL.SetRange("Activity Type", PickLinesL."Activity Type"::Pick);
        PickLinesL.SetRange("Source Type", 37);
        PickLinesL.SetRange("Source Subtype", 1);
        PickLinesL.SetRange("Source No.", SalesOrderNoP);
        PickLinesL.SetRange("Item No.", ItemP);
        if PickLinesL.FindSet() then
            repeat
                // PickHeaderL.Get(PickHeaderL.Type::Pick, PickLinesL."No.");
                PickLinesL.Delete();
            until PickLinesL.Next() = 0;

        // IF PickLinesL.IsEmpty() then
        //     PickHeaderL.Delete();
    end;
    //MITL.VS.20200721--
    local procedure CheckWebShipErrorOnWebIndex(WebShipIdP: Code[20]) ReturnR: Boolean
    var
        WebIndexL: Record "WEB Index";
    begin
        ReturnR := false;
        WebIndexL.Reset();
        WebIndexL.SetRange("Table No.", 50014);
        WebIndexL.SetRange("Key Field 1", WebShipIdP);
        WebIndexL.SetRange(Status, WebIndex.Status::Error);
        if WebIndexL.FindFirst() then
            ReturnR := true;
    end;

    local procedure QtyHandleOnPick(SalesOrderNoP: Code[20]; WebShipmentIdP: Code[20])
    var
        PickLines: Record "Warehouse Activity Line";
        PickLine2: Record "Warehouse Activity Line";
        QtyL: Decimal;
        WebShipmentLineL: Record "WEB Shipment Lines";
        SalesLineL: Record "Sales Line";
        CheckPickedQtyL: Decimal;
        WebShippedQtyL: Decimal;
    begin
        CheckPickedQtyL := 0;//MITL.vs.20200907
        WebShippedQtyL := 0;
        PickLines.Reset();
        PickLines.SetRange("Source Type", 37);
        PickLines.SetRange("Source Subtype", 1);
        PickLines.SetRange("Source No.", SalesOrderNoP);
        PickLines.SetRange("Activity Type", PickLines."Activity Type"::Pick);
        if PickLines.FindFirst() then
            PickLines.DeleteQtyToHandle(PickLines);

        QtyL := 0;
        WebShipmentLineL.Reset();
        WebShipmentLineL.SetRange("Shipment ID", WebShipmentIdP);
        if WebShipmentLineL.FindSet() then
            repeat
                SalesLineL.Reset();
                SalesLineL.SetRange("Document Type", SalesLineL."Document Type"::Order);
                SalesLineL.SetRange("Document No.", SalesOrderNoP);
                SalesLineL.SetRange(Type, SalesLineL.Type::Item);
                SalesLineL.SetRange("No.", WebShipmentLineL.Sku);
                if SalesLineL.FindSet() then begin

                    //mitl.vs.20200907++
                    Evaluate(QtyL, WebShipmentLineL.QTY);
                    WebShippedQtyL := CheckAlreadyPickedWebShipQty(SalesLineL."Document No.", SalesLineL."No.");
                    if WebShippedQtyL > 0 then
                        QtyL := QtyL + WebShippedQtyL;

                    CheckPickedQtyL := GetPickedQty(SalesLineL);
                    if (CheckPickedQtyL > 0) and (CheckPickedQtyL < QtyL) then
                        QtyL := QtyL - CheckPickedQtyL;
                    //mitl.vs.20200907--
                    PickLine2.Reset();
                    PickLine2.SetRange("Activity Type", PickLine2."Activity Type"::Pick);
                    PickLine2.SetRange("Source Type", 37);
                    PickLine2.SetRange("Source Subtype", 1);
                    PickLine2.SetRange("Source No.", SalesLineL."Document No.");
                    PickLine2.SetRange("Source Line No.", SalesLineL."Line No.");
                    PickLine2.SetRange("Item No.", SalesLineL."No.");
                    // if PickLine2.FindFirst() then//MITL.VS.20200812
                    // PickLine2.AutofillQtyToHandle(PickLine2);//MITL.VS.20200812

                    if PickLine2.FindSet() then
                        repeat
                            // Evaluate(QtyL, WebShipmentLineL.QTY);//mitl.vs.20200907
                            IF (QtyL < PickLine2."Qty. Outstanding") AND (QtyL > 0) THEN BEGIN
                                PickLine2."Qty. to Handle" := QtyL;
                                PickLine2."Qty. to Handle (Base)" := QtyL;
                            END ELSE
                                IF QtyL > 0 THEN BEGIN
                                    PickLine2."Qty. to Handle" := PickLine2."Qty. Outstanding";
                                    PickLine2."Qty. to Handle (Base)" := PickLine2."Qty. Outstanding";
                                END;

                            IF QtyL > 0 THEN
                                IF PickLine2."Action Type" = PickLine2."Action Type"::Place THEN
                                    QtyL := QtyL - PickLine2."Qty. Outstanding";

                            PickLine2.Modify();
                        until PickLine2.Next() = 0;
                end;
            until WebShipmentLineL.Next() = 0;
    end;

    local procedure CheckBlankBinCodePickLine(SalesOrderNoP: Code[20])
    var
        PickLinesL: Record "Warehouse Activity Line";
        PickHeaderL: Record "Warehouse Activity Header";
        PickLine2L: Record "Warehouse Activity Line";
        DelCheckL: Boolean;
    begin
        DelCheckL := false;
        // IF CompanyName() = 'Tile Mountain' then begin
        PickLinesL.Reset();
        PickLinesL.SetRange("Activity Type", PickLinesL."Activity Type"::Pick);
        PickLinesL.SetRange("Source Type", 37);
        PickLinesL.SetRange("Source Subtype", 1);
        PickLinesL.SetRange("Source No.", SalesOrderNoP);
        PickLinesL.SetRange("Action Type", PickLinesL."Action Type"::Take);
        PickLinesL.SetRange("Bin Code", '');
        if CompanyName() = 'Walls and Floors' then
            PickLinesL.SetRange("Picking Bin", '');
        if PickLinesL.FindSet() then
            repeat
                DelCheckL := true;
            until (PickLinesL.Next() = 0) OR DelCheckL;

        if DelCheckL then begin
            PickLine2L.Reset();
            PickLine2L.SetRange("Activity Type", PickLine2L."Activity Type"::Pick);
            PickLine2L.SetRange("Source Type", 37);
            PickLine2L.SetRange("Source Subtype", 1);
            PickLine2L.SetRange("Source No.", SalesOrderNoP);
            if PickLine2L.FindSet() then begin
                repeat
                    PickHeaderL.Get(PickLine2L."Activity Type"::Pick, PickLine2L."No.");
                    PickLine2L.Delete();
                until PickLine2L.Next() = 0;
                PickHeaderL.Delete();
            end;
        end;
    end;
    //MITL.VS.20200821++
    local procedure CheckPickExistsLinewise(SalesLineP: Record "Sales Line"): Boolean
    var
        PickLines: Record "Warehouse Activity Line";
    begin
        PickLines.Reset();
        PickLines.SetRange("Activity Type", PickLines."Activity Type"::Pick);
        PickLines.SetRange("Source Type", 37);
        PickLines.SetRange("Source Subtype", 1);
        PickLines.SetRange("Source No.", SalesLineP."Document No.");
        PickLines.SetRange("Item No.", SalesLineP."No.");
        PickLines.SetRange("Source Line No.", SalesLineP."Line No.");
        if PickLines.FindFirst() then
            exit(true);
    end;

    local procedure CheckAlreadyPickRegistered(WebShipmentIdP: Code[20])
    var
        WebShipHeaderL: Record "WEB Shipment Header";
        WhseShipLineL: Record "Warehouse Shipment Line";
        WebShipLineL: Record "WEB Shipment Lines";
        SalesLineL: Record "Sales Line";
        CheckL: Boolean;
    begin
        WebShipHeaderL.Reset();
        WebShipHeaderL.SetRange("Shipment ID", WebShipmentIdP);
        if WebShipHeaderL.FindFirst() then begin
            CheckL := false;
            WebShipLineL.Reset();
            WebShipLineL.SetRange("Shipment ID", WebShipHeaderL."Shipment ID");
            if WebShipLineL.FindSet() then
                repeat
                    SalesLineL.Reset();
                    SalesLineL.SetRange("Document Type", SalesLineL."Document Type"::Order);
                    SalesLineL.SetRange("Document No.", WebShipHeaderL."Order ID");
                    SalesLineL.SetRange(Type, SalesLineL.Type::Item);
                    SalesLineL.SetRange("No.", WebShipLineL.Sku);
                    if SalesLineL.FindFirst() then begin
                        WhseShipLineL.Reset();
                        WhseShipLineL.SETRANGE("Source Type", 37);
                        WhseShipLineL.SETRANGE("Source Subtype", 1);
                        WhseShipLineL.SETRANGE("Source No.", SalesLineL."Document No.");
                        WhseShipLineL.SetRange("Source Line No.", SalesLineL."Line No.");
                        WhseShipLineL.SetRange("Item No.", SalesLineL."No.");
                        IF WhseShipLineL.FINDFIRST THEN begin
                            if (WhseShipLineL."Qty. Shipped" = WhseShipLineL."Qty. Picked") ANd
                                (WhseShipLineL.Quantity = WhseShipLineL."Qty. Picked")
                            then
                                CheckL := true;
                        end
                        //MITL.VS.20200825++
                        else begin
                            if (SalesLineL.Quantity = SalesLineL."Quantity Shipped") AND
                                (SalesLineL."Quantity Shipped" = GetPickedQty(SalesLineL)) then
                                CheckL := true;
                        end;
                        //MITL.VS.20200825--
                    end;
                until (WebShipLineL.Next() = 0) OR CheckL;
        end;
        if CheckL then
            CheckG := true;
    end;
    //MITL.VS.20200821--

    local procedure GetPickedQty(SalesLineP: Record "Sales Line") QtyR: Decimal
    var
        RegisteredPickLine: Record "Registered Whse. Activity Line";
    begin
        QtyR := 0;
        RegisteredPickLine.Reset();
        RegisteredPickLine.SetRange("Activity Type", RegisteredPickLine."Activity Type"::Pick);
        RegisteredPickLine.SetRange("Source Type", 37);
        RegisteredPickLine.SetRange("Source Subtype", 1);
        RegisteredPickLine.SetRange("Source No.", SalesLineP."Document No.");
        RegisteredPickLine.SetRange("Source Line No.", SalesLineP."Line No.");
        RegisteredPickLine.SetRange("Item No.", SalesLineP."No.");
        RegisteredPickLine.SetRange("Action Type", RegisteredPickLine."Action Type"::Take);
        if RegisteredPickLine.FindSet() then
            repeat
                QtyR += RegisteredPickLine."Qty. (Base)";
            until RegisteredPickLine.Next() = 0;
    end;

    //MITL.VS.20200904++
    local procedure CheckQtyPickedShippedInvoiced(WebShipmentIdP: code[20]) ReturnR: Boolean
    var
        PostedSalesShipLinesL: Record "Sales Shipment Line";
        RegisteredPickLinesL: Record "Registered Whse. Activity Line";
        PostedSalesInvLinesL: Record "Sales Invoice Line";
        WebShipHeaderL: Record "WEB Shipment Header";
        WebShipLinesL: Record "WEB Shipment Lines";
        WebShipQtyL: Decimal;
        PickedQtyL: Decimal;
        ShippedQtyL: Decimal;
        InvoicedQtyL: Decimal;
        WebShippedQtyL: Decimal;
    begin
        ReturnR := false;
        WebShipHeaderL.Reset();
        WebShipHeaderL.SetRange("Shipment ID", WebShipmentIdP);
        if WebShipHeaderL.FindFirst then begin
            WebShipLinesL.Reset;
            WebShipLinesL.SetRange("Shipment ID", WebShipHeaderL."Shipment Id");
            if WebShipLinesL.FindSet() then
                repeat
                    WebShipQtyL := 0;
                    PickedQtyL := 0;
                    ShippedQtyL := 0;
                    InvoicedQtyL := 0;
                    WebShippedQtyL := 0;
                    Evaluate(WebShipQtyL, WebShipLinesL.QTY);

                    RegisteredPickLinesL.Reset();
                    RegisteredPickLinesL.SetRange("Activity Type", RegisteredPickLinesL."Activity Type"::Pick);
                    RegisteredPickLinesL.SetRange("Action Type", RegisteredPickLinesL."Action Type"::Take);
                    RegisteredPickLinesL.SetRange("Source Type", 37);
                    RegisteredPickLinesL.SetRange("Source Subtype", 1);
                    RegisteredPickLinesL.SetRange("Source No.", WebShipHeaderL."Order ID");
                    RegisteredPickLinesL.SetRange("Item No.", WebShipLinesL.Sku);
                    if RegisteredPickLinesL.FindSet() then
                        repeat
                            PickedQtyL += RegisteredPickLinesL."Qty. (Base)";
                        until RegisteredPickLinesL.Next() = 0;

                    PostedSalesShipLinesL.Reset();
                    PostedSalesShipLinesL.SetRange("Order No.", WebShipHeaderL."Order ID");
                    PostedSalesShipLinesL.SetRange(Type, PostedSalesShipLinesL.Type::Item);
                    PostedSalesShipLinesL.SetRange("No.", WebShipLinesL.Sku);
                    PostedSalesShipLinesL.SetFilter(Quantity, '<>0');
                    if PostedSalesShipLinesL.FindSet() then
                        repeat
                            ShippedQtyL += PostedSalesShipLinesL."Quantity (Base)";
                        until PostedSalesShipLinesL.Next() = 0;

                    PostedSalesInvLinesL.Reset();
                    PostedSalesInvLinesL.SetRange("Order No.", WebShipHeaderL."Order ID");
                    PostedSalesInvLinesL.SetRange(Type, PostedSalesInvLinesL.Type::Item);
                    PostedSalesInvLinesL.SetRange("No.", WebShipLinesL.Sku);
                    PostedSalesInvLinesL.SetFilter(Quantity, '<>0');
                    if PostedSalesInvLinesL.FindSet() then
                        repeat
                            InvoicedQtyL += PostedSalesInvLinesL."Quantity (Base)";
                        until PostedSalesInvLinesL.Next() = 0;

                    //mitl.vs.20200908++
                    if PickedQtyL >= WebShipQtyL then begin//mitl.vs.20200910
                        WebShippedQtyL := CheckAlreadyPickedWebShipQty(WebShipHeaderL."Order ID", WebShipLinesL.Sku);
                        if WebShippedQtyL > 0 then
                            WebShipQtyL += WebShippedQtyL;
                    end;
                    //mitl.vs.20200908--

                    if (PickedQtyL < WebShipQtyL) OR
                        (ShippedQtyL < WebShipQtyL) OR
                        (InvoicedQtyL < WebShipQtyL)
                    then
                        ReturnR := true;

                until (WebShipLinesL.Next() = 0) OR ReturnR;
        end;
    end;
    //MITL.VS.20200904--
    //MITL.vs.20200907++
    local procedure CheckAlreadyPickedWebShipQty(SalesOrderNoP: Code[20]; ItemNoP: Code[20]) QtyR: Decimal
    var
        WebShipLineL: Record "WEB Shipment Lines";
        WebShipHeaderL: record "WEB Shipment Header";
        WebIndexL: Record "WEB Index";
        WebShipQtyL: Decimal;
        ReturnQtyL: Decimal;
    begin
        ReturnQtyL := 0;
        WebShipHeaderL.Reset();
        WebShipHeaderL.SetRange("Order ID", SalesOrderNoP);
        if WebShipHeaderL.FindSet() then
            repeat
                WebIndexL.Reset();
                WebIndexL.SetRange("Key Field 1", WebShipHeaderL."Shipment ID");
                // WebIndexL.SetRange(Status, WebIndexL.Status::Complete);//mitl.vs.20200909
                WebIndexL.SetFilter(Status, '%1|%2', WebIndexL.Status::" ", WebIndexL.Status::Complete);//mitl.vs.20200909
                if WebIndexL.FindFirst() then begin
                    WebShipLineL.Reset();
                    WebShipLineL.SetRange("Shipment ID", WebShipHeaderL."Shipment ID");
                    WebShipLineL.SetRange(Sku, ItemNoP);
                    if WebShipLineL.FindFirst() then begin
                        Evaluate(WebShipQtyL, WebShipLineL.QTY);
                        if WebShipmentHeader."Shipment ID" <> WebShipLineL."Shipment ID" then//mitl.vs.20200909
                            ReturnQtyL += WebShipQtyL;
                    end;
                end;
            until WebShipHeaderL.Next() = 0;

        if ReturnQtyL > 0 then
            QtyR := ReturnQtyL;
    end;
    //MITL.vs.20200907--
    var
        SalesOrderHeader: Record "Sales Header";
        SalesOrderLines: Record "Sales Line";
        WebFunc: Codeunit "WEB Functions";
        WebShipmentHeader: Record "WEB Shipment Header";
        StartDtTime: DateTime;
        EndDttime: DateTime;
        WebIndex: Record "WEB Index";
        WebToolBox: Codeunit "WEB Toolbox";
        ApplyDatefilter: Boolean;
        CheckG: Boolean;
        WebShipLines: Record "WEB Shipment Lines";//MITL.VS.20200729
        CrossRefNo: Code[20];
        ItemNo: Code[20];
}
//MITL_6702_VS--