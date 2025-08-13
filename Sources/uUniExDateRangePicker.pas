unit uUniExDateRangePicker;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, uniGUIBaseClasses,
  uniGUIApplication, uniGUIClasses, uniEdit, uniGUITypes, uniGUIServer;

type
  TOpensOption = (ooLeft, ooRight, ooCenter);
  TDropsOption = (doDown, doUp, doAuto);

  // Новый класс для параметров Date Range Picker
  TUniExDatePickerOptions = class(TPersistent)
  private
    FAlwaysShowCalendars: Boolean;
    FShowWeekNumbers: Boolean;
    FShowISOWeekNumbers: Boolean;
    FLinkedCalendars: Boolean;
    FAutoUpdateInput: Boolean;
    FShowCustomRangeLabel: Boolean;
    FShowDropdowns: Boolean;
    /// <remarks>
    ///  Определяет, будет ли элемент выбора выровнен по левому краю, по правому краю или по центру относительно HTML-элемента, к которому он прикреплен.
    /// </remarks>
    FOpens: TOpensOption;
    /// <remarks>
    /// Определяет, будет ли отображаться средство выбора ниже (по умолчанию) или выше элемента HTML, к которому оно прикреплено.
    /// </remarks>
    FDrops: TDropsOption;
    FRanges: TStringList;
    FRangesEnabled: Boolean;
    procedure SetOpens(const Value: TOpensOption);
    function GetOpensAsString: string;
    procedure SetDrops(const Value: TDropsOption);
    function GetDropsAsString: string;
    procedure SetRanges(const Value: TStringList);
    function GetRangesAsJavaScript: string;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property AlwaysShowCalendars: Boolean read FAlwaysShowCalendars write FAlwaysShowCalendars default True;
    property ShowWeekNumbers: Boolean read FShowWeekNumbers write FShowWeekNumbers default True;
    property ShowISOWeekNumbers: Boolean read FShowISOWeekNumbers write FShowISOWeekNumbers default True;
    property LinkedCalendars: Boolean read FLinkedCalendars write FLinkedCalendars default True;
    property AutoUpdateInput: Boolean read FAutoUpdateInput write FAutoUpdateInput default True;
    property ShowCustomRangeLabel: Boolean read FShowCustomRangeLabel write FShowCustomRangeLabel default False;
    property ShowDropdowns: Boolean read FShowDropdowns write FShowDropdowns default True;
    property Opens: TOpensOption read FOpens write SetOpens default ooLeft;
    property Drops: TDropsOption read FDrops write SetDrops default doAuto;
    property RangesEnabled: Boolean read FRangesEnabled write FRangesEnabled default False;
    property Ranges: TStringList read FRanges write SetRanges;
  end;

  /// <summary>
  /// https://www.daterangepicker.com/#examples
  /// Компонент для выбора диапазонов дат, дат и времени
  /// </summary>
  TUniDateRangePicker = class(TUniEdit)
  private
    FDateFormat: string;
    FStartDate: TDateTime;
    FEndDate: TDateTime;
    FDatePickerOptions: TUniExDatePickerOptions;
    FIsLoaded: Boolean;

    procedure SetEndDate(const Value: TDateTime);
    procedure SetStartDate(const Value: TDateTime);

  protected
   procedure LoadCompleted; override;
   procedure JSEventHandler(AEventName: string; AParams: TUniStrings); override;
   procedure DoHandleTriggerClick(const AButtonId: Integer); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    /// <summary>
    /// ClearDateRange - Очистит поле ввода
    /// </summary>
    procedure ClearDateRange;

    function GetFormattedDate: string;
  published

    property DateFormat: string read FDateFormat write FDateFormat;
    /// <summary>
    /// DateStart - Дата начала периода
    /// </summary>
    property DateStart: TDateTime read FStartDate write SetStartDate;
    /// <summary>
    /// DateEnd - Дата конца периода
    /// </summary>
    property DateEnd: TDateTime read FEndDate write SetEndDate;

    property DatePickerOptions: TUniExDatePickerOptions read FDatePickerOptions write FDatePickerOptions;

    property Text;
    property Alignment;
    property Font;
    property Color;
    property ReadOnly;
    property OnChange;
    property OnAjaxEvent;
    property OnTriggerEvent;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('UniExt', [TUniDateRangePicker]);
end;

{ TDatePickerOptions }

