pageextension 50105 CommentSheetExt extends "Comment Sheet"
{
    layout
    {
        addafter(Code)
        {
            field("File Name"; "File Name")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                CaptionML = ENU = 'Attachement', ENG = 'Attachment';
                Editable = False;
                trigger OnDrillDown()
                var
                    FileName: Text;
                    TempBlob: Codeunit "Temp Blob";
                    FileManagement: Codeunit "File Management";
                    DocStream: InStream;
                begin
                    If ("File Name" <> SelectFileTxt) and ("File Name" <> '') then begin
                        TempBlob.CreateInStream(DocStream);
                        //TempBlob.Blob.CREATEINSTREAM(DocStream);
                        If UPLOADINTOSTREAM(FileDialogTxt, '', AllFilesDescriptionTxt, "File Name", DocStream) then
                            "Document Reference ID".IMPORTSTREAM(DocStream, '', "File Name");
                        IF "Document Reference ID".HasValue() then
                            Export(true);
                        CLEAR("Document Reference ID");
                    END
                    else
                        IF NOT Saved then
                            "File Name" := FileManagement.BLOBImportWithFilter(TempBlob, ImportTxt, FileName, STRSUBSTNO(FileDialogTxt, FilterTxt), FilterTxt)
                        else
                            Error('Comments already saved');
                end;
            }
            field("User ID"; "User ID")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Editable = false;
            }
            field("Date&Time"; "Date&Time")
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Editable = false;
            }
            field(Saved; Saved)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Editable = false;
            }

        }
    }

    actions
    {
        addlast(Processing)
        {
            action("Save")
            {
                Caption = 'Save Comment';
                Image = Save;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Page Field';
                trigger OnAction()
                var
                    RecCommentLine: Record "Comment Line";
                begin
                    if "Table Name" IN ["Table Name"::Customer, "Table Name"::Vendor] then begin
                        CurrPage.SetSelectionFilter(RecCommentLine);
                        IF RecCommentLine.FindSet() then
                            repeat
                                RecCommentLine."Date&Time" := CurrentDateTime();
                                RecCommentLine."User ID" := UserId();
                                RecCommentLine.Saved := true;
                                RecCommentLine.Modify();
                            until RecCommentLine.Next = 0;
                        CurrPage.Update();
                    end;
                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "File Name" := SelectFileTxt;
    end;

    trigger OnModifyRecord(): Boolean
    Begin
        if "Table Name" IN ["Table Name"::Customer, "Table Name"::Vendor] then
            If Saved = true then
                Error('Saved comments cannot be modified');
    End;

    var
        SelectFileTxt: TextConst ENU = 'Select File...', ENG = 'Select File...';
        ImportTxt: TextConst ENU = 'Attach a document.', ENG = 'Attach a document.';
        FileDialogTxt: TextConst ENU = 'Attachments (%1)|%1', ENG = 'Attachments (%1)|%1';
        AllFilesDescriptionTxt: TextConst ENU = 'All Files (*.*)|*.*', ENG = 'All Files (*.*)|*.*';
        FilterTxt: TextConst ENU = '*.jpg;*.jpeg;*.bmp;*.png;*.gif;*.tiff;*.tif;*.pdf;*.docx;*.doc;*.xlsx;*.xls;*.pptx;*.ppt;*.msg;*.xml;*.*', ENG = '*.jpg;*.jpeg;*.bmp;*.png;*.gif;*.tiff;*.tif;*.pdf;*.docx;*.doc;*.xlsx;*.xls;*.pptx;*.ppt;*.msg;*.xml;*.*';

}