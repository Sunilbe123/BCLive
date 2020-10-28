report 50002 "WhseSource-CreateDocument"
{
    // version NAVW19.00.00.43897, CASE 13601,CASE13605

    Caption = 'Whse.-Source - Create Document';
    Permissions = TableData 6550 = rm;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Posted Whse. Receipt Line"; "Posted Whse. Receipt Line")
        {
            DataItemTableView = SORTING ("No.", "Line No.");

            trigger OnAfterGetRecord()
            var
                PostedWhseReceiptLine2: Record "Posted Whse. Receipt Line";
                TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
                WMSMgt: Codeunit "WMS Management";
                ItemTrackingManagement: Codeunit "Item Tracking Management";
                WhseSNRequired: Boolean;
                WhseLNRequired: Boolean;
            begin
                WMSMgt.CheckOutboundBlockedBin("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");

                WhseWkshLine.SETRANGE("Whse. Document Line No.", "Line No.");
                IF NOT WhseWkshLine.FINDFIRST THEN BEGIN
                    PostedWhseReceiptLine2 := "Posted Whse. Receipt Line";
                    PostedWhseReceiptLine2.TESTFIELD("Qty. per Unit of Measure");
                    PostedWhseReceiptLine2.CALCFIELDS("Put-away Qty. (Base)");
                    PostedWhseReceiptLine2."Qty. (Base)" :=
                      PostedWhseReceiptLine2."Qty. (Base)" -
                      (PostedWhseReceiptLine2."Qty. Put Away (Base)" +
                       PostedWhseReceiptLine2."Put-away Qty. (Base)");
                    IF PostedWhseReceiptLine2."Qty. (Base)" > 0 THEN BEGIN
                        PostedWhseReceiptLine2.Quantity :=
                          ROUND(
                            PostedWhseReceiptLine2."Qty. (Base)" /
                            PostedWhseReceiptLine2."Qty. per Unit of Measure", 0.00001);

                        ItemTrackingManagement.CheckWhseItemTrkgSetup("Item No.", WhseSNRequired, WhseLNRequired, FALSE);
                        IF WhseSNRequired OR WhseLNRequired THEN
                            ItemTrackingManagement.InitItemTrkgForTempWkshLine(
                              WhseWkshLine."Whse. Document Type"::Receipt,
                              PostedWhseReceiptLine2."No.",
                              PostedWhseReceiptLine2."Line No.",
                              PostedWhseReceiptLine2."Source Type",
                              PostedWhseReceiptLine2."Source Subtype",
                              PostedWhseReceiptLine2."Source No.",
                              PostedWhseReceiptLine2."Source Line No.",
                              0);

                        CreatePutAway.SetCrossDockValues(PostedWhseReceiptLine2."Qty. Cross-Docked" <> 0);
                        CreatePutAwayFromDiffSource(PostedWhseReceiptLine2, DATABASE::"Posted Whse. Receipt Line");
                        CreatePutAway.GetQtyHandledBase(TempWhseItemTrkgLine);
                        UpdateWhseItemTrkgLines(PostedWhseReceiptLine2, DATABASE::"Posted Whse. Receipt Line", TempWhseItemTrkgLine);

                        IF CreateErrorText = '' THEN
                            CreatePutAway.GetMessage(CreateErrorText);
                        IF EverythingHandled THEN
                            EverythingHandled := CreatePutAway.EverythingIsHandled;
                    END;
                END;
            end;

            trigger OnPreDataItem()
            begin
                IF WhseDoc <> WhseDoc::"Posted Receipt" THEN
                    CurrReport.BREAK;

                CreatePutAway.SetValues(AssignedID, SortActivity, DoNotFillQtytoHandle, BreakbulkFilter);
                COPYFILTERS(PostedWhseReceiptLine);

                WhseWkshLine.SETCURRENTKEY("Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.");
                WhseWkshLine.SETRANGE(
                  "Whse. Document Type", WhseWkshLine."Whse. Document Type"::Receipt);
                WhseWkshLine.SETRANGE("Whse. Document No.", PostedWhseReceiptLine."No.");
            end;
        }
        dataitem("Whse. Mov.-Worksheet Line"; "Whse. Worksheet Line")
        {
            DataItemTableView = SORTING ("Worksheet Template Name", Name, "Location Code", "Line No.");

            trigger OnAfterGetRecord()
            var
                ItemTrackingMgt: Codeunit "Item Tracking Management";
                PickQty: Decimal;
                PickQtyBase: Decimal;
            begin
                IF FEFOLocation("Location Code") AND ItemTracking("Item No.") THEN
                    CreatePick.SetCalledFromWksh(TRUE)
                ELSE
                    CreatePick.SetCalledFromWksh(FALSE);

                TESTFIELD("Qty. per Unit of Measure");
                IF WhseWkshLine.CheckAvailQtytoMove < 0 THEN
                    ERROR(
                      Text004,
                      TABLECAPTION, FIELDCAPTION("Worksheet Template Name"), "Worksheet Template Name",
                      FIELDCAPTION(Name), Name, FIELDCAPTION("Location Code"), "Location Code",
                      FIELDCAPTION("Line No."), "Line No.");

                CheckBin("Location Code", "From Bin Code", FALSE);
                CheckBin("Location Code", "To Bin Code", TRUE);
                CreatePick.SetCalledFromWksh(TRUE);
                CreatePick.SetWhseWkshLine("Whse. Mov.-Worksheet Line", 1);
                CreatePick.SetTempWhseItemTrkgLine(
                  Name, DATABASE::"Whse. Worksheet Line", "Worksheet Template Name", 0,
                  "Line No.", "Location Code");
                PickQty := "Qty. to Handle";
                PickQtyBase := "Qty. to Handle (Base)";
                CreatePick.CreateTempLine(
                  "Location Code", "Item No.", "Variant Code", "Unit of Measure Code",
                  "From Bin Code", "To Bin Code", "Qty. per Unit of Measure", PickQty, PickQtyBase);

                WhseWkshLine := "Whse. Mov.-Worksheet Line";
                IF WhseWkshLine."Qty. to Handle" = WhseWkshLine."Qty. Outstanding" THEN BEGIN
                    WhseWkshLine.DELETE;
                    ItemTrackingMgt.DeleteWhseItemTrkgLines(
                      DATABASE::"Whse. Worksheet Line", 0, Name, "Worksheet Template Name", 0, "Line No.", "Location Code", TRUE);
                END ELSE BEGIN
                    PickQtyBase := "Qty. Handled (Base)" + "Qty. to Handle (Base)" - PickQtyBase;
                    WhseWkshLine.VALIDATE("Qty. Handled", "Qty. Handled" + "Qty. to Handle" - PickQty);
                    WhseWkshLine."Qty. Handled (Base)" := PickQtyBase;
                    WhseWkshLine."Qty. Outstanding (Base)" := "Qty. (Base)" - WhseWkshLine."Qty. Handled (Base)";
                    WhseWkshLine.MODIFY;
                END;
            end;

            trigger OnPreDataItem()
            begin
                IF WhseDoc <> WhseDoc::"Whse. Mov.-Worksheet" THEN
                    CurrReport.BREAK;

                CreatePick.SetValues(
                  AssignedID, 2, SortActivity, 2, 0, 0, FALSE, DoNotFillQtytoHandle, BreakbulkFilter, FALSE);

                CreatePick.SetCalledFromMoveWksh(TRUE);

                COPYFILTERS(WhseWkshLine);
                SETFILTER("Qty. to Handle (Base)", '>0');
                LOCKTABLE;
            end;
        }
        dataitem("Whse. Put-away Worksheet Line"; "Whse. Worksheet Line")
        {
            DataItemTableView = SORTING ("Worksheet Template Name", Name, "Location Code", "Line No.")
                                WHERE ("Whse. Document Type" = FILTER (Receipt | "Internal Put-away"));

            trigger OnAfterGetRecord()
            var
                PostedWhseRcptLine: Record "Posted Whse. Receipt Line";
                TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
                QtyHandledBase: Decimal;
                SourceType: Integer;
            begin
                LOCKTABLE;

                CheckBin("Location Code", "From Bin Code", FALSE);
                IF NOT PostedWhseRcptLine.GET("Whse. Document No.", "Whse. Document Line No.") THEN BEGIN
                    PostedWhseRcptLine.INIT;
                    PostedWhseRcptLine."No." := "Whse. Document No.";
                    PostedWhseRcptLine."Line No." := "Whse. Document Line No.";
                    PostedWhseRcptLine."Item No." := "Item No.";
                    PostedWhseRcptLine.Description := Description;
                    PostedWhseRcptLine."Description 2" := "Description 2";
                    PostedWhseRcptLine."Location Code" := "Location Code";
                    PostedWhseRcptLine."Zone Code" := "From Zone Code";
                    PostedWhseRcptLine."Bin Code" := "From Bin Code";
                    PostedWhseRcptLine."Shelf No." := "Shelf No.";
                    PostedWhseRcptLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
                    PostedWhseRcptLine."Due Date" := "Due Date";
                    PostedWhseRcptLine."Unit of Measure Code" := "Unit of Measure Code";
                    SourceType := DATABASE::"Whse. Internal Put-away Line";
                END ELSE
                    SourceType := DATABASE::"Posted Whse. Receipt Line";

                PostedWhseRcptLine.TESTFIELD("Qty. per Unit of Measure");
                PostedWhseRcptLine.Quantity := "Qty. to Handle";
                PostedWhseRcptLine."Qty. (Base)" := "Qty. to Handle (Base)";

                CreatePutAway.SetCrossDockValues(PostedWhseRcptLine."Qty. Cross-Docked" <> 0);
                CreatePutAwayFromDiffSource(PostedWhseRcptLine, SourceType);

                IF "Qty. to Handle" <> "Qty. Outstanding" THEN
                    EverythingHandled := FALSE;

                IF EverythingHandled THEN
                    EverythingHandled := CreatePutAway.EverythingIsHandled;

                QtyHandledBase := CreatePutAway.GetQtyHandledBase(TempWhseItemTrkgLine);

                IF QtyHandledBase > 0 THEN BEGIN
                    // update/delete line
                    WhseWkshLine := "Whse. Put-away Worksheet Line";
                    WhseWkshLine.VALIDATE("Qty. Handled (Base)", "Qty. Handled (Base)" + QtyHandledBase);
                    IF (WhseWkshLine."Qty. Outstanding" = 0) AND
                       (WhseWkshLine."Qty. Outstanding (Base)" = 0)
                    THEN
                        WhseWkshLine.DELETE
                    ELSE
                        WhseWkshLine.MODIFY;
                    UpdateWhseItemTrkgLines(PostedWhseRcptLine, SourceType, TempWhseItemTrkgLine);
                END ELSE
                    IF CreateErrorText = '' THEN
                        CreatePutAway.GetMessage(CreateErrorText);
            end;

            trigger OnPreDataItem()
            begin
                IF WhseDoc <> WhseDoc::"Put-away Worksheet" THEN
                    CurrReport.BREAK;

                CreatePutAway.SetValues(AssignedID, SortActivity, DoNotFillQtytoHandle, BreakbulkFilter);

                COPYFILTERS(WhseWkshLine);
                SETFILTER("Qty. to Handle (Base)", '>0');
            end;
        }
        dataitem("Whse. Internal Pick Line"; "Whse. Internal Pick Line")
        {
            DataItemTableView = SORTING ("No.", "Line No.");

            trigger OnAfterGetRecord()
            var
                WMSMgt: Codeunit "WMS Management";
                QtyToPick: Decimal;
                QtyToPickBase: Decimal;
            begin
                WMSMgt.CheckInboundBlockedBin("Location Code", "To Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");

                CheckBin(FALSE);
                WhseWkshLine.SETRANGE("Whse. Document Line No.", "Line No.");
                IF NOT WhseWkshLine.FINDFIRST THEN BEGIN
                    TESTFIELD("Qty. per Unit of Measure");
                    CALCFIELDS("Pick Qty. (Base)");
                    QtyToPickBase := "Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)");
                    QtyToPick :=
                      ROUND(
                        ("Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)")) /
                        "Qty. per Unit of Measure", 0.00001);
                    IF QtyToPick > 0 THEN BEGIN
                        CreatePick.SetWhseInternalPickLine("Whse. Internal Pick Line", 1);
                        CreatePick.SetTempWhseItemTrkgLine(
                          "No.", DATABASE::"Whse. Internal Pick Line", '', 0, "Line No.", "Location Code");
                        CreatePick.CreateTempLine(
                          "Location Code", "Item No.", "Variant Code", "Unit of Measure Code",
                          '', "To Bin Code", "Qty. per Unit of Measure", QtyToPick, QtyToPickBase);
                    END;
                END ELSE
                    WhseWkshLineFound := TRUE;
            end;

            trigger OnPreDataItem()
            begin
                IF WhseDoc <> WhseDoc::"Internal Pick" THEN
                    CurrReport.BREAK;

                CreatePick.SetValues(
                  AssignedID, 3, SortActivity, 1, 0, 0, FALSE, DoNotFillQtytoHandle, BreakbulkFilter, FALSE);

                COPYFILTERS(WhseInternalPickLine);
                SETFILTER("Qty. (Base)", '>0');

                WhseWkshLine.SETCURRENTKEY("Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.");
                WhseWkshLine.SETRANGE(
                  "Whse. Document Type", WhseWkshLine."Whse. Document Type"::"Internal Pick");
                WhseWkshLine.SETRANGE("Whse. Document No.", WhseInternalPickLine."No.");
            end;
        }
        dataitem("Whse. Internal Put-away Line"; "Whse. Internal Put-away Line")
        {
            DataItemTableView = SORTING ("No.", "Line No.");

            trigger OnAfterGetRecord()
            var
                TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
                WMSMgt: Codeunit "WMS Management";
                QtyToPutAway: Decimal;
            begin
                WMSMgt.CheckOutboundBlockedBin("Location Code", "From Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
                CheckCurrentLineQty;
                WhseWkshLine.SETRANGE("Whse. Document Line No.", "Line No.");
                IF NOT WhseWkshLine.FINDFIRST THEN BEGIN
                    TESTFIELD("Qty. per Unit of Measure");
                    CALCFIELDS("Put-away Qty. (Base)");
                    QtyToPutAway :=
                      ROUND(
                        ("Qty. (Base)" - ("Qty. Put Away (Base)" + "Put-away Qty. (Base)")) /
                        "Qty. per Unit of Measure", 0.00001);

                    IF QtyToPutAway > 0 THEN
                        WITH PostedWhseReceiptLine DO BEGIN
                            INIT;
                            "No." := "Whse. Internal Put-away Line"."No.";
                            "Line No." := "Whse. Internal Put-away Line"."Line No.";
                            "Location Code" := "Whse. Internal Put-away Line"."Location Code";
                            "Bin Code" := "Whse. Internal Put-away Line"."From Bin Code";
                            "Zone Code" := "Whse. Internal Put-away Line"."From Zone Code";
                            "Item No." := "Whse. Internal Put-away Line"."Item No.";
                            "Shelf No." := "Whse. Internal Put-away Line"."Shelf No.";
                            Quantity := QtyToPutAway;
                            "Qty. (Base)" :=
                              "Whse. Internal Put-away Line"."Qty. (Base)" -
                              ("Whse. Internal Put-away Line"."Qty. Put Away (Base)" +
                               "Whse. Internal Put-away Line"."Put-away Qty. (Base)");
                            "Qty. Put Away" := "Whse. Internal Put-away Line"."Qty. Put Away";
                            "Qty. Put Away (Base)" := "Whse. Internal Put-away Line"."Qty. Put Away (Base)";
                            "Put-away Qty." := "Whse. Internal Put-away Line"."Put-away Qty.";
                            "Put-away Qty. (Base)" := "Whse. Internal Put-away Line"."Put-away Qty. (Base)";
                            "Unit of Measure Code" := "Whse. Internal Put-away Line"."Unit of Measure Code";
                            "Qty. per Unit of Measure" := "Whse. Internal Put-away Line"."Qty. per Unit of Measure";
                            "Variant Code" := "Whse. Internal Put-away Line"."Variant Code";
                            Description := "Whse. Internal Put-away Line".Description;
                            "Description 2" := "Whse. Internal Put-away Line"."Description 2";
                            "Due Date" := "Whse. Internal Put-away Line"."Due Date";
                            CreatePutAwayFromDiffSource(PostedWhseReceiptLine, DATABASE::"Whse. Internal Put-away Line");
                            CreatePutAway.GetQtyHandledBase(TempWhseItemTrkgLine);
                            UpdateWhseItemTrkgLines(PostedWhseReceiptLine, DATABASE::"Whse. Internal Put-away Line", TempWhseItemTrkgLine);
                        END;
                END;
            end;

            trigger OnPreDataItem()
            begin
                IF WhseDoc <> WhseDoc::"Internal Put-away" THEN
                    CurrReport.BREAK;

                CreatePutAway.SetValues(AssignedID, SortActivity, DoNotFillQtytoHandle, BreakbulkFilter);

                SETRANGE("No.", WhseInternalPutAwayHeader."No.");
                SETFILTER("Qty. (Base)", '>0');

                WhseWkshLine.SETCURRENTKEY("Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.");
                WhseWkshLine.SETRANGE(
                  "Whse. Document Type", WhseWkshLine."Whse. Document Type"::"Internal Put-away");
                WhseWkshLine.SETRANGE("Whse. Document No.", WhseInternalPutAwayHeader."No.");
            end;
        }
        dataitem("Prod. Order Component"; "Prod. Order Component")
        {
            DataItemTableView = SORTING (Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.");

            trigger OnAfterGetRecord()
            var
                WMSMgt: Codeunit "WMS Management";
                QtyToPick: Decimal;
                QtyToPickBase: Decimal;
            begin
                IF ("Flushing Method" = "Flushing Method"::"Pick + Forward") AND ("Routing Link Code" = '') THEN
                    CurrReport.SKIP;

                IF NOT RequirePick("Location Code") THEN
                    CurrReport.SKIP;

                WMSMgt.CheckInboundBlockedBin("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");

                WhseWkshLine.SETRANGE("Source Line No.", "Prod. Order Line No.");
                WhseWkshLine.SETRANGE("Source Subline No.", "Line No.");
                IF NOT WhseWkshLine.FINDFIRST THEN BEGIN
                    TESTFIELD("Qty. per Unit of Measure");
                    CALCFIELDS("Pick Qty. (Base)");
                    QtyToPickBase := "Expected Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)");
                    QtyToPick :=
                      ROUND(
                        ("Expected Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)")) /
                        "Qty. per Unit of Measure", 0.00001);
                    IF QtyToPick > 0 THEN BEGIN
                        CreatePick.SetProdOrderCompLine("Prod. Order Component", 1);
                        CreatePick.SetTempWhseItemTrkgLine(
                          "Prod. Order No.", DATABASE::"Prod. Order Component", '',
                          "Prod. Order Line No.", "Line No.", "Location Code");
                        CreatePick.CreateTempLine(
                          "Location Code", "Item No.", "Variant Code", "Unit of Measure Code",
                          '', "Bin Code",
                          "Qty. per Unit of Measure", QtyToPick, QtyToPickBase);
                    END;
                END ELSE
                    WhseWkshLineFound := TRUE;
            end;

            trigger OnPreDataItem()
            begin
                IF WhseDoc <> WhseDoc::Production THEN
                    CurrReport.BREAK;

                WhseSetup.GET;
                CreatePick.SetValues(
                  AssignedID, 4, SortActivity, 1, 0, 0, FALSE, DoNotFillQtytoHandle, BreakbulkFilter, FALSE);

                SETRANGE("Prod. Order No.", ProdOrderHeader."No.");
                SETRANGE(Status, Status::Released);
                SETFILTER(
                  "Flushing Method", '%1|%2|%3',
                  "Flushing Method"::Manual,
                  "Flushing Method"::"Pick + Forward",
                  "Flushing Method"::"Pick + Backward");
                SETRANGE("Planning Level Code", 0);
                SETFILTER("Expected Qty. (Base)", '>0');

                WhseWkshLine.SETCURRENTKEY(
                  "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
                WhseWkshLine.SETRANGE("Source Type", DATABASE::"Prod. Order Component");
                WhseWkshLine.SETRANGE("Source Subtype", ProdOrderHeader.Status);
                WhseWkshLine.SETRANGE("Source No.", ProdOrderHeader."No.");
            end;
        }
        dataitem("Assembly Line"; "Assembly Line")
        {
            DataItemTableView = SORTING ("Document Type", "Document No.", Type, "Location Code")
                                WHERE (Type = CONST (Item));

            trigger OnAfterGetRecord()
            var
                WMSMgt: Codeunit "WMS Management";
            begin
                IF NOT RequirePick("Location Code") THEN
                    CurrReport.SKIP;

                WMSMgt.CheckInboundBlockedBin("Location Code", "Bin Code", "No.", "Variant Code", "Unit of Measure Code");

                WhseWkshLine.SETRANGE("Source Line No.", "Line No.");
                IF NOT WhseWkshLine.FINDFIRST THEN
                    CreatePick.CreateAssemblyPickLine("Assembly Line")
                ELSE
                    WhseWkshLineFound := TRUE;
            end;

            trigger OnPreDataItem()
            begin
                IF WhseDoc <> WhseDoc::Assembly THEN
                    CurrReport.BREAK;

                WhseSetup.GET;
                CreatePick.SetValues(
                  AssignedID, 5, SortActivity, 1, 0, 0, FALSE, DoNotFillQtytoHandle, BreakbulkFilter, FALSE);

                SETRANGE("Document No.", AssemblyHeader."No.");
                SETRANGE("Document Type", AssemblyHeader."Document Type");
                SETRANGE(Type, Type::Item);
                SETFILTER("Remaining Quantity (Base)", '>0');

                WhseWkshLine.SETCURRENTKEY(
                  "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
                WhseWkshLine.SETRANGE("Source Type", DATABASE::"Assembly Line");
                WhseWkshLine.SETRANGE("Source Subtype", AssemblyHeader."Document Type");
                WhseWkshLine.SETRANGE("Source No.", AssemblyHeader."No.");
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(AssignedID; AssignedID)
                    {
                        Caption = 'Assigned User ID';
                        TableRelation = "Warehouse Employee";

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            WhseEmployee: Record "Warehouse Employee";
                            LookupWhseEmployee: Page "Warehouse Employee List";
                        begin
                            WhseEmployee.SETCURRENTKEY("Location Code");
                            WhseEmployee.SETRANGE("Location Code", GetHeaderLocationCode);
                            LookupWhseEmployee.LOOKUPMODE(TRUE);
                            LookupWhseEmployee.SETTABLEVIEW(WhseEmployee);
                            IF LookupWhseEmployee.RUNMODAL = ACTION::LookupOK THEN BEGIN
                                LookupWhseEmployee.GETRECORD(WhseEmployee);
                                AssignedID := WhseEmployee."User ID";
                            END;
                        end;

                        trigger OnValidate()
                        var
                            WhseEmployee: Record "Warehouse Employee";
                        begin
                            IF AssignedID <> '' THEN
                                WhseEmployee.GET(AssignedID, GetHeaderLocationCode);
                        end;
                    }
                    field(SortingMethodForActivityLines; SortActivity)
                    {
                        Caption = 'Sorting Method for Activity Lines';
                        MultiLine = true;
                        OptionCaption = ' ,Item,Document,Shelf or Bin,Due Date,,Bin Ranking,Action Type';
                    }
                    field(BreakbulkFilter; BreakbulkFilter)
                    {
                        Caption = 'Set Breakbulk Filter';
                    }
                    field(DoNotFillQtytoHandle; DoNotFillQtytoHandle)
                    {
                        Caption = 'Do Not Fill Qty. to Handle';
                    }
                    field(PrintDoc; PrintDoc)
                    {
                        Caption = 'Print Document';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        var
            Location: Record Location;
        begin
            GetLocation(Location, GetHeaderLocationCode);
            IF Location."Use ADCS" THEN
                DoNotFillQtytoHandle := TRUE;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        WhseActivHeader: Record "Warehouse Activity Header";
        TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        IF (CreateErrorText <> '') AND (FirstActivityNo = '') AND (LastActivityNo = '') THEN
            ERROR(CreateErrorText);
        IF NOT (WhseDoc IN
                [WhseDoc::"Put-away Worksheet", WhseDoc::"Posted Receipt", WhseDoc::"Internal Put-away"])
        THEN BEGIN
            CreatePick.SetSalesOrderNo(WhseWkshLine."Source No.", WhseWkshLine."Source Line No.", WhseWkshLine."Movement Type"); //CASE 13601
            IF ForCreditG THEN  // CASE 13601
                CreatePick.CreateWhseDocumentCustom(FirstActivityNo, LastActivityNo, TRUE) // CASE 13601
            ELSE
                IF ItemWiseG THEN BEGIN// CASE 13605
                    //IF CreatePick.CreateWhseDocumentItemwise(FirstActivityNo, LastActivityNo, TRUE) THEN; // CASE 13605
                    CreatePick.CreateWhseDocumentItemwise(FirstActivityNo, LastActivityNo, TRUE);
                END ELSE
                    CreatePick.CreateWhseDocument(FirstActivityNo, LastActivityNo, TRUE);

            CreatePick.ReturnTempItemTrkgLines(TempWhseItemTrkgLine);
            ItemTrackingMgt.UpdateWhseItemTrkgLines(TempWhseItemTrkgLine);
            COMMIT;
        END ELSE
            CreatePutAway.GetWhseActivHeaderNo(FirstActivityNo, LastActivityNo);

        WhseActivHeader.SETRANGE("No.", FirstActivityNo, LastActivityNo);

        CASE WhseDoc OF
            WhseDoc::"Internal Pick", WhseDoc::Production, WhseDoc::Assembly:
                WhseActivHeader.SETRANGE(Type, WhseActivHeader.Type::Pick);
            WhseDoc::"Whse. Mov.-Worksheet":
                WhseActivHeader.SETRANGE(Type, WhseActivHeader.Type::Movement);
            WhseDoc::"Posted Receipt", WhseDoc::"Put-away Worksheet", WhseDoc::"Internal Put-away":
                WhseActivHeader.SETRANGE(Type, WhseActivHeader.Type::"Put-away");
        END;

        IF WhseActivHeader.FIND('-') THEN BEGIN
            REPEAT
                IF SortActivity > 0 THEN
                    WhseActivHeader.SortWhseDoc;
                COMMIT;
            UNTIL WhseActivHeader.NEXT = 0;

            IF PrintDoc THEN BEGIN
                CASE WhseDoc OF
                    WhseDoc::"Internal Pick", WhseDoc::Production, WhseDoc::Assembly:
                        REPORT.RUN(REPORT::"Picking List", FALSE, FALSE, WhseActivHeader);
                    WhseDoc::"Whse. Mov.-Worksheet":
                        REPORT.RUN(REPORT::"Movement List", FALSE, FALSE, WhseActivHeader);
                    WhseDoc::"Posted Receipt", WhseDoc::"Put-away Worksheet", WhseDoc::"Internal Put-away":
                        REPORT.RUN(REPORT::"Put-away List", FALSE, FALSE, WhseActivHeader);
                END
            END
        END ELSE
            ERROR(Text003);
    end;

    trigger OnPreReport()
    begin
        CLEAR(CreatePick);
        CLEAR(CreatePutAway);
        EverythingHandled := TRUE;
    end;

    var
        WhseSetup: Record "Warehouse Setup";
        WhseWkshLine: Record "Whse. Worksheet Line";
        WhseInternalPickLine: Record "Whse. Internal Pick Line";
        WhseInternalPutAwayHeader: Record "Whse. Internal Put-away Header";
        ProdOrderHeader: Record "Production Order";
        AssemblyHeader: Record "Assembly Header";
        PostedWhseReceiptLine: Record "Posted Whse. Receipt Line";
        CreatePick: Codeunit Create_Pick;
        CreatePutAway: Codeunit "Create Put-away";
        FirstActivityNo: Code[20];
        LastActivityNo: Code[20];
        AssignedID: Code[50];
        WhseDoc: Option "Whse. Mov.-Worksheet","Posted Receipt","Internal Pick","Internal Put-away",Production,"Put-away Worksheet",Assembly,"Service Order";
        SortActivity: Option " ",Item,Document,"Shelf/Bin No.","Due Date","Ship-To","Bin Ranking","Action Type";
        SourceTableCaption: Text[30];
        CreateErrorText: Text[80];
        Text000: Label '%1 activity no. %2 has been created.';
        Text001: Label '%1 activities no. %2 to %3 have been created.';
        PrintDoc: Boolean;
        EverythingHandled: Boolean;
        WhseWkshLineFound: Boolean;
        Text002: Label '\For %1 with existing Warehouse Worksheet Lines, no %2 lines have been created.';
        HideValidationDialog: Boolean;
        Text003: Label 'There is nothing to handle.';
        DoNotFillQtytoHandle: Boolean;
        Text004: Label 'You can create a Movement only for the available quantity in %1 %2 = %3,%4 = %5,%6 = %7,%8 = %9.';
        BreakbulkFilter: Boolean;
        ForCreditG: Boolean;
        ItemWiseG: Boolean;

    procedure SetPostedWhseReceiptLine(var PostedWhseReceiptLine2: Record "Posted Whse. Receipt Line"; AssignedID2: Code[50])
    begin
        PostedWhseReceiptLine.COPY(PostedWhseReceiptLine2);
        WhseDoc := WhseDoc::"Posted Receipt";
        SourceTableCaption := PostedWhseReceiptLine.TABLECAPTION;
        AssignedID := AssignedID2;
    end;

    procedure SetWhseWkshLine(var WhseWkshLine2: Record "Whse. Worksheet Line")
    begin
        WhseWkshLine.COPY(WhseWkshLine2);
        CASE WhseWkshLine."Whse. Document Type" OF
            WhseWkshLine."Whse. Document Type"::Receipt,
          WhseWkshLine."Whse. Document Type"::"Internal Put-away":
                WhseDoc := WhseDoc::"Put-away Worksheet";
            WhseWkshLine."Whse. Document Type"::" ":
                WhseDoc := WhseDoc::"Whse. Mov.-Worksheet";
        END;
    end;

    procedure SetWhseInternalPickLine(var WhseInternalPickLine2: Record "Whse. Internal Pick Line"; AssignedID2: Code[50])
    begin
        WhseInternalPickLine.COPY(WhseInternalPickLine2);
        WhseDoc := WhseDoc::"Internal Pick";
        SourceTableCaption := WhseInternalPickLine.TABLECAPTION;
        AssignedID := AssignedID2;
    end;

    procedure SetWhseInternalPutAway(var WhseInternalPutAwayHeader2: Record "Whse. Internal Put-away Header")
    begin
        WhseInternalPutAwayHeader.COPY(WhseInternalPutAwayHeader2);
        WhseDoc := WhseDoc::"Internal Put-away";
        SourceTableCaption := WhseInternalPutAwayHeader.TABLECAPTION;
        AssignedID := WhseInternalPutAwayHeader2."Assigned User ID";
    end;

    procedure SetProdOrder(var ProdOrderHeader2: Record "Production Order")
    begin
        ProdOrderHeader.COPY(ProdOrderHeader2);
        WhseDoc := WhseDoc::Production;
        SourceTableCaption := ProdOrderHeader.TABLECAPTION;
    end;

    procedure SetAssemblyOrder(var AssemblyHeader2: Record "Assembly Header")
    begin
        AssemblyHeader.COPY(AssemblyHeader2);
        WhseDoc := WhseDoc::Assembly;
        SourceTableCaption := AssemblyHeader.TABLECAPTION;
    end;

    procedure GetResultMessage(WhseDocType: Option): Boolean
    var
        WhseActivHeader: Record "Warehouse Activity Header";
    begin
        IF FirstActivityNo = '' THEN
            EXIT(FALSE);

        IF NOT HideValidationDialog THEN BEGIN
            WhseActivHeader.Type := WhseDocType;
            IF WhseWkshLineFound THEN BEGIN
                IF FirstActivityNo = LastActivityNo THEN
                    MESSAGE(
                      STRSUBSTNO(
                        Text000, FORMAT(WhseActivHeader.Type), FirstActivityNo) +
                      STRSUBSTNO(
                        Text002, SourceTableCaption, FORMAT(WhseActivHeader.Type)))
                ELSE
                    MESSAGE(
                      STRSUBSTNO(
                        Text001,
                        FORMAT(WhseActivHeader.Type), FirstActivityNo, LastActivityNo) +
                      STRSUBSTNO(
                        Text002, SourceTableCaption, FORMAT(WhseActivHeader.Type)));
            END ELSE BEGIN
                IF FirstActivityNo = LastActivityNo THEN
                    MESSAGE(Text000, FORMAT(WhseActivHeader.Type), FirstActivityNo)
                ELSE
                    MESSAGE(Text001, FORMAT(WhseActivHeader.Type), FirstActivityNo, LastActivityNo);
            END;
        END;
        EXIT(EverythingHandled);
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure RequirePick(LocationCode: Code[10]): Boolean
    var
        Location: Record Location;
    begin
        GetLocation(Location, LocationCode);
        IF Location.Code = '' THEN
            EXIT(WhseSetup."Require Pick" AND WhseSetup."Require Shipment");

        EXIT(Location."Require Pick" AND Location."Require Shipment");
    end;

    local procedure GetLocation(var Location: Record 14; LocationCode: Code[10])
    begin
        IF Location.Code <> LocationCode THEN
            IF LocationCode = '' THEN
                CLEAR(Location)
            ELSE
                Location.GET(LocationCode);
    end;

    procedure Initialize(AssignedID2: Code[50]; SortActivity2: Option " ",Item,Document,"Shelf/Bin No.","Due Date","Ship-To","Bin Ranking","Action Type"; PrintDoc2: Boolean; DoNotFillQtytoHandle2: Boolean; BreakbulkFilter2: Boolean)
    begin
        AssignedID := AssignedID2;
        SortActivity := SortActivity2;
        PrintDoc := PrintDoc2;
        DoNotFillQtytoHandle := DoNotFillQtytoHandle2;
        BreakbulkFilter := BreakbulkFilter2;
    end;

    procedure SetQuantity(var PostedWhseRcptLine: Record "Posted Whse. Receipt Line"; SourceType: Integer; var QtyToHandleBase: Decimal): Decimal
    var
        WhseItemTrackingLine: Record "Whse. Item Tracking Line";
    begin
        WITH WhseItemTrackingLine DO BEGIN
            RESET;
            SETCURRENTKEY("Serial No.", "Lot No.");
            SETRANGE("Serial No.", PostedWhseRcptLine."Serial No.");
            SETRANGE("Lot No.", PostedWhseRcptLine."Lot No.");
            SETRANGE("Source Type", SourceType);
            SETRANGE("Source ID", PostedWhseRcptLine."No.");
            SETRANGE("Source Ref. No.", PostedWhseRcptLine."Line No.");
            IF FINDFIRST THEN BEGIN
                IF QtyToHandleBase < "Qty. to Handle (Base)" THEN
                    PostedWhseRcptLine."Qty. (Base)" := QtyToHandleBase
                ELSE
                    PostedWhseRcptLine."Qty. (Base)" := "Qty. to Handle (Base)";
                QtyToHandleBase -= PostedWhseRcptLine."Qty. (Base)";
                PostedWhseRcptLine.Quantity :=
                  ROUND(PostedWhseRcptLine."Qty. (Base)" / PostedWhseRcptLine."Qty. per Unit of Measure", 0.00001);
            END;
        END
    end;

    procedure UpdateWhseItemTrkgLines(PostedWhseRcptLine: Record "Posted Whse. Receipt Line"; SourceType: Integer; var TempWhseItemTrkgLine: Record "Whse. Item Tracking Line")
    var
        WhseItemTrackingLine: Record "Whse. Item Tracking Line";
    begin
        WITH WhseItemTrackingLine DO BEGIN
            RESET;
            SETCURRENTKEY(
              "Source ID", "Source Type", "Source Subtype", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.");
            SETRANGE("Source ID", PostedWhseRcptLine."No.");
            SETRANGE("Source Type", SourceType);
            SETRANGE("Source Subtype", 0);
            SETRANGE("Source Batch Name", '');
            SETRANGE("Source Prod. Order Line", 0);
            SETRANGE("Source Ref. No.", PostedWhseRcptLine."Line No.");
            IF FIND('-') THEN
                REPEAT
                    TempWhseItemTrkgLine.SETRANGE("Source Type", "Source Type");
                    TempWhseItemTrkgLine.SETRANGE("Source ID", "Source ID");
                    TempWhseItemTrkgLine.SETRANGE("Source Ref. No.", "Source Ref. No.");
                    TempWhseItemTrkgLine.SETRANGE("Serial No.", "Serial No.");
                    TempWhseItemTrkgLine.SETRANGE("Lot No.", "Lot No.");
                    IF TempWhseItemTrkgLine.FIND('-') THEN
                        "Quantity Handled (Base)" += TempWhseItemTrkgLine."Quantity (Base)";
                    "Qty. to Handle (Base)" := "Quantity (Base)" - "Quantity Handled (Base)";
                    MODIFY;
                UNTIL NEXT = 0;
        END
    end;

    procedure CreatePutAwayFromDiffSource(PostedWhseRcptLine: Record "Posted Whse. Receipt Line"; SourceType: Integer)
    var
        TempPostedWhseRcptLine: Record "Posted Whse. Receipt Line" temporary;
        TempPostedWhseRcptLine2: Record "Posted Whse. Receipt Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        RemQtyToHandleBase: Decimal;
    begin
        CASE SourceType OF
            DATABASE::"Whse. Internal Put-away Line":
                ItemTrackingMgt.SplitInternalPutAwayLine(PostedWhseRcptLine, TempPostedWhseRcptLine);
            DATABASE::"Posted Whse. Receipt Line":
                ItemTrackingMgt.SplitPostedWhseRcptLine(PostedWhseRcptLine, TempPostedWhseRcptLine);
        END;
        RemQtyToHandleBase := PostedWhseRcptLine."Qty. (Base)";
        IF TempPostedWhseRcptLine.FIND('-') THEN
            REPEAT
                TempPostedWhseRcptLine2 := TempPostedWhseRcptLine;
                TempPostedWhseRcptLine2."Line No." := PostedWhseRcptLine."Line No.";
                SetQuantity(TempPostedWhseRcptLine2, SourceType, RemQtyToHandleBase);
                IF TempPostedWhseRcptLine2."Qty. (Base)" > 0 THEN BEGIN
                    CreatePutAway.RUN(TempPostedWhseRcptLine2);
                    CreatePutAway.UpdateTempWhseItemTrkgLines(TempPostedWhseRcptLine2, SourceType);
                END;
            UNTIL TempPostedWhseRcptLine.NEXT = 0;
    end;

    procedure FEFOLocation(LocCode: Code[10]): Boolean
    var
        Location2: Record Location;
    begin
        IF LocCode <> '' THEN BEGIN
            Location2.GET(LocCode);
            EXIT(Location2."Pick According to FEFO");
        END;
        EXIT(FALSE);
    end;

    procedure ItemTracking(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        IF ItemNo <> '' THEN BEGIN
            Item.GET(ItemNo);
            IF Item."Item Tracking Code" <> '' THEN BEGIN
                ItemTrackingCode.GET(Item."Item Tracking Code");
                EXIT((ItemTrackingCode."SN Specific Tracking" OR ItemTrackingCode."Lot Specific Tracking"));
            END;
        END;
        EXIT(FALSE);
    end;

    local procedure GetHeaderLocationCode(): Code[10]
    begin
        CASE WhseDoc OF
            WhseDoc::"Posted Receipt":
                EXIT(PostedWhseReceiptLine."Location Code");
            WhseDoc::"Put-away Worksheet",
          WhseDoc::"Whse. Mov.-Worksheet":
                EXIT(WhseWkshLine."Location Code");
            WhseDoc::"Internal Pick":
                EXIT(WhseInternalPickLine."Location Code");
            WhseDoc::"Internal Put-away":
                EXIT(WhseInternalPutAwayHeader."Location Code");
            WhseDoc::Production:
                EXIT(ProdOrderHeader."Location Code");
            WhseDoc::Assembly:
                EXIT(AssemblyHeader."Location Code");
        END;
    end;

    procedure ExecuteForCredit(ForCredit: Boolean)
    begin
        // CASE 13601
        ForCreditG := ForCredit;
        // CASE 13601
    end;

    procedure SetItemWiseMovements(ItemWiseP: Boolean)
    begin
        ItemWiseG := ItemWiseP;
    end;
}

