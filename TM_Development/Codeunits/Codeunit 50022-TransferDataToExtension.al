// codeunit 50022 TransferDataToExtenson
// {
//     // Subtype = Install;

//     trigger OnRun()
//     begin

//     end;

//     var
//         myInt: Integer;

//     procedure MoveLocationData()
//     var
//         LocationL: Record Location;
//         LocationUPG: Record "Location UPG";
//     begin
//         IF LocationUPG.FindSet() then
//             repeat
//                 IF LocationL.Get(LocationUPG.Code) then begin
//                     LocationL."Auto Movement Template" := LocationUPG."Auto Movement Template";
//                     LocationL."Auto Movement Batch Name" := LocationUPG."Auto Movement Batch Name";
//                     LocationL."Auto Movement for Credit Memo" := LocationUPG."Auto Movement for Credit Memo";
//                     LocationL."Auto Pick Template Name" := LocationUPG."Auto Pick Template Name";
//                     LocationL."Auto Pick Batch Name" := LocationUPG."Auto Pick Batch Name";
//                     LocationL.Modify();
//                 end;
//             until LocationUPG.Next() = 0;
//         LocationUPG.DeleteAll();
//     end;

//     // procedure MoveGLEntryData()
//     // var
//     //     GLEntryL: Record "G/L Entry";
//     //     GLEntryUPG: Record "G/L Entry UPG";
//     // begin
//     //     GLEntryUPG.Setfilter(GLEntryUPG.WebIncrementID, '<>%1', '');
//     //     IF GLEntryUPG.FindSet() then
//     //         repeat
//     //             IF GLEntryL.Get(GLEntryUPG."Entry No.") then begin
//     //                 GLEntryL.WebIncrementID := GLEntryUPG.WebIncrementID;
//     //                 GLEntryL.Modify();
//     //             end;
//     //         until GLEntryUPG.Next() = 0;
//     //     GLEntryUPG.DeleteAll();
//     // end;

//     procedure MoveCustomerData()
//     var
//         CustomerL: Record Customer;
//         CustomerUPG: Record "Customer UPG";
//     begin

//         IF CustomerUPG.FindSet() then
//             repeat
//                 IF CustomerL.Get(CustomerUPG."No.") then begin
//                     CustomerL."Import Name" := CustomerUPG."Import Name";
//                     CustomerL."Import Address" := CustomerUPG."Import Address";
//                     CustomerL."Import Address 2" := CustomerUPG."Import Address 2";
//                     CustomerL."Import City" := CustomerUPG."Import City";
//                     CustomerL."Import County" := CustomerUPG."Import County";
//                     CustomerL."Import Post Code" := CustomerUPG."Import Post Code";
//                     CustomerL."Import Phone No." := CustomerUPG."Import Phone No.";
//                     CustomerL."Import Search Name" := CustomerUPG."Import Search Name";
//                     CustomerL."Import Email" := CustomerUPG."Import Email";
//                     CustomerL."Import Synched" := CustomerUPG."Import Synched";
//                     CustomerL."Customer ID" := CustomerUPG."Customer ID";
//                     CustomerL.WebCustomerFlag := CustomerUPG.WebCustomerFlag;
//                     CustomerL.WebCustomerGender := CustomerUPG.WebCustomerGender;
//                     CustomerL.WebCustomerGroup := CustomerUPG.WebCustomerGroup;
//                     CustomerL.WebSiteCode := CustomerUPG.WebSiteCode;
//                     CustomerL.WebCustomerID := CustomerUPG.WebCustomerID;
//                     CustomerL.WebBillToAddressID := CustomerUPG.WebBillToAddressID;
//                     CustomerL.WebSyncFlag := CustomerUPG.WebSyncFlag;
//                     CustomerL.WebCustomerGuestID := CustomerUPG.WebCustomerGuestID;
//                     CustomerL.IsWebGuest := CustomerUPG.IsWebGuest;
//                     CustomerL.Modify();
//                 end;
//             until CustomerUPG.Next() = 0;
//         CustomerUPG.DeleteAll();
//     end;

//     procedure MoveCustLedgerEntryData()
//     var
//         CustLedgEntryL: Record "Cust. Ledger Entry";
//         CustLedgerEntryUPG: Record "Cust. Ledger Entry UPG";
//     begin
//         CustLedgerEntryUPG.Setfilter(CustLedgerEntryUPG.WebIncrementID, '<>%1', '');
//         IF CustLedgerEntryUPG.FindSet() then
//             repeat
//                 IF CustLedgEntryL.Get(CustLedgerEntryUPG."Entry No.") then begin
//                     CustLedgEntryL.WebIncrementID := CustLedgerEntryUPG.WebIncrementID;
//                     CustLedgEntryL.Modify();
//                 end;
//             until CustLedgerEntryUPG.Next() = 0;
//         CustLedgerEntryUPG.DeleteAll();
//     end;

//     procedure MoveItemData()
//     var
//         ItemL: Record Item;
//         ItemUPG: Record "Item UPG";
//     begin
//         IF ItemUPG.FindSet() then
//             repeat
//                 IF ItemL.Get(ItemUPG."No.") then begin
//                     ItemL."Manufacturer Description" := ItemUPG."Manufacturer Description";
//                     ItemL.Size := ItemUPG.Size;
//                     ItemL."Manufacturer SKU" := ItemUPG."Manufacturer SKU";
//                     ItemL.Discontinued := ItemUPG.Discontinued;
//                     ItemL."Qty Per SQM" := ItemUPG."Qty Per SQM";
//                     ItemL.Height := ItemUPG.Height;
//                     ItemL.Width := ItemUPG.Width;
//                     ItemL.Status := ItemUPG.Status;
//                     ItemL."Item Weight Tolerence %" := ItemUPG."Item Weight Tolerence %";
//                     ItemL."Product Type" := ItemUPG."Product Type";
//                     ItemL.WebItemFlag := ItemUPG.WebItemFlag;
//                     ItemL.WebID := ItemUPG.WebID;
//                     ItemL.WebSyncFlag := ItemUPG.WebSyncFlag;
//                     ItemL.WebStockFlag := ItemUPG.WebStockFlag;
//                     ItemL.WebTierPriceSyncFlag := ItemUPG.WebTierPriceSyncFlag;
//                     ItemL.WebSpecialPriceSyncFlag := ItemUPG.WebSpecialPriceSyncFlag;
//                     ItemL.WebProdType := ItemUPG.WebProdType;
//                     ItemL.WebPriceType := ItemUPG.WebPriceType;
//                     ItemL.Modify();
//                 end;
//             until ItemUPG.Next() = 0;
//         ItemUPG.DeleteAll();
//     end;

//     procedure MoveSalesHeaderData()
//     var
//         SalesHeaderL: Record "Sales Header";
//         SalesHeaderUPG: Record "Sales Header UPG";
//     begin
//         IF SalesHeaderUPG.FindSet() then
//             repeat
//                 IF SalesHeaderL.Get(SalesHeaderUPG."Document Type", SalesHeaderUPG."No.") then begin
//                     SalesHeaderL."Payment Created" := SalesHeaderUPG."Payment Created";
//                     SalesHeaderL."Import Sell-to Cust. Name" := SalesHeaderUPG."Import Sell-to Cust. Name";
//                     SalesHeaderL."Import Sell-to Address" := SalesHeaderUPG."Import Sell-to Address";
//                     SalesHeaderL."Import Sell-to Address 2" := SalesHeaderUPG."Import Sell-to Address 2";
//                     SalesHeaderL."Import Sell-to City" := SalesHeaderUPG."Import Sell-to City";
//                     SalesHeaderL."Import Sell-to County" := SalesHeaderUPG."Import Sell-to County";
//                     SalesHeaderL."Import Sell-to Post Code" := SalesHeaderUPG."Import Sell-to Post Code";
//                     SalesHeaderL."Import Bill-to Name" := SalesHeaderUPG."Import Bill-to Name";
//                     SalesHeaderL."Import Bill-to Address" := SalesHeaderUPG."Import Bill-to Address";
//                     SalesHeaderL."Import Bill-to Address 2" := SalesHeaderUPG."Import Bill-to Address 2";
//                     SalesHeaderL."Import Bill-to City" := SalesHeaderUPG."Import Bill-to City";
//                     SalesHeaderL."Import Bill-to County" := SalesHeaderUPG."Import Bill-to County";
//                     SalesHeaderL."Import Bill-to Post Code" := SalesHeaderUPG."Import Bill-to Post Code";
//                     SalesHeaderL."Import Ship-to Name" := SalesHeaderUPG."Import Ship-to Name";
//                     SalesHeaderL."Import Ship-to Address" := SalesHeaderUPG."Import Ship-to Address";
//                     SalesHeaderL."Import Ship-to Address 2" := SalesHeaderUPG."Import Ship-to Address 2";
//                     SalesHeaderL."Import Ship-to City" := SalesHeaderUPG."Import Ship-to City";
//                     SalesHeaderL."Import Ship-to County" := SalesHeaderUPG."Import Ship-to County";
//                     SalesHeaderL."Import Ship-to Post Code" := SalesHeaderUPG."Import Ship-to Post Code";
//                     SalesHeaderL."Import Synched" := SalesHeaderUPG."Import Synched";
//                     SalesHeaderL.Modify();
//                 end;
//             until SalesHeaderUPG.Next() = 0;
//         SalesHeaderUPG.DeleteAll();
//     end;

