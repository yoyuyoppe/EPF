﻿#Область ОбработчикиСобытийФормы

Процедура ПередОткрытием(Отказ, СтандартнаяОбработка)
	
	ОбновитьПолеТабличногоДокумента();
		
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

Процедура РезультатСверкиВыбор(Элемент, Область, СтандартнаяОбработка)
	
	Если Не Область.Расшифровка = Неопределено 
		И ТипЗнч(Область.Расшифровка) = Тип("Структура")
		И Не Область.Расшифровка.Свойство("Команда", "ПометитьНаУдаление") = Неопределено
		И Не Область.Расшифровка.Свойство("ДокументСсылка") = Неопределено
		И ЗначениеЗаполнено(Область.Расшифровка.ДокументСсылка) Тогда
		
		СтандартнаяОбработка = Ложь;
		ДокументОбъект = Область.Расшифровка.ДокументСсылка.ПолучитьОбъект();
		
		Попытка
			ДокументОбъект.УстановитьПометкуУдаления(Истина);
			Сообщить("Документ " + ДокументОбъект.Ссылка + " помечен на удаление!");
			ОбновитьПолеТабличногоДокумента();
		Исключение
			Сообщить("Не удалось установить пометку удаления документа " + ДокументОбъект.Ссылка + " !");
		КонецПопытки;
		
	КонецЕсли;
		
КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОбновитьПолеТабличногоДокумента()
	
	Запрос = Новый Запрос;
	Запрос.Текст = ПолучитьТекстЗапросаСверка();
	Запрос.УстановитьПараметр("Источник", Строка(Партнер));
	Запрос.УстановитьПараметр("тзСверка", ТаблицаДанныхДляСверки);
	Запрос.УстановитьПараметр("ДатаПоставки", КонецПериода);
	Запрос.УстановитьПараметр("ДатаЗаписи", НачалоДня(ТекущаяДатаСеанса()));
	//Запрос.УстановитьПараметр("ДатаЗаписи", Дата('20220502')); // для отладки
	Запрос.УстановитьПараметр("КонтрагентНаВыкуп", СвойстваПартнера.КонтрагентНаВыкуп);
	Запрос.УстановитьПараметр("Свойство_НомерВходящегоДокумента", ПланыВидовХарактеристик.СвойстваОбъектов.ПолучитьСвойствоПоИмени("НомерВходящегоДокумента"));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Макет = ПолучитьМакет("СверкаПоставок");
	ОбластьЗаголовок 		= Макет.ПолучитьОбласть("Заголовок");
	ОбластьШапкаТаблицы 	= Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьДетальныхЗаписей = Макет.ПолучитьОбласть("Детали");
	ОбластьДетальныхЗаписейПометка = Макет.ПолучитьОбласть("ДеталиПометка");
	ОбластьДетальныхЗаписейЗагрузка = Макет.ПолучитьОбласть("ДеталиЗагрузка");
	
	ТабДок = ЭлементыФормы.РезультатСверки;
	
	ТабДок.Очистить();
	
	ОбластьЗаголовок.Параметры.ТекущаяДата = Формат(ТекущаяДатаСеанса(), "ДФ=dd.MM.yyyy");
	ТабДок.Вывести(ОбластьЗаголовок);
	ТабДок.Вывести(ОбластьШапкаТаблицы);
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
				
		Если ВыборкаДетальныеЗаписи.Действие ="Пометить на удаление" Тогда
			ВыводимаяОбласть = ОбластьДетальныхЗаписейПометка;
			СтруктураКоманды = Новый Структура;
			СтруктураКоманды.Вставить("Команда", "ПометитьНаУдаление");
			СтруктураКоманды.Вставить("ДокументСсылка", ВыборкаДетальныеЗаписи.Документ);
			ВыводимаяОбласть.Параметры.СтруктураКоманды = СтруктураКоманды;
			
			Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.Документ) И ВыборкаДетальныеЗаписи.Документ.ПометкаУдаления Тогда
				ОбластьДетальныхЗаписейПометка.Область("R1C5").ЦветФона = WebЦвета.СветлоРозовый;
			Иначе
				ОбластьДетальныхЗаписейПометка.Область("R1C5").ЦветФона = Новый Цвет(-1, -1, -1);
			КонецЕсли;

		ИначеЕсли ВыборкаДетальныеЗаписи.Действие ="Загрузить" Тогда
			ВыводимаяОбласть = ОбластьДетальныхЗаписейЗагрузка;
		Иначе
			ВыводимаяОбласть = ОбластьДетальныхЗаписей;
		КонецЕсли;
		
		ВыводимаяОбласть.Параметры.Заполнить(ВыборкаДетальныеЗаписи);
				
		ТабДок.Вывести(ВыводимаяОбласть, ВыборкаДетальныеЗаписи.Уровень());
		
	КонецЦикла;
	
	ТабДок.ТолькоПросмотр = Истина;
	ТабДок.ОтображатьСетку = Ложь;
	ТабДок.ФиксацияСверху = 4;

