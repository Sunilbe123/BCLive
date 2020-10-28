codeunit 50005 "WEB Toolbox"
{
    // version R4501

    // R4501 - RM - 31/01/2016
    // commented out OnRun code, just in case!


    trigger OnRun()
    begin
        WEBlog.SETRANGE(WEBlog.Status, WEBlog.Status::Error);
        WEBlog.MODIFYALL(WEBlog.Status, WEBlog.Status::" ");
        WEBlog.MODIFYALL(WEBlog.Error, '');
    end;

    var
        WEBlog: Record "WEB Index";

    procedure UpdateIndex(var WebIndex: Record "WEB Index"; OptionStatus: Option " ",Complete,Error,Ignored,"Awaiting Information Request"; ErrorText: Text)
    Var
        WebIndexL: Record "WEB Index";
    begin
        //MITL4523 ++ //MITL.AJ.19Dec2019 ++
        WebIndexL.Reset;
        IF WebIndexL.Get(WebIndex."Line no.") THEN BEGIN
            WebIndexL.Status := OptionStatus;
            WebIndexL.Error := ErrorText;
            WebIndexL.MODIFY;

            IF COPYSTR(WebIndex.Error, 1, 29) = COPYSTR('An attempt was made to change an old version of a Sales', 1, 29) THEN BEGIN
                WebIndexL.Status := WebIndexL.Status::" ";
                WebIndexL.Error := '';
                WebIndexL.MODIFY;
            END;
        END;
        WebIndex := WebIndexL;
        //MITL4523 ** //MITL.AJ.19Dec2019 ++
    end;

    procedure CreateRequest(TableNo: Integer; TableName: Text; ID: Code[80]; IndexNo: Integer)
    var
        WEBRequests: Record "WEB Requests";
    begin
        WEBRequests.SETRANGE(Table, TableNo);
        WEBRequests.SETRANGE("Table Name", TableName);
        WEBRequests.SETRANGE(ID, ID);
        IF NOT WEBRequests.FINDFIRST THEN BEGIN
            WEBRequests.INIT;
            WEBRequests."Line No." := 0;
            WEBRequests.Table := TableNo;
            WEBRequests."Table Name" := TableName;
            WEBRequests.ID := ID;
            WEBRequests."Index No." := IndexNo;
            WEBRequests.INSERT(TRUE);
        END;
    end;

    procedure InsertWEBlog(Notes: Text[250]; OrderID: Code[20])
    var
        WEBLog: Record "WEB Log";
    begin
        WEBLog."Line No." := 0;
        WEBLog.Note := Notes;
        WEBLog."Order ID" := OrderID;
        WEBLog.INSERT(TRUE);
    end;
}