//     procedure MoveSalesLineData()
//     var
//         SalesLineL: Record "Sales Line";
//         SalesLineUPG: Record "Sales Line UPG";
//     begin
//         IF SalesLineUPG.FindSet() then
//             repeat
//                 IF SalesLineL.Get(SalesLineUPG."Document Type", SalesLineUPG."Document No.", SalesLineUPG."Line No.") then begin
//                     SalesLineL."Cut Size" := SalesLineUPG."Cut Size";
//                     SalesLineL."Cut Size To-Do" := SalesLineUPG."Cut Size To-Do";
//                     SalesLineL.Processed := SalesLineUPG.Processed;
//                     SalesLineL.WebOrderItemID := SalesLineUPG.WebOrderItemID;
//                     SalesLineL.Modify();
//                 end;
//             until SalesLineUPG.Next() = 0;
//         SalesLineUPG.DeleteAll();
//     end;

//     procedure MovePurchaseHaederData()
//     var
//         PurchHeadL: Record "Purchase Header";
//         PurchHeadUPG: Record "Purchase Header UPG";
//     begin
//         IF PurchHeadUPG.FindSet() then
//             repeat
//                 IF PurchHeadL.Get(PurchHeadUPG."Document Type", PurchHeadUPG."No.") then begin
//                     PurchHeadL."PO Status" := PurchHeadUPG."PO Status";
//                     PurchHeadL."Container No." := PurchHeadUPG."Container No.";
//                     PurchHeadL.TimeUpdated := PurchHeadUPG.TimeUpdated;
//                     PurchHeadL.Modify();
//                 end;
//             until PurchHeadUPG.Next() = 0;
//         PurchHeadUPG.DeleteAll();
//     end;

//     procedure MoveGenJnlLineData()
//     var
//         GenJnlLineL: Record "Gen. Journal Line";
//         GenJnlLineUPG: Record "Gen. Journal Line UPG";
//     begin
//         GenJnlLineUPG.SetFilter(GenJnlLineUPG.WebIncrementID, '<>%1', '');
//         IF GenJnlLineUPG.FindSet() then
//             repeat
//                 IF GenJnlLineL.Get(GenJnlLineUPG."Journal Template Name", GenJnlLineUPG."Journal Batch Name", GenJnlLineUPG."Line No.") then begin
//                     GenJnlLineL.WebIncrementID := GenJnlLineUPG.WebIncrementID;
//                     GenJnlLineL.Modify();
//                 end;
//             until GenJnlLineUPG.Next() = 0;
//         GenJnlLineUPG.DeleteAll();
//     end;


//     procedure MoveUserSetupData()
//     var
//         UserSetupL: Record "User Setup";
//         UserSetupUPG: Record "User Setup UPG";
//     begin
//         IF UserSetupUPG.FindSet() then
//             repeat
//                 IF UserSetupL.Get(UserSetupUPG."User ID") then begin
//                     UserSetupL."Receive Only" := UserSetupUPG."Receive Only";
//                     UserSetupL."Get Sync.Warning Email" := UserSetupUPG."Get Sync.Warning Email";
//                     UserSetupL.Modify();
//                 end;
//             until UserSetupUPG.Next() = 0;
//         UserSetupUPG.DeleteAll();
//     end;

//     procedure MoveSalesShipHeadData()
//     Var
//         SalShipHeadL: Record "Sales Shipment Header";
//         SalShipHeadUPG: Record "Sales Shipment Header UPG";
//     Begin
//         IF SalShipHeadUPG.FindSet() then
//             repeat
//                 IF SalShipHeadL.Get(SalShipHeadUPG."No.") then begin
//                     SalShipHeadL."Payment Created" := SalShipHeadUPG."Payment Created";
//                     SalShipHeadL."Import Sell-to Cust. Name" := SalShipHeadUPG."Import Sell-to Cust. Name";
//                     SalShipHeadL."Import Sell-to Address" := SalShipHeadUPG."Import Sell-to Address";
//                     SalShipHeadL."Import Sell-to Address 2" := SalShipHeadUPG."Import Sell-to Address 2";
//                     SalShipHeadL."Import Sell-to City" := SalShipHeadUPG."Import Sell-to City";
//                     SalShipHeadL."Import Sell-to County" := SalShipHeadUPG."Import Sell-to County";
//                     SalShipHeadL."Import Sell-to Post Code" := SalShipHeadUPG."Import Sell-to Post Code";
//                     SalShipHeadL."Import Bill-to Name" := SalShipHeadUPG."Import Bill-to Name";
//                     SalShipHeadL."Import Bill-to Address" := SalShipHeadUPG."Import Bill-to Address";
//                     SalShipHeadL."Import Bill-to Address 2" := SalShipHeadUPG."Import Bill-to Address 2";
//                     SalShipHeadL."Import Bill-to City" := SalShipHeadUPG."Import Bill-to City";
//                     SalShipHeadL."Import Bill-to County" := SalShipHeadUPG."Import Bill-to County";
//                     SalShipHeadL."Import Bill-to Post Code" := SalShipHeadUPG."Import Bill-to Post Code";
//                     SalShipHeadL."Import Ship-to Name" := SalShipHeadUPG."Import Ship-to Name";
//                     SalShipHeadL."Import Ship-to Address" := SalShipHeadUPG."Import Ship-to Address";
//                     SalShipHeadL."Import Ship-to Address 2" := SalShipHeadUPG."Import Ship-to Address 2";
//                     SalShipHeadL."Import Ship-to City" := SalShipHeadUPG."Import Ship-to City";
//                     SalShipHeadL."Import Ship-to County" := SalShipHeadUPG."Import Ship-to County";
//                     SalShipHeadL."Import Ship-to Post Code" := SalShipHeadUPG."Import Ship-to Post Code";
//                     SalShipHeadL."Import Synched" := SalShipHeadUPG."Import Synched";
//                     SalShipHeadL.WebIncrementID := SalShipHeadUPG.WebIncrementID;
//                     SalShipHeadL.WebOrderID := SalShipHeadUPG.WebOrderID;
//                     SalShipHeadL.WebSyncFlag := SalShipHeadUPG.WebSyncFlag;
//                     SalShipHeadL.WebOrderFlag := SalShipHeadUPG.WebOrderFlag;
//                     SalShipHeadL."Web Payment Transaction Id" := SalShipHeadUPG."Web Payment Transaction Id";
//                     SalShipHeadL."Web Shipment Tracing No." := SalShipHeadUPG."Web Shipment Tracing No.";
//                     SalShipHeadL."Web Shipment Carrier" := SalShipHeadUPG."Web Shipment Carrier";
//                     SalShipHeadL."Web Payment Method Code" := SalShipHeadUPG."Web Payment Method Code";
//                     SalShipHeadL."Web Shipment Increment Id" := SalShipHeadUPG."Web Shipment Increment Id";
//                     SalShipHeadL."Web Invoice Increment Id" := SalShipHeadUPG."Web Invoice Increment Id";
//                     SalShipHeadL.Modify();
//                 end;
//             until SalShipHeadUPG.Next() = 0;
//         SalShipHeadUPG.DeleteAll();
//     End;

//     procedure MoveSalesShipLineData()
//     Var
//         SalShipLineL: Record "Sales Shipment Line";
//         SalShipLineUPG: Record "Sales Shipment Line UPG";
//     Begin
//         IF SalShipLineUPG.FindSet() then
//             repeat
//                 IF SalShipLineL.Get(SalShipLineUPG."Document No.", SalShipLineUPG."Line No.") then begin
//                     SalShipLineL."Cut Size" := SalShipLineUPG."Cut Size";
//                     SalShipLineL."Cut Size To-Do" := SalShipLineUPG."Cut Size To-Do";
//                     SalShipLineL.WebOrderItemID := SalShipLineUPG.WebOrderItemID;
//                     SalShipLineL.Modify();
//                 end;
//             until SalShipLineUPG.Next() = 0;
//         SalShipLineUPG.DeleteAll();
//     End;

