// MITL.SM.5767
codeunit 50035 "Item Jnl Posting Job"
{
    trigger OnRun()
    begin
        ItemJnlLine.SETRANGE("Journal Template Name", 'ITEM');
        ItemJnlLine.SETRANGE("Journal Batch Name", 'WHSEJNLB');
        IF ItemJnlLine.FINDSET THEN
            ItemJnlLine.DELETEALL(TRUE);
        COMMIT;
        DocNo := 'Whse. Adj ' + format(Date2DMY(Today(), 1))
                + format(Date2DMY(Today(), 2)) + format(Date2DMY(Today(), 3));
        ItemJnlLine."Journal Template Name" := 'ITEM';
        ItemJnlLine."Journal Batch Name" := 'WHSEJNLB';
        Clear(CalcWhseAdj);
        CalcWhseAdj.SetItemJnlLine(ItemJnlLine);
        CalcWhseAdj.InitializeRequest(Today(), DocNo);
        CalcWhseAdj.SetReasonCodeFilter('', true, DMY2Date(01, 05, 2020));// MITL.5767.SM.04052020
        CalcWhseAdj.USEREQUESTPAGE := FALSE;
        CalcWhseAdj.SetHideValidationDialog(TRUE);
        CalcWhseAdj.RUNMODAL;
        COMMIT;
        ResonCode.Reset();
        ResonCode.FindSet();
        repeat
            Clear(CalcWhseAdj);
            CalcWhseAdj.SetItemJnlLine(ItemJnlLine);
            CalcWhseAdj.InitializeRequest(Today(), DocNo);
            CalcWhseAdj.SetReasonCodeFilter(ResonCode.Code, true, DMY2Date(01, 05, 2020));// MITL.5767.SM.04052020
            CalcWhseAdj.USEREQUESTPAGE := FALSE;
            CalcWhseAdj.SetHideValidationDialog(TRUE);
            CalcWhseAdj.RUNMODAL;
            COMMIT;
        until ResonCode.Next = 0;
        // ItemJnlPost.RUN(ItemJnlLine);

    end;

    var
        ItemJnlLine: Record "Item Journal Line";
        ResonCode: Record "Reason Code";
        ItemJnlPost: Codeunit "Item Jnl.-Post Batch";
        CalcWhseAdj: Report "Calc Whse. Adj. with Reason";
        DocNo: Code[20];
}