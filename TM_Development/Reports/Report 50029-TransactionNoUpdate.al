// report 50029 TransactionNoUpdate
// {
//     CaptionML = ENU = 'Trans. No. Update', ENG = 'Trans. No. Update';
//     UsageCategory = ReportsAndAnalysis;
//     ProcessingOnly = true;
//     ApplicationArea = All;
//     Description = 'MITL_TransNo';
//     Permissions = TableData 17 = rim, TableData 23 = rim, TableData 25 = rim, TableData 254 = rim,
//                     TableData 271 = rim, TableData 379 = rim, TableData 380 = rim;

//     dataset
//     {
//         dataitem("G/L Entry"; "G/L Entry")
//         {
//             DataItemTableView = sorting ("Entry No."); //where
//                                                        // ("Entry No." = filter (3160483 .. 3162385));

//             trigger OnPreDataItem()
//             begin
//                 SetFilter("Entry No.", '%1..%2', GLFrmEntryNo, GLToEntryNo);
//             end;

//             trigger OnAfterGetRecord()
//             begin
//                 // NewTransNo := 814107;
//                 // Counter := 0;
//                 TempGLReg.Reset();
//                 TempGLReg.SetRange("No.", "G/L Entry"."Transaction No.");
//                 if NOT TempGLReg.FindFirst() then begin
//                     Counter += 1;
//                     TempGLReg.Init();
//                     TempGLReg."No." := "G/L Entry"."Transaction No.";
//                     TempGLReg."From Entry No." := "G/L Entry"."Entry No.";
//                     TempGLReg."From VAT Entry No." := NewTransNo + Counter;
//                     TempGLReg."To VAT Entry No." := "G/L Entry"."old Transaction No.";
//                     TempGLReg.Insert();
//                 end else begin
//                     TempGLReg."To Entry No." := "G/L Entry"."Entry No.";
//                     TempGLReg.Modify();
//                 end;
//             end;

//             trigger OnPostDataItem()
//             var
//                 GLEntryL: Record "G/L Entry";
//             begin
//                 // if NOT TempGLReg.IsEmpty() then
//                 TempGLReg.Reset();
//                 if TempGLReg.FindSet() then
//                     repeat
//                         if GLEntryL.Get(TempGLReg."From Entry No.") then Begin

//                             Window.Update(1, 'New TransNo Update');
//                             Window.Update(2, TempGLReg."From VAT Entry No.");
//                             Window.Update(3, TempGLReg."To VAT Entry No.");

//                             UpdateTransNoCustLed(GLEntryL."Posting Date", GLEntryL."Document No.", TempGLReg."From VAT Entry No.", TempGLReg."To VAT Entry No.");
//                             UpdateTransNoDetailedCustLed(GLEntryL."Posting Date", GLEntryL."Document No.", TempGLReg."From VAT Entry No.", TempGLReg."To VAT Entry No.");
//                             UpdateTransVendLed(GLEntryL."Posting Date", GLEntryL."Document No.", TempGLReg."From VAT Entry No.", TempGLReg."To VAT Entry No.");
//                             UpdateTransNoDetailedVendLed(GLEntryL."Posting Date", GLEntryL."Document No.", TempGLReg."From VAT Entry No.", TempGLReg."To VAT Entry No.");
//                             UpdateTransVATEntry(GLEntryL."Posting Date", GLEntryL."Document No.", TempGLReg."From VAT Entry No.", TempGLReg."To VAT Entry No.");
//                             UpdateTransBankLed(GLEntryL."Posting Date", GLEntryL."Document No.", TempGLReg."From VAT Entry No.", TempGLReg."To VAT Entry No.");
//                             UpdateGLEntry(TempGLReg."From Entry No.", TempGLReg."To Entry No.", TempGLReg."From VAT Entry No.");
//                         End;
//                     until TempGLReg.Next() = 0;
//             end;
//         }
//     }

