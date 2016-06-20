unit Auxo.Http.Url;

interface

uses
  System.Generics.Collections;

type
  TUrl = record
  private
    FBaseUrl: string;
    FPath: string;
    FQuery: TDictionary<string, Variant>;
    FParam: Variant;
    function GetURL: string;
    function GetItem(Name: string): Variant;
    procedure SetItem(Name: string; const Value: Variant);
  public
    property BaseUrl: string read FBaseUrl write FBaseUrl;
    property Path: string read FPath write FPath;
    property Param: Variant read FParam write FParam;
    property Query[Name: string]: Variant read GetItem write SetItem; default;
    class operator Implicit(url: TUrl): string;
    constructor Create(ABaseURL: string; APath: string; AParam: Variant);
  end;

implementation

uses
  System.Variants, System.SysUtils;

{ TUrl }

constructor TUrl.Create(ABaseURL: string; APath: string; AParam: Variant);
begin
  FQuery := TDictionary<string, Variant>.Create;
  BaseUrl := ABaseURL;
  Path := APath;
  Param := AParam;
end;

function TUrl.GetItem(Name: string): Variant;
begin
  Result := FQuery[Name];
end;

function TUrl.GetURL: string;
var
  qry: string;
  Item: TPair<string, Variant>;
begin
  Result := string.Join('/', [FBaseUrl, FPath]);
  if FParam <> Null then
    Result := string.Join('/', [Result, VarToStr(FParam)]);
  if FQuery.Count > 0 then
  begin
    for item in FQuery do
    begin
      if qry = EmptyStr then
        qry := Item.Key+'='+VarToStr(Item.Value)
      else
        qry := string.Join('&', [qry, Item.Key+'='+VarToStr(Item.Value)]);
    end;
    Result := string.join('?', [Result, qry]);
  end;
end;

class operator TUrl.Implicit(url: TUrl): string;
begin
  Result :=  url.GetURL;
end;

procedure TUrl.SetItem(Name: string; const Value: Variant);
begin
  FQuery.AddOrSetValue(Name, Value);
end;

end.