//     procedure MoveSalesInvHeadData()
//     Var
//         SalInvHeadL: Record "Sales Invoice Header";
//         SalInvHeadUPG: Record "Sales Invoice Header UPG";
//     Begin
//         IF SalInvHeadUPG.FindSet() then
//             repeat
//                 IF SalInvHeadL.Get(SalInvHeadUPG."No.") then begin
//                     SalInvHeadL."Payment Created" := SalInvHeadUPG."Payment Created";
//                     SalInvHeadL."Import Sell-to Cust. Name" := SalInvHeadUPG."Import Sell-to Cust. Name";
//                     SalInvHeadL."Import Sell-to Address" := SalInvHeadUPG."Import Sell-to Address";
//                     SalInvHeadL."Import Sell-to Address 2" := SalInvHeadUPG."Import Sell-to Address 2";
//                     SalInvHeadL."Import Sell-to City" := SalInvHeadUPG."Import Sell-to City";
//                     SalInvHeadL."Import Sell-to County" := SalInvHeadUPG."Import Sell-to County";
//                     SalInvHeadL."Import Sell-to Post Code" := SalInvHeadUPG."Import Sell-to Post Code";
//                     SalInvHeadL."Import Bill-to Name" := SalInvHeadUPG."Import Bill-to Name";
//                     SalInvHeadL."Import Bill-to Address" := SalInvHeadUPG."Import Bill-to Address";
//                     SalInvHeadL."Import Bill-to Address 2" := SalInvHeadUPG."Import Bill-to Address 2";
//                     SalInvHeadL."Import Bill-to City" := SalInvHeadUPG."Import Bill-to City";
//                     SalInvHeadL."Import Bill-to County" := SalInvHeadUPG."Import Bill-to County";
//                     SalInvHeadL."Import Bill-to Post Code" := SalInvHeadUPG."Import Bill-to Post Code";
//                     SalInvHeadL."Import Ship-to Name" := SalInvHeadUPG."Import Ship-to Name";
//                     SalInvHeadL."Import Ship-to Address" := SalInvHeadUPG."Import Ship-to Address";
//                     SalInvHeadL."Import Ship-to Address 2" := SalInvHeadUPG."Import Ship-to Address 2";
//                     SalInvHeadL."Import Ship-to City" := SalInvHeadUPG."Import Ship-to City";
//                     SalInvHeadL."Import Ship-to County" := SalInvHeadUPG."Import Ship-to County";
//                     SalInvHeadL."Import Ship-to Post Code" := SalInvHeadUPG."Import Ship-to Post Code";
//                     SalInvHeadL."Import Synched" := SalInvHeadUPG."Import Synched";
//                     SalInvHeadL.WebIncrementID := SalInvHeadUPG.WebIncrementID;
//                     SalInvHeadL.WebOrderID := SalInvHeadUPG.WebOrderID;
//                     SalInvHeadL.WebSyncFlag := SalInvHeadUPG.WebSyncFlag;
//                     SalInvHeadL.WebOrderFlag := SalInvHeadUPG.WebOrderFlag;
//                     SalInvHeadL."Web Payment Transaction Id" := SalInvHeadUPG."Web Payment Transaction Id";
//                     SalInvHeadL."Web Shipment Tracing No." := SalInvHeadUPG."Web Shipment Tracing No.";
//                     SalInvHeadL."Web Shipment Carrier" := SalInvHeadUPG."Web Shipment Carrier";
//                     SalInvHeadL."Web Payment Method Code" := SalInvHeadUPG."Web Payment Method Code";
//                     SalInvHeadL."Web Shipment Increment Id" := SalInvHeadUPG."Web Shipment Increment Id";
//                     SalInvHeadL."Web Invoice Increment Id" := SalInvHeadUPG."Web Invoice Increment Id";
//                     SalInvHeadL.Modify();
//                 end;
//             until SalInvHeadUPG.Next() = 0;
//         SalInvHeadUPG.DeleteAll();
//     End;

//     procedure MoveSalesInvLineData()
//     Var
//         SalInvLineL: Record "Sales Invoice Line";
//         SalInvLineUPG: Record "Sales Invoice Line UPG";
//     Begin
//         IF SalInvLineUPG.FindSet() then
//             repeat
//                 IF SalInvLineL.Get(SalInvLineUPG."Document No.", SalInvLineUPG."Line No.") then begin
//                     SalInvLineL."Cut Size" := SalInvLineUPG."Cut Size";
//                     SalInvLineL."Cut Size To-Do" := SalInvLineUPG."Cut Size To-Do";
//                     SalInvLineL.WebOrderItemID := SalInvLineUPG.WebOrderItemID;
//                     SalInvLineL.Modify();
//                 end;
//             until SalInvLineUPG.Next() = 0;
//         SalInvLineUPG.DeleteAll();
//     End;

//     procedure MoveSalesCrMemoHeadData()
//     Var
//         SalCrMHeadL: Record "Sales Cr.Memo Header";
//         SalCrMHeadUPG: Record "Sales Cr.Memo Header UPG";
//     Begin
//         IF SalCrMHeadUPG.FindSet() then
//             repeat
//                 IF SalCrMHeadL.Get(SalCrMHeadUPG."No.") then begin
//                     SalCrMHeadL."Payment Created" := SalCrMHeadUPG."Payment Created";
//                     SalCrMHeadL."Import Sell-to Cust. Name" := SalCrMHeadUPG."Import Sell-to Cust. Name";
//                     SalCrMHeadL."Import Sell-to Address" := SalCrMHeadUPG."Import Sell-to Address";
//                     SalCrMHeadL."Import Sell-to Address 2" := SalCrMHeadUPG."Import Sell-to Address 2";
//                     SalCrMHeadL."Import Sell-to City" := SalCrMHeadUPG."Import Sell-to City";
//                     SalCrMHeadL."Import Sell-to County" := SalCrMHeadUPG."Import Sell-to County";
//                     SalCrMHeadL."Import Sell-to Post Code" := SalCrMHeadUPG."Import Sell-to Post Code";
//                     SalCrMHeadL."Import Bill-to Name" := SalCrMHeadUPG."Import Bill-to Name";
//                     SalCrMHeadL."Import Bill-to Address" := SalCrMHeadUPG."Import Bill-to Address";
//                     SalCrMHeadL."Import Bill-to Address 2" := SalCrMHeadUPG."Import Bill-to Address 2";
//                     SalCrMHeadL."Import Bill-to City" := SalCrMHeadUPG."Import Bill-to City";
//                     SalCrMHeadL."Import Bill-to County" := SalCrMHeadUPG."Import Bill-to County";
//                     SalCrMHeadL."Import Bill-to Post Code" := SalCrMHeadUPG."Import Bill-to Post Code";
//                     SalCrMHeadL."Import Ship-to Name" := SalCrMHeadUPG."Import Ship-to Name";
//                     SalCrMHeadL."Import Ship-to Address" := SalCrMHeadUPG."Import Ship-to Address";
//                     SalCrMHeadL."Import Ship-to Address 2" := SalCrMHeadUPG."Import Ship-to Address 2";
//                     SalCrMHeadL."Import Ship-to City" := SalCrMHeadUPG."Import Ship-to City";
//                     SalCrMHeadL."Import Ship-to County" := SalCrMHeadUPG."Import Ship-to County";
//                     SalCrMHeadL."Import Ship-to Post Code" := SalCrMHeadUPG."Import Ship-to Post Code";
//                     SalCrMHeadL."Import Synched" := SalCrMHeadUPG."Import Synched";
//                     SalCrMHeadL.WebIncrementID := SalCrMHeadUPG.WebIncrementID;
//                     SalCrMHeadL.WebCustomerFlag := SalCrMHeadUPG.WebCustomerFlag;
//                     SalCrMHeadL.WebCustomerGender := SalCrMHeadUPG.WebCustomerGender;
//                     SalCrMHeadL.WebCustomerGroup := SalCrMHeadUPG.WebCustomerGroup;
//                     SalCrMHeadL.WebSiteCode := SalCrMHeadUPG.WebSiteCode;
//                     SalCrMHeadL.WebCustomerID := SalCrMHeadUPG.WebCustomerID;
//                     SalCrMHeadL.WebBillToAddressID := SalCrMHeadUPG.WebBillToAddressID;
//                     SalCrMHeadL.WebSyncFlag := SalCrMHeadUPG.WebSyncFlag;
//                     SalCrMHeadL.Modify();
//                 end;
//             until SalCrMHeadUPG.Next() = 0;
//         SalCrMHeadUPG.DeleteAll();
//     end;

