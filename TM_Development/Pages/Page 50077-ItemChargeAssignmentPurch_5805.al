pageextension 50077 ItemChargeAssignmentPurch extends "Item Charge Assignment (Purch)"
{
    //MITL2147 - Added a new Action "Calculate Expected Charges" as per the specification and the corresponding function.
    layout
    {
        // Add changes to page layout here
        addafter(QtyToShipBase)
        {
            field("Net Weight"; "Net Weight")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Gross Weight"; "Gross Weight")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field("Expected Amount"; "Expected Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
            }
            field(AmountDifference; AmountDifference)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';

            }

        }
    }

    actions
    {
        // Add changes to page actions here
        //MITL2147 ++
        addafter(SuggestItemChargeAssignment)
        {
            action("Expected Item Charge Calculation")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                CaptionML = ENU = 'Expected Item Charge Calculation', ENG = 'Expected Item Charge Calculation';
                Image = ItemCosts;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ConfirmMessage: TextConst ENU = 'Do you want to calculate expected charges?';
                begin
                    //# 14134-->
                    IF CONFIRM(ConfirmMessage, FALSE) THEN BEGIN
                        SETRANGE("Document Line No.");
                        SETRANGE("Line No.");
                        REPEAT
                            CalculateExpectedCharges(Rec); //14134
                        UNTIL NEXT = 0;
                    END;
                    //#14134<--
                end;
            }
        }
        //MITL2147 **
    }
    //MITL2147 ++
    trigger OnAfterGetRecord()
    var
    begin
        UpdateDifferences();
    end;
    //MITL2147 **
    var
        QtyReceivedBase: Decimal;
        AmountDifference: Decimal; //MITL2147

    //MITL2147 ++
    local procedure CalculateExpectedCharges(VAR pItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)")
    var
        lItemChargeCalculationL: Record ItemChgCalculation;
        ItemL: Record Item;
        PurchRcptLineL: Record "Purch. Rcpt. Line";
        CurrFactorL: Decimal;
    begin
        WITH pItemChargeAssignmentPurch DO BEGIN
            PurchRcptLineL.SETRANGE("Document No.", pItemChargeAssignmentPurch."Applies-to Doc. No.");
            PurchRcptLineL.SETRANGE("Line No.", pItemChargeAssignmentPurch."Applies-to Doc. Line No.");
            PurchRcptLineL.SETRANGE("No.", pItemChargeAssignmentPurch."Item No.");
            IF PurchRcptLineL.FINDFIRST THEN;
            CurrFactorL := GetCurrFactor(PurchRcptLineL."Document No.");
            lItemChargeCalculationL.SETRANGE("Item No.", pItemChargeAssignmentPurch."Item No.");
            lItemChargeCalculationL.SETRANGE("Item Charge", pItemChargeAssignmentPurch."Item Charge No.");
            IF lItemChargeCalculationL.FINDFIRST THEN BEGIN
                IF lItemChargeCalculationL."Calculation Method" = lItemChargeCalculationL."Calculation Method"::Percentage THEN BEGIN
                    pItemChargeAssignmentPurch."Expected Amount" := (((PurchRcptLineL."Direct Unit Cost" / CurrFactorL) * PurchRcptLineL."Quantity (Base)") * lItemChargeCalculationL."Calculation Value") / 100; // Added
                    pItemChargeAssignmentPurch.MODIFY;
                END ELSE
                    IF lItemChargeCalculationL."Calculation Method" = lItemChargeCalculationL."Calculation Method"::"Gross Weight" THEN BEGIN
                        pItemChargeAssignmentPurch."Expected Amount" := (pItemChargeAssignmentPurch."Gross Weight" * lItemChargeCalculationL."Calculation Value") * QtyReceivedBase;
                        pItemChargeAssignmentPurch.MODIFY;
                    END ELSE
                        IF lItemChargeCalculationL."Calculation Method" = lItemChargeCalculationL."Calculation Method"::"Net Weight" THEN BEGIN
                            pItemChargeAssignmentPurch."Expected Amount" := (pItemChargeAssignmentPurch."Net Weight" * lItemChargeCalculationL."Calculation Value") * QtyReceivedBase;
                            pItemChargeAssignmentPurch.MODIFY;
                        END ELSE
                            IF lItemChargeCalculationL."Calculation Method" = lItemChargeCalculationL."Calculation Method"::"Per Quantity" THEN BEGIN
                                pItemChargeAssignmentPurch."Expected Amount" := QtyReceivedBase * lItemChargeCalculationL."Calculation Value";
                                pItemChargeAssignmentPurch.MODIFY;
                            END;
            END;
        END;
    end;

    local procedure UpdateDifferences()
    var
        PurchRectHeaderL: Record "Purch. Rcpt. Header";
    begin
        InitVariables;
        IF "Expected Amount" > 0 THEN
            AmountDifference := "Amount to Assign" - "Expected Amount";
    end;

    local procedure InitVariables()
    var
    begin
        AmountDifference := 0;
    end;

    local procedure GetCurrFactor(DocNoP: Code[20]): Decimal
    var
        PurchRectHeaderL: Record "Purch. Rcpt. Header";
    begin
        PurchRectHeaderL.RESET;
        PurchRectHeaderL.SETRANGE("No.", DocNoP);
        IF PurchRectHeaderL.FINDFIRST THEN
            IF PurchRectHeaderL."Currency Factor" <> 0 THEN
                EXIT(PurchRectHeaderL."Currency Factor")
            ELSE
                EXIT(1);
    end;
    //MITL2147 **
}