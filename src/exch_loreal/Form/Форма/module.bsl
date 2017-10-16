﻿Перем СтарНачПериода, СтарКонПериода;

Процедура ПриОткрытии()
	НачПериода = НачалоДня(ОбщиеФункции.ДобавитьДень(ТекущаяДата(),-2));
	КонПериода = НачалоДня(ОбщиеФункции.ДобавитьДень(ТекущаяДата(),-1));
	СтарНачПериода = НачПериода;
	СтарКонПериода = КонПериода;
	ЭтоМесячныйОтчет = Ложь;
	ЭтоКорректировка = Истина;
	ВыгружатьНаFTP = Истина;
	фВыгружатьПоступления = Истина;
	фВыгружатьРеализацию = Истина;
	фВыгружатьОстатки = Истина;
	
	УстановитьДоступностьЭлементовУправления();
КонецПроцедуры

Процедура ОткрытьФормуУстановкиСоответствий(Кнопка)
	Форма = ПолучитьФорму("УстановкаСоответствий");
	Форма.ОткрытьМодально();
КонецПроцедуры

Процедура пвПериодПриИзменении(Элемент)
	СтарНачПериода = НачПериода;
	СтарКонПериода = КонПериода;
	фЭтоМесячныйОтчет = Ложь;
КонецПроцедуры

Процедура флПриИзменении(Элемент)
	УстановитьДоступностьЭлементовУправления();
КонецПроцедуры

Процедура УстановитьДоступностьЭлементовУправления()
	
	Если фЭтоМесячныйОтчет Тогда
		НачПериода = НачалоМесяца(НачПериода);
		//НачПериода = НачалоМесяца(ДобавитьМесяц(НачПериода,-1));
		КонПериода = НачалоДня(КонецМесяца(НачПериода));
	Иначе
		НачПериода = СтарНачПериода;
		КонПериода = СтарКонПериода;
	КонецЕсли;
	
	ЭлементыФормы.ндВыбКаталог.Доступность = НЕ фВыгружатьНаFTP;
	ЭлементыФормы.пвВыбКаталог.Доступность = НЕ фВыгружатьНаFTP;
	ЭлементыФормы.ндГУИДСообщения.Доступность = фЭтоКоррекция;
	ЭлементыФормы.пвГУИДСообщения.Доступность = фЭтоКоррекция;
	
КонецПроцедуры

Процедура ВыбКаталогНачалоВыбора(Элемент, СтандартнаяОбработка)
	ВыборФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	ВыборФайла.Каталог = фВыбКаталог;
	
	Если Не ВыборФайла.Выбрать() Тогда
		Возврат;		
	КонецЕсли;
	
	фВыбКаталог = ВыборФайла.Каталог;
КонецПроцедуры

Процедура КнопкаВыполнитьНажатие(Кнопка)
	Если ЗначениеЗаполнено(фВыбКаталог) ИЛИ фВыгружатьНаFTP Тогда
		Если ЗначениеЗаполнено(НачПериода) И ЗначениеЗаполнено(КонПериода) Тогда
			ОбработкаОбъект.МесячнаяВыгрузка = фЭтоМесячныйОтчет;
			ОбработкаОбъект.ЭтоКоррекция = фЭтоКоррекция;
			СписокИсключаемых = Новый СписокЗначений;
			
			Если фЭтоКоррекция Тогда
				ОбработкаОбъект.СтарыйГУИД = СокрЛП(фГУИДСтрокой);
				Если НЕ ЗначениеЗаполнено(ОбработкаОбъект.СтарыйГУИД) Тогда
					Сообщить("Не указан УИД предыдущей выгрузки! Выгрузка отменена.");
				КонецЕсли;
			Иначе
				ОбработкаОбъект.СтарыйГУИД = "";
			КонецЕсли;
			
			Если НЕ фВыгружатьПоступления Тогда
				СписокИсключаемых.Добавить("INVOICIN");
			КонецЕсли;
			Если НЕ фВыгружатьРеализацию Тогда
				СписокИсключаемых.Добавить("INVOIC");
			КонецЕсли;
			Если НЕ фВыгружатьОстатки Тогда
				СписокИсключаемых.Добавить("INVRPT");
			КонецЕсли;
			ВыгрузитьОтчеты(фВыгружатьНаFTP,?(фВыгружатьНаFTP,Неопределено,фВыбКаталог),СписокИсключаемых);
		Иначе
			Сообщить("Не указаны дата начала или окончания периода выгрузки! Выгрузка отменена.");
		КонецЕсли;
	Иначе
		Сообщить("Выберите каталог для выгрузки! Выгрузка отменена.");
	КонецЕсли;
КонецПроцедуры









