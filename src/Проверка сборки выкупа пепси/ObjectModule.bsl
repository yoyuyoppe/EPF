﻿
#Область ОписаниеПеременных

Перем Выкуп, ОтгрузкаПоВыкупу, Склад;

#КонецОбласти

#Область ПрограммныйИнтерфейс

Функция ПроверитьСборкуВыкупаПепси(ОтборВыкупа, СобранныеМарки) Экспорт 
	
	
	
КонецФункции  

Процедура ЗавершитьСборку(ВыкупТовараСХранения) Экспорт 	
	
	Выкуп = ВыкупТовараСХранения;
	
	ОтгрузкаПоВыкупу = НайтиОтгрузкуНаВыкуп();
	
	СобранныеМарки = НайтиСобранныеМаркиПоВыкупу();
	
	ОтборВыкупа = НайтиОтборВыкупа();
	
	ПеренестиМаркиВОтбор(ОтборВыкупа, СобранныеМарки);
	
	//ToDo: здесь надо будет проверить, есть ли расхождения между планом и фактом по позициям с ПУ
	// Если есть расхождения, то обновить факт в отборе, перезаполнить РСО, ПСО, ПТУ
	ПроверитьСборкуВыкупаПепси(ОтборВыкупа, СобранныеМарки);
	
	СоздатьЗаявкуНаОтправкуМарокВUtrace(ОтборВыкупа);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция КонтрагентНаВыкуп()
	
	Контрагент = Справочники.Контрагенты.ПустаяСсылка();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	ДополнительныеРеквизиты_3PL.Значение КАК Значение
		|ИЗ
		|	РегистрСведений.ДополнительныеРеквизиты_3PL КАК ДополнительныеРеквизиты_3PL
		|ГДЕ
		|	ДополнительныеРеквизиты_3PL.Свойство = ""КонтрагентНаВыкуп""";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		Контрагент = ВыборкаДетальныеЗаписи.Значение;
	КонецЕсли;
	
	Возврат Контрагент;

КонецФункции

Функция НайтиСобранныеМаркиПоВыкупу()
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Выкуп);
	Запрос.УстановитьПараметр("ОтгрузкаНаВыкуп", НайтиОтгрузкуНаВыкуп()); 
	Запрос.Текст = "ВЫБРАТЬ
	|	&ОтгрузкаНаВыкуп КАК ЗаказНаОтгрузку,
	|	КодыМаркировки.КодМаркировки КАК КодМаркировки,
	|	КодыМаркировки.Номенклатура,
	|	КодыМаркировки.КодМаркировкиИсходный,
	|	КодыМаркировки.СтатусОшибки
	|ИЗ
	|	Документ.ВыкупТовараСХранения.ДокументыОснования КАК ВыкупТовараСХраненияДокументыОснования
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ОтборЗапасовНаСкладе.ЗаказыНаОтгрузку КАК ОтборыЗапасов
	|		ПО ВыкупТовараСХраненияДокументыОснования.ОтгрузкаТоваровУслуг = ОтборыЗапасов.ЗаказНаОтгрузку
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ОтборЗапасовНаСкладе.КодыМаркировки КАК КодыМаркировки
	|		ПО (ОтборыЗапасов.Ссылка = КодыМаркировки.Ссылка)
	|ГДЕ
	|	ВыкупТовараСХраненияДокументыОснования.Ссылка = &Ссылка";
	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	Возврат РезультатЗапроса;
	
КонецФункции

Функция НайтиОтгрузкуНаВыкуп()
	
	ДатаВыкупа = Выкуп.Дата;
	Склад = Выкуп.Склад;
	ОтгрузкаНаВыкуп = Документы.ОтгрузкаТоваровУслуг.ПустаяСсылка();
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("НачДата", НачалоДня(ДатаВыкупа)); 
	Запрос.УстановитьПараметр("КонДата", КонецДня(ДатаВыкупа));
	Запрос.УстановитьПараметр("ДатаВыкупа", ДатаВыкупа);
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("КонтрагентНаВыкуп", КонтрагентНаВыкуп());
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	|	ОТУ.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.ОтгрузкаТоваровУслуг КАК ОТУ
	|ГДЕ
	|	ОТУ.Дата МЕЖДУ &НачДата И &КонДата
	|	И ОТУ.Дата > &ДатаВыкупа
	|	И ОТУ.Склад = &Склад
	|	И ОТУ.Контрагент = &КонтрагентНаВыкуп
	|	И ОТУ.Проведен
	|
	|УПОРЯДОЧИТЬ ПО
	|	ОТУ.Дата УБЫВ";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		ОтгрузкаНаВыкуп = Выборка.Ссылка;
	КонецЕсли;
	
	Возврат ОтгрузкаНаВыкуп;
	
КонецФункции

Функция НайтиОтборВыкупа()
	
	ОтборВыкупа = Документы.ОтборЗапасовНаСкладе.ПустаяСсылка();
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ОтгрузкаНаВыкуп", ОтгрузкаПоВыкупу); 
	Запрос.Текст = "ВЫБРАТЬ
	|	ДокументыПоОтгрузкеТоваровУслуг.Ссылка КАК Ссылка
	|ИЗ
	|	КритерийОтбора.ДокументыПоОтгрузкеТоваровУслуг(&ОтгрузкаНаВыкуп) КАК ДокументыПоОтгрузкеТоваровУслуг
	|ГДЕ
	|	ТИПЗНАЧЕНИЯ(ДокументыПоОтгрузкеТоваровУслуг.Ссылка) = ТИП(Документ.ОтборЗапасовНаСкладе)";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		ОтборВыкупа = Выборка.Ссылка;
	КонецЕсли; 
	
	Возврат ОтборВыкупа;
	
КонецФункции

Функция ИсточникПриемникЗаявки()
	
	ДляЗаполнения = Новый Структура("Источник, Приемник", "", "");
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Склад", Склад); 
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1 Объект ИЗ РегистрСведений.ДополнительныеРеквизиты_3PL ГДЕ Значение = &Склад";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		ТекФилиал = СтрПолучитьСтроку(СтрЗаменить(Строка(Выборка.Объект), "_", Символы.ПС),3);	
		ДляЗаполнения.Источник = "1С_КМ_" + ТекФилиал;
		ДляЗаполнения.Приемник = "Utrace_" + ТекФилиал;
	КонецЕсли;
	
	Возврат ДляЗаполнения;
		
КонецФункции

Процедура СоздатьЗаявкуНаОтправкуМарокВUtrace(ОтборСсылка)
	
	Если НЕ ЗначениеЗаполнено(ОтборСсылка) Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ОтборСсылка.КодыМаркировки) Тогда
		Возврат;
	КонецЕсли;
	
	ИсточникПриемник = ИсточникПриемникЗаявки();
	
	Если ЗначениеЗаполнено(ИсточникПриемник.Источник)
		И ЗначениеЗаполнено(ИсточникПриемник.Приемник) Тогда
		_3PLСервер.ДобавитьЗаписьПоДокументуВЖурналОпераций(ОтборСсылка, ИсточникПриемник.Источник, ИсточникПриемник.Приемник, Справочники.СтатусыЗаявок.Новая, "");		
	Иначе
		ТекстСообщения = СтрШаблон("Не удалось создать заявку для Utrace по документу '%1', т.к не найдены источник и приемник по причине: 
		|по складу '%2' в выкупе '%3' не найден партнер в РС.ДополнительныеРеквизиты_3PL");
		Сообщить(ТекстСообщения, СтатусСообщения.ОченьВажное);
	КонецЕсли; 
	
КонецПроцедуры

Процедура ПеренестиМаркиВОтбор(ОтборСсылка, КодыМаркировки)
	
	Если НЕ ЗначениеЗаполнено(ОтборСсылка) Тогда
		Сообщить("Не найден отбор по выкупу", СтатусСообщения.ОченьВажное);
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(КодыМаркировки) Тогда
		Сообщить("Не найдены отобранные марки", СтатусСообщения.ОченьВажное);
		Возврат;
	КонецЕсли; 
	
	Попытка
		ОтборОбъект = ОтборСсылка.ПолучитьОбъект();
		ОтборОбъект.КодыМаркировки.Загрузить(КодыМаркировки);
		ОтборОбъект.Записать(РежимЗаписиДокумента.Запись);
	Исключение
		ВызватьИсключение "Не удалось перенести марки в отбор " + ОтборСсылка;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти


