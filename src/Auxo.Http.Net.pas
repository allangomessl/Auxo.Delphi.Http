unit Auxo.Http.Net;

interface

uses
  Auxo.Http.Core, System.Net.HttpClient, System.Net.HttpClientComponent, System.Generics.Collections, System.Classes, System.SysUtils;

type
  IHttp = Auxo.Http.Core.IHttp;
  THttpMethod = Auxo.Http.Core.THttpMethod;
  THttpParams = Auxo.Http.Core.THttpParams;
  THttpBodyType = Auxo.Http.Core.THttpBodyType;

  THttpNet = class(TInterfacedObject, IHttp, IHttpReq, IHttpBase)
  private
    FHttp: THTTPClient;
    FBaseUrl: string;
    FMethod: THttpMethod;
    FResource: string;
    FCurrentParams: TDictionary<string,Variant>;
    FHeaderParams: TDictionary<string,Variant>;
    FQueryParams: TDictionary<string,Variant>;
    FParam: Variant;
    FBody: TStream;
    FBodyType: THttpBodyType;
  protected
    function GetBaseUrl: string;
    procedure SetBaseURL(const Value: string);
    function GetParam(Name: string; Value: Variant): IHttpReq;
    property Param[Name: string; Value: Variant]: IHttpReq read GetParam; default;
    function Header: IHttpReq;
    function Query: IHttpReq;
    function Body(Value: string; AType: THttpBodyType = JSON): IHttpBase;
    function NewRequest(AMethod: THttpMethod; AResource: string; AParam: Variant): IHttpReq;
  public
    function Execute: THttpReturn; overload;
    procedure Execute(ACallback: TProc<THttpReturn>; Async: Boolean = True); overload;
    function GET(const APath: array of string; AQuery: string = ''): IHttpReq; overload;
    function POST(const APath: array of string; AQuery: string = ''): IHttpReq; overload;
    function PUT(const APath: array of string; AQuery: string = ''): IHttpReq; overload;
    function DELETE(const APath: array of string; AQuery: string = ''): IHttpReq; overload;
    constructor Create(AHttp: THTTPClient; ABaseURL: string = '');
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

implementation

uses
  System.Net.URLClient, System.Variants, System.NetConsts, Auxo.Http.Url, System.StrUtils, Auxo.Core.Threading;

{ THttp }

procedure THttpNet.AfterConstruction;
begin
  inherited;
  FHeaderParams := TDictionary<string,Variant>.Create;
  FQueryParams := TDictionary<string,Variant>.Create;
end;

procedure THttpNet.BeforeDestruction;
begin
  inherited;
  FHeaderParams.Free;
  FQueryParams.Free;
end;

function THttpNet.Body(Value: string; AType: THttpBodyType): IHttpBase;
begin
  Result := Self;
  if Assigned(FBody) then
    FreeAndNil(FBody);
  FBodyType := AType;
  FBody := TStringStream.Create(Value);
end;

constructor THttpNet.Create(AHttp: THTTPClient; ABaseURL: string = '');
begin
  FHttp := AHttp;
  FBaseUrl := ABaseURL;
end;

function THttpNet.GetBaseUrl: string;
begin
  Result := FBaseUrl;
end;

function THttpNet.GetParam(Name: string; Value: Variant): IHttpReq;
begin
  Result := Self;
  FCurrentParams.AddOrSetValue(Name, Value);
end;

function THttpNet.Header: IHttpReq;
begin
  Result := Self;
  FCurrentParams := FHeaderParams;
end;

function THttpNet.NewRequest(AMethod: THttpMethod; AResource: string; AParam: Variant): IHttpReq;
begin
  Result := Query;
  FParam := VarToStr(AParam);
  FHeaderParams.Clear;
  FQueryParams.Clear;
  FMethod := AMethod;
  FResource := AResource;
  if Assigned(FBody) then
    FreeAndNil(FBody);
end;

function THttpNet.GET(const APath: array of string; AQuery: string): IHttpReq;
begin
  Result := NewRequest(THttpMethod.GET, string.Join('/', APath), AQuery);
end;

function THttpNet.DELETE(const APath: array of string; AQuery: string = ''): IHttpReq;
begin
  Result := NewRequest(THttpMethod.DELETE, string.Join('/', APath), AQuery);
end;

procedure THttpNet.Execute(ACallback: TProc<THttpReturn>; Async: Boolean);
begin
  if Async then
  begin
    TThreadContext.Run(Self,
    procedure
    begin
      ACallback(Execute);
    end)
  end
  else
    ACallback(Execute);
end;

function THttpNet.POST(const APath: array of string; AQuery: string): IHttpReq;
begin
  Result := NewRequest(THttpMethod.POST, string.Join('/', APath), AQuery);
end;

function THttpNet.PUT(const APath: array of string; AQuery: string): IHttpReq;
begin
  Result := NewRequest(THttpMethod.PUT, string.Join('/', APath), AQuery);
end;

function THttpNet.Query: IHttpReq;
begin
  Result := Self;
  FCurrentParams := FQueryParams;
end;

function THttpNet.Execute: THttpReturn;
var
  response: IHTTPResponse;
  P: TPair<string, Variant>;
  Url: TUrl;
begin
  url := TUrl.Create(FBaseUrl, FResource, FParam);
  if Assigned(FBody) then
    FHttp.ContentType := HTTP_BODY_TYPE[FBodyType];
  for P in FQueryParams do
    Url[P.Key] := P.Value;
  case FMethod of
    THttpMethod.GET: response := FHttp.Get(Url);
    THttpMethod.POST: response := FHttp.Post(Url, FBody);
    THttpMethod.PUT: response := FHttp.Put(Url, FBody);
    THttpMethod.DELETE: response := FHttp.Delete(Url);
  end;
  Result.HttpStatus := response.StatusCode;
  Result.Content := response.ContentAsString;
end;

procedure THttpNet.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
end;

end.
