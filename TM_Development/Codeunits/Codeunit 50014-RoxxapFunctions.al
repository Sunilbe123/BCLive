codeunit 50014 "Roxxap Functions"
{
    // version R01971

    // R1971 - RM - 19.08.2014
    // Moved "Cut Size To-Do" field.


    trigger OnRun()
    begin
        //IF CONFIRM('create TO?') THEN
        //WEBFunctions.CreateTransferOrderCredits;
        //UpdateContactName;
        //CreateCutTileToDo;
        //CreditProcessing;
        //Item.GET('430845');
        //MESSAGE(FORMAT(SplitText(Item.Description + ' ' + Item."Description 2")));
        //JohnSons;
        //CreateBins;
        //IF CONFIRM('create new bins') THEN
        //  CreateNewBins;
        //IF CONFIRM('update putawa') THEN
        //  UpdatePutAway;
        //UpdateCustomers;
        //  createDefaultBin;
        //IF CONFIRM('createpick') THEN
        //WEBIndexHandling.MultiPicks;
        //WEBIndexHandling.HandleWriteOffs; //MITL2221
        //MarkWebCombinedPickAsDone;
        IF CONFIRM('Post Picks/Shipments?') THEN
            WebAdminPostPicksAndShipments;
    end;

    var
        LineBuf: array[10] of Text[250];
        Item: Record Item;
        //WEBIndexHandling: Codeunit 50004;
        //WEBFunctions: Codeunit 50001;

    procedure CreateCutTileToDo()
    var
        ToDo: Record "To-do";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        MarketingSetup: Record "Marketing Setup";
        SalesLine: Record "Sales Invoice Line";
        SalesHeader: Record "Sales Invoice Header";
        ContBusRel: Record "Contact Business Relation";
        OldNo: Code[20];
    begin
        MarketingSetup.GET;
        SalesLine.SETRANGE("Cut Size", TRUE);
        SalesLine.SETRANGE("Cut Size To-Do", FALSE);
        IF SalesLine.FINDSET THEN
            REPEAT
                SalesHeader.GET(SalesLine."Document No.");
                IF SalesHeader."Cut Size To-Do" = '' THEN BEGIN
                    ToDo.INIT;
                    ToDo."No." := NoSeriesMgt.GetNextNo(MarketingSetup."To-do Nos.", TODAY, TRUE);
                    ToDo."Team Code" := 'SALE';

                    ContBusRel.SETRANGE("No.", SalesHeader."Sell-to Customer No.");
                    ContBusRel.SETRANGE("Link to Table", ContBusRel."Link to Table"::Customer);
                    ContBusRel.FINDFIRST;

                    ToDo.VALIDATE("Contact No.", ContBusRel."Contact No.");
                    ToDo.Type := ToDo.Type::"Phone Call";
                    ToDo.Date := SalesHeader."Posting Date";
                    ToDo.Status := ToDo.Status::"Not Started";
                    ToDo.Description := 'Cut Size';
                    ToDo."Organizer To-do No." := ToDo."No.";
                    ToDo."System To-do Type" := ToDo."System To-do Type"::Team;
                    ToDo."Ending Date" := SalesHeader."Posting Date";
                    ToDo.INSERT(TRUE);
                    OldNo := ToDo."No.";

                    ToDo.INIT;
                    ToDo."No." := NoSeriesMgt.GetNextNo(MarketingSetup."To-do Nos.", TODAY, TRUE);
                    ToDo."Team Code" := 'SALE';

                    ContBusRel.SETRANGE("No.", SalesHeader."Sell-to Customer No.");
                    ContBusRel.SETRANGE("Link to Table", ContBusRel."Link to Table"::Customer);
                    ContBusRel.FINDFIRST;

                    ToDo.VALIDATE("Contact No.", ContBusRel."Contact No.");
                    ToDo.Type := ToDo.Type::"Phone Call";
                    ToDo.Date := SalesHeader."Posting Date";
                    ToDo.Status := ToDo.Status::"Not Started";
                    ToDo.Description := 'Cut Size';
                    ToDo."Organizer To-do No." := OldNo;
                    ToDo."System To-do Type" := ToDo."System To-do Type"::"Contact Attendee";
                    ToDo."Ending Date" := SalesHeader."Posting Date";
                    ToDo.INSERT(TRUE);
                    SalesLine."Cut Size To-Do" := TRUE;
                    SalesLine.MODIFY;
                    SalesHeader."Cut Size To-Do" := ToDo."No.";
                    SalesHeader.MODIFY;

                END;
            UNTIL SalesLine.NEXT = 0;
    end;

    procedure UpdateContactName()
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        Cust: Record Customer;
    begin
        Contact.SETFILTER("Phone No.", '%1', '');

        IF Contact.FINDSET THEN
            REPEAT
                ContBusRel.SETRANGE(ContBusRel."Contact No.", Contact."No.");
                ContBusRel.SETRANGE("Link to Table", ContBusRel."Link to Table"::Customer);
                IF ContBusRel.FINDFIRST THEN BEGIN
                    IF Cust.GET(ContBusRel."No.") THEN BEGIN
                        IF Contact."Phone No." = '' THEN
                            Contact."Phone No." := Cust."Phone No.";
                        Contact.MODIFY(TRUE);
                    END;
                END;

            UNTIL Contact.NEXT = 0;
    end;

    procedure NonInvtblCostAmt(var SalesLine: Record "Sales Invoice Line"): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SETRANGE("Item No.", SalesLine."No.");
        ValueEntry.SETRANGE("Document No.", SalesLine."Document No.");
        ValueEntry.SETRANGE("Document Line No.", SalesLine."Line No.");
        IF ValueEntry.FINDFIRST THEN BEGIN
            ItemLedgerEntry.GET(ValueEntry."Item Ledger Entry No.");
            ItemLedgerEntry.CALCFIELDS("Cost Amount (Non-Invtbl.)");
            EXIT(ItemLedgerEntry."Cost Amount (Non-Invtbl.)");
        END;
    end;

    // procedure CreditProcessing()
    // var
    //     CustLe: Record 21;
    //     CreditHandling: Record 50009;
    // begin
    //     CustLe.SETRANGE("Document Type", CustLe."Document Type"::Refund);
    //     IF CustLe.FINDSET THEN REPEAT
    //                                IF NOT CreditHandling.GET(CustLe."Entry No.", CustLe."Document No.") THEN BEGIN
    //                                    CustLe.CALCFIELDS(CustLe.Amount);
    //                                    CreditHandling."Entry No." := CustLe."Entry No.";
    //                                    CreditHandling."Document No." := CustLe."Document No.";
    //                                    CreditHandling.Customer := CustLe."Customer No.";
    //                                    CreditHandling.Amount := CustLe.Amount;
    //                                    CreditHandling.INSERT;
    //                                END
    //         UNTIL CustLe.NEXT = 0;


    //     CreditHandling.SETRANGE(Posted, FALSE);
    //     IF CreditHandling.FINDSET THEN REPEAT
    //                                        CustLe.RESET;
    //                                        CustLe.SETRANGE("Customer No.", CreditHandling.Customer);
    //                                        //CustLe.SETRANGE(CustLe."Entry No.",0,CreditHandling."Entry No.");
    //                                        CustLe.SETRANGE(Amount, -CreditHandling.Amount);
    //                                        IF CustLe.FINDFIRST THEN BEGIN
    //                                            CustLe.CALCFIELDS(Amount);
    //                                            CreditHandling."Apples to Entry" := CustLe."Entry No.";
    //                                            CreditHandling."Applies to Amount" := CustLe.Amount;
    //                                            CreditHandling.Application := 'Direct';
    //                                            CreditHandling.WebIncrementID := CustLe.WebIncrementID;
    //                                            CreditHandling.MODIFY;
    //                                        END ELSE BEGIN
    //                                            CustLe.SETRANGE(CustLe."Entry No.", 0, CreditHandling."Entry No.");
    //                                            CustLe.SETRANGE(Amount);
    //                                            CustLe.FINDLAST;
    //                                            CustLe.NEXT(-1);
    //                                            CustLe.CALCFIELDS(Amount);
    //                                            CreditHandling."Apples to Entry" := CustLe."Entry No.";
    //                                            CreditHandling."Applies to Amount" := CustLe.Amount;
    //                                            CreditHandling.Application := 'Closest';
    //                                            CreditHandling.WebIncrementID := CustLe.WebIncrementID;
    //                                            CreditHandling.MODIFY;
    //                                        END;
    //         UNTIL CreditHandling.NEXT = 0;
    // end;

    // procedure CreateCreditHandlingCredit(var CreditHandling: Record 50009)
    // var
    //     CreditHeader: Record 36;
    //     CreditLine: Record 37;
    //     CustLE: Record 21;
    // begin
    //     CreditHandling.CALCFIELDS("Shipment Exists");
    //     IF CreditHandling."Shipment Exists" <> 0 THEN BEGIN
    //         CustLE.GET(CreditHandling."Entry No.");
    //         CreditHeader.INIT;
    //         CreditHeader."Document Type" := CreditHeader."Document Type"::"Credit Memo";
    //         CreditHeader."No." := CreditHandling."Document No." + '-C';
    //         CreditHeader.VALIDATE("Posting Date", CustLE."Posting Date");
    //         CreditHeader.WebIncrementID := CreditHandling.WebIncrementID;
    //         CreditHeader.INSERT(TRUE);
    //         CreditHeader.VALIDATE("Sell-to Customer No.", CreditHandling.Customer);
    //         CreditHeader.VALIDATE("Payment Method Code", 'REFUNDS');
    //         CreditHeader.VALIDATE("Prices Including VAT", TRUE);
    //         CreditHeader.MODIFY(TRUE);

    //         CreditLine."Document Type" := CreditLine."Document Type"::"Credit Memo";
    //         CreditLine."Document No." := CreditHeader."No.";
    //         CreditLine."Line No." := 1;
    //         CreditLine.INSERT(TRUE);
    //         CreditLine.Type := CreditLine.Type::"Charge (Item)";
    //         CreditLine.VALIDATE("No.", 'REFUNDS');
    //         CreditLine.VALIDATE(Quantity, 1);
    //         CreditLine.VALIDATE("Unit Price", CreditHandling.Amount);
    //         CreditLine.MODIFY(TRUE);
    //         InsertItemChargeAss(CreditHandling, CreditLine);
    //         AssignCharges(CreditLine, CreditHandling);

    //     END;
    // end;

    // procedure InsertItemChargeAss(var ImportLine: Record 50009; var SalesLine: Record 37)
    // var
    //     SSHip: Record 111;
    //     SSHipHeader: Record 110;
    //     PurchLineAs: Record 5809;
    // begin

    //     SSHipHeader.SETRANGE(SSHipHeader.WebIncrementID, ImportLine.WebIncrementID);
    //     SSHipHeader.FINDFIRST;
    //     SSHip.SETRANGE("Document No.", SSHipHeader."No.");
    //     SSHip.SETRANGE(Type, SSHip.Type::Item);
    //     IF SSHip.FINDSET THEN REPEAT

    //                               PurchLineAs."Document Type" := SalesLine."Document Type";
    //                               PurchLineAs."Document No." := SalesLine."Document No.";
    //                               PurchLineAs."Document Line No." := SalesLine."Line No.";
    //                               PurchLineAs."Line No." := SSHip."Line No.";
    //                               PurchLineAs."Item Charge No." := 'REFUNDS';
    //                               PurchLineAs."Item No." := SSHip."No.";


    //                               //PurchLineAs."Qty. to Assign"
    //                               //PurchLineAs."Qty. Assigned"
    //                               //PurchLineAs."Unit Cost"
    //                               //PurchLineAs."Amount to Assign"
    //                               PurchLineAs."Applies-to Doc. Type" := PurchLineAs."Applies-to Doc. Type"::Shipment;
    //                               PurchLineAs."Applies-to Doc. No." := SSHipHeader."No.";
    //                               PurchLineAs."Applies-to Doc. Line No." := SSHip."Line No.";
    //                               //PurchLineAs."Applies-to Doc. Line Amount" :=
    //                               //PurchLineAs."Net Weight"
    //                               //PurchLineAs."Gross Weight"
    //                               PurchLineAs.INSERT;

    //         UNTIL SSHip.NEXT = 0;
    // end;

    // procedure AssignCharges(var Purchline: Record 37; var ImportLine: Record 50009)
    // var
    //     Charge: Codeunit 5807;
    //     SSHip: Record 111;
    //     SSHipHeader: Record 110;
    // begin

    //     SSHipHeader.SETRANGE(SSHipHeader.WebIncrementID, ImportLine.WebIncrementID);
    //     SSHipHeader.FINDFIRST;
    //     SSHip.SETRANGE("Document No.", SSHipHeader."No.");
    //     SSHip.SETRANGE(Type, SSHip.Type::Item);
    //     IF SSHip.FINDFIRST THEN
    //         IF SSHip."Unit Price" <> 0 THEN
    //             Charge.SuggestAssignment2(Purchline, 1, ((Purchline."Unit Price" / (100 + Purchline."VAT %")) * 100), 2)
    //         ELSE
    //             Charge.SuggestAssignment2(Purchline, 1, ((Purchline."Unit Price" / (100 + Purchline."VAT %")) * 100), 1);
    // end;

    procedure SplitText(InputText: Text[250]): Integer
    var
        i: Integer;
        RemainingText: Text[250];
        NextWord: Text[250];
        WordLen: Integer;
        LineWidth: Integer;
        LineNo: Integer;
        LineLength: Integer;
        InputLine: Integer;
    begin
        CLEAR(LineBuf);
        InputLine := 1;
        RemainingText := InputText;

        REPEAT
            i := STRPOS(RemainingText, ' ');
            IF i = 0 THEN BEGIN
                NextWord := RemainingText;
                RemainingText := '';
            END ELSE BEGIN
                NextWord := COPYSTR(RemainingText, 1, i - 1);
                RemainingText := COPYSTR(RemainingText, i + 1);
            END;
            WordLen := STRLEN(NextWord);

            IF (LineLength + WordLen <= 35) THEN BEGIN
                LineBuf[InputLine] += NextWord;
                LineLength += WordLen;
                IF LineLength < 35 THEN BEGIN
                    LineBuf[InputLine] += ' ';
                    LineLength += 1;
                END
            END ELSE BEGIN
                IF WordLen <= 35 THEN BEGIN
                    InputLine += 1;
                    LineBuf[InputLine] := NextWord;
                    LineLength := WordLen;
                    IF LineLength < 35 THEN BEGIN
                        LineBuf[InputLine] += ' ';
                        LineLength += 1;
                    END
                END;
            END;
        UNTIL RemainingText = '';
        EXIT(InputLine);
    end;

    // procedure GetStockCounters(ItemNo: Code[20]) Counts: Text
    // var
    //     StockCount: Record 50014;
    // begin
    //     Counts := '';
    //     StockCount.SETRANGE("Item No", ItemNo);
    //     IF StockCount.FINDSET THEN REPEAT
    //                                    IF Counts = '' THEN
    //                                        Counts := StockCount."User/Device" + '(' + FORMAT(StockCount.Qty) + ')'
    //                                    ELSE
    //                                        Counts := Counts + ' / ' + StockCount."User/Device" + '(' + FORMAT(StockCount.Qty) + ')'
    //     UNTIL StockCount.NEXT = 0;


    //     EXIT(Counts);
    // end;

    // procedure JohnSons()
    // var
    //     Item: Record 27;
    //     SalesLine: Record 37;
    //     JonSons: Record 50020;
    //     UOMMgt: Codeunit 5402;
    // begin
    //     Item.SETFILTER("Vendor No.", 'V00010');
    //     IF Item.FINDSET THEN REPEAT
    //                              SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Order);
    //                              SalesLine.SETRANGE("No.", Item."No.");
    //                              IF SalesLine.FINDSET THEN REPEAT

    //                                                            IF NOT JonSons.GET(SalesLine."Document No.", SalesLine."Line No.") THEN BEGIN
    //                                                                JonSons.INIT;
    //                                                                JonSons."Sales Order No." := SalesLine."Document No.";
    //                                                                JonSons."Sales Order Line No." := SalesLine."Line No.";
    //                                                                JonSons."Item No." := SalesLine."No.";
    //                                                                JonSons.Quantity := SalesLine.Quantity;
    //                                                                JonSons."Sales Order Date" := SalesLine."Shipment Date";
    //                                                                JonSons."Sales Order Unit Of Measure" := SalesLine."Unit of Measure Code";
    //                                                                JonSons."Qty Per Purchase UOM" := UOMMgt.GetQtyPerUnitOfMeasure(Item, Item."Purch. Unit of Measure");
    //                                                                JonSons."Qty Per Sales UOM" := UOMMgt.GetQtyPerUnitOfMeasure(Item, JonSons."Sales Order Unit Of Measure");
    //                                                                JonSons."DateTime Created" := CURRENTDATETIME;
    //                                                                JonSons.INSERT(TRUE);
    //                                                                IF (JonSons.Quantity = 1) AND (JonSons."Sales Order Unit Of Measure" = 'PCS') THEN
    //                                                                    JonSons.DELETE;
    //                                                            END;
    //                                  UNTIL SalesLine.NEXT = 0;
    //                              Item."Replenishment System" := Item."Replenishment System"::Purchase;
    //                              Item."Reordering Policy" := Item."Reordering Policy"::Order;
    //                              Item.MODIFY;
    //         UNTIL Item.NEXT = 0;
    // end;

    // procedure CreateJohnSonsPO(var PurchHeader: Record 38)
    // var
    //     Item: Record 27;
    //     PurchLine: Record 39;
    //     JonSons: Record 50020;
    //     tempJonSons: Record 50020 temporary;
    //     i: Integer;
    //     IUOM: Record 5404;
    // begin
    //     JonSons.SETRANGE("PO Completed", FALSE);
    //     IF JonSons.FINDSET THEN REPEAT
    //                                 tempJonSons.SETRANGE("Item No.", JonSons."Item No.");
    //                                 tempJonSons.SETRANGE("Sales Order Unit Of Measure", JonSons."Sales Order Unit Of Measure");
    //                                 IF tempJonSons.FINDFIRST THEN BEGIN
    //                                     tempJonSons.Quantity := tempJonSons.Quantity + JonSons.Quantity;
    //                                     tempJonSons.MODIFY;
    //                                 END ELSE BEGIN
    //                                     tempJonSons.INIT;
    //                                     tempJonSons := JonSons;
    //                                     tempJonSons.INSERT;
    //                                 END;
    //                                 JonSons."Purchase Order No." := PurchHeader."No.";
    //                                 //JonSons."Purchase Order Line No." := PurchLine."Line No.";
    //                                 JonSons."PO Completed" := TRUE;
    //                                 JonSons.MODIFY(TRUE);

    //         UNTIL JonSons.NEXT = 0;

    //     tempJonSons.RESET;

    //     IF tempJonSons.FINDSET THEN REPEAT
    //                                     IF Item.GET(tempJonSons."Item No.") THEN BEGIN
    //                                         i := i + 10000;
    //                                         PurchLine."Document Type" := PurchHeader."Document Type";
    //                                         PurchLine."Document No." := PurchHeader."No.";
    //                                         PurchLine."Line No." := i;
    //                                         PurchLine.Type := PurchLine.Type::Item;
    //                                         PurchLine.INSERT(TRUE);
    //                                         PurchLine.VALIDATE("No.", tempJonSons."Item No.");
    //                                         PurchLine.VALIDATE(Quantity, tempJonSons.Quantity / tempJonSons."Qty Per Purchase UOM");
    //                                         PurchLine.MODIFY(TRUE);
    //                                     END;
    //         UNTIL tempJonSons.NEXT = 0;


    //     PurchLine.SETRANGE("Document Type", PurchHeader."Document Type");
    //     PurchLine.SETRANGE("Document No.", PurchHeader."No.");
    //     IF PurchLine.FINDSET THEN REPEAT
    //                                   PurchLine.VALIDATE(Quantity, ROUND(PurchLine.Quantity, 1, '>'));
    //                                   PurchLine.MODIFY(TRUE);
    //         UNTIL PurchLine.NEXT = 0;
    //     MESSAGE('complete');
    // end;

    procedure CreateBins()
    var
        Bin: Record Bin;
        Bin2: Record Bin;
    begin
        Bin.SETFILTER(Code, 'AA-01-B..BH-64-B');
        Bin.SETRANGE("Zone Code", 'BULK');
        IF Bin.FINDSET THEN
            REPEAT
                Bin2.TRANSFERFIELDS(Bin);
                CASE COPYSTR(Bin.Code, 1, 2) OF
                    'AB':
                        BEGIN
                            Bin2.Code := 'AC' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AC':
                        BEGIN
                            Bin2.Code := 'AD' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AD':
                        BEGIN
                            Bin2.Code := 'AE' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AE':
                        BEGIN
                            Bin2.Code := 'AF' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AF':
                        BEGIN
                            Bin2.Code := 'AG' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AG':
                        BEGIN
                            Bin2.Code := 'AH' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AH':
                        BEGIN
                            Bin2.Code := 'AI' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AI':
                        BEGIN
                            Bin2.Code := 'AJ' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AJ':
                        BEGIN
                            Bin2.Code := 'AK' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AK':
                        BEGIN
                            Bin2.Code := 'AL' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AL':
                        BEGIN
                            Bin2.Code := 'AM' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AM':
                        BEGIN
                            Bin2.Code := 'AN' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AN':
                        BEGIN
                            Bin2.Code := 'AO' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AO':
                        BEGIN
                            Bin2.Code := 'AP' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AP':
                        BEGIN
                            Bin2.Code := 'AQ' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AQ':
                        BEGIN
                            Bin2.Code := 'AR' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AR':
                        BEGIN
                            Bin2.Code := 'AS' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AS':
                        BEGIN
                            Bin2.Code := 'AT' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AT':
                        BEGIN
                            Bin2.Code := 'AU' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AU':
                        BEGIN
                            Bin2.Code := 'AV' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AV':
                        BEGIN
                            Bin2.Code := 'AW' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AW':
                        BEGIN
                            Bin2.Code := 'AX' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AX':
                        BEGIN
                            Bin2.Code := 'AY' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AY':
                        BEGIN
                            Bin2.Code := 'AZ' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'AZ':
                        BEGIN
                            Bin2.Code := 'BA' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'BA':
                        BEGIN
                            Bin2.Code := 'BB' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'BB':
                        BEGIN
                            Bin2.Code := 'BC' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'BC':
                        BEGIN
                            Bin2.Code := 'BD' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'BD':
                        BEGIN
                            Bin2.Code := 'BE' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'BE':
                        BEGIN
                            Bin2.Code := 'BF' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'BF':
                        BEGIN
                            Bin2.Code := 'BG' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                    'BG':
                        BEGIN
                            Bin2.Code := 'BH' + COPYSTR(Bin.Code, 3, 5);
                            IF Bin2.INSERT THEN;
                        END;
                END;

            UNTIL Bin.NEXT = 0;
    end;

    procedure SendAllStockAvail()
    var
        Item: Record Item;
        WEBAvailableStock: Record "WEB Available Stock";
        ValueEntry: Record "Value Entry";
        Window: Dialog;
        i: Integer;
        j: Integer;
    begin
        i := Item.COUNT;
        Window.OPEN('Processing @@@@@1@@@@@@@@@@');

        IF Item.FINDSET THEN
            REPEAT
                j := j + 1;
                Window.UPDATE(1, ROUND((j / i) * 10000, 1));
                ValueEntry.SETFILTER("Item No.", Item."No.");
                ValueEntry.CALCSUMS("Cost Amount (Actual)", "Cost Amount (Expected)");
                Item.CALCFIELDS(Inventory, "Qty. on Sales Order");
                WEBAvailableStock.INIT;
                WEBAvailableStock.SKU := Item."No.";
                WEBAvailableStock."Available Quantity" := Item.Inventory - Item."Qty. on Sales Order";
                IF Item.Inventory <> 0 THEN
                    WEBAvailableStock."Average Cost" := (ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)") / Item.Inventory;
                WEBAvailableStock."Line No." := 0;
                IF WEBAvailableStock.INSERT THEN
                    WEBAvailableStock.MODIFY;
            UNTIL Item.NEXT = 0;


        Window.CLOSE;
    end;

    local procedure CreateNewBins()
    var
        Item: Record Item;
        Bin: Record Bin;
        Bin2: Record Bin;
        WebSetupRecL: Record "WEB Setup";
    begin
        // MITL
        WebSetupRecL.GET;
        WebSetupRecL.TESTFIELD("Web Location");
        Bin2.GET(WebSetupRecL."Web Location", 'A002');
        // MITL --
        IF Item.FINDSET THEN
            REPEAT
                IF Item."Shelf No." = '' THEN
                    Item."Shelf No." := 'UNKNOWN';

                Bin.TRANSFERFIELDS(Bin2);
                Bin.Code := Item."Shelf No.";

                IF Bin.INSERT THEN;

            UNTIL Item.NEXT = 0;

        MESSAGE('finished');
    end;

    local procedure UpdatePutAway()
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        Item: Record Item;
        Bin: Record Bin;
        WebSetupRecL: Record "WEB Setup";
    begin
        IF Item.FINDSET THEN
            REPEAT
                IF Item."Shelf No." = '' THEN
                    Item."Shelf No." := 'UNKNOWN';
                WarehouseActivityLine.SETRANGE("No.", 'PU000004');
                WarehouseActivityLine.SETRANGE("Item No.", Item."No.");
                // MITL ++
                WebSetupRecL.GET;
                WebSetupRecL.TESTFIELD("Web Location");
                Bin.GET(WebSetupRecL."Web Location", Item."Shelf No.");
                // MITL --
                WarehouseActivityLine.SETRANGE("Action Type", WarehouseActivityLine."Action Type"::Place);
                IF WarehouseActivityLine.FINDFIRST THEN BEGIN
                    WarehouseActivityLine.VALIDATE("Zone Code", Bin."Zone Code");
                    WarehouseActivityLine.VALIDATE("Bin Code", Item."Shelf No.");
                    WarehouseActivityLine.MODIFY(TRUE);
                END;
            UNTIL Item.NEXT = 0;

        MESSAGE('finsihed');
    end;

    local procedure createDefaultBin()
    var
        BinContent: Record "Bin Content";
        Item: Record Item;
        Bin: Record Bin;
        WebSetupRecL: Record "WEB Setup";
    begin
        Item.INIT;
        IF Item.FINDSET THEN
            REPEAT
                IF Item."Shelf No." = '' THEN
                    Item."Shelf No." := 'UNKNOWN';
                // MITL ++
                WebSetupRecL.GET;
                WebSetupRecL.TESTFIELD("Web Location");
                Bin.GET(WebSetupRecL."Web Location", Item."Shelf No.");
                // MITL --
                BinContent."Item No." := Item."No.";
                BinContent."Bin Code" := Item."Shelf No.";
                BinContent."Bin Type Code" := 'PUTPICK';
                BinContent."Zone Code" := Bin."Zone Code";
                // MITL ++
                BinContent."Location Code" := WebSetupRecL."Web Location";
                // MITL --
                BinContent."Unit of Measure Code" := Item."Base Unit of Measure";
                BinContent.Default := TRUE;
                IF BinContent.INSERT(TRUE) THEN;


            UNTIL Item.NEXT = 0;
        BinContent.RESET;
        IF BinContent.FINDSET THEN
            REPEAT
                IF BinContent."Location Code" = '' THEN
                    BinContent.DELETE;
            UNTIL BinContent.NEXT = 0;



        MESSAGE('complete');
    end;

    local procedure UpdateCustomers()
    var
        Customer: Record Customer;
        WebSetupRecL: Record "WEB Setup";
    begin
        IF Customer.FINDSET THEN
            REPEAT
                // MITL ++
                WebSetupRecL.GET;
                WebSetupRecL.TESTFIELD("Web Location");
                Customer.VALIDATE("Location Code", Item."Shelf No.");
                // MITL --
                Customer.MODIFY(TRUE);
            UNTIL Customer.NEXT = 0;




        MESSAGE('done');
    end;

    local procedure MarkWebCombinedPickAsDone()
    var
        WEBCombinedPicks: Record "WEB Combined Picks";
    begin
        WEBCombinedPicks.SETRANGE(Created, FALSE);
        WEBCombinedPicks.MODIFYALL(Created, TRUE);
        MESSAGE('updated web combined picks');
    end;

    procedure ItemBin(ItemNo: Code[20]): Code[20]
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.SETRANGE("Item No.", ItemNo);
        BinContent.SETRANGE(Default, TRUE);
        IF BinContent.FINDFIRST THEN
            EXIT(BinContent."Bin Code")
        ELSE BEGIN
            BinContent.SETRANGE(Default);
            BinContent.SETFILTER(Quantity, '<>0');
            IF BinContent.FINDFIRST THEN
                EXIT(BinContent."Bin Code")
        END;
    end;

    local procedure WebAdminPostPicksAndShipments()
    var
        WebIndexAdminPage: Page "WEB Index Monitoring ADMIN";
        WebReconciliation: Record "WEB Daily Reconciliation";
        WebIndex: Record "WEB Index";
    begin
        WebIndex.SETRANGE("Table No.", 50014);
        WebIndex.SETRANGE("Key Field 2", 'Insert');

        WebReconciliation.SETRANGE("WEB Type", WebReconciliation."WEB Type"::Shipment);
        WebReconciliation.SETRANGE("Reconciliation Complete", FALSE);
        WebReconciliation.SETRANGE("WEB Date", DMY2DATE(01, 01, 17), DMY2DATE(31, 01, 17));
        IF WebReconciliation.FINDSET THEN
            REPEAT
                WebIndex.SETRANGE("Key Field 1", WebReconciliation.ID);
                IF WebIndex.FINDFIRST THEN BEGIN
                    WebIndexAdminPage.PostShipmentandPick(WebIndex);
                    CLEAR(WebIndexAdminPage);
                    COMMIT;
                END;
            UNTIL WebReconciliation.NEXT = 0;
    end;
}