//     requestpage
//     {
//         layout
//         {
//             area(Content)
//             {
//                 field(NewTransNo; NewTransNo)
//                 {
//                     ApplicationArea = All;
//                     CaptionML = ENG = 'New Trans. No.', ENU = 'New Trans. No.';
//                 }
//                 group("GL Entry")
//                 {
//                     field(GLFrmEntryNo; GLFrmEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'From Entry No.', ENG = 'From Entry No.';
//                     }
//                     field(GLToEntryNo; GLToEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'To Entry No.', ENG = 'To Entry No.';
//                     }
//                 }
//                 group("Cust. Ledg Entry")
//                 {
//                     field(CustLedFrmEntryNo; CustLedFrmEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'From Entry No.', ENG = 'From Entry No.';
//                     }
//                     field(CustLedToEntryNo; CustLedToEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'To Entry No.', ENG = 'To Entry No.';
//                     }
//                 }
//                 group("Detailed Cust Ledg. Entry")
//                 {
//                     field(DCustLedFrmEntryNo; DCustLedFrmEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'From Entry No.', ENG = 'From Entry No.';
//                     }
//                     field(DCustLedToEntryNo; DCustLedToEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'To Entry No.', ENG = 'To Entry No.';
//                     }
//                 }
//                 group("Vend. Ledg Entry")
//                 {
//                     field(VendLedFrmEntryNo; VendLedFrmEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'From Entry No.', ENG = 'From Entry No.';
//                     }
//                     field(VendLedToEntryNo; VendLedToEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'To Entry No.', ENG = 'To Entry No.';
//                     }
//                 }
//                 group("Detailed Vend. Ledg Entry")
//                 {
//                     field(DVendLedFrmEntryNo; DVendLedFrmEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'From Entry No.', ENG = 'From Entry No.';
//                     }
//                     field(DVendLedToEntryNo; DVendLedToEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'To Entry No.', ENG = 'To Entry No.';
//                     }
//                 }
//                 group("VAT Entry")
//                 {
//                     field(VatFrmEntryNo; VatFrmEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'From Entry No.', ENG = 'From Entry No.';
//                     }
//                     field(VatToEntryNo; VatToEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'To Entry No.', ENG = 'To Entry No.';
//                     }
//                 }
//                 group("Bank Ledg Entry")
//                 {
//                     field(BankLedFrmEntryNo; BankLedFrmEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'From Entry No.', ENG = 'From Entry No.';
//                     }
//                     field(BankLedToEntryNo; BankLedToEntryNo)
//                     {
//                         ApplicationArea = All;
//                         CaptionML = ENU = 'To Entry No.', ENG = 'To Entry No.';
//                     }
//                 }
//             }
//         }

//         /*        actions
//                 {
//                     area(processing)
//                     {
//                         action(ActionName)
//                         {
//                             ApplicationArea = All;

//                         }
//                     }
//                 }*/
//     }

//     trigger OnInitReport()
//     begin
//         StartTime := 0DT;
//         EndTime := 0DT;
//         TotalTime := 0;
//     end;

//     trigger OnPreReport()
//     begin
//         //update the current transaction no to old transaction no field in all related table 
//         // Error('');
//         // if NewTransNo = 0 then
//         //     Error('Enter New Transaction No.');

//         if (GLFrmEntryNo = 0) OR (GLToEntryNo = 0) OR
//             (CustLedFrmEntryNo = 0) OR (CustLedToEntryNo = 0) OR
//             (DCustLedFrmEntryNo = 0) OR (DCustLedToEntryNo = 0) OR
//             (VendLedFrmEntryNo = 0) OR (VendLedToEntryNo = 0) OR
//             (DVendLedFrmEntryNo = 0) OR (DVendLedToEntryNo = 0) OR
//             (VatFrmEntryNo = 0) OR (VatToEntryNo = 0) OR
//             (BankLedFrmEntryNo = 0) OR (BankLedToEntryNo = 0)
//         then
//             Error('Entry No. should not blank');