//     procedure MoveSalesCrMemoLineData()
//     Var
//         SalCrMLineL: Record "Sales Cr.Memo Line";
//         SalCrMLineUPG: Record "Sales Cr.Memo Line UPG";
//     begin
//         SalCrMLineUPG.SetFilter(SalCrMLineUPG."Cut Size", '<>%1', false);
//         IF SalCrMLineUPG.FindSet() then
//             repeat
//                 IF SalCrMLineL.Get(SalCrMLineUPG."Document No.", SalCrMLineUPG."Line No.") then begin
//                     SalCrMLineL."Cut Size" := SalCrMLineUPG."Cut Size";
//                     SalCrMLineL.Modify();
//                 end;
//             until SalCrMLineUPG.Next() = 0;
//         SalCrMLineUPG.DeleteAll();
//     End;

//     procedure MoveShipToAddData()
//     Var
//         ShipToAddL: Record "Ship-to Address";
//         ShipToAddUPG: Record "Ship-to Address UPG";
//     Begin
//         IF ShipToAddUPG.FindSet() then
//             repeat
//                 IF ShipToAddL.Get(ShipToAddUPG."Customer No.", ShipToAddUPG.Code) then begin
//                     ShipToAddL."Import Name" := ShipToAddUPG."Import Name";
//                     ShipToAddL."Import Address" := ShipToAddUPG."Import Address";
//                     ShipToAddL."Import Address 2" := ShipToAddUPG."Import Address 2";
//                     ShipToAddL."Import City" := ShipToAddUPG."Import City";
//                     ShipToAddL."Import County" := ShipToAddUPG."Import County";
//                     ShipToAddL."Import Post Code" := ShipToAddUPG."Import Post Code";
//                     ShipToAddL."Import Phone No." := ShipToAddUPG."Import Phone No.";
//                     ShipToAddL."Import Email" := ShipToAddUPG."Import Email";
//                     ShipToAddL."Import Synched" := ShipToAddUPG."Import Synched";
//                     ShipToAddL.WebAddressID := ShipToAddUPG.WebAddressID;
//                     ShipToAddL.WebIsDefault := ShipToAddUPG.WebIsDefault;
//                     ShipToAddL.Modify();
//                 end;
//             until ShipToAddUPG.Next() = 0;
//         ShipToAddUPG.DeleteAll();
//     End;

//     procedure MoveReasonCodeData()
//     Var
//         ReasonCodeL: Record "Reason Code";
//         ReasonCodeUPG: Record "Reason Code UPG";
//     Begin
//         ReasonCodeUPG.SetFilter(ReasonCodeUPG."Gen. Bus. Posting Group", '<>%1', '');
//         IF ReasonCodeUPG.FindSet() then
//             repeat
//                 IF ReasonCodeL.Get(ReasonCodeUPG.Code) then begin
//                     ReasonCodeL."Gen. Bus. Posting Group" := ReasonCodeUPG."Gen. Bus. Posting Group";
//                     ReasonCodeL.Modify();
//                 end;
//             until ReasonCodeUPG.Next() = 0;
//         ReasonCodeUPG.DeleteAll();
//     End;

//     //  procedure MoveItemJnlbatchData()
//     // Var
//     //     ItemJnlbatchL: Record "Item Journal Batch";
//     //     ItemJnlbatchUPG: Record "Item Journal Batch UPG";
//     // Begin

//     // End;
//     procedure MoveBankAccLedgerEntryData()
//     Var
//         BankAccLedgerEntryL: Record "Bank Account Ledger Entry";
//         BankAccLedgerEntryUPG: Record "Bank Account Ledger Entry UPG";
//     begin
//         BankAccLedgerEntryUPG.SetFilter(BankAccLedgerEntryUPG.WebIncrementID, '<>%1', '');
//         IF BankAccLedgerEntryUPG.FindSet() then
//             repeat
//                 IF BankAccLedgerEntryL.Get(BankAccLedgerEntryUPG."Entry No.") then begin
//                     BankAccLedgerEntryL.WebIncrementID := BankAccLedgerEntryUPG.WebIncrementID;
//                     BankAccLedgerEntryL.Modify();
//                 end;
//             until BankAccLedgerEntryUPG.Next() = 0;
//         BankAccLedgerEntryUPG.DeleteAll();
//     end;

//     procedure MoveSaleReceSetupData()
//     Var
//         SaleReceSetupL: Record "Sales & Receivables Setup";
//         SaleReceSetupUPG: Record "Sales & Receivables Setup UPG";
//     begin
//         IF SaleReceSetupUPG.FindSet() then
//             repeat
//                 IF SaleReceSetupL.Get(SaleReceSetupUPG."Primary Key") then begin
//                     SaleReceSetupL."Sales Pmt. Jnl Batch Name" := SaleReceSetupUPG."Sales Pmt. Jnl Batch Name";
//                     SaleReceSetupL."Sales Pmt. Jnl Template Name" := SaleReceSetupUPG."Sales Pmt. Jnl Template Name";
//                     SaleReceSetupL."Last Payment Creation" := SaleReceSetupUPG."Last Payment Creation";
//                     SaleReceSetupL."Returns Location" := SaleReceSetupUPG."Returns Location";
//                     SaleReceSetupL."Credit Memo Discount Account" := SaleReceSetupUPG."Credit Memo Discount Account";
//                     SaleReceSetupL."Credit File URL" := SaleReceSetupUPG."Credit File URL";
//                     SaleReceSetupL."Excel Sheet Name" := SaleReceSetupUPG."Excel Sheet Name";
//                     SaleReceSetupL."Skip Header Row" := SaleReceSetupUPG."Skip Header Row";
//                     SaleReceSetupL."Print Mobile Pick Label" := SaleReceSetupUPG."Print Mobile Pick Label";
//                     SaleReceSetupL.Modify();
//                 end;
//             until SaleReceSetupUPG.Next() = 0;
//         SaleReceSetupUPG.DeleteAll();
//     end;

//     procedure MoveInventorySetupData()
//     Var
//         InventorySetupL: Record "Inventory Setup";
//         InventorySetupUPG: Record "Inventory Setup UPG";
//     begin
//         IF InventorySetupUPG.FindSet() then
//             repeat
//                 IF InventorySetupL.Get(InventorySetupUPG."Primary Key") then begin
//                     InventorySetupL."Weight Tolerence Percentage" := InventorySetupUPG."Weight Tolerence Percentage";
//                     InventorySetupL.Modify();
//                 end;
//             until InventorySetupUPG.Next() = 0;
//         InventorySetupUPG.DeleteAll();
//     end;

//     //  procedure MoveReservationEnrtyData()
//     // Var
//     //     ReservationEnrtyL: Record "Reservation Entry";
//     //     ReservationEnrtyUPG: Record "Reservation Entry UPG";
//     // begin

//     // end;
//     procedure MoveJobQEntryData()
//     Var
//         JobQEntryL: Record "Job Queue Entry";
//         JobQEntryUPG: Record "Job Queue Entry UPG";
//     begin
//         JobQEntryUPG.SetFilter(JobQEntryUPG."Duration Process Max", '<>%1', 0);
//         IF JobQEntryUPG.FindSet() then
//             repeat
//                 IF JobQEntryL.Get(JobQEntryUPG.ID) then begin
//                     JobQEntryL."Duration Process Max" := JobQEntryUPG."Duration Process Max";
//                     JobQEntryL.Modify();
//                 end;
//             until JobQEntryUPG.Next() = 0;
//         JobQEntryUPG.DeleteAll();
//     end;

//     procedure MoveWhseActHeadData()
//     Var
//         WhseActHeadL: Record "Warehouse Activity Header";
//         WhseActHeadUPG: Record "Warehouse Activity Header UPG";
//     begin
//         IF WhseActHeadUPG.FindSet() then
//             repeat
//                 IF WhseActHeadL.Get(WhseActHeadUPG.Type, WhseActHeadUPG."No.") then begin
//                     WhseActHeadL."Movement Type" := WhseActHeadUPG."Movement Type";
//                     WhseActHeadL."Latest Dispatch Date" := WhseActHeadUPG."Latest Dispatch Date";
//                     WhseActHeadL.Modify();
//                 end;
//             until WhseActHeadUPG.Next() = 0;
//         WhseActHeadUPG.DeleteAll();
//     end;

//     procedure MoveWhseActLineData()
//     Var
//         WhseActLineL: Record "Warehouse Activity Line";
//         WhseActLineUPG: Record "Warehouse Activity Line UPG";
//     begin
//         IF WhseActLineUPG.FindSet() then
//             repeat
//                 IF WhseActLineL.Get(WhseActLineUPG."Activity Type", WhseActLineUPG."No.", WhseActLineUPG."Line No.") then begin
//                     WhseActLineL."Measured Weight" := WhseActLineUPG."Measured Weight";
//                     WhseActLineL."Weight Difference" := WhseActLineUPG."Weight Difference";
//                     WhseActLineL."Product Type" := WhseActLineUPG."Product Type";
//                     WhseActLineL.Modify();
//                 end;
//             until WhseActLineUPG.Next() = 0;
//         WhseActLineUPG.DeleteAll();
//     end;