КонецПроцедуры

Функция ПолучитьТекстЗапросаСверка()
	
	Возврат
	"ВЫБРАТЬ
	|	влЗапрос.Объект КАК ДокументСсылка,
	|	СвойстваОбъектов.Значение КАК НомерПоклажедателя,
	|	ВЫБОР
	|		КОГДА ТИПЗНАЧЕНИЯ(влЗапрос.Объект) = ТИП(Документ.ОтгрузкаТоваровУслуг)
	|			ТОГДА влЗапрос.Объект.ДатаОтгрузки
	|		ИНАЧЕ влЗапрос.Объект.Дата
	|	КОНЕЦ КАК ДатаОтгрузки
	|ПОМЕСТИТЬ втОтгрузкаТоваровУслугНаТекДату
	|ИЗ
	|	(ВЫБРАТЬ
	|		ЖурналРегистрацииСостоянийЗаявокНаОформлениеОпераций.Объект КАК Объект
	|	ИЗ
	|		РегистрСведений.ЖурналРегистрацииСостоянийЗаявокНаОформлениеОпераций КАК ЖурналРегистрацииСостоянийЗаявокНаОформлениеОпераций
	|	ГДЕ
	|		ЖурналРегистрацииСостоянийЗаявокНаОформлениеОпераций.Источник = &Источник
	|		И НАЧАЛОПЕРИОДА(ЖурналРегистрацииСостоянийЗаявокНаОформлениеОпераций.ДатаВремяПолученияЗаявкиСервисом, ДЕНЬ) = НАЧАЛОПЕРИОДА(&ДатаЗаписи, ДЕНЬ)
	|		И ТИПЗНАЧЕНИЯ(ЖурналРегистрацииСостоянийЗаявокНаОформлениеОпераций.Объект) В (ТИП(Документ.ОтгрузкаТоваровУслуг), ТИП(Документ.ВозвратТоваровОтПокупателя))
	|		И ВЫБОР
	|				КОГДА ТИПЗНАЧЕНИЯ(ЖурналРегистрацииСостоянийЗаявокНаОформлениеОпераций.Объект) = ТИП(Документ.ОтгрузкаТоваровУслуг)
	|					ТОГДА ЖурналРегистрацииСостоянийЗаявокНаОформлениеОпераций.Объект.ДатаОтгрузки <= &ДатаПоставки
	|				ИНАЧЕ ИСТИНА
	|			КОНЕЦ) КАК влЗапрос
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияСвойствОбъектов КАК СвойстваОбъектов
	|		ПО влЗапрос.Объект = СвойстваОбъектов.Объект
	|			И (СвойстваОбъектов.Свойство = &Свойство_НомерВходящегоДокумента)
	|ГДЕ
	|   влЗапрос.Объект.Контрагент <> &КонтрагентНаВыкуп 
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Сверка.Поставка
	|ПОМЕСТИТЬ втСверка
	|ИЗ
	|	&тзСверка КАК Сверка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	втОтгрузкаТоваровУслуг.ДокументСсылка КАК Документ,
	|	ПРЕДСТАВЛЕНИЕ(втОтгрузкаТоваровУслуг.ДокументСсылка) КАК ДокументПредставление,
	|	ЕСТЬNULL(втОтгрузкаТоваровУслуг.НомерПоклажедателя, втСверка.Поставка) КАК НомерПоставки,
	|	ВЫБОР
	|		КОГДА втОтгрузкаТоваровУслуг.НомерПоклажедателя ЕСТЬ NULL
	|			ТОГДА ""Загрузить""
	|		КОГДА втСверка.Поставка ЕСТЬ NULL
	|			ТОГДА ""Пометить на удаление""
	|		ИНАЧЕ NULL
	|	КОНЕЦ КАК Действие,
	|	втОтгрузкаТоваровУслуг.ДатаОтгрузки
	|ИЗ
	|	втОтгрузкаТоваровУслугНаТекДату КАК втОтгрузкаТоваровУслуг
	|		ПОЛНОЕ СОЕДИНЕНИЕ втСверка КАК втСверка
	|		ПО втОтгрузкаТоваровУслуг.НомерПоклажедателя = втСверка.Поставка
	|
	|УПОРЯДОЧИТЬ ПО
	|	втОтгрузкаТоваровУслуг.ДокументСсылка.ДатаОтгрузки";
	
КонецФункции

#КонецОбласти 