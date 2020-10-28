tableextension 50093 CommentLineExt extends 97
{
    fields
    {
        field(50000; "User ID"; Code[50])
        {
            Description = 'MILT-17-02-20';
            CaptionML = ENU = 'User ID', ENG = 'User ID';
            TableRelation = "User Setup"."User ID";

        }
        field(50001; "Date&Time"; DateTime)
        {
            Description = 'MILT-17-02-20';
            CaptionML = ENU = 'Date and Time', ENG = 'Date and Time';

        }
        field(50002; "Saved"; Boolean)
        {
            Description = 'MILT-17-02-20';
            CaptionML = ENU = 'Saved', ENG = 'Saved';

        }
        field(50003; "File Name"; Text[250])
        {
            Description = 'MILT-17-02-20';
            CaptionML = ENU = 'File Name', ENG = 'File Name';
            trigger OnValidate()
            begin
                //If "File Name" = '' then
                //    "Document Reference ID" := ;
            end;
        }
        field(50004; "Document Reference ID"; Media)
        {
            Description = 'MILT-17-02-20';
        }

    }
    /*
    trigger OnModify()
    begin
        if "Table Name" IN ["Table Name"::Customer, "Table Name"::Vendor] then
            If Saved = true then
                Error('Record cannot be modified');
    end;
    */

    procedure Export(ShowFileDialog: Boolean): Text
    var
        //TempBlob: Record TempBlob;
        TempBlobCU: Codeunit "Temp Blob";
        DocumentStream: OutStream;
        FileManagement: Codeunit "File Management";

    begin
        IF NOT "Document Reference ID".HasValue() THEN
            exit;
        /*
        TempBlob.Blob.CREATEOUTSTREAM(DocumentStream);
        "Document Reference ID".EXPORTSTREAM(DocumentStream);
        EXIT(FileManagement.BLOBExport(TempBlob, "File Name", ShowFileDialog));
        */
        TempBlobCU.CreateOutStream(DocumentStream);
        "Document Reference ID".ExportStream(DocumentStream);
        exit(FileManagement.BLOBExport(TempBlobCU, "File Name", ShowFileDialog))
    end;
}