﻿
Перем ИдентификаторФонЗадания;

Процедура ОсновныеДействияФормыВыполнитьВыгрузкуСправочников(Кнопка)
	
	Если НЕ Кластер.ЯвляетсяВладельцемЗапасов Тогда
		Сообщить(ОбщиеФункции._СтрШаблон_("Операция прервана по причине: '%1' не является владельцем запасов в WMS.", Кластер), СтатусСообщения.Внимание);
		Возврат;
	КонецЕсли; 
	
	//ВладелецФормы.ОбработкаОбъект.СоздатьЗаявкиПоПервичкеДляТранзита(Кластер);
	МассивПараметров = Новый Массив;
	МассивПараметров.Добавить(Кластер);
	
	ФонЗадание = ФоновыеЗадания.Выполнить("Обмен_1С_Транзит.СоздатьЗаявкиПоПервичкеДляТранзита", МассивПараметров, "Обмен_1С_Транзит.СоздатьЗаявкиПоПервичкеДляТранзита");
	ИдентификаторФонЗадания = ФонЗадание.УникальныйИдентификатор;
	
	ПодключитьОбработчикОжидания("ОбновитьИнфо", 1, Истина);
	
КонецПроцедуры

Процедура ОбновитьИнфо()
	
	ФонЗадание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторФонЗадания);
	
	Если ФонЗадание.Состояние = СостояниеФоновогоЗадания.Активно Тогда
		МассивСообщений = ФонЗадание.ПолучитьСообщенияПользователю(Истина);
		Для каждого ЭлМассива Из МассивСообщений Цикл
			Если Найти(ЭлМассива.Текст, "#!") > 0 Тогда
				Сообщить(ОбщиеФункции._СтрШаблон_("%1 | %2", ТекущаяДата(), СтрЗаменить(ЭлМассива.Текст, "#!", "")), СтатусСообщения.Информация);
			КонецЕсли; 
		КонецЦикла; 
		ПодключитьОбработчикОжидания("ОбновитьИнфо", 15, Истина);
	ИначеЕсли ФонЗадание.Состояние = СостояниеФоновогоЗадания.ЗавершеноАварийно Тогда 	
		Сообщить(ОбщиеФункции._СтрШаблон_("Операция завершена аварийно по причине: %1", ФонЗадание.ИнформацияОбОшибке.Описание));
	ИначеЕсли ФонЗадание.Состояние = СостояниеФоновогоЗадания.Отменено Тогда 
		Сообщить(ОбщиеФункции._СтрШаблон_("Операция отменена пользователем: %1", ФонЗадание.ИнформацияОбОшибке.Описание));
	ИначеЕсли ФонЗадание.Состояние = СостояниеФоновогоЗадания.Завершено Тогда 
		МассивСообщений = ФонЗадание.ПолучитьСообщенияПользователю(Истина);
		Для каждого ЭлМассива Из МассивСообщений Цикл
			Если Найти(ЭлМассива.Текст, "#!") > 0 Тогда
				Сообщить(ОбщиеФункции._СтрШаблон_("%1 | %2", ТекущаяДата(), СтрЗаменить(ЭлМассива.Текст, "#!", "")), СтатусСообщения.Информация);
			КонецЕсли; 
		КонецЦикла; 
		Сообщить("Операция завершена", СтатусСообщения.Информация);	
	КонецЕсли; 
	
КонецПроцедуры
 
