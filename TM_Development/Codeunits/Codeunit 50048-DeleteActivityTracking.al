codeunit 50048 "Delete Act. Track. Lines"
{
    trigger OnRun()
    begin
        TillTime := DT2Time(CurrentDateTime) - 7200000;
        ActiTrackLines_g.Reset();
        ActiTrackLines_g.SetRange("Start Time", 0DT, CreateDateTime(Today, TillTime));
        if ActiTrackLines_g.FindSet() then
            ActiTrackLines_g.DeleteAll();
    end;

    var
        ActiTrackLines_g: Record "Activity Tracking Lines";
        TillTime: Time;
}