//     procedure MoveRegWhseActHeadData()
//     Var
//         RegWhseActHeadL: Record "Registered Whse. Activity Hdr.";
//         RegWhseActHeadUPG: Record "Registered Whse. Act Hdr UPG";
//     begin
//         IF RegWhseActHeadUPG.FindSet() then
//             repeat
//                 IF RegWhseActHeadL.Get(RegWhseActHeadUPG.Type, RegWhseActHeadUPG."No.") then begin
//                     RegWhseActHeadL."Movement Type" := RegWhseActHeadUPG."Movement Type";
//                     RegWhseActHeadL.Modify();
//                 end;
//             until RegWhseActHeadUPG.Next() = 0;
//         RegWhseActHeadUPG.DeleteAll();
//     end;

//     procedure MoveRegWhseActLineData()
//     Var
//         RegWhseActLineL: Record "Registered Whse. Activity Line";
//         RegWhseActLineUPG: Record "Registered Whse. Act Line UPG";
//     begin
//         IF RegWhseActLineUPG.FindSet() then
//             repeat
//                 IF RegWhseActLineL.Get(RegWhseActLineUPG."Activity Type", RegWhseActLineUPG."No.", RegWhseActLineUPG."Line No.") then begin
//                     RegWhseActLineL."Measured Weight" := RegWhseActLineUPG."Measured Weight";
//                     RegWhseActLineL."Weight Difference" := RegWhseActLineUPG."Weight Difference";
//                     RegWhseActLineL.Modify();
//                 end;
//             until RegWhseActLineUPG.Next() = 0;
//         RegWhseActLineUPG.DeleteAll();
//     end;

//     procedure MoveItemChargeData()
//     Var
//         ItemChargeL: Record "Item Charge";
//         ItemChargeUPG: Record "Item Charge UPG";
//     begin
//         IF ItemChargeUPG.FindSet() then
//             repeat
//                 IF ItemChargeL.Get(ItemChargeUPG."No.") then begin
//                     ItemChargeL.Type := ItemChargeUPG.Type;
//                     ItemChargeL.Modify();
//                 end;
//             until ItemChargeUPG.Next() = 0;
//         ItemChargeUPG.DeleteAll();
//     end;

//     procedure MoveItemChargeAssPurchData()
//     Var
//         ItemChargeAssPurchL: Record "Item Charge Assignment (Purch)";
//         ItemChargeAssPurchUPG: Record "Item Charge Assign (Purch) UPG";
//     begin
//         IF ItemChargeAssPurchUPG.FindSet() then
//             repeat
//                 IF ItemChargeAssPurchL.Get(ItemChargeAssPurchUPG."Document Type", ItemChargeAssPurchUPG."Document No.", ItemChargeAssPurchUPG."Document Line No.", ItemChargeAssPurchUPG."Line No.") then begin
//                     ItemChargeAssPurchL."Net Weight" := ItemChargeAssPurchUPG."Net Weight";
//                     ItemChargeAssPurchL."Gross Weight" := ItemChargeAssPurchUPG."Gross Weight";
//                     ItemChargeAssPurchL."Expected Amount" := ItemChargeAssPurchUPG."Expected Amount";
//                     ItemChargeAssPurchL."Expected Gross Weight" := ItemChargeAssPurchUPG."Expected Gross Weight";
//                     ItemChargeAssPurchL."Expected Net Weight" := ItemChargeAssPurchUPG."Expected Net Weight";
//                     ItemChargeAssPurchL."Expected Quantity" := ItemChargeAssPurchUPG."Expected Quantity";
//                     ItemChargeAssPurchL.Modify();
//                 end;
//             until ItemChargeAssPurchUPG.Next() = 0;
//         ItemChargeAssPurchUPG.DeleteAll();
//     end;

//     procedure MoveSalesPriceData()
//     Var
//         SalesPriceL: Record "Sales Price";
//         SalesPriceUPG: Record "Sales Price UPG";
//     begin
//         IF SalesPriceUPG.FindSet() then
//             repeat
//                 IF SalesPriceL.Get(SalesPriceUPG."Item No.", SalesPriceUPG."Sales Code", SalesPriceUPG."Currency Code", SalesPriceUPG."Starting Date", SalesPriceUPG."Sales Type", SalesPriceUPG."Minimum Quantity", SalesPriceUPG."Unit of Measure Code", SalesPriceUPG."Variant Code") then begin
//                     SalesPriceL.WebSyncFlag := SalesPriceUPG.WebSyncFlag;
//                     SalesPriceL.WebSite := SalesPriceUPG.WebSite;
//                     SalesPriceL.WebSiteID := SalesPriceUPG.WebSiteID;
//                     SalesPriceL.Modify();
//                 end;
//             until SalesPriceUPG.Next() = 0;
//         SalesPriceUPG.DeleteAll();
//     end;

//     procedure MoveSaleLineDisData()
//     Var
//         SaleLineDisL: Record "Sales Line Discount";
//         SaleLineDisUPG: Record "Sales Line Discount UPG";
//     begin
//         IF SaleLineDisUPG.FindSet() then
//             repeat
//                 IF SaleLineDisL.Get(SaleLineDisUPG.Code, SaleLineDisUPG."Sales Code", SaleLineDisUPG."Currency Code", SaleLineDisUPG."Starting Date", SaleLineDisUPG."Sales Type",
//                                 SaleLineDisUPG."Minimum Quantity", SaleLineDisUPG.Type, SaleLineDisUPG."Unit of Measure Code", SaleLineDisUPG."Variant Code") then begin
//                     SaleLineDisL.WebSite := SaleLineDisUPG.WebSite;
//                     SaleLineDisL.WebSiteID := SaleLineDisUPG.WebSiteID;
//                     SaleLineDisL.Modify();
//                 end;
//             until SaleLineDisUPG.Next() = 0;
//         SaleLineDisUPG.DeleteAll();
//     end;

//     //  procedure MoveWhseJnlBatchData()
//     // Var
//     //     WhseJnlBatchL: Record "Warehouse Journal Batch";
//     //     WhseJnlBatchUPG: Record "Warehouse Journal Batch UPG";
//     // Begin

//     // End;
//     procedure MoveWhseJnlLineData()
//     Var
//         WhseJnlLineL: Record "Warehouse Journal Line";
//         WhseJnlLineUPG: Record "Warehouse Journal Line UPG";
//     Begin
//         WhseJnlLineUPG.SetFilter(WhseJnlLineUPG."Int. Register No.", '<>%1', 0);
//         IF WhseJnlLineUPG.FindSet() then
//             repeat
//                 IF WhseJnlLineL.Get(WhseJnlLineUPG."Journal Template Name", WhseJnlLineUPG."Journal Batch Name", WhseJnlLineUPG."Line No.", WhseJnlLineUPG."Location Code") then begin
//                     WhseJnlLineL."Int. Register No." := WhseJnlLineUPG."Int. Register No.";
//                     WhseJnlLineL.Modify();
//                 end;
//             until WhseJnlLineUPG.Next() = 0;
//         WhseJnlLineUPG.DeleteAll();
//     End;

//     procedure MoveWhseEntryData()
//     Var
//         WhseEntryL: Record "Warehouse Entry";
//         WhseEntryUPG: Record "Warehouse Entry UPG";
//     Begin
//         WhseEntryUPG.SetFilter(WhseEntryUPG."Int. Register No.", '<>%1', 0);
//         IF WhseEntryUPG.FindSet() then
//             repeat
//                 IF WhseEntryL.Get(WhseEntryUPG."Entry No.") then begin
//                     WhseEntryL."Int. Register No." := WhseEntryUPG."Int. Register No.";
//                     WhseEntryL.Modify();
//                 end;
//             until WhseEntryUPG.Next() = 0;
//         WhseEntryUPG.DeleteAll();
//     End;

//     procedure MoveWhseShipHeadData()
//     Var
//         WhseShipHeadL: Record "Warehouse Shipment Header";
//         WhseShipHeadUPG: Record "Warehouse Shipment Header UPG";
//     Begin
//         WhseShipHeadUPG.SetFilter(WhseShipHeadUPG."Latest Dispatch Date", '<>%1', 0D);
//         IF WhseShipHeadUPG.FindSet() then
//             repeat
//                 IF WhseShipHeadL.Get(WhseShipHeadUPG."No.") then begin
//                     WhseShipHeadL."Latest Dispatch Date" := WhseShipHeadUPG."Latest Dispatch Date";
//                     WhseShipHeadL.Modify();
//                 end;
//             until WhseShipHeadUPG.Next() = 0;
//         WhseShipHeadUPG.DeleteAll();
//     End;