//         Window.Open('Transaction No. Update\Name #1####################\NewTransNo. #2####################\OldTransNo. #3####################');
//         StartTime := CurrentDateTime();
//         Counter := 0;
//         UpdateOldTransNo();

//     end;

//     trigger OnPostReport()
//     var
//     // myInt: Integer;
//     begin
//         EndTime := CurrentDateTime();
//         TotalTime := EndTime - StartTime;
//         window.Close();
//         Message('Total time %1', TotalTime);
//     end;

//     var
//         //Add here global variables 
//         TempGLReg: Record "G/L Register" temporary;
//         NewTransNo: Integer;
//         Counter: Integer;
//         StartTime: DateTime;
//         EndTime: DateTime;
//         TotalTime: Duration;
//         Window: Dialog;
//         GLFrmEntryNo: Integer;
//         GLToEntryNo: Integer;
//         CustLedFrmEntryNo: Integer;
//         CustLedToEntryNo: Integer;
//         DCustLedFrmEntryNo: Integer;
//         DCustLedToEntryNo: Integer;
//         VendLedFrmEntryNo: Integer;
//         VendLedToEntryNo: Integer;
//         DVendLedFrmEntryNo: Integer;
//         DVendLedToEntryNo: Integer;
//         VatFrmEntryNo: Integer;
//         VatToEntryNo: Integer;
//         BankLedFrmEntryNo: Integer;
//         BankLedToEntryNo: Integer;

//     local procedure UpdateTransNoCustLed(PostingDtP: Date; DocNoP: Code[20]; NewTrasactionNoP: Integer; OldTransNoP: Integer)
//     var
//         CustLedgerEntryL: Record "Cust. Ledger Entry";
//     begin
//         CustLedgerEntryL.RESET;
//         CustLedgerEntryL.SETRANGE("Posting Date", PostingDtP);
//         CustLedgerEntryL.SETRANGE("Document No.", DocNoP);
//         CustLedgerEntryL.SETRANGE("Old Transaction No.", OldTransNoP);
//         IF CustLedgerEntryL.FINDSET THEN
//             REPEAT
//                 CustLedgerEntryL."Transaction No." := NewTrasactionNoP;
//                 CustLedgerEntryL.MODIFY;
//             UNTIL CustLedgerEntryL.NEXT = 0;
//     end;

//     local procedure UpdateTransNoDetailedCustLed(PostingDtP: Date; DocNoP: Code[20]; NewTrasactionNoP: Integer; OldTransNoP: Integer)
//     var
//         DetailedCustLedgEntryL: Record "Detailed Cust. Ledg. Entry";
//     begin
//         DetailedCustLedgEntryL.RESET;
//         DetailedCustLedgEntryL.SETRANGE("Posting Date", PostingDtP);
//         DetailedCustLedgEntryL.SETRANGE("Document No.", DocNoP);
//         DetailedCustLedgEntryL.SetRange("Old Transaction No.", OldTransNoP);
//         IF DetailedCustLedgEntryL.FINDSET THEN
//             REPEAT
//                 DetailedCustLedgEntryL."Transaction No." := NewTrasactionNoP;
//                 DetailedCustLedgEntryL.MODIFY;
//             UNTIL DetailedCustLedgEntryL.NEXT = 0;
//     end;

//     local procedure UpdateTransVendLed(PostingDtP: Date; DocNoP: Code[20]; NewTrasactionNoP: Integer; OldTransNoP: Integer)
//     var
//         VendLedgerEntryL: Record "Vendor Ledger Entry";
//     Begin
//         VendLedgerEntryL.RESET;
//         VendLedgerEntryL.SETRANGE("Posting Date", PostingDtP);
//         VendLedgerEntryL.SETRANGE("Document No.", DocNoP);
//         VendLedgerEntryL.SetRange("Old Transaction No.", OldTransNoP);
//         IF VendLedgerEntryL.FINDSET THEN
//             REPEAT
//                 VendLedgerEntryL."Transaction No." := NewTrasactionNoP;
//                 VendLedgerEntryL.MODIFY;
//             UNTIL VendLedgerEntryL.NEXT = 0;
//     End;