constructor TUniExDatePickerOptions.Create;
begin
  FAlwaysShowCalendars := True;
  FShowWeekNumbers     := True;
  FShowISOWeekNumbers  := True;
  FLinkedCalendars     := True;
  FAutoUpdateInput     := True;
  FShowCustomRangeLabel:= False;
  FShowDropdowns       := True;
  FOpens :=  ooLeft;
  FDrops := doAuto;
  FRangesEnabled:=False;


  FRanges := TStringList.Create;
  FRanges.Add('Сегодня=[moment(), moment()]');
  FRanges.Add('Вчера=[moment().subtract(1, "days"), moment().subtract(1, "days")]');
  FRanges.Add('Последние 7 дней=[moment().subtract(6, "days"), moment()]');
  FRanges.Add('Последние 30 дней=[moment().subtract(29, "days"), moment()]');
  FRanges.Add('Этот месяц=[moment().startOf("month"), moment().endOf("month")]');
  FRanges.Add('Прошлый месяц=[moment().subtract(1, "month").startOf("month"), moment().subtract(1, "month").endOf("month")]');
end;

procedure TUniExDatePickerOptions.SetDrops(const Value: TDropsOption);
begin
  FDrops := Value;
end;

destructor TUniExDatePickerOptions.Destroy;
begin
  FRanges.Free;
  inherited;
end;

function TUniExDatePickerOptions.GetDropsAsString: string;
begin
  case FDrops of
    doDown: Result := 'down';
    doUp: Result   := 'up';
    doAuto: Result := 'auto';
  else
    Result := 'auto'; // Значение по умолчанию
  end;
end;

procedure TUniExDatePickerOptions.SetOpens(const Value: TOpensOption);
begin
  FOpens := Value;
end;

procedure TUniExDatePickerOptions.SetRanges(const Value: TStringList);
begin
   FRanges.Assign(Value);
end;

function TUniExDatePickerOptions.GetOpensAsString: string;
begin
  case FOpens of
    ooLeft: Result := 'left';
    ooRight: Result := 'right';
    ooCenter: Result := 'center';
  else
    Result := 'center'; // Значение по умолчанию
  end;
end;

function TUniExDatePickerOptions.GetRangesAsJavaScript: string;
var
  i: Integer;
  RangeItem: string;
begin
  if FRangesEnabled then
  begin
    Result := ' ranges: { ';
    for i := 0 to FRanges.Count - 1 do
    begin
      RangeItem := FRanges.Names[i];
      Result := Result + '"' + RangeItem + '": ' + FRanges.ValueFromIndex[i] + ', ';
    end;
    Result := Copy(Result, 1, Length(Result) - 2) + ' },'; // Убираем последнюю запятую и пробел
  end
  else
    Result:='';
end;

{ TUniDateRangePicker }

constructor TUniDateRangePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Width := 160;

  FStartDate := 0;
  FEndDate := 0;

  FDatePickerOptions := TUniExDatePickerOptions.Create;
  FDateFormat := 'DD/MM/YYYY';

  // Добавляем триггер
  Triggers.Add;
  Triggers[0].IconCls := 'x-form-clear-trigger'; // Иконка триггера (например, троеточие)
  Triggers[0].HandleClicks := True;


  Triggers.Add;
  Triggers[1].IconCls := 'x-form-date-trigger';
  Triggers[1].HandleClicks := True;
end;

destructor TUniDateRangePicker.Destroy;
begin
  FDatePickerOptions.Free;
  inherited;
end;

procedure TUniDateRangePicker.JSEventHandler(AEventName: string;
  AParams: TUniStrings);
begin
  inherited;

  if AEventName = 'select' then
  begin
    // Обработка выбора диапазона дат, когда меняюся даты
    try
      FStartDate := StrToDate(AParams.Values['start']);
      FEndDate := StrToDate(AParams.Values['end']);
    except
     // on E: Exception do
        //('Ошибка обработки события select: ' + E.Message);
    end;
  end
  else
  if AEventName = 'apply' then
  begin
    // Обработка выбора диапазона дат, когда меняюся даты
    try
      FStartDate := StrToDate(AParams.Values['start']);
      FEndDate := StrToDate(AParams.Values['end']);
    except
     // on E: Exception do
        //('Ошибка обработки события select: ' + E.Message);
    end;
  end
  else
  if AEventName = 'cancel' then // Обработка отмены выбора
  begin
    ClearDateRange; // Очистка диапазона дат
  end
  else
  if AEventName = 'trgclick' then
  begin
    DoHandleTriggerClick(StrToIntDef(AParams.Values['id'], -1)); // Обработка клика по триггеру
  end;
end;

procedure TUniDateRangePicker.DoHandleTriggerClick(const AButtonId: Integer);
begin
  if AButtonId = 0 then
  begin
    ClearDateRange;
  end
  else
  if AButtonId = 1 then
  begin
    UniSession.AddJS('$(function() { $("input[name=' + QuotedStr(self.JSName) + ']").data("daterangepicker").show(); });');
  end;
end;

procedure TUniDateRangePicker.ClearDateRange;
begin
  Clear;

  FStartDate := 0;
  FEndDate := 0;

  UniSession.AddJS(
  Format(
     '''
       $(function() {
       $("input[name='%s']").val("");
       });
     ''', [self.jsName]));