//     procedure MoveWhseShipLineData()
//     Var
//         WhseShipLineL: Record "Warehouse Shipment Line";
//         WhseShipLineUPG: Record "Warehouse Shipment Line UPG";
//     Begin
//         IF WhseShipLineUPG.FindSet() then
//             repeat
//                 IF WhseShipLineL.Get(WhseShipLineUPG."No.", WhseShipLineUPG."Line No.") then begin
//                     WhseShipLineL."Combined Pick" := WhseShipLineUPG."Combined Pick";
//                     WhseShipLineL."Product Type" := WhseShipLineUPG."Product Type";
//                     WhseShipLineL.Modify();
//                 end;
//             until WhseShipLineUPG.Next() = 0;
//         WhseShipLineUPG.DeleteAll();
//     End;

//     procedure MoveWhseWorkLineData()
//     Var
//         WhseWorkLineL: Record "Whse. Worksheet Line";
//         WhseWorkLineUPG: Record "Whse. Worksheet Line UPG";
//     Begin
//         IF WhseWorkLineUPG.FindSet() then
//             repeat
//                 IF WhseWorkLineL.Get(WhseWorkLineUPG."Worksheet Template Name", WhseWorkLineUPG.Name, WhseWorkLineUPG."Line No.", WhseWorkLineUPG."Location Code") then begin
//                     WhseWorkLineL."Movement Type" := WhseWorkLineUPG."Movement Type";
//                     WhseWorkLineL.Modify();
//                 end;
//             until WhseWorkLineUPG.Next() = 0;
//         WhseWorkLineUPG.DeleteAll();
//     End;

//     procedure MoveWhseWorkNameData()
//     Var
//         WhseWorkNameL: Record "Whse. Worksheet Name";
//         WhseWorkNameUPG: Record "Whse. Worksheet Name UPG";
//     Begin
//         WhseWorkNameUPG.SetFilter(WhseWorkNameUPG."Direct Posting", '<>%1', false);
//         IF WhseWorkNameUPG.FindSet() then
//             repeat
//                 IF WhseWorkNameL.Get(WhseWorkNameUPG."Worksheet Template Name", WhseWorkNameUPG.Name, WhseWorkNameUPG."Location Code") then begin
//                     WhseWorkNameL."Direct Posting" := WhseWorkNameUPG."Direct Posting";
//                     WhseWorkNameL.Modify();
//                 end;
//             until WhseWorkNameUPG.Next() = 0;
//         WhseWorkNameUPG.DeleteAll();
//     end;

//     procedure MoveBinContBufferData()
//     Var
//         BinContBufferL: Record "Bin Content Buffer";
//         BinContBufferUPG: Record "Bin Content Buffer UPG";
//     Begin
//         IF BinContBufferUPG.FindSet() then
//             repeat
//                 IF BinContBufferL.Get(BinContBufferUPG."Location Code", BinContBufferUPG."Bin Code", BinContBufferUPG."Item No.", BinContBufferUPG."Variant Code", BinContBufferUPG."Unit of Measure Code",
//                                     BinContBufferUPG."Lot No.", BinContBufferUPG."Serial No.") then begin
//                     BinContBufferL."Reason Code" := BinContBufferUPG."Reason Code";
//                     BinContBufferL."Whse. Template Code" := BinContBufferUPG."Whse. Template Code";
//                     BinContBufferL."Whse. Batch Code" := BinContBufferUPG."Whse. Batch Code";
//                     BinContBufferL.Modify();
//                 end;
//             until BinContBufferUPG.Next() = 0;
//         BinContBufferUPG.DeleteAll();
//     End;

//     procedure MoveSalesOrderProcessingBatchData()
//     Var
//         SalesOrderProcessingBatchL: Record SalesOrderProcessingBatch;
//         SalesOrderProcessingBatchUPG: Record "Sales Order Process BatchUPG";
//     Begin
//         IF SalesOrderProcessingBatchUPG.FindSet() then
//             repeat
//                 SalesOrderProcessingBatchL.TransferFields(SalesOrderProcessingBatchUPG);
//                 SalesOrderProcessingBatchL.Insert();
//             until SalesOrderProcessingBatchUPG.Next() = 0;
//         SalesOrderProcessingBatchUPG.DeleteAll();
//     End;

//     procedure MoveBinDataUpdateData()
//     Var
//         BinDataUpdateL: Record "Bin Data Update";
//         BinDataUpdateUPG: Record "Bin Data Update UPG";
//     Begin
//         IF BinDataUpdateUPG.FindSet() then
//             repeat
//                 BinDataUpdateL.TransferFields(BinDataUpdateUPG);
//                 BinDataUpdateL.Insert();
//             until BinDataUpdateUPG.Next() = 0;
//         BinDataUpdateUPG.DeleteAll();
//     End;

//     procedure MovePayMthTempMapData()
//     Var
//         PayMthTempMapL: Record "Payment Method Template MAP";
//         PayMthTempMapUPG: Record "Payment Method Template MAPUPG";
//     Begin
//         IF PayMthTempMapUPG.FindSet() then
//             repeat
//                 PayMthTempMapL.TransferFields(PayMthTempMapUPG);
//                 PayMthTempMapL.Insert();
//             until PayMthTempMapUPG.Next() = 0;
//         PayMthTempMapUPG.DeleteAll();
//     End;

//     procedure MoveCutSizeAnalyseData()
//     Var
//         CutSizeAnalyseL: Record "Cut Size Analysis";
//         CutSizeAnalyseUPG: Record "Cut Size Analysis UPG";
//     Begin
//         IF CutSizeAnalyseUPG.FindSet() then
//             repeat
//                 CutSizeAnalyseL.TransferFields(CutSizeAnalyseUPG);
//                 CutSizeAnalyseL.Insert();
//             until CutSizeAnalyseUPG.Next() = 0;
//         CutSizeAnalyseUPG.DeleteAll();
//     End;

//     procedure MoveActTrackAuditData()
//     Var
//         ActTrackAuditL: Record "Activity Tracking Audit";
//         ActTrackAuditUPG: Record "Activity Tracking Audit UPG";
//     Begin
//         IF ActTrackAuditUPG.FindSet() then
//             repeat
//                 ActTrackAuditL.TransferFields(ActTrackAuditUPG);
//                 ActTrackAuditL.Insert();
//             until ActTrackAuditUPG.Next() = 0;
//         ActTrackAuditUPG.DeleteAll();
//     End;

//     procedure MoveUnplanCountRegData()
//     Var
//         UnplanCountRegL: Record "Unplanned Counts Registrations";
//         UnplanCountRegUPG: Record "Unplanned Counts Regis UPG";
//     Begin
//         IF UnplanCountRegUPG.FindSet() then
//             repeat
//                 UnplanCountRegL.TransferFields(UnplanCountRegUPG);
//                 UnplanCountRegL.Insert();
//             until UnplanCountRegUPG.Next() = 0;
//         UnplanCountRegUPG.DeleteAll();
//     End;

//     procedure MoveRoxLoggData()
//     Var
//         RoxLoggL: Record "Rox Logging";
//         RoxLoggUPG: Record "Rox Logging UPG";
//     Begin
//         IF RoxLoggUPG.FindSet() then
//             repeat
//                 RoxLoggL.TransferFields(RoxLoggUPG);
//                 RoxLoggL.Insert();
//             until RoxLoggUPG.Next() = 0;
//         RoxLoggUPG.DeleteAll();
//     End;

//     procedure MoveScannerScanData()
//     Var
//         ScannerScanL: Record "Scanner Scans";
//         ScannerScanUPG: Record "Scanner Scans UPG";
//     Begin
//         IF ScannerScanUPG.FindSet() then
//             repeat
//                 ScannerScanL.TransferFields(ScannerScanUPG);
//                 ScannerScanL.Insert();
//             until ScannerScanUPG.Next() = 0;
//         ScannerScanUPG.DeleteAll();
//     End;

//     procedure MoveItemAttributesData()
//     Var
//         ItemAttributesL: Record "Item Attributes";
//         ItemAttributesUPG: Record "Item Attributes UPG";
//     Begin
//         IF ItemAttributesUPG.FindSet() then
//             repeat
//                 ItemAttributesL.TransferFields(ItemAttributesUPG);
//                 ItemAttributesL.Insert();
//             until ItemAttributesUPG.Next() = 0;
//         ItemAttributesUPG.DeleteAll();
//     End;

