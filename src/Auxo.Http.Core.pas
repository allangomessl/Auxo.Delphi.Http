unit Auxo.Http.Core;

interface

uses
  System.Rtti, System.SysUtils;

type
  THttpMethod = (GET, POST, PUT, DELETE);
  THttpBodyType = (JSON);

  THttpParam = record
    Name: string;
    Value: Variant;
    constructor Create(AName: string; AValue: Variant);
  end;

  THttpReturn = record
  public
    HttpStatus: Integer;
    Content: string;
  end;

  THttpParams = TArray<THttpParam>;
  IHttpBase = interface;
  IHttpReq = interface;

  IHttpBase = interface
    procedure Execute(ACallback: TProc<THttpReturn>; Async: Boolean = True); overload;
  end;

  IHttpReq = interface(IHttpBase)
    function GetParam(Name: string; Value: Variant): IHttpReq;
    property Param[Name: string; Value: Variant]: IHttpReq read GetParam; default;
    function Header: IHttpReq;
    function Query: IHttpReq;
    function Body(Value: string; AType: THttpBodyType = JSON): IHttpBase;
  end;

  IHttp = interface
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);
    function GET(const APath: array of string; AQuery: string = ''): IHttpReq; overload;
    function POST(const APath: array of string; AQuery: string = ''): IHttpReq; overload;
    function PUT(const APath: array of string; AQuery: string = ''): IHttpReq; overload;
    function DELETE(const APath: array of string; AQuery: string = ''): IHttpReq; overload;
    property BaseUrl: string read GetBaseUrl write SetBaseUrl;
  end;

const
  HTTP_METHOD: array[THttpMethod] of string = ('GET', 'POST', 'PUT', 'DELETE');
  HTTP_BODY_TYPE: array[THttpBodyType] of string = ('application/json');

implementation

{ THttpParam }

constructor THttpParam.Create(AName: string; AValue: Variant);
begin
  Name  := AName;
  Value := AValue;
end;

end.
