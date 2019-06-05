{
  PowerSQLBuilder.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a execu��o de comandos SQL via codigos livre de
             componentes de terceiros.
  ------------------------------------------------------------------------------
  Autor : Antonio Julio
  ------------------------------------------------------------------------------
  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la
  sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a vers�o 3.29 da Licen�a, ou (a seu crit�rio)
  qualquer vers�o posterior.

  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM
  NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU
  ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor
  do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)

  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto
  com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,
  no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Voc� tamb�m pode obter uma copia da licen�a em:
  http://www.opensource.org/licenses/lgpl-license.php
}
unit PowerSqlBuilder;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils, System.DateUtils,
  {ZeusLib}
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZConnection, ZAbstractTable,
  {FireDac}
  FireDAC.Stan.Intf, FireDAC.Stan.Option,FireDAC.Stan.Error, Rest.Json,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf,FireDAC.DApt, FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, FireDAC.Phys.PG, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  {ADO}
  Data.Win.ADODB,
  {UniDac}
  MemDS, DBAccess, Uni;

type
  TExecuteZc = procedure (var Connection : TZConnection ) of object;
  TExecuteZ = procedure (var Query : TZQuery ) of object;

  TExecuteFc = procedure (var Connection : TFDConnection ) of object;
  TExecuteF = procedure (var Query : TFDQuery ) of object;

  TExecuteUc = procedure (var Connection : TUniConnection ) of object;
  TExecuteU = procedure (var Query : TUniQuery ) of object;

  TExecuteAc = procedure (var Connection : TADOConnection ) of object;
  TExecuteA = procedure (var Query : TADOQuery ) of object;

  TOpenZ = procedure (var query : TZQuery ) of object;
  TOpenF = procedure (var query : TFDQuery ) of object;
  TOpenU = procedure (var query : TUniQuery ) of object;
  TOpenA = procedure (var query : TADOQuery ) of object;

  TSGDBType = ( dbPostGreSQL, dbMySQL, dbMsSQL, dbFireBird, dbNenhum );

  /// <summary>
  ///   PowerSQLBuilder � uma classe de manipula��o SQL
  /// </summary>
  /// <comments>
  ///   Chega de ficar concatenando peda�os do texto gerando um scripts SQL manual
  ///   E muita das vezes falho, atrav�s do PowerSQLBuilder voc� apenas chama os
  ///   comandos SQL que ele mesmo interpreta e gera o scripts SQL automaticamente
  ///   <para><c>Mais o que torna ele �gil � a possibilidade de passar par�metros sem se preocupar
  ///   com seu tipo de origem o PowerSQLBulder faz isso automaticamente para voc�.
  ///   interpleta e gera o scripts SQL automaticamente</c></para>
  /// </comments>
  /// <remarks>
  ///   Para saber mais entre no site https://github.com/juliospd/PowerSQLBuilder
  /// </remarks>
  TPowerSQLBuilder = class(TObject)
  private
    FValuePSB : TStringBuilder;
    FSGDBType: TSGDBType;
    FWhere : Boolean;

    FOpenFire: TOpenF;
    FOpenZeus: TOpenZ;
    FOpenUniDac : TOpenU;
    FOpenADO : TOpenA;
    FExecuteFire: TExecuteF;
    FExecuteZeus: TExecuteZ;
    FExecuteUniDac: TExecuteU;
    FExecuteADO: TExecuteA;
    FExecuteZeusC: TExecuteZc;
    FExecuteFireC: TExecuteFc;
    FExecuteUniDacC: TExecuteUc;
    FExecuteADOC: TExecuteAc;

    function Test( const Value : WideString; Condition : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Test( const Value : Double; DecimalValue : ShortInt = 2; Condition : WideString = '' ) : TPowerSQLBuilder; overload; virtual;
    function Test( const Value : Int64; Condition : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Test( const Value : Integer; Condition : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Test( const Value : Boolean; Condition : WideString ) : TPowerSQLBuilder; overload; virtual;
    function TestDate( const Value : TDateTime; Condition : WideString; Mask : WideString = '' ) : TPowerSQLBuilder; overload; virtual;
    function TestOfDate( const Value : TDateTime; Condition : WideString; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    function TestOfTime( const Value : TDateTime; Seconds : Boolean = True; Condition : WideString = ''; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
  protected
    procedure SetZeus( ExecuteZeusC : TExecuteZc; ExecuteZeus : TExecuteZ; OpenZeus : TOpenZ );
    procedure SetFireDac( ExecuteFireC : TExecuteFc; ExecuteFire : TExecuteF; OpenFire : TOpenF );
    procedure SetUniDac( ExecuteUniDacC : TExecuteUc; ExecuteUniDac : TExecuteU; OpenUniDac : TOpenU );
    procedure SetADO( ExecuteADOC : TExecuteAc; ExecuteADO : TExecuteA; OpenADO : TOpenA );
  public
    property SGDBType : TSGDBType read FSGDBType;
    // Fun��es simples
    function Add(const Value : WideString) : TPowerSQLBuilder; virtual;
    function AddQuoted(const Value : WideString) : TPowerSQLBuilder; virtual;
    function AddLine(const Value : WideString) : TPowerSQLBuilder; virtual;
    function Clear : TPowerSQLBuilder; virtual;
    function GetString : WideString; virtual;
    // Teste de Igual a
    function Equal( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Equal( const Value : Double; DecimalValue : ShortInt = 2 ) : TPowerSQLBuilder; overload; virtual;
    function Equal( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; overload; virtual;
    function Equal( const Value : Int64 ) : TPowerSQLBuilder; overload; virtual;
    function Equal( const Value : Integer ) : TPowerSQLBuilder; overload; virtual;
    function Equal( const Value : Boolean ) : TPowerSQLBuilder; overload; virtual;
    function EqualOfDate( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    function EqualOfTime( const Value : TDateTime; Seconds : Boolean = True; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    // Teste de Maior que
    function Major( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Major( const Value : Double; DecimalValue : ShortInt = 2 ) : TPowerSQLBuilder; overload; virtual;
    function Major( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; overload; virtual;
    function Major( const Value : Int64 ) : TPowerSQLBuilder; overload; virtual;
    function Major( const Value : Integer ) : TPowerSQLBuilder; overload; virtual;
    function Major( const Value : Boolean ) : TPowerSQLBuilder; overload; virtual;
    function MajorOfDate( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    function MajorOfTime( const Value : TDateTime; Seconds : Boolean = True; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    // Teste de Maior igual
    function MajorEqual( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function MajorEqual( const Value : Double; DecimalValue : ShortInt = 2 ) : TPowerSQLBuilder; overload; virtual;
    function MajorEqual( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; overload; virtual;
    function MajorEqual( const Value : Int64 ) : TPowerSQLBuilder; overload; virtual;
    function MajorEqual( const Value : Integer ) : TPowerSQLBuilder; overload; virtual;
    function MajorEqual( const Value : Boolean ) : TPowerSQLBuilder; overload; virtual;
    function MajorEqualOfDate( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    function MajorEqualOfTime( const Value : TDateTime; Seconds : Boolean = True; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    // Teste de Menor que
    function Minor( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Minor( const Value : Double; DecimalValue : ShortInt = 2 ) : TPowerSQLBuilder; overload; virtual;
    function Minor( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; overload; virtual;
    function Minor( const Value : Int64 ) : TPowerSQLBuilder; overload; virtual;
    function Minor( const Value : Integer ) : TPowerSQLBuilder; overload; virtual;
    function Minor( const Value : Boolean ) : TPowerSQLBuilder; overload; virtual;
    function MinorOfDate( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    function MinorOfTime( const Value : TDateTime; Seconds : Boolean = True; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    // Teste de Menor Igual
    function MinorEqual( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function MinorEqual( const Value : Double; DecimalValue : ShortInt = 2 ) : TPowerSQLBuilder; overload; virtual;
    function MinorEqual( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; overload; virtual;
    function MinorEqual( const Value : Int64 ) : TPowerSQLBuilder; overload; virtual;
    function MinorEqual( const Value : Integer ) : TPowerSQLBuilder; overload; virtual;
    function MinorEqual( const Value : Boolean ) : TPowerSQLBuilder; overload; virtual;
    function MinorEqualOfDate( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    function MinorEqualOfTime( const Value : TDateTime; Seconds : Boolean = True; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    // Teste de Diferen�a que
    function Different( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Different( const Value : Double; DecimalValue : ShortInt = 2 ) : TPowerSQLBuilder; overload; virtual;
    function Different( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; overload; virtual;
    function Different( const Value : Int64 ) : TPowerSQLBuilder; overload; virtual;
    function Different( const Value : Integer ) : TPowerSQLBuilder; overload; virtual;
    function Different( const Value : Boolean ) : TPowerSQLBuilder; overload; virtual;
    function DifferentOfDate( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    function DifferentOfTime( const Value : TDateTime; Seconds : Boolean = True; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    // Field usado na inser��o
    function Field( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Field( const Value : Double; DecimalValue : ShortInt = 2 ) : TPowerSQLBuilder; overload; virtual;
    function Field( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; overload; virtual;
    function Field( const Value : Int64 ) : TPowerSQLBuilder; overload; virtual;
    function Field( const Value : Integer ) : TPowerSQLBuilder; overload; virtual;
    function Field( const Value : Boolean ) : TPowerSQLBuilder; overload; virtual;
    function FieldFloat( const Value : Double; DecimalValue : ShortInt = 2 ) : TPowerSQLBuilder; virtual;
    function FieldOfDate( const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    function FieldOfTime( const Value : TDateTime; Seconds : Boolean = True; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    // Campo e valor usado no Update
    function UpField( Field : WideString; const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function UpField( Field : WideString; const Value : Double; DecimalValue : ShortInt = 2 ) : TPowerSQLBuilder; overload; virtual;
    function UpField( Field : WideString; const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; overload; virtual;
    function UpField( Field : WideString; const Value : Int64 ) : TPowerSQLBuilder; overload; virtual;
    function UpField( Field : WideString; const Value : Integer ) : TPowerSQLBuilder; overload; virtual;
    function UpField( Field : WideString; const Value : Boolean ) : TPowerSQLBuilder; overload; virtual;
    function UpFieldOfDate( Field : WideString; const Value : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    function UpFieldOfTime( Field : WideString; const Value : TDateTime; Seconds : Boolean = True; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    // Power SQL
    function Insert( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Insert : TPowerSQLBuilder; overload; virtual;
    function Select : TPowerSQLBuilder; overload; virtual;
    function Select( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function SelectFrom : TPowerSQLBuilder; overload; virtual;
    function SelectFrom( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Update( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Update : TPowerSQLBuilder; overload; virtual;
    function Delete( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Delete : TPowerSQLBuilder; overload; virtual;
    function DeleteFrom( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function DeleteFrom : TPowerSQLBuilder; overload; virtual;
    function From( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function From : TPowerSQLBuilder; overload; virtual;
    function Where( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Where( const Value : WideString; const Cast : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Order_By : TPowerSQLBuilder; overload; virtual;
    function Order_By( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Desc : TPowerSQLBuilder; virtual;
    function Group_By( const Value : WideString ) : TPowerSQLBuilder; virtual;
    function Values : TPowerSQLBuilder; virtual;
    function EndValues : TPowerSQLBuilder; virtual;
    function EndValuesID : TPowerSQLBuilder; virtual;
    function Sum : TPowerSQLBuilder;  overload; virtual;
    function Sum( const Value : WideString ) : TPowerSQLBuilder;  overload; virtual;
    function SumAs( const Value : WideString; asValue : WideString ) : TPowerSQLBuilder; virtual;
    function having( const Value : WideString ) : TPowerSQLBuilder; virtual;
    /// <summary>
    /// sP : Abre um Parentese Start Parent '('
    /// </summary>
    function sP : TPowerSQLBuilder; virtual;
    /// <summary>
    /// eP : Fecha um Parentese end parent ')'
    /// </summary>
    function eP : TPowerSQLBuilder; virtual;
    function LeftJoin( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function LeftJoin : TPowerSQLBuilder; overload; virtual;
    function RightJoin( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function RightJoin : TPowerSQLBuilder; overload; virtual;
    function InnerJoin( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function InnerJoin : TPowerSQLBuilder; overload; virtual;
    function FullJoin( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function FullJoin : TPowerSQLBuilder; overload; virtual;
    function Top( const Value : Integer ) : TPowerSQLBuilder; overload; virtual;
    function Limit( const Value : Integer ) : TPowerSQLBuilder; overload; virtual;
    function Limit( const pag1, pag2 : Integer ) : TPowerSQLBuilder; overload; virtual;
    function Like( const Value : WideString ) : TPowerSQLBuilder; virtual;
    function Next : TPowerSQLBuilder; virtual;
    function Fields( const Value : WideString ) : TPowerSQLBuilder; virtual;
    function FieldsStart( const Value : WideString ) : TPowerSQLBuilder; virtual;
    function FieldsInline( const Value : WideString ) : TPowerSQLBuilder; virtual;
    function FieldsEnd( const Value : WideString ) : TPowerSQLBuilder; virtual;
    function BetWeen( const ValueStart, ValueEnd : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; overload; virtual;
    function BetWeen( const ValueStart, ValueEnd : Int64 ) : TPowerSQLBuilder; overload; virtual;
    function BetWeen( const ValueStart, ValueEnd : Integer ) : TPowerSQLBuilder; overload; virtual;
    function BetWeen( const ValueStart, ValueEnd : Double; DecimalValue : ShortInt = 2 ) : TPowerSQLBuilder; overload; virtual;
    function BetWeenOfDate( const ValueStart, ValueEnd : TDateTime; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    function BetWeenOfTime( const ValueStart, ValueEnd : TDateTime; Seconds : Boolean = True; Mask : WideString = '' ) : TPowerSQLBuilder; virtual;
    function Cast( Field : WideString; const Value : WideString ) : TPowerSQLBuilder; virtual;
    function Distinct : TPowerSQLBuilder; overload; virtual;
    function Distinct( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function Count : TPowerSQLBuilder; virtual;
    function CountAs( const asValue : WideString ) : TPowerSQLBuilder; virtual;
    function Max(const Value : WideString ) : TPowerSQLBuilder; virtual;
    function Min(const Value : WideString ) : TPowerSQLBuilder; Virtual;
    function AlterTable(const Value : WideString ) : TPowerSQLBuilder; virtual;
    function AutoIncrement(const Value : Integer ) : TPowerSQLBuilder; virtual;
    function EndIn : TPowerSQLBuilder; virtual;
    function Returning( Field : WideString ) : TPowerSQLBuilder; virtual;
    //
    function Empty : TPowerSQLBuilder; virtual;
    function &Is : TPowerSQLBuilder; virtual;
    function &IsNull : TPowerSQLBuilder; virtual;
    function &IsNotNull : TPowerSQLBuilder; virtual;
    function &As( const Value : WideString ) : TPowerSQLBuilder; virtual;
    function &Not( const Value : WideString ) : TPowerSQLBuilder; virtual;
    function &Or( const Value : WideString ) : TPowerSQLBuilder; virtual;
    function &And( const Value : WideString ) : TPowerSQLBuilder; virtual;
    function &On( const Value : WideString ) : TPowerSQLBuilder; virtual;
    function &In : TPowerSQLBuilder;  overload; virtual;
    function &In( const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function &Not_In : TPowerSQLBuilder; overload; virtual;
    function &Not_In(const Value : WideString ) : TPowerSQLBuilder; overload; virtual;
    function &Case( Condition : WideString ) : TPowerSQLBuilder; overload; virtual;
    function &Case : TPowerSQLBuilder; overload; virtual;
    function &When( Condition : WideString )  : TPowerSQLBuilder; overload; virtual;
    function &When  : TPowerSQLBuilder; overload; virtual;
    function &Then( Value : WideString )  : TPowerSQLBuilder; overload; virtual;
    function &Then( Value : Double; DecimalValue : ShortInt = 2 )  : TPowerSQLBuilder; overload; virtual;
    function &Then( Value : TDateTime; Mask : WideString = ''  )  : TPowerSQLBuilder; overload; virtual;
    function &Then( Value : Int64 )  : TPowerSQLBuilder; overload; virtual;
    function &Then( Value : Integer )  : TPowerSQLBuilder; overload; virtual;
    function &Then( Value : Boolean )  : TPowerSQLBuilder; overload; virtual;
    function &Else( Value : WideString )  : TPowerSQLBuilder; overload; virtual;
    function &Else( Value : Double; DecimalValue : ShortInt = 2 )  : TPowerSQLBuilder; overload; virtual;
    function &Else( Value : TDateTime; Mask : WideString = ''  )  : TPowerSQLBuilder; overload; virtual;
    function &Else( Value : Int64 )  : TPowerSQLBuilder; overload; virtual;
    function &Else( Value : Integer ) : TPowerSQLBuilder; overload; virtual;
    function &Else( Value : Boolean ) : TPowerSQLBuilder; overload; virtual;
    function &End( Name : WideString ) : TPowerSQLBuilder; overload; virtual;
    function &End : TPowerSQLBuilder; overload; virtual;

    function GetJson( var Query : TZQuery; NameArray : WideString ) : WideString; overload;

    function Execute(var Connection : TZConnection ) : TPowerSQLBuilder; overload;
    function Execute(var Query : TZQuery ) : TPowerSQLBuilder; overload;
    function Execute(var Connection : TFDConnection ) : TPowerSQLBuilder; overload;
    function Execute(var Query : TFDQuery ) : TPowerSQLBuilder; overload;
    function Execute(var Connection : TUniConnection ) : TPowerSQLBuilder; overload;
    function Execute(var Query : TUniQuery ) : TPowerSQLBuilder; overload;
    function Execute(var Connection : TADOConnection ) : TPowerSQLBuilder; overload;
    function Execute(var Query : TADOQuery ) : TPowerSQLBuilder; overload;
    function Open(var query : TZQuery ) : TPowerSQLBuilder; overload;
    function Open(var query : TFDQuery ) : TPowerSQLBuilder; overload;
    function Open(var query : TUniQuery ) : TPowerSQLBuilder; overload;
    function Open(var query : TADOQuery ) : TPowerSQLBuilder; overload;
    function PostGreSQL : TPowerSQLBuilder;
    function FireBird : TPowerSQLBuilder;
    function MSSQL : TPowerSQLBuilder;
    function MySQL : TPowerSQLBuilder;

    constructor Create; virtual;
    destructor Destroy; override;
  end;

implementation

{ TPowerSQLBuilder }

function TPowerSQLBuilder.&ON(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' on (').Add( Value ).EndValues;
end;

function TPowerSQLBuilder.Open(var query: TADOQuery): TPowerSQLBuilder;
begin
  if Assigned( Self.FOpenADO ) then
    Self.FOpenADO( Query );

  Result := Self;
end;

function TPowerSQLBuilder.Open(var query: TFDQuery): TPowerSQLBuilder;
begin
  if Assigned( Self.FOpenFire ) then
    Self.FOpenFire( Query );

  Result := Self;
end;

function TPowerSQLBuilder.Open(var query: TZQuery): TPowerSQLBuilder;
begin
  if Assigned( Self.FOpenZeus ) then
    Self.FOpenZeus( Query );

  Result := Self;
end;

function TPowerSQLBuilder.&IN(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' in (').Add( Value );
end;

function TPowerSQLBuilder.InnerJoin: TPowerSQLBuilder;
begin
  Result := Add(' Inner Join');
end;

function TPowerSQLBuilder.Insert: TPowerSQLBuilder;
begin
  Result := Add('insert into');
end;

function TPowerSQLBuilder.&NOT_IN(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' not in (').Add( Value ).eP;
end;

function TPowerSQLBuilder.&IN: TPowerSQLBuilder;
begin
  Result := Add(' in (');
end;

function TPowerSQLBuilder.&As(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' as ').Add( Value );
end;

function TPowerSQLBuilder.AutoIncrement(const Value: Integer): TPowerSQLBuilder;
begin
  Result := Add(' auto_increment').Equal( Value );
end;

function TPowerSQLBuilder.&Case: TPowerSQLBuilder;
begin
  Result := Add(' case');
end;

function TPowerSQLBuilder.&Case(Condition: WideString): TPowerSQLBuilder;
begin
  Result := Add(' case ').Add( Condition );
end;

function TPowerSQLBuilder.&Else(Value: Int64): TPowerSQLBuilder;
begin
  Result := Add(' else ').Field( Value );
end;

function TPowerSQLBuilder.&Else(Value: Integer): TPowerSQLBuilder;
begin
  Result := Add(' else ').Field( Value );
end;

function TPowerSQLBuilder.&Else( Value: Boolean ): TPowerSQLBuilder;
begin
  Result := Add(' else ').Field( Value );
end;

function TPowerSQLBuilder.Empty: TPowerSQLBuilder;
begin
  Result := Add(' null ');
end;

function TPowerSQLBuilder.&Else(Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' else ').Add( Value );
end;

function TPowerSQLBuilder.&Else(Value: Double; DecimalValue: ShortInt): TPowerSQLBuilder;
begin
  Result := Add(' else ').Field( Value, DecimalValue );
end;

function TPowerSQLBuilder.&Else(Value: TDateTime; Mask: WideString): TPowerSQLBuilder;
begin
  Result := Add(' else ').Field( Value, Mask );
end;

function TPowerSQLBuilder.&End: TPowerSQLBuilder;
begin
  Result := Add(' end');
end;

function TPowerSQLBuilder.&End(Name: WideString): TPowerSQLBuilder;
begin
  Result := Add(' end').&As( Name );
end;

function TPowerSQLBuilder.&Then(Value: Int64): TPowerSQLBuilder;
begin
  Result := Add(' then ').Field( Value );
end;

function TPowerSQLBuilder.&Then(Value: Integer): TPowerSQLBuilder;
begin
  Result := Add(' then ').Field( Value );
end;

function TPowerSQLBuilder.&Then(Value: Boolean): TPowerSQLBuilder;
begin
  Result := Add(' then ').Field( Value );
end;

function TPowerSQLBuilder.Top(const Value: Integer): TPowerSQLBuilder;
begin
  Result := Add(' TOP ').Field(Value);
end;

function TPowerSQLBuilder.&Then(Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' then ').Add( Value );
end;

function TPowerSQLBuilder.&Then(Value: Double; DecimalValue: ShortInt): TPowerSQLBuilder;
begin
  Result := Add(' then ').Field( Value, DecimalValue );
end;

function TPowerSQLBuilder.&Then(Value: TDateTime; Mask: WideString): TPowerSQLBuilder;
begin
  Result := Add(' then ').Field( Value, Mask );
end;

function TPowerSQLBuilder.&Is: TPowerSQLBuilder;
begin
  Result := Add(' is ');
end;

function TPowerSQLBuilder.IsNotNull: TPowerSQLBuilder;
begin
  Result := Add(' is not null ');
end;

function TPowerSQLBuilder.&IsNull: TPowerSQLBuilder;
begin
  Result := Add(' is null ');
end;

function TPowerSQLBuilder.Add(const Value: WideString): TPowerSQLBuilder;
begin
  Self.FValuePSB.Append( Value );
  Result := Self;
end;

function TPowerSQLBuilder.AddLine(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add( Value ).Add( #10 );
end;

function TPowerSQLBuilder.AddQuoted( const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add( QuotedStr( Value ) );
end;

function TPowerSQLBuilder.AlterTable(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' alter table ').Add( value );
end;

function TPowerSQLBuilder.BetWeen(const ValueStart, ValueEnd: Double; DecimalValue: ShortInt): TPowerSQLBuilder;
begin
  Result := Add(' between ').Field( ValueStart, DecimalValue ).Add(' and ').Field( ValueEnd, DecimalValue );
end;

function TPowerSQLBuilder.BetWeen(const ValueStart, ValueEnd: Int64): TPowerSQLBuilder;
begin
  Result := Add(' between ').Field( ValueStart ).Add(' and ').Field( ValueEnd );
end;

function TPowerSQLBuilder.BetWeen(const ValueStart, ValueEnd: Integer): TPowerSQLBuilder;
begin
  Result := Add(' between ').Field( ValueStart ).Add(' and ').Field( ValueEnd );
end;

function TPowerSQLBuilder.BetWeen(const ValueStart, ValueEnd: TDateTime; Mask : WideString ): TPowerSQLBuilder;
begin
  Result := Add(' between ').Field( ValueStart, Mask ).Add(' and ').Field( ValueEnd, Mask );
end;

function TPowerSQLBuilder.BetWeenOfDate(const ValueStart, ValueEnd: TDateTime; Mask : WideString ): TPowerSQLBuilder;
begin
  Result := Add(' between ').FieldOfDate( ValueStart, Mask ).Add(' and ').FieldOfDate( ValueEnd, Mask );
end;

function TPowerSQLBuilder.BetWeenOfTime(const ValueStart, ValueEnd: TDateTime; Seconds : Boolean; Mask : WideString): TPowerSQLBuilder;
begin
  Result := Add(' between ').FieldOfTime( ValueStart, Seconds, Mask ).Add(' and ').FieldOfTime( ValueEnd, Seconds, Mask );
end;

function TPowerSQLBuilder.Cast(Field: WideString; const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' cast(').Add(Field).&As(Value).Add(')');
end;

function TPowerSQLBuilder.Clear: TPowerSQLBuilder;
begin
  Self.FValuePSB.Clear;
  Self.FWhere := False;
  Result := Self;
end;

function TPowerSQLBuilder.CountAs(const asValue: WideString): TPowerSQLBuilder;
begin
  Result := Add(' count(*)').&As( asValue );
end;

function TPowerSQLBuilder.Count: TPowerSQLBuilder;
begin
  Result := Add(' count(*)');
end;

constructor TPowerSQLBuilder.Create;
begin
  Self.FValuePSB := TStringBuilder.Create;
  Self.FSGDBType := dbNenhum;
end;

function TPowerSQLBuilder.Desc: TPowerSQLBuilder;
begin
  Result := Add(' Desc');
end;

destructor TPowerSQLBuilder.Destroy;
begin
  FreeAndNil( Self.FValuePSB );
  inherited;
end;

function TPowerSQLBuilder.Different(const Value: Double;DecimalValue: ShortInt): TPowerSQLBuilder;
begin
  Result := Test( Value, DecimalValue, '<>');
end;

function TPowerSQLBuilder.Different(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Test( Value, '<>' );
end;

function TPowerSQLBuilder.Different(const Value: TDateTime; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestDate( Value, '<>', Mask );
end;

function TPowerSQLBuilder.Different(const Value: Boolean): TPowerSQLBuilder;
begin
  Result := Test( Value, '<>' );
end;

function TPowerSQLBuilder.Different(const Value: Integer): TPowerSQLBuilder;
begin
  Result := Test( Value, '<>' );
end;

function TPowerSQLBuilder.Different(const Value: Int64): TPowerSQLBuilder;
begin
  Result := Test( Value, '<>' );
end;

function TPowerSQLBuilder.DifferentOfDate(const Value: TDateTime; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestOfDate( Value, '<>', Mask );
end;

function TPowerSQLBuilder.DifferentOfTime(const Value: TDateTime;Seconds: Boolean; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestOfTime( Value, Seconds,  '<>', Mask );
end;

function TPowerSQLBuilder.Distinct(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' Distinct ').Add( Value );
end;

function TPowerSQLBuilder.Distinct: TPowerSQLBuilder;
begin
  Result := Add(' Distinct');
end;

function TPowerSQLBuilder.Equal(const Value: TDateTime; Mask : WideString ): TPowerSQLBuilder;
begin
  Result := TestDate( Value, '=', Mask);
end;

function TPowerSQLBuilder.Equal(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Test( Value, '=' );
end;

function TPowerSQLBuilder.Equal(const Value: Double; DecimalValue: ShortInt): TPowerSQLBuilder;
begin
  Result := Test( Value, DecimalValue, '=' );
end;

function TPowerSQLBuilder.Equal(const Value: Integer): TPowerSQLBuilder;
begin
  Result := Test( Value, '=' );
end;

function TPowerSQLBuilder.EndIn: TPowerSQLBuilder;
begin
  Result := eP;
end;

function TPowerSQLBuilder.EndValues: TPowerSQLBuilder;
begin
  Result := eP;
end;

function TPowerSQLBuilder.EndValuesID: TPowerSQLBuilder;
begin
  Result := eP.Add(' returning id ');
end;

function TPowerSQLBuilder.eP: TPowerSQLBuilder;
begin
  Result := Add(')');
end;

function TPowerSQLBuilder.Equal(const Value: Boolean): TPowerSQLBuilder;
begin
  Result := Test( Value, '=' );
end;

function TPowerSQLBuilder.Equal(const Value: Int64): TPowerSQLBuilder;
begin
  Result := Test( Value, '=' );
end;

function TPowerSQLBuilder.EqualOfDate(const Value: TDateTime; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestOfDate( Value, '=', Mask );
end;

function TPowerSQLBuilder.EqualOfTime(const Value: TDateTime; Seconds : Boolean; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestOfTime( Value, Seconds, '=', Mask );
end;

function TPowerSQLBuilder.Execute(var Connection: TADOConnection): TPowerSQLBuilder;
begin
  if Assigned( Self.FExecuteADOC ) then
    Self.FExecuteADOC( Connection );

  Result := Self;
end;

function TPowerSQLBuilder.Execute(var Query: TADOQuery): TPowerSQLBuilder;
begin
  if Assigned( Self.FExecuteADO ) then
    Self.FExecuteADO( Query );

  Result := Self;
end;

function TPowerSQLBuilder.Execute(var Connection: TZConnection): TPowerSQLBuilder;
begin
  if Assigned( Self.FExecuteZeusC ) then
    Self.FExecuteZeusC( Connection );

  Result := Self;
end;

function TPowerSQLBuilder.Execute(var Connection: TFDConnection): TPowerSQLBuilder;
begin
  if Assigned( Self.FExecuteFireC ) then
    Self.FExecuteFireC( Connection );

  Result := Self;
end;

function TPowerSQLBuilder.Execute(var Query: TFDQuery): TPowerSQLBuilder;
begin
  if Assigned( Self.FExecuteFire ) then
    Self.FExecuteFire( Query );

  Result := Self;
end;

function TPowerSQLBuilder.Execute(var Query: TZQuery): TPowerSQLBuilder;
begin
  if Assigned( Self.FExecuteZeus ) then
    Self.FExecuteZeus( Query );

  Result := Self;
end;

function TPowerSQLBuilder.Field(const Value: TDateTime; Mask : WideString ): TPowerSQLBuilder;
begin
  if Mask = '' then
    Mask := 'yyyy.mm.dd hh:nn:ss';

  case Self.FSGDBType of
    dbPostGreSQL:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbMySQL:
    begin
      if DateOf(Value) = 0 then
        Add( QuotedStr( '0000.00.00 00:00:00' ) )
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbMsSQL:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbFireBird:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbNenhum:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
  end;

  Result := Self;
end;

function TPowerSQLBuilder.Field(const Value: Integer): TPowerSQLBuilder;
begin
  Result := Add( IntToStr( Value ) );
end;

function TPowerSQLBuilder.Field(const Value: Boolean): TPowerSQLBuilder;
begin
  case Self.FSGDBType of
    dbPostGreSQL: Add( IfThen(Value, 'true', 'false') );
    dbMySQL: Add( IfThen(Value, '1', '0') );
    dbMsSQL: Add( IfThen(Value, '1', '0') );
    dbFireBird: Add( IfThen(Value, 'true', 'false') );
    dbNenhum: Add( IfThen(Value, 'true', 'false') );
  end;

  Result := Self;
end;

function TPowerSQLBuilder.FieldFloat(const Value: Double; DecimalValue: ShortInt): TPowerSQLBuilder;
begin
  Result := Add( StringReplace(FormatFloat('#0.' + Format('%.' + IntToStr(DecimalValue) +'d', [0]), Value ),',','.',[rfReplaceAll]) );
end;

function TPowerSQLBuilder.Field(const Value: Int64): TPowerSQLBuilder;
begin
  Result := Add( IntToStr( Value ) );
end;

function TPowerSQLBuilder.FieldOfDate(const Value: TDateTime; Mask : WideString ): TPowerSQLBuilder;
begin
  if Mask = '' then
    Mask := 'yyyy.mm.dd';

  case Self.FSGDBType of
    dbPostGreSQL:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime(Mask, Value ) ) );
    end;
    dbMySQL:
    begin
      if DateOf(Value) = 0 then
        Add( QuotedStr( '0000.00.00' ) )
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbMsSQL:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime(Mask, Value ) ) );
    end;
    dbFireBird:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime(Mask, Value ) ) );
    end;
    dbNenhum:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime(Mask, Value ) ) );
    end;
  end;

  Result := Self;
end;

function TPowerSQLBuilder.FieldOfTime(const Value: TDateTime; Seconds: Boolean; Mask : WideString): TPowerSQLBuilder;
begin
  if Mask = '' then
  begin
    if Seconds then
      Mask := 'hh:mm:ss'
    else
      Mask := 'hh:mm'
  end;

  case Self.FSGDBType of
    dbPostGreSQL:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) )
    end;
    dbMySQL:
    begin
      if DateOf(Value) = 0 then
      begin
        if Seconds then
          Add( QuotedStr( '00:00:00' ) )
        else
          Add( QuotedStr( '00:00' ) )
      end
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbMsSQL:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) )
    end;
    dbFireBird:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) )
    end;
    dbNenhum:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) )
    end;
  end;

  Result := Self;
end;

function TPowerSQLBuilder.Fields(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' (').Add( Value ).EndValues;
end;

function TPowerSQLBuilder.FieldsEnd( const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add( Value ).EndValues;
end;

function TPowerSQLBuilder.FieldsInline( const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add( Value );
end;

function TPowerSQLBuilder.FieldsStart( const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' (').Add( Value );
end;

function TPowerSQLBuilder.FireBird: TPowerSQLBuilder;
begin
  Self.FSGDBType := dbFireBird;
  Result := Self;
end;

function TPowerSQLBuilder.From: TPowerSQLBuilder;
begin
  Result := Add(' from');
end;

function TPowerSQLBuilder.FullJoin: TPowerSQLBuilder;
begin
  Result := Add(' full join');
end;

function TPowerSQLBuilder.Field(const Value: WideString): TPowerSQLBuilder;
begin
  Result := AddQuoted(Value);
end;

function TPowerSQLBuilder.Field(const Value: Double; DecimalValue : ShortInt): TPowerSQLBuilder;
begin
  Result := Add( StringReplace(FormatFloat('#0.' + Format('%.' + IntToStr(DecimalValue) +'d', [0]), Value ),',','.',[rfReplaceAll]) );
end;

function TPowerSQLBuilder.GetJson(var Query: TZQuery; NameArray: WideString): WideString;
var
  SqlFreeze : WideString;
begin
  Result := '';

  if Self.FSGDBType <> dbPostGreSQL then
    Exit;

  SqlFreeze := GetString;

  if Trim(NameArray) = '' then
    NameArray := 'tabela';

  Clear;

  Add('SELECT CAST ( row_to_json ( T ) AS TEXT ) AS json  FROM ( ');
  Add('select ');
  Add('(select array_to_json(array_agg(row_to_json(a))) as json from ( ');
  Add( SqlFreeze );
  Add(') as a) as ').Add( NameArray ).Add(') AS T');

  Open( Query );

  Result := Query.FieldByName('json').AsWideString;
end;

function TPowerSQLBuilder.GetString: WideString;
begin
  Result := Self.FValuePSB.ToString;
end;

function TPowerSQLBuilder.&AND( const Value : WideString ) : TPowerSQLBuilder;
begin
  if not Self.FWhere then
  begin
    Result := Add(' where ').Add( Value );
    Self.FWhere := True;
  end
  else Result := Add(' and ').Add( Value );
end;

function TPowerSQLBuilder.Delete( const Value : WideString ) : TPowerSQLBuilder;
begin
  Result := Add('delete ').Add( Value );
end;

function TPowerSQLBuilder.DeleteFrom( const Value : WideString ) : TPowerSQLBuilder;
begin
  Result := Add('delete from ').Add( Value );
end;

function TPowerSQLBuilder.From( const Value : WideString ) : TPowerSQLBuilder;
begin
  Result := Add(' from ').Add( Value );
end;

function TPowerSQLBuilder.FullJoin( const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' full join ').Add( Value );
end;

function TPowerSQLBuilder.Group_By( const Value : WideString ) : TPowerSQLBuilder;
begin
  Result := Add(' group by ').Add( Value );
end;

function TPowerSQLBuilder.having(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' having (').Add( Value ).eP;
end;

function TPowerSQLBuilder.InnerJoin( const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' Inner Join ').Add( Value );
end;

function TPowerSQLBuilder.Insert( const Value : WideString ) : TPowerSQLBuilder;
begin
  Result := Add('insert into ').Add( Value );
end;

function TPowerSQLBuilder.LeftJoin( const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' Left Join ').Add( Value );
end;

function TPowerSQLBuilder.LeftJoin: TPowerSQLBuilder;
begin
  Result := Add(' Left Join');
end;

function TPowerSQLBuilder.Like(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' like ').AddQuoted( Trim(Value) + '%' );
end;

function TPowerSQLBuilder.Limit(const pag1, pag2: Integer): TPowerSQLBuilder;
begin
  Result := Add(' limit ').Field(pag1).Add(', ').Field(pag2);
end;

function TPowerSQLBuilder.Limit(const Value: Integer): TPowerSQLBuilder;
begin
  Result := Add(' limit ').Field(Value);
end;

function TPowerSQLBuilder.Major(const Value: Int64): TPowerSQLBuilder;
begin
  Result := Test( Value, '>');
end;

function TPowerSQLBuilder.Major(const Value: Integer): TPowerSQLBuilder;
begin
  Result := Test( Value, '>');
end;

function TPowerSQLBuilder.Major(const Value: Boolean): TPowerSQLBuilder;
begin
  Result := Test( Value, '>');
end;

function TPowerSQLBuilder.Major(const Value: Double;DecimalValue: ShortInt): TPowerSQLBuilder;
begin
  Result := Test( Value, DecimalValue, '>');
end;

function TPowerSQLBuilder.Major(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Test( Value, '>');
end;

function TPowerSQLBuilder.Major(const Value: TDateTime; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestDate( Value, '>', Mask);
end;

function TPowerSQLBuilder.MajorEqual(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Test( Value, '>=');
end;

function TPowerSQLBuilder.MajorEqual(const Value: Int64): TPowerSQLBuilder;
begin
  Result := Test( Value, '>=');
end;

function TPowerSQLBuilder.MajorEqual(const Value: Integer): TPowerSQLBuilder;
begin
  Result := Test( Value, '>=');
end;

function TPowerSQLBuilder.MajorEqual(const Value: Boolean): TPowerSQLBuilder;
begin
  Result := Test( Value, '>=');
end;

function TPowerSQLBuilder.MajorEqual(const Value: TDateTime; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestDate( Value, '>=', Mask);
end;

function TPowerSQLBuilder.MajorEqual(const Value: Double;DecimalValue: ShortInt): TPowerSQLBuilder;
begin
  Result := Test( Value, DecimalValue, '>=');
end;

function TPowerSQLBuilder.MajorEqualOfDate(const Value: TDateTime; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestOfDate( Value, '>=', Mask);
end;

function TPowerSQLBuilder.MajorEqualOfTime(const Value: TDateTime;Seconds: Boolean; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestOfTime( Value, Seconds, '>=', Mask);
end;

function TPowerSQLBuilder.MajorOfDate(const Value: TDateTime; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestOfDate( Value, '>', Mask);
end;

function TPowerSQLBuilder.MajorOfTime(const Value: TDateTime;Seconds: Boolean; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestOfTime( Value, Seconds, '>', Mask);
end;

function TPowerSQLBuilder.Max(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' max(').Add( Value ).EndValues
end;

function TPowerSQLBuilder.Min(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' min(').Add( Value ).EndValues
end;

function TPowerSQLBuilder.Minor(const Value: TDateTime; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestDate( Value, '<', Mask);
end;

function TPowerSQLBuilder.Minor(const Value: Int64): TPowerSQLBuilder;
begin
  Result := Test( Value, '<');
end;

function TPowerSQLBuilder.Minor(const Value: Boolean): TPowerSQLBuilder;
begin
  Result := Test( Value, '<');
end;

function TPowerSQLBuilder.Minor(const Value: Integer): TPowerSQLBuilder;
begin
  Result := Test( Value, '<');
end;

function TPowerSQLBuilder.Minor(const Value: Double;DecimalValue: ShortInt): TPowerSQLBuilder;
begin
  Result := Test( Value, DecimalValue, '<');
end;

function TPowerSQLBuilder.Minor(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Test( Value, '<');
end;

function TPowerSQLBuilder.MinorEqual(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Test( Value, '<=');
end;

function TPowerSQLBuilder.MinorEqual(const Value: Int64): TPowerSQLBuilder;
begin
  Result := Test( Value, '<=');
end;

function TPowerSQLBuilder.MinorEqual(const Value: Integer): TPowerSQLBuilder;
begin
  Result := Test( Value, '<=');
end;

function TPowerSQLBuilder.MinorEqual(const Value: TDateTime; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestDate( Value, '<=', Mask);
end;

function TPowerSQLBuilder.MinorEqual(const Value: Double;DecimalValue: ShortInt): TPowerSQLBuilder;
begin
  Result := Test( Value, DecimalValue, '<=');
end;

function TPowerSQLBuilder.MinorEqual(const Value: Boolean): TPowerSQLBuilder;
begin
  Result := Test( Value, '<=');
end;

function TPowerSQLBuilder.MinorEqualOfDate(const Value: TDateTime; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestOfDate( Value, '<=', Mask);
end;

function TPowerSQLBuilder.MinorEqualOfTime(const Value: TDateTime;Seconds: Boolean; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestOfTime( Value, Seconds, '<=', Mask);
end;

function TPowerSQLBuilder.MinorOfDate(const Value: TDateTime; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestOfDate( Value, '<', Mask);
end;

function TPowerSQLBuilder.MinorOfTime(const Value: TDateTime;Seconds: Boolean; Mask : WideString): TPowerSQLBuilder;
begin
  Result := TestOfTime( Value, Seconds, '<', Mask);
end;

function TPowerSQLBuilder.MSSQL: TPowerSQLBuilder;
begin
  Self.FSGDBType := dbMsSQL;
  Result := Self;
end;

function TPowerSQLBuilder.MySQL: TPowerSQLBuilder;
begin
  Self.FSGDBType := dbMySQL;
  Result := Self;
end;

function TPowerSQLBuilder.Next: TPowerSQLBuilder;
begin
  Result := Add(', ');
end;

function TPowerSQLBuilder.&OR( const Value : WideString ) : TPowerSQLBuilder;
begin
  Result := Add(' or ').Add( Value );
end;

function TPowerSQLBuilder.Order_By: TPowerSQLBuilder;
begin
  Result := Add(' order by');
end;

function TPowerSQLBuilder.&NOT( const Value : WideString ) : TPowerSQLBuilder;
begin
  Result := Add(' not ').Add( Value );
end;

function TPowerSQLBuilder.NOT_IN: TPowerSQLBuilder;
begin
  Result := Add(' not in (')
end;

function TPowerSQLBuilder.Order_By( const Value : WideString ) : TPowerSQLBuilder;
begin
  Result := Add(' order by ').Add( Value );
end;

function TPowerSQLBuilder.PostGreSQL: TPowerSQLBuilder;
begin
  Self.FSGDBType := dbPostGreSQL;
  Result := Self;
end;

function TPowerSQLBuilder.Returning(Field: WideString): TPowerSQLBuilder;
begin
  Result := Add(' returning ').Add( Field );
end;

function TPowerSQLBuilder.RightJoin: TPowerSQLBuilder;
begin
  Result := Add(' Right Join');
end;

function TPowerSQLBuilder.RightJoin( const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' Right Join ').Add( Value );
end;

function TPowerSQLBuilder.Select( const Value : WideString ) : TPowerSQLBuilder;
begin
  Result := Add('select ').Add( Value );
end;

function TPowerSQLBuilder.SelectFrom: TPowerSQLBuilder;
begin
  Result := Add('select * from');
end;

function TPowerSQLBuilder.Select: TPowerSQLBuilder;
begin
  Result := Add('select');
end;

function TPowerSQLBuilder.SelectFrom( const Value : WideString ) : TPowerSQLBuilder;
begin
  Result := Add('select * from ').Add( Value );
end;

procedure TPowerSQLBuilder.SetADO(ExecuteADOC: TExecuteAc; ExecuteADO: TExecuteA; OpenADO: TOpenA);
begin
  Self.FExecuteADOC    := ExecuteADOC;
  Self.FExecuteADO     := ExecuteADO;
  Self.FOpenADO        := OpenADO;
end;

procedure TPowerSQLBuilder.SetFireDac(ExecuteFireC: TExecuteFc; ExecuteFire: TExecuteF; OpenFire: TOpenF);
begin
  Self.FExecuteFireC   := ExecuteFireC;
  Self.FExecuteFire    := ExecuteFire;
  Self.FOpenFire       := OpenFire;
end;

procedure TPowerSQLBuilder.SetUniDac(ExecuteUniDacC: TExecuteUc; ExecuteUniDac: TExecuteU; OpenUniDac: TOpenU);
begin
  Self.FExecuteUniDacC := ExecuteUniDacC;
  Self.FExecuteUniDac  := ExecuteUniDac;
  Self.FOpenUniDac     := OpenUniDac;
end;

procedure TPowerSQLBuilder.SetZeus(ExecuteZeusC: TExecuteZc; ExecuteZeus: TExecuteZ; OpenZeus: TOpenZ);
begin
  Self.FExecuteZeusC   := ExecuteZeusC;
  Self.FExecuteZeus    := ExecuteZeus;
  Self.FOpenZeus       := OpenZeus;
end;

function TPowerSQLBuilder.sP: TPowerSQLBuilder;
begin
  Result := Add(' (')
end;

function TPowerSQLBuilder.Sum(const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' sum(').Add(Value).Add(')');
end;

function TPowerSQLBuilder.Sum: TPowerSQLBuilder;
begin
  Result := Add(' sum(');
end;

function TPowerSQLBuilder.SumAs(const Value: WideString; asValue: WideString): TPowerSQLBuilder;
begin
  Result := Add(' sum(').Add(Value).Add(') as ').Add( asValue );
end;

function TPowerSQLBuilder.Test(const Value: Int64;Condition: WideString): TPowerSQLBuilder;
begin
  Result := Add(' ').Add( Condition ).Add(' ').Add( IntToStr( Value ) );
end;

function TPowerSQLBuilder.TestDate(const Value: TDateTime;Condition: WideString; Mask : WideString): TPowerSQLBuilder;
begin
  if Mask = '' then
    Mask := 'yyyy.mm.dd hh:nn:ss';

  Add(' ').Add( Condition ).Add(' ');

  case Self.FSGDBType of
    dbPostGreSQL:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbMySQL:
    begin
      if DateOf(Value) = 0 then
        Add( QuotedStr( '0000.00.00 00:00:00' ) )
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbMsSQL:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbFireBird:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbNenhum:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
  end;

  Result := Self;
end;

function TPowerSQLBuilder.Test(const Value: Boolean;Condition: WideString): TPowerSQLBuilder;
begin
  case Self.FSGDBType of
    dbPostGreSQL: Add(' ').Add( Condition ).Add(' ').Add( IfThen(Value, 'true', 'false') );
    dbMySQL: Add(' ').Add( Condition ).Add(' ').Add( IfThen(Value, '1', '0') );
    dbMsSQL: Add(' ').Add( Condition ).Add(' ').Add( IfThen(Value, '1', '0') );
    dbFireBird: Add(' ').Add( Condition ).Add(' ').Add( IfThen(Value, 'true', 'false') );
    dbNenhum: Add(' ').Add( Condition ).Add(' ').Add( IfThen(Value, 'true', 'false') );
  end;

  Result := Self;
end;

function TPowerSQLBuilder.Test(const Value: Integer;Condition: WideString): TPowerSQLBuilder;
begin
  Result := Add(' ').Add( Condition ).Add(' ').Add( IntToStr( Value ) );
end;

function TPowerSQLBuilder.Test(const Value: WideString;Condition: WideString): TPowerSQLBuilder;
begin
  if UpperCase(Value) = 'NULL' then
    Result := Add(' ').Add( Condition ).Add(' ').Add(Value)
  else
    Result := Add(' ').Add( Condition ).Add(' ').AddQuoted(Value);
end;

function TPowerSQLBuilder.Test(const Value: Double; DecimalValue: ShortInt;Condition: WideString): TPowerSQLBuilder;
begin
  Result := Add(' ').Add( Condition ).Add(' ').Add( StringReplace(FormatFloat('#0.' + Format('%.' + IntToStr(DecimalValue) +'d', [0]), Value ),',','.',[rfReplaceAll]) );
end;

function TPowerSQLBuilder.TestOfDate(const Value: TDateTime;Condition: WideString; Mask : WideString): TPowerSQLBuilder;
begin
  if Mask = '' then
    Mask := 'yyyy.mm.dd';

  Add(' ').Add( Condition ).Add(' ');

  case Self.FSGDBType of
    dbPostGreSQL:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbMySQL:
    begin
      if DateOf(Value) = 0 then
        Add( QuotedStr( '0000.00.00 00:00:00' ) )
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbMsSQL:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbFireBird:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbNenhum:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
  end;

  Result := Self;
end;

function TPowerSQLBuilder.TestOfTime(const Value: TDateTime;Seconds: Boolean; Condition: WideString; Mask : WideString): TPowerSQLBuilder;
begin
  if Mask = '' then
  begin
    if Seconds then
      Mask := 'hh:mm:ss'
    else
      Mask := 'hh:mm';
  end;

  Add(' ').Add( Condition ).Add(' ');

  case Self.FSGDBType of
    dbPostGreSQL:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) )
    end;
    dbMySQL:
    begin
      if DateOf(Value) = 0 then
      begin
        if Seconds then
          Add( QuotedStr( '00:00:00' ) )
        else
          Add( QuotedStr( '00:00' ) )
      end
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) );
    end;
    dbMsSQL:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) )
    end;
    dbFireBird:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) )
    end;
    dbNenhum:
    begin
      if DateOf(Value) = 0 then
        Add('null')
      else
        Add( QuotedStr( FormatDateTime( Mask, Value ) ) )
    end;
  end;

  Result := Self;
end;

function TPowerSQLBuilder.Update( const Value : WideString ) : TPowerSQLBuilder;
begin
  Result := Add('update ').Add( Value ).Add(' set ');
end;

function TPowerSQLBuilder.UpField(Field: WideString; const Value: Double; DecimalValue: ShortInt): TPowerSQLBuilder;
begin
  Result := Add(' ').Add( Field ).Equal( Value, DecimalValue );
end;

function TPowerSQLBuilder.UpField(Field: WideString; const Value: WideString): TPowerSQLBuilder;
begin
  Result := Add(' ').Add( Field ).Equal( Value );
end;

function TPowerSQLBuilder.Update: TPowerSQLBuilder;
begin
  Result := Add('update');
end;

function TPowerSQLBuilder.UpField(Field: WideString; const Value: Boolean): TPowerSQLBuilder;
begin
  Result := Add(' ').Add( Field ).Equal( Value );
end;

function TPowerSQLBuilder.UpField(Field: WideString; const Value: Int64): TPowerSQLBuilder;
begin
  Result := Add(' ').Add( Field ).Equal( Value );
end;

function TPowerSQLBuilder.UpField(Field: WideString; const Value: Integer): TPowerSQLBuilder;
begin
  Result := Add(' ').Add( Field ).Equal( Value );
end;

function TPowerSQLBuilder.UpField(Field: WideString; const Value: TDateTime; Mask : WideString ): TPowerSQLBuilder;
begin
  Result := Add(' ').Add( Field ).Equal( Value, Mask );
end;

function TPowerSQLBuilder.UpFieldOfDate(Field: WideString; const Value: TDateTime; Mask : WideString ): TPowerSQLBuilder;
begin
  Result := Add(' ').Add( Field ).EqualOfDate( Value, Mask );
end;

function TPowerSQLBuilder.UpFieldOfTime(Field: WideString; const Value: TDateTime; Seconds: Boolean; Mask : WideString ): TPowerSQLBuilder;
begin
  Result := Add(' ').Add( Field ).EqualOfTime( Value, Seconds, Mask );
end;

function TPowerSQLBuilder.Values: TPowerSQLBuilder;
begin
  Result := Add(' Values (');
end;

function TPowerSQLBuilder.When(Condition: WideString): TPowerSQLBuilder;
begin
  Result := Add(' when ').Add( Condition );
end;

function TPowerSQLBuilder.When: TPowerSQLBuilder;
begin
  Result := Add(' when');
end;

function TPowerSQLBuilder.Where(const Value, Cast: WideString): TPowerSQLBuilder;
begin
  Result := Add(' where ').Cast( Value, Cast );
  Self.FWhere := True;
end;

function TPowerSQLBuilder.Where( const Value : WideString ) : TPowerSQLBuilder;
begin
  Result := Add(' where ').Add( Value );
  Self.FWhere := True;
end;

function TPowerSQLBuilder.Delete: TPowerSQLBuilder;
begin
  Result := Add('delete');
end;

function TPowerSQLBuilder.DeleteFrom: TPowerSQLBuilder;
begin
  Result := Add('delete from');
end;

function TPowerSQLBuilder.Execute( var Connection: TUniConnection): TPowerSQLBuilder;
begin
  if Assigned( Self.FExecuteUniDacC ) then
    Self.FExecuteUniDacC( Connection );

  Result := Self
end;

function TPowerSQLBuilder.Execute(var Query: TUniQuery): TPowerSQLBuilder;
begin
  if Assigned( Self.FExecuteUniDac ) then
    Self.FExecuteUniDac( Query );

  Result := Self;
end;

function TPowerSQLBuilder.Open(var query: TUniQuery): TPowerSQLBuilder;
begin
  if Assigned( Self.FOpenUniDac ) then
    Self.FOpenUniDac( Query );

  Result := Self;
end;

end.