//     procedure MoveWEBCustData()
//     Var
//         WEBCustL: Record "WEB Customer";
//         WEBCustUPG: Record "WEB Customer UPG";
//     Begin
//         IF WEBCustUPG.FindSet() then
//             repeat
//                 WEBCustL.TransferFields(WEBCustUPG);
//                 WEBCustL.Insert();
//             until WEBCustUPG.Next() = 0;
//         WEBCustUPG.DeleteAll();
//     End;

//     procedure MoveWEBOrdHeadData()
//     Var
//         WEBOrdHeadL: Record "WEB Order Header";
//         WEBOrdHeadUPG: Record "WEB Order Header UPG";
//     Begin
//         IF WEBOrdHeadUPG.FindSet() then
//             repeat
//                 WEBOrdHeadL.TransferFields(WEBOrdHeadUPG);
//                 WEBOrdHeadL.Insert();
//             until WEBOrdHeadUPG.Next() = 0;
//         WEBOrdHeadUPG.DeleteAll();
//     End;

//     procedure MoveWEBOrdLineData()
//     Var
//         WEBOrdLineL: Record "WEB Order Lines";
//         WEBOrdLineUPG: Record "WEB Order Lines UPG";
//     Begin
//         IF WEBOrdLineUPG.FindSet() then
//             repeat
//                 WEBOrdLineL.TransferFields(WEBOrdLineUPG);
//                 WEBOrdLineL.Insert();
//             until WEBOrdLineUPG.Next() = 0;
//         WEBOrdLineUPG.DeleteAll();
//     End;

//     procedure MovePostPickAuditData()
//     Var
//         PostPickAuditL: Record "Posted Pick Audit";
//         PostPickAuditUPG: Record "Posted Pick Audit UPG";
//     Begin
//         IF PostPickAuditUPG.FindSet() then
//             repeat
//                 PostPickAuditL.TransferFields(PostPickAuditUPG);
//                 PostPickAuditL.Insert();
//             until PostPickAuditUPG.Next() = 0;
//         PostPickAuditUPG.DeleteAll();
//     End;

//     procedure MoveWEBCustShipToData()
//     Var
//         WEBCustShipToL: Record "WEB Customer Ship-To";
//         WEBCustShipToUPG: Record "WEB Customer Ship-To UPG";
//     Begin
//         IF WEBCustShipToUPG.FindSet() then
//             repeat
//                 WEBCustShipToL.TransferFields(WEBCustShipToUPG);
//                 WEBCustShipToL.Insert();
//             until WEBCustShipToUPG.Next() = 0;
//         WEBCustShipToUPG.DeleteAll();
//     End;

//     procedure MoveWEBShipHeadData()
//     Var
//         WEBShipHeadL: Record "WEB Shipment Header";
//         WEBShipHeadUPG: Record "WEB Shipment Header UPG";
//     Begin
//         IF WEBShipHeadUPG.FindSet() then
//             repeat
//                 WEBShipHeadL.TransferFields(WEBShipHeadUPG);
//                 WEBShipHeadL.Insert();
//             until WEBShipHeadUPG.Next() = 0;
//         WEBShipHeadUPG.DeleteAll();
//     End;

//     procedure MoveWEBShipLineData()
//     Var
//         WEBShipLineL: Record "WEB Shipment Lines";
//         WEBShipLineUPG: Record "WEB Shipment Lines UPG";
//     Begin
//         IF WEBShipLineUPG.FindSet() then
//             repeat
//                 WEBShipLineL.TransferFields(WEBShipLineUPG);
//                 WEBShipLineL.Insert();
//             until WEBShipLineUPG.Next() = 0;
//         WEBShipLineUPG.DeleteAll();
//     End;

//     procedure MoveWEBItemData()
//     Var
//         WEBItemL: Record "WEB Item";
//         WEBItemUPG: Record "WEB Item UPG";
//     Begin
//         IF WEBItemUPG.FindSet() then
//             repeat
//                 WEBItemL.TransferFields(WEBItemUPG);
//                 WEBItemL.Insert();
//             until WEBItemUPG.Next() = 0;
//         WEBItemUPG.DeleteAll();
//     End;

//     procedure MoveWEBItemAttributeData()
//     Var
//         WEBItemAttributeL: Record "WEB Item Attribute";
//         WEBItemAttributeUPG: Record "WEB Item Attribute UPG";
//     Begin
//         IF WEBItemAttributeUPG.FindSet() then
//             repeat
//                 WEBItemAttributeL.TransferFields(WEBItemAttributeUPG);
//                 WEBItemAttributeL.Insert();
//             until WEBItemAttributeUPG.Next() = 0;
//         WEBItemAttributeUPG.DeleteAll();
//     End;

//     procedure MoveWEBCrditHeadData()
//     Var
//         WEBCrditHeadL: Record "WEB Credit Header";
//         WEBCrditHeadUPG: Record "WEB Credit Header UPG";
//     Begin
//         IF WEBCrditHeadUPG.FindSet() then
//             repeat
//                 WEBCrditHeadL.TransferFields(WEBCrditHeadUPG);
//                 WEBCrditHeadL.Insert();
//             until WEBCrditHeadUPG.Next() = 0;
//         WEBCrditHeadUPG.DeleteAll();
//     End;

//     procedure MoveWEBCrditLineData()
//     Var
//         WEBCrditLineL: Record "WEB Credit Lines";
//         WEBCrditLineUPG: Record "WEB Credit Lines UPG";
//     Begin
//         IF WEBCrditLineUPG.FindSet() then
//             repeat
//                 WEBCrditLineL.TransferFields(WEBCrditLineUPG);
//                 WEBCrditLineL.Insert();
//             until WEBCrditLineUPG.Next() = 0;
//         WEBCrditLineUPG.DeleteAll();
//     End;

//     procedure MoveWEBIndexData()
//     Var
//         WEBIndexL: Record "WEB Index";
//         WEBIndexUPG: Record "WEB Index UPG";
//     Begin
//         IF WEBIndexUPG.FindSet() then
//             repeat
//                 WEBIndexL.TransferFields(WEBIndexUPG);
//                 WEBIndexL.Insert();
//             until WEBIndexUPG.Next() = 0;
//         WEBIndexUPG.DeleteAll();
//     End;

//     procedure MoveWEBMappData()
//     Var
//         WEBMappL: Record "WEB Mapping";
//         WEBMappUPG: Record "WEB Mapping UPG";
//     Begin
//         IF WEBMappUPG.FindSet() then
//             repeat
//                 WEBMappL.TransferFields(WEBMappUPG);
//                 WEBMappL.Insert();
//             until WEBMappUPG.Next() = 0;
//         WEBMappUPG.DeleteAll();
//     End;

//     procedure MoveWEBSetupData()
//     Var
//         WEBSetupL: Record "WEB Setup";
//         WEBSetupUPG: Record "WEB Setup UPG";
//     Begin
//         IF WEBSetupUPG.FindSet() then
//             repeat
//                 WEBSetupL.TransferFields(WEBSetupUPG);
//                 WEBSetupL.Insert();
//             until WEBSetupUPG.Next() = 0;
//         WEBSetupUPG.DeleteAll();
//     End;

//     procedure MoveWEBReqData()
//     Var
//         WEBReqL: Record "WEB Requests";
//         WEBReqUPG: Record "WEB Requests UPG";
//     Begin
//         IF WEBReqUPG.FindSet() then
//             repeat
//                 WEBReqL.TransferFields(WEBReqUPG);
//                 WEBReqL.Insert();
//             until WEBReqUPG.Next() = 0;
//         WEBReqUPG.DeleteAll();
//     End;

//     procedure MoveWEBCueData()
//     Var
//         WEBCueL: Record "WEB Cue";
//         WEBCueUPG: Record "WEB Cue UPG";
//     Begin
//         IF WEBCueUPG.FindSet() then
//             repeat
//                 WEBCueL.TransferFields(WEBCueUPG);
//                 WEBCueL.Insert();
//             until WEBCueUPG.Next() = 0;
//         WEBCueUPG.DeleteAll();
//     End;

//     procedure MoveWEBLogData()
//     Var
//         WEBLogL: Record "WEB Log";
//         WEBLogUPG: Record "WEB Log UPG";
//     Begin
//         IF WEBLogUPG.FindSet() then
//             repeat
//                 WEBLogL.TransferFields(WEBLogUPG);
//                 WEBLogL.Insert();
//             until WEBLogUPG.Next() = 0;
//         WEBLogUPG.DeleteAll();
//     End;

//     procedure MoveWEBAvailStkData()
//     Var
//         WEBAvailStkL: Record "WEB Available Stock";
//         WEBAvailStkUPG: Record "WEB Available Stock UPG";
//     Begin
//         IF WEBAvailStkUPG.FindSet() then
//             repeat
//                 WEBAvailStkL.TransferFields(WEBAvailStkUPG);
//                 WEBAvailStkL.Insert();
//             until WEBAvailStkUPG.Next() = 0;
//         WEBAvailStkUPG.DeleteAll();
//     End;