//     local procedure UpdateTransNoDetailedVendLed(PostingDtP: Date; DocNoP: Code[20]; NewTrasactionNoP: Integer; OldTransNoP: Integer)
//     var
//         DetailedVendLedgEntryL: Record "Detailed Vendor Ledg. Entry";
//     begin
//         DetailedVendLedgEntryL.RESET;
//         DetailedVendLedgEntryL.SETRANGE("Posting Date", PostingDtP);
//         DetailedVendLedgEntryL.SETRANGE("Document No.", DocNoP);
//         DetailedVendLedgEntryL.SetRange("Old Transaction No.", OldTransNoP);
//         IF DetailedVendLedgEntryL.FINDSET THEN
//             REPEAT
//                 DetailedVendLedgEntryL."Transaction No." := NewTrasactionNoP;
//                 DetailedVendLedgEntryL.MODIFY;
//             UNTIL DetailedVendLedgEntryL.NEXT = 0;
//     end;

//     local procedure UpdateTransVATEntry(PostingDtP: Date; DocNoP: Code[20]; NewTrasactionNoP: Integer; OldTransNoP: Integer)
//     var
//         VATEntryL: Record "VAT Entry";
//     begin
//         VATEntryL.RESET;
//         VATEntryL.SETRANGE("Posting Date", PostingDtP);
//         VATEntryL.SETRANGE("Document No.", DocNoP);
//         VATEntryL.SetRange("Old Transaction No.", OldTransNoP);
//         IF VATEntryL.FINDSET THEN
//             REPEAT
//                 VATEntryL."Transaction No." := NewTrasactionNoP;
//                 VATEntryL.MODIFY;
//             UNTIL VATEntryL.NEXT = 0;
//     end;

//     local procedure UpdateTransBankLed(PostingDtP: Date; DocNoP: Code[20]; NewTrasactionNoP: Integer; OldTransNoP: Integer)
//     var
//         BankAcLedEntryL: Record "Bank Account Ledger Entry";
//     begin
//         BankAcLedEntryL.RESET;
//         BankAcLedEntryL.SETRANGE("Posting Date", PostingDtP);
//         BankAcLedEntryL.SETRANGE("Document No.", DocNoP);
//         BankAcLedEntryL.SetRange("Old Transaction No.", OldTransNoP);
//         IF BankAcLedEntryL.FINDSET THEN
//             REPEAT
//                 BankAcLedEntryL."Transaction No." := NewTrasactionNoP;
//                 BankAcLedEntryL.MODIFY;
//             UNTIL BankAcLedEntryL.NEXT = 0;
//     end;

//     local procedure UpdateGLEntry(FrmEntryNoP: Integer; ToEntryNoP: Integer; NewTransNoP: Integer)
//     var
//         GLEntryL: Record "G/L Entry";
//     begin
//         GLEntryL.Reset();
//         GLEntryL.SetRange("Entry No.", FrmEntryNoP, ToEntryNoP);
//         if GLEntryL.FindSet() then
//             repeat
//                 GLEntryL."Transaction No." := NewTransNoP;
//                 GLEntryL.Modify();
//             until GLEntryL.Next() = 0;
//     end;

//     local procedure UpdateOldTransNo()
//     var
//         GLEntryL: Record "G/L Entry";
//         CustLedEntryL: Record "Cust. Ledger Entry";
//         DetailedCustLedEntryL: Record "Detailed Cust. Ledg. Entry";
//         VendLedEntryL: Record "Vendor Ledger Entry";
//         DetailedVendLedEntryL: Record "Detailed Vendor Ledg. Entry";
//         VATEntryL: Record "VAT Entry";
//         BankLedEntryL: Record "Bank Account Ledger Entry";
//     begin
//         Window.Update(1, 'Old Trans.No Update');
//         Window.Update(2, '');

