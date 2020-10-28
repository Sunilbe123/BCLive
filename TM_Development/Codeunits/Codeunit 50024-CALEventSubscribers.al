//This codeunit is used in C/Side to create event subscribers in CAL. Object ID is 50024.
codeunit 50024 CALEventSubscribers
{
    [EventSubscriber(ObjectType::Codeunit, 7301, 'OnInitWhseEntryCopyFromWhseJnlLine', '', true, true)]
    local procedure UpdateWhseRegNoInWhseEntry(VAR WarehouseEntry: Record 7312; WarehouseJournalLine: Record 7311; OnMovement: Boolean)
    begin
        WarehouseEntry."Int. Register No." := WarehouseJournalLine."Int. Register No."; //MITL14137  
    end;

    PROCEDURE SendDocument(ReportUsage: Integer; RecordVariant: Variant; DocNo: Code[20]; ToCust: Code[20]; DocName: Text[150]; CustomerFieldNo: Integer; DocumentNoFieldNo: Integer);
    VAR
        DocumentSendingProfile: Record 60;
    BEGIN
        DocumentSendingProfile.Send(ReportUsage, RecordVariant, DocNo, ToCust, DocName, CustomerFieldNo, DocumentNoFieldNo);
    END;

    [EventSubscriber(ObjectType::Codeunit, 1521, 'OnReleaseDocument', '', true, true)]
    local procedure OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        Variant: Variant;
    begin
        RecRef.GetTable(Variant);
        CASE RecRef.NUMBER OF
            DATABASE::Vendor:// Mitl ADDED FOR VENDOR WORKFLOW APPROVAL For W&F
                begin
                    RemoveVendorBankModification(Variant);   // Mitl ADDED FOR VENDOR WORKFLOW APPROVAL For W&F
                    Handled := true;
                end;
        end;
    end;


    local procedure RemoveVendorBankModification(VAR VendorP: Record 23);
    VAR
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldRef1: FieldRef;
    BEGIN
        IF VendorP.Blocked = VendorP.Blocked::All THEN BEGIN
            RecRef.GETTABLE(VendorP);
            FieldRef := RecRef.FIELD(50000);
            FieldRef.VALUE := FALSE;
            FieldRef1 := RecRef.FIELD(39);
            FieldRef1.VALUE := 0;
            RecRef.MODIFY();
            //VendorP.Blocked := VendorP.Blocked::" ";
            //VendorP.MODIFY;
        END;
    END;

    [EventSubscriber(ObjectType::Codeunit, 7304, 'OnBeforeRegisterLines', '', true, true)]
    local procedure OnBeforeRegisterLines(var TempTrackingSpecification: Record "Tracking Specification"; var WarehouseJournalLine: Record "Warehouse Journal Line")
    var
        WhseRegNo: Integer;
    begin
        WhseRegNo := FindWhseRegNo();
        with WarehouseJournalLine do
            repeat
                WarehouseJournalLine."Int. Register No." := WhseRegNo
            until Next() = 0;
        WarehouseJournalLine.FindFirst();
    end;

    local procedure FindWhseRegNo(): Integer
    var
        WhseEntry: Record "Warehouse Entry";
        WhseReg: Record "Warehouse Register";
    begin
        WhseEntry.LockTable();
        if WhseEntry.FindLast() then;
        WhseReg.LockTable();
        exit(WhseReg.GetLastEntryNo() + 1);
    end;
}