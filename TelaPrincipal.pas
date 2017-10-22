unit TelaPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, pngimage, StdCtrls
  , StrUtils
  , RegularExpressions
  , DateUtils
  , Generics.Collections, Menus;

type
  TFrmPrincipal = class(TForm)
    pnlCabecalho: TPanel;
    pnlConteudo: TPanel;
    imgBtnClose: TImage;
    meListaTwitters: TMemo;
    lbNomeLogo: TLabel;
    edSearchTwitters: TEdit;
    imgBtnSendTwitters: TImage;
    imgBtnSearchTwitters: TImage;
    Label3: TLabel;
    meTwitters: TEdit;
    meTopHastags: TMemo;
    lbTopHastags: TLabel;
    lbTopTwitters: TLabel;
    Image1: TImage;
    pnlAlignSend: TPanel;
    pumOpcoes: TPopupMenu;
    pumItemFazerBackup: TMenuItem;
    pumItemCarregarBackup: TMenuItem;
    fodBackup: TFileOpenDialog;
    fsdBackup: TFileSaveDialog;
    Label1: TLabel;
    imgBtnSave: TImage;
    imgBtnOpen: TImage;
    procedure imgBtnCloseClick(Sender: TObject);
    procedure imgBtnSendTwittersClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure meTwittersKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure imgBtnSearchTwittersClick(Sender: TObject);
    procedure pumItemFazerBackupClick(Sender: TObject);
    procedure pumItemCarregarBackupClick(Sender: TObject);
    procedure edSearchTwittersKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure imgBtnOpenClick(Sender: TObject);
    procedure imgBtnSaveClick(Sender: TObject);
  private
    var
      HashTags, Tweets: Array of String;
      PosicaoHashtags:  Array of Integer;

      Dicionario: TDictionary<String, Integer>;

    procedure ListaTwitters(const Filtro:String);
    procedure ListaTopHashtags;
    procedure BuscaHastags(var twitter: String);
    procedure OrdenaTopHashtags;
    procedure BackUp;

  public

  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

procedure TFrmPrincipal.BackUp;
var
  indice : Integer;
begin
   if fsdBackup.Execute then
     meListaTwitters.Lines.SaveToFile(fsdBackup.FileName);
end;

procedure TFrmPrincipal.BuscaHastags(var twitter: String);
var
  ExprReg    : TRegEx;
  Lista      : TMatch;
  quantidade : Integer;
  hastag           : String;
begin
  ExprReg := TRegEx.Create('\S*#(?:\[[^\]]+\]|\S+)',[roIgnoreCase,roMultiline]);
  Lista := ExprReg.Match(twitter);
  if not Lista.Success then
    exit;

  while Lista.Success do
    begin
      if ((Dicionario.ContainsKey(Lista.Value)) OR (Dicionario.ContainsKey(' '+Lista.Value))) then
        begin
          quantidade := Dicionario[Lista.Value];
          quantidade := quantidade + 1;
          Dicionario[Lista.Value] := quantidade;
        end
      else
        begin
          Dicionario.Add(Lista.Value, 1);
        end;
      Lista := Lista.NextMatch;
    end;
end;

procedure TFrmPrincipal.pumItemCarregarBackupClick(Sender: TObject);
var
  indice: Integer;
  Filtro: String;
begin
  Dicionario := TDictionary<String, Integer>.Create;
  SetLength(Tweets, 0);
  if fodBackup.Execute then
    meListaTwitters.Lines.LoadFromFile(fodBackup.FileName);

  SetLength(Tweets, meListaTwitters.Lines.Count);
  for indice := 0 to meListaTwitters.Lines.Count -1 do
    begin
      Tweets[indice] := meListaTwitters.Lines[indice];
      BuscaHastags(Tweets[indice]);
    end;
    ListaTwitters(Filtro);
    OrdenaTopHashtags;
    ListaTopHashtags;

end;