//         GLEntryL.Reset();
//         // GLEntryL.SetRange("Entry No.", 3160483, 3199750);
//         GLEntryL.SetRange("Entry No.", GLFrmEntryNo, GLToEntryNo);
//         if GLEntryL.FindSet() then
//             repeat
//                 Window.Update(3, GLEntryL."Transaction No.");

//                 GLEntryL."Old Transaction No." := GLEntryL."Transaction No.";
//                 GLEntryL.Modify();
//             until GLEntryL.Next() = 0;

//         CustLedEntryL.Reset();
//         // CustLedEntryL.SetRange("Entry No.", 3160484, 3199010);
//         CustLedEntryL.SetRange("Entry No.", CustLedFrmEntryNo, CustLedToEntryNo);
//         if CustLedEntryL.FindSet() then
//             repeat
//                 Window.Update(3, CustLedEntryL."Transaction No.");

//                 CustLedEntryL."Old Transaction No." := CustLedEntryL."Transaction No.";
//                 CustLedEntryL.Modify();
//             until CustLedEntryL.Next() = 0;

//         DetailedCustLedEntryL.Reset();
//         // DetailedCustLedEntryL.SetRange("Entry No.", 629615, 636406);
//         DetailedCustLedEntryL.SetRange("Entry No.", DCustLedFrmEntryNo, DCustLedToEntryNo);
//         if DetailedCustLedEntryL.FindSet() then
//             repeat
//                 Window.Update(3, DetailedCustLedEntryL."Transaction No.");

//                 DetailedCustLedEntryL."Old Transaction No." := DetailedCustLedEntryL."Transaction No.";
//                 DetailedCustLedEntryL.Modify();
//             until DetailedCustLedEntryL.Next() = 0;

//         VendLedEntryL.Reset();
//         // VendLedEntryL.SetRange("Entry No.", 3167398, 3192001);
//         VendLedEntryL.SetRange("Entry No.", VendLedFrmEntryNo, VendLedToEntryNo);
//         if VendLedEntryL.FindSet() then
//             repeat
//                 Window.Update(3, VendLedEntryL."Transaction No.");

//                 VendLedEntryL."Old Transaction No." := VendLedEntryL."Transaction No.";
//                 VendLedEntryL.Modify();
//             until VendLedEntryL.Next() = 0;

//         DetailedVendLedEntryL.Reset();
//         // DetailedVendLedEntryL.SetRange("Entry No.", 20650, 21235);
//         DetailedVendLedEntryL.SetRange("Entry No.", DVendLedFrmEntryNo, DVendLedToEntryNo);
//         if DetailedVendLedEntryL.FindSet() then
//             repeat
//                 Window.Update(3, DetailedVendLedEntryL."Transaction No.");

//                 DetailedVendLedEntryL."Old Transaction No." := DetailedVendLedEntryL."Transaction No.";
//                 DetailedVendLedEntryL.Modify();
//             until DetailedVendLedEntryL.Next() = 0;

//         VATEntryL.Reset();
//         // VATEntryL.SetRange("Entry No.", 223625, 226214);
//         VATEntryL.SetRange("Entry No.", VatFrmEntryNo, VatToEntryNo);
//         if VATEntryL.FindSet() then
//             repeat
//                 Window.Update(3, VATEntryL."Transaction No.");

//                 VATEntryL."Old Transaction No." := VATEntryL."Transaction No.";
//                 VATEntryL.Modify();
//             until VATEntryL.Next() = 0;

//         BankLedEntryL.Reset();
//         // BankLedEntryL.SetRange("Entry No.", 3160483, 3198844);
//         BankLedEntryL.SetRange("Entry No.", BankLedFrmEntryNo, BankLedToEntryNo);
//         if BankLedEntryL.FindSet() then
//             repeat
//                 Window.Update(3, BankLedEntryL."Transaction No.");

//                 BankLedEntryL."Old Transaction No." := BankLedEntryL."Transaction No.";
//                 BankLedEntryL.Modify();
//             until BankLedEntryL.Next() = 0;
//     end;
// }