end;

procedure TUniDateRangePicker.LoadCompleted;
var _JSName, JSRanges : string;
begin
  inherited;

  if WebMode then
  begin
    _JSName := Self.JSName;
    JSRanges := FDatePickerOptions.GetRangesAsJavaScript;

    JSInterface.JSAdd(
      '$(function() {' +
      '   var input = $("input[name=''' + _JSName + ''']").daterangepicker({' +
      '      alwaysShowCalendars: ' + BoolToStr(FDatePickerOptions.AlwaysShowCalendars, True).ToLower + ',' +
      '      showWeekNumbers: ' + BoolToStr(FDatePickerOptions.ShowWeekNumbers,True).ToLower  + ',' +
      '      showISOWeekNumbers: ' + BoolToStr(FDatePickerOptions.ShowISOWeekNumbers,True).ToLower  + ',' +
      '      linkedCalendars: ' + BoolToStr(FDatePickerOptions.LinkedCalendars,True).ToLower + ',' +
      '      autoUpdateInput: ' +BoolToStr( FDatePickerOptions.AutoUpdateInput,True).ToLower  + ',' +
      '      showCustomRangeLabel: ' + BoolToStr(FDatePickerOptions.ShowCustomRangeLabel,True).ToLower  + ',' +
      '      showDropdowns: ' + BoolToStr(FDatePickerOptions.ShowDropdowns,True).ToLower  + ',' +
      '      opens: "' + FDatePickerOptions.GetOpensAsString + '",' +
      '      drops: "' + FDatePickerOptions.GetDropsAsString + '",' +
       JSRanges +
      '      locale: {' +
      '          format: "' + FDateFormat + '",' +
      '          separator: "-",' +
      '          applyLabel: "Применить",' +
      '          cancelLabel: "Очистить",' +
      '          fromLabel: "From",' +
      '          toLabel: "To",' +
      '          customRangeLabel: "Custom",' +
      '          weekLabel: "Н",' +
      '          daysOfWeek: ["Вс","Пн","Вт","Ср","Чт","Пт","Сб"],' +
      '          monthNames: ["Январь","Февраль","Март","Апрель","Май","Июнь","Июль","Август","Сентябрь","Октябрь","Ноябрь","Декабрь"],' +
      '          firstDay: 1' +
      '      }' +

      '   }, function(start, end, label) {' +
      '       ajaxRequest(' + _JSName + ', "select", ["Start=" + start.format("DDMMYYYY"), "End=" + end.format("DDMMYYYY")]);' +
      '   });' +

      '   $(''input[name="' + _JSName + '"]'').on("apply.daterangepicker", function(ev, picker) {' +
      '       $(this).val(picker.startDate.format("DD/MM/YYYY") + "-" + picker.endDate.format("DD/MM/YYYY"));' +
      '       ajaxRequest(' + _JSName +  ', "apply", ["Start=" + picker.startDate.format("DDMMYYYY"), "End=" + picker.endDate.format("DDMMYYYY")]);' +
      '   });' +

      '   $(''input[name="' + _JSName + '"]'').on("cancel.daterangepicker", function(ev, picker) {' +
      '       ajaxRequest(' + _JSName + ', "cancel", [""]);' +
      '   });' +

      '});'
    );

    FIsLoaded:=True;

    ClearDateRange;
  end;
end;

procedure TUniDateRangePicker.SetEndDate(const Value: TDateTime);
begin
  if FEndDate <> Value then
  begin
    FEndDate := Value;
    if FIsLoaded then
      UniSession.AddJS(Format(
      '''
        $(function() {
        console.info('ty');
        $("input[name='%s']").data("daterangepicker").setEndDate('%s');
        });
      ''', [jsName, FormatDateTime(FDateFormat, Value)]));
  end;
end;

procedure TUniDateRangePicker.SetStartDate(const Value: TDateTime);
begin
  if FStartDate <> Value then
  begin
    FStartDate := Value;
    if FIsLoaded then
      UniSession.AddJS(Format(
      '''
        $(function() {
        $("input[name='%s']").data("daterangepicker").setStartDate('%s');
        });
      ''', [jsName, FormatDateTime(FDateFormat, Value)]));
  end;
end;

function TUniDateRangePicker.GetFormattedDate: string;
begin
  // Возвращает форматированную строку даты
  Result := FormatDateTime(FDateFormat, FStartDate) + '-' + FormatDateTime(FDateFormat, FEndDate);
end;

initialization
  UniAddJSLibrary('daterangepicker/moment.min.js', False, [upoFolderUni, upoPlatformBoth]);
  UniAddJSLibrary('daterangepicker/daterangepicker.js', False, [upoFolderUni, upoPlatformBoth]);
  UniAddCSSLibrary('daterangepicker/daterangepicker.css', False, [upoFolderUni, upoPlatformBoth]);
end.

