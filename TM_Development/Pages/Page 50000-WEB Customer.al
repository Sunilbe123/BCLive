page 50000 "WEB Customer"
{
    SourceTable = "WEB Customer";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(Email; Email)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Customer ID"; Rec."Customer ID")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Customer Group"; Rec."Customer Group")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("IP address"; Rec."IP address")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Type"; Rec."LineType")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("DateTime"; Rec."Date Time")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Dimension Code"; Rec."Dimension Code")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Visible = false;
            }
            //MITL_MF_5480++
            field("Wholesale Customer"; Rec."Wholesale Customer")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';

            }

            //MITL_MF_5480--
        }
    }

    actions
    {
        area(processing)
        {
            // action("Custom Tables Data Movement")
            // {
            //     Image = Task;
            //     Promoted = true;
            //     PromotedCategory = Category4;
            //     PromotedIsBig = true;

            //     trigger OnAction()
            //     var
            //         CUTransferDataL: Codeunit TransferDataToExtenson;
            //     begin
            //         CUTransferDataL.MoveSalesOrderProcessingBatchData();
            //         CUTransferDataL.MoveBinDataUpdateData();
            //         CUTransferDataL.MovePayMthTempMapData();
            //         CUTransferDataL.MoveCutSizeAnalyseData();
            //         CUTransferDataL.MoveActTrackAuditData();
            //         CUTransferDataL.MoveUnplanCountRegData();
            //         CUTransferDataL.MoveRoxLoggData();
            //         CUTransferDataL.MoveScannerScanData();
            //         CUTransferDataL.MoveItemAttributesData();
            //         CUTransferDataL.MoveWEBCustData();
            //         CUTransferDataL.MoveWEBOrdHeadData();
            //         CUTransferDataL.MoveWEBOrdLineData();
            //         CUTransferDataL.MovePostPickAuditData();
            //         CUTransferDataL.MoveWEBCustShipToData();
            //         CUTransferDataL.MoveWEBShipHeadData();
            //         CUTransferDataL.MoveWEBShipLineData();
            //         CUTransferDataL.MoveWEBItemData();
            //         CUTransferDataL.MoveWEBItemAttributeData();
            //         CUTransferDataL.MoveWEBCrditHeadData();
            //         CUTransferDataL.MoveWEBCrditLineData();
            //         CUTransferDataL.MoveWEBIndexData();
            //         CUTransferDataL.MoveWEBMappData();
            //         CUTransferDataL.MoveWEBSetupData();
            //         CUTransferDataL.MoveWEBReqData();
            //         CUTransferDataL.MoveWEBCueData();
            //         CUTransferDataL.MoveWEBLogData();
            //         CUTransferDataL.MoveWEBAvailStkData();
            //         CUTransferDataL.MoveWEBCustBillToData();
            //         CUTransferDataL.MoveWEBReconData();
            //         CUTransferDataL.MoveWEBOrdStatusData();
            //         CUTransferDataL.MoveWEBDailyReconData();
            //         CUTransferDataL.MoveWEBComPickData();
            //         CUTransferDataL.MoveWEBWriteOffData();
            //         CUTransferDataL.MoveWEBUserScanData();
            //         CUTransferDataL.MoveWEBItemUpdateData();
            //         CUTransferDataL.MovePickCrtWhseShipLineData();
            //         CUTransferDataL.MovePickCrtBuff1Data();
            //         CUTransferDataL.MovePickCrtBuff2Data();
            //         CUTransferDataL.MovePickCreationStatusData();
            //         CUTransferDataL.MoveActivityMasterData();
            //         CUTransferDataL.MoveActivityStatusData();
            //         CUTransferDataL.MoveScaleWeightData();
            //         CUTransferDataL.MoveItemChgCalData();
            //         Message('Done');
            //     end;
            // }
            // action("Standard Tables Quick update")
            // {
            //     Image = Task;
            //     Promoted = true;
            //     PromotedCategory = Category4;
            //     PromotedIsBig = true;

            //     trigger OnAction()
            //     var
            //         CUTransferDataL: Codeunit TransferDataToExtenson;
            //     begin
            //         CUTransferDataL.MoveLocationData();
            //         CUTransferDataL.MoveInventorySetupData();
            //         CUTransferDataL.MoveSaleReceSetupData();
            //         CUTransferDataL.MoveSalesPriceData();
            //         CUTransferDataL.MoveSaleLineDisData();
            //         CUTransferDataL.MoveBankAccLedgerEntryData();
            //         CUTransferDataL.MoveReasonCodeData();
            //         CUTransferDataL.MoveShipToAddData();
            //         CUTransferDataL.MoveUserSetupData();
            //         CUTransferDataL.MoveGenJnlLineData();
            //         CUTransferDataL.MovePurchaseHaederData();
            //         CUTransferDataL.MoveItemData();
            //         CUTransferDataL.MoveWhseActHeadData();
            //         CUTransferDataL.MoveWhseActLineData();
            //         CUTransferDataL.MoveRegWhseActHeadData();
            //         CUTransferDataL.MoveRegWhseActLineData();
            //         CUTransferDataL.MoveItemChargeData();
            //         CUTransferDataL.MoveItemChargeAssPurchData();
            //         CUTransferDataL.MoveWhseJnlLineData();
            //         CUTransferDataL.MoveWhseShipHeadData();
            //         CUTransferDataL.MoveWhseShipLineData();
            //         CUTransferDataL.MoveWhseWorkNameData();
            //         CUTransferDataL.MoveBinContBufferData();
            //         Message('Done');
            //     end;
            // }
            // action("Sales Data update")
            // {
            //     Image = Task;
            //     Promoted = true;
            //     PromotedCategory = Category4;
            //     PromotedIsBig = true;

            //     trigger OnAction()
            //     var
            //         CUTransferDataL: Codeunit TransferDataToExtenson;
            //     begin
            //         // CUTransferDataL.MoveSalesHeaderData();
            //         // CUTransferDataL.MoveSalesLineData();
            //         // CUTransferDataL.MoveSalesShipHeadData();
            //         // CUTransferDataL.MoveSalesShipLineData();
            //         // CUTransferDataL.MoveSalesInvHeadData();
            //         // CUTransferDataL.MoveSalesInvLineData();
            //         CUTransferDataL.MoveSalesCrMemoHeadData();
            //         // CUTransferDataL.MoveSalesCrMemoLineData();
            //         Message('Done');
            //     end;
            // }

            // action("WhseworksheetLine update")
            // {
            //     Image = Task;
            //     Promoted = true;
            //     PromotedCategory = Category4;
            //     PromotedIsBig = true;

            //     trigger OnAction()
            //     var
            //         CUTransferDataL: Codeunit TransferDataToExtenson;
            //     begin
            //         CUTransferDataL.MoveWhseWorkLineData();
            //         Message('Done');
            //     end;
            // }
            // action("WhseEntry update")
            // {
            //     Image = Task;
            //     Promoted = true;
            //     PromotedCategory = Category4;
            //     PromotedIsBig = true;

            //     trigger OnAction()
            //     var
            //         CUTransferDataL: Codeunit TransferDataToExtenson;
            //     begin
            //         CUTransferDataL.MoveWhseEntryData();
            //         Message('Done');
            //     end;
            // }
            // action("Customer update")
            // {
            //     Image = Task;
            //     Promoted = true;
            //     PromotedCategory = Category4;
            //     PromotedIsBig = true;

            //     trigger OnAction()
            //     var
            //         CUTransferDataL: Codeunit TransferDataToExtenson;
            //     begin
            //         CUTransferDataL.MoveCustomerData();
            //         Message('Done');
            //     end;
            // }
            // action("CustLedgerEntry update")
            // {
            //     Image = Task;
            //     Promoted = true;
            //     PromotedCategory = Category4;
            //     PromotedIsBig = true;

            //     trigger OnAction()
            //     var
            //         CUTransferDataL: Codeunit TransferDataToExtenson;
            //     begin
            //         CUTransferDataL.MoveCustLedgerEntryData();
            //         Message('Done');
            //     end;
            // }
            // action("GLEntry update")
            // {
            //     Image = Task;
            //     Promoted = true;
            //     PromotedCategory = Category4;
            //     PromotedIsBig = true;

            //     trigger OnAction()
            //     var
            //         CUTransferDataL: Codeunit TransferDataToExtenson;
            //     begin
            //         CUTransferDataL.MoveGLEntryData();
            //         Message('Done');
            //     end;
            // }

        }

    }
}