//     procedure MoveWEBCustBillToData()
//     Var
//         WEBCustBillToL: Record "WEB Customer Bill-To";
//         WEBCustBillToG: Record "WEB Customer Bill-To UPG";
//     Begin
//         IF WEBCustBillToG.FindSet() then
//             repeat
//                 WEBCustBillToL.TransferFields(WEBCustBillToG);
//                 WEBCustBillToL.Insert();
//             until WEBCustBillToG.Next() = 0;
//         WEBCustBillToG.DeleteAll();
//     End;

//     procedure MoveWEBReconData()
//     Var
//         WEBReconL: Record "WEB Reconciliation";
//         WEBReconUPG: Record "WEB Reconciliation UPG";
//     Begin
//         IF WEBReconUPG.FindSet() then
//             repeat
//                 WEBReconL.TransferFields(WEBReconUPG);
//                 WEBReconL.Insert();
//             until WEBReconUPG.Next() = 0;
//         WEBReconUPG.DeleteAll();
//     End;

//     procedure MoveWEBOrdStatusData()
//     Var
//         WEBOrdStatusL: Record "WEB Order Status";
//         WEBOrdStatusUPG: Record "WEB Order Status UPG";
//     Begin
//         IF WEBOrdStatusUPG.FindSet() then
//             repeat
//                 WEBOrdStatusL.TransferFields(WEBOrdStatusUPG);
//                 WEBOrdStatusL.Insert();
//             until WEBOrdStatusUPG.Next() = 0;
//         WEBOrdStatusUPG.DeleteAll();
//     End;

//     procedure MoveWEBDailyReconData()
//     Var
//         WEBDailyReconL: Record "WEB Daily Reconciliation";
//         WEBDailyReconUPG: Record "WEB Daily Reconciliation UPG";
//     Begin
//         IF WEBDailyReconUPG.FindSet() then
//             repeat
//                 WEBDailyReconL.TransferFields(WEBDailyReconUPG);
//                 WEBDailyReconL.Insert();
//             until WEBDailyReconUPG.Next() = 0;
//         WEBDailyReconUPG.DeleteAll();
//     End;

//     procedure MoveWEBComPickData()
//     Var
//         WEBComPickL: Record "WEB Combined Picks";
//         WEBComPickUPG: Record "WEB Combined Picks UPG";
//     Begin
//         IF WEBComPickUPG.FindSet() then
//             repeat
//                 WEBComPickL.TransferFields(WEBComPickUPG);
//                 WEBComPickL.Insert();
//             until WEBComPickUPG.Next() = 0;
//         WEBComPickUPG.DeleteAll();
//     End;

//     procedure MoveWEBWriteOffData()
//     Var
//         WEBWriteOffL: Record "Web Write Offs";
//         WEBWriteOffUPG: Record "Web Write Offs UPG";
//     Begin
//         IF WEBWriteOffUPG.FindSet() then
//             repeat
//                 WEBWriteOffL.TransferFields(WEBWriteOffUPG);
//                 WEBWriteOffL.Insert();
//             until WEBWriteOffUPG.Next() = 0;
//         WEBWriteOffUPG.DeleteAll();
//     End;

//     procedure MoveWEBUserScanData()
//     Var
//         WEBUserScanL: Record "WEB User Scan";
//         WEBUserScanUPG: Record "WEB User Scan UPG";
//     Begin
//         IF WEBUserScanUPG.FindSet() then
//             repeat
//                 WEBUserScanL.TransferFields(WEBUserScanUPG);
//                 WEBUserScanL.Insert();
//             until WEBUserScanUPG.Next() = 0;
//         WEBUserScanUPG.DeleteAll();
//     End;

//     procedure MoveWEBItemUpdateData()
//     Var
//         WEBItemUpdateL: Record "WEB Item Updates";
//         WEBItemUpdateUPG: Record "WEB Item Updates UPG";
//     Begin
//         IF WEBItemUpdateUPG.FindSet() then
//             repeat
//                 WEBItemUpdateL.TransferFields(WEBItemUpdateUPG);
//                 WEBItemUpdateL.Insert();
//             until WEBItemUpdateUPG.Next() = 0;
//         WEBItemUpdateUPG.DeleteAll();
//     End;

//     procedure MovePickCrtWhseShipLineData()
//     Var
//         PickCrtWhseShipLineL: Record "Pick Crt_Whse Shp Lines";
//         PickCrtWhseShipLineUPG: Record "Pick Crt_Whse Shp Lines UPG";
//     Begin
//         IF PickCrtWhseShipLineUPG.FindSet() then
//             repeat
//                 PickCrtWhseShipLineL.TransferFields(PickCrtWhseShipLineUPG);
//                 PickCrtWhseShipLineL.Insert();
//             until PickCrtWhseShipLineUPG.Next() = 0;
//         PickCrtWhseShipLineUPG.DeleteAll();
//     End;

//     procedure MovePickCrtBuff1Data()
//     Var
//         PickCrtBuff1L: Record "Pick Crt_Buffer1";
//         PickCrtBuff1UPG: Record "Pick Crt_Buffer1 UPG";
//     Begin
//         IF PickCrtBuff1UPG.FindSet() then
//             repeat
//                 PickCrtBuff1L.TransferFields(PickCrtBuff1UPG);
//                 PickCrtBuff1L.Insert();
//             until PickCrtBuff1UPG.Next() = 0;
//         PickCrtBuff1UPG.DeleteAll();
//     End;

//     procedure MovePickCrtBuff2Data()
//     Var
//         PickCrtBuff2L: Record "Pick Crt_Buffer2";
//         PickCrtBuff2UPG: Record "Pick Crt_Buffer2 UPG";
//     Begin
//         IF PickCrtBuff2UPG.FindSet() then
//             repeat
//                 PickCrtBuff2L.TransferFields(PickCrtBuff2UPG);
//                 PickCrtBuff2L.Insert();
//             until PickCrtBuff2UPG.Next() = 0;
//         PickCrtBuff2UPG.DeleteAll();
//     End;

//     procedure MovePickCreationStatusData()
//     Var
//         PickCreationStatusL: Record "Pick Creation Status";
//         PickCreationStatusUPG: Record "Pick Creation Status UPG";
//     Begin
//         IF PickCreationStatusUPG.FindSet() then
//             repeat
//                 PickCreationStatusL.TransferFields(PickCreationStatusUPG);
//                 PickCreationStatusL.Insert();
//             until PickCreationStatusUPG.Next() = 0;
//         PickCreationStatusUPG.DeleteAll();
//     End;

//     procedure MoveActivityMasterData()
//     Var
//         ActivityMasterL: Record "Activity Master";
//         ActivityMasterUPG: Record "Activity Master UPG";
//     Begin
//         IF ActivityMasterUPG.FindSet() then
//             repeat
//                 ActivityMasterL.TransferFields(ActivityMasterUPG);
//                 ActivityMasterL.Insert();
//             until ActivityMasterUPG.Next() = 0;
//         ActivityMasterUPG.DeleteAll();
//     End;

//     procedure MoveActivityStatusData()
//     Var
//         ActivityStatusL: Record "Activity Status";
//         ActivityStatusUPG: Record "Activity Status UPG";
//     Begin
//         IF ActivityStatusUPG.FindSet() then
//             repeat
//                 ActivityStatusL.TransferFields(ActivityStatusUPG);
//                 ActivityStatusL.Insert();
//             until ActivityStatusUPG.Next() = 0;
//         ActivityStatusUPG.DeleteAll();
//     End;

//     procedure MoveScaleWeightData()
//     Var
//         ScaleWeightL: Record "Scale Weight Capture";
//         ScaleWeightUPG: Record "Scale Weight Capture UPG";
//     Begin
//         IF ScaleWeightUPG.FindSet() then
//             repeat
//                 ScaleWeightL.TransferFields(ScaleWeightUPG);
//                 ScaleWeightL.Insert();
//             until ScaleWeightUPG.Next() = 0;
//         ScaleWeightUPG.DeleteAll();
//     End;

//     procedure MoveItemChgCalData()
//     Var
//         ItemChgCalL: Record ItemChgCalculation;
//         ItemChgCalUPG: Record "Item Chg Calculation UPG";
//     begin
//         IF ItemChgCalUPG.FindSet() then
//             repeat
//                 ItemChgCalL.TransferFields(ItemChgCalUPG);
//                 ItemChgCalL.Insert();
//             until ItemChgCalUPG.Next() = 0;
//         ItemChgCalUPG.DeleteAll();
//     End;

// }