procedure TFrmPrincipal.edSearchTwittersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_RETURN then
    imgBtnSearchTwittersClick(nil);
end;

procedure TFrmPrincipal.pumItemFazerBackupClick(Sender: TObject);
begin
    BackUp;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  Dicionario := TDictionary<String, Integer>.Create;
end;

procedure TFrmPrincipal.imgBtnOpenClick(Sender: TObject);
begin
   pumItemCarregarBackup.Click;
end;

procedure TFrmPrincipal.imgBtnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrmPrincipal.imgBtnSaveClick(Sender: TObject);
begin
  pumItemFazerBackup.Click;
end;

procedure TFrmPrincipal.imgBtnSearchTwittersClick(Sender: TObject);
var
  FiltroHashtag : String;
begin
  FiltroHashtag := Trim(edSearchTwitters.Text);
  ListaTwitters(FiltroHashtag);
end;

procedure TFrmPrincipal.imgBtnSendTwittersClick(Sender: TObject);
var
 indice          : Integer;
 twitter, Filtro : String;
begin
  twitter := meTwitters.Text;
  SetLength(Tweets, length(Tweets) + 1);  // manda twitter para um Array.
  Tweets[length(Tweets)-1] := twitter;
  ListaTwitters(Filtro);                   // Faz a listagem dos Twitters no Memo.
  BuscaHastags(twitter);                   // Aqui busca se tem Hastags no Twitter.

  OrdenaTopHashtags;
  ListaTopHashtags;
end;

procedure TFrmPrincipal.ListaTopHashtags;
var
  indice: integer;
begin
  meTopHastags.Lines.Clear;
  for indice := 0 to High(Hashtags) do
    begin
      meTopHastags.Lines.Add(Hashtags[indice] + ' :   ' +IntToStr(PosicaoHashtags[indice]));
    end;
end;

procedure TFrmPrincipal.ListaTwitters(const Filtro:String);
var
  indice: integer;
begin
  meListaTwitters.Lines.Clear;
  if Filtro <> '' then
    begin
      for indice := Low(Tweets) to High(Tweets) do
        begin
          if (pos(Trim(AnsiUpperCase(Filtro)),AnsiUpperCase(Tweets[indice])) > 0) then
            meListaTwitters.Lines.Add(Tweets[indice]);
        end;
    end
    else
      for indice := Low(Tweets) to High(Tweets) do
        meListaTwitters.Lines.Add(Tweets[indice]);

end;

procedure TFrmPrincipal.meTwittersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_RETURN then
    imgBtnSendTwittersClick(nil);
end;

procedure TFrmPrincipal.OrdenaTopHashtags;
var
  Lista      : TMatch;
  hastag, auxHastag  : String;
  indice, auxPosicao : integer;
  Trocou     : Boolean;
begin
  Trocou := True;
  Setlength(HashTags, 0);
  Setlength(PosicaoHashtags, 0);

  for hastag in Dicionario.Keys do
    begin
       Setlength(HashTags, length(HashTags) + 1);
       Setlength(PosicaoHashtags, length(PosicaoHashtags) + 1);

       HashTags[length(HashTags) -1]               :=   hastag;
       PosicaoHashtags[length(PosicaoHashtags) -1] :=   Dicionario[hastag];
    end;
  while Trocou <> False do
    begin
      Trocou := False;
      for indice := Low(PosicaoHashtags) to High(PosicaoHashtags)-1 do
        begin
          if PosicaoHashtags[indice] < PosicaoHashtags[indice +1] then
            begin
              auxHastag            := HashTags[indice];
              HashTags[indice]     :=  HashTags[indice +1];
              HashTags[indice +1]  := auxHastag;

              auxPosicao                  := PosicaoHashtags[indice];
              PosicaoHashtags[indice]     := PosicaoHashtags[indice +1];
              PosicaoHashtags[indice +1]  := auxPosicao;

              Trocou := True;
            end;
        end;
    end;
end;
end.
