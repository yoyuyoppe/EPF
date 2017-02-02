﻿// перевод десятичного числа в шестнадцатеричное 
Функция ДесятьВШестнадцать(пЧисло) 
	лЦифры = "0123456789ABCDEF"; 
	Рез = пЧисло; 
	лСтр = ""; 
	Пока Рез > 0 Цикл 
		Ост = Рез % 16 + 1; 
		лСтр = Сред(лЦифры, Ост, 1) + лСтр; 
		Рез = Цел(Рез / 16); 
	КонецЦикла; 
	Возврат лСтр; 
КонецФункции 

// рассчитывает хэш-код переданной строки
// 	СтрокаХэш - исходный текст
// 	hash- начальное значение hash
// 	М - множитель (влияет накачество хэш и производительность)
// 	TABLE_SIZE - максимальный размер целочисленного типа (int32)
Функция Хэш(СтрокаХэш, hash=0, M = 31, TABLE_SIZE = 2147483647)
	//TABLE_SIZE = 18446744073709551615; 64 бита
	//M = 31; множитель
	ДлинаСтроки = СтрДлина(СтрокаХэш);
	Для к=1 по ДлинаСтроки цикл
		hash = M * hash + КодСимвола(Сред(СтрокаХэш,к,1));
	конеццикла;
	возврат hash%TABLE_SIZE;
КонецФункции

// рассчитывает хэш-код по полям заголовка и ТЧ документа
Функция РассчитатьХэшКод(СтруктураДокумента) экспорт
	
	СтрокаХэш = "";
	
	Для Каждого КлючИЗначение из СтруктураДокумента цикл
		Если ВРЕГ(КлючИЗначение.Ключ) = ВРЕГ("ТабЧасть") тогда
			Продолжить;
		КонецЕсли;	
		СтрокаХэш = СтрокаХэш + КлючИЗначение.Значение + Символы.ПС;
	КонецЦикла;
	
	ТабЧасть = СтруктураДокумента.ТабЧасть;
	
	Для Каждого стрТабЧасть Из ТабЧасть Цикл
		Для Каждого табКолонка из ТабЧасть.Колонки цикл
			СтрокаХэш = СтрокаХэш + стрТабЧасть[табКолонка.Имя] + Символы.ПС;
		КонецЦикла;
	КонецЦикла;
	
	ХэшКодДокумента = Хэш(СтрокаХэш);
	ХэшКодДокумента = ДесятьВШестнадцать(ХэшКодДокумента);
	Возврат ХэшКодДокумента;
	
КонецФункции

&НаКлиенте
Функция Из_10_В_Любую(Знач Значение=0,Нотация=36) Экспорт
	Если Нотация<=0 Тогда Возврат("") КонецЕсли;
	Значение=Число(Значение);
	Если Значение<=0 Тогда Возврат("0") КонецЕсли;
	Значение=Цел(Значение);
	Результат="";
	Пока Значение>0 Цикл
		Результат=Сред("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",Значение%Нотация+1,1)+Результат;
		Значение=Цел(Значение/Нотация) ;
	КонецЦикла;
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция Из_Любой_В_10(Знач Значение="0",Нотация=36) Экспорт
	Если Нотация<=0 Тогда Возврат(0) КонецЕсли;
	Значение=СокрЛП(Значение);
	Если Значение="0" Тогда Возврат(0) КонецЕсли;
	Результат=0;
	Длина=СтрДлина(Значение);
	Для Х=1 По Длина Цикл
		М=1;
		Для У=1 По Длина-Х Цикл М=М*Нотация КонецЦикла;
		Результат=Результат+(Найти("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",Сред(Значение,Х,1))-1)*М;
	КонецЦикла;
	Возврат Окр(Результат);
КонецФункции

&НаКлиенте
Функция TxtToHex(Текст)
	
	Рез = "";
	Счетчик = 1;
	МассивСтрок = ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(Текст,Символы.ПС);
	
	Для Каждого ЭлементМассива Из МассивСтрок Цикл 
		
		Пока Не Счетчик = СтрДлина(Текст)+1 цикл
			СледующийСимвол = Сред(Текст, Счетчик, 1);
			Рез = Рез+СимволTxtToHex(СледующийСимвол);
			Счетчик = Счетчик +1;
		КонецЦикла;
	КонецЦикла;
	
	Возврат Рез;
	
КонецФункции

&НаКлиенте
Функция СимволTxtToHex(ИсходныйСимвол)Экспорт	
	
	Рез = "";
	ИсходныйСимвол = Лев(ИсходныйСимвол, 1);
	
	Если ИсходныйСимвол = """" Тогда
		КодСимвола = 34;
	Иначе
		
		Попытка 
			Если ИсходныйСимвол = Символы.ПС Тогда 
				КодСимвола = 10;	
			Иначе 
				КодСимвола = КодСимволаASCII(ИсходныйСимвол);
			КонецЕсли;
		Исключение 
			
		КонецПопытки;
		
	КонецЕсли;
	
	Если ИсходныйСимвол = Символы.ПС Тогда 
		Рез = "0A";	
	Иначе 
		Рез = Из_10_В_Любую(Формат(КодСимвола, "ЧГ=0"),16); 
	КонецЕсли;
	
	Возврат Рез; 
	
КонецФункции

&НаКлиенте
Функция КодСимволаASCII(Символ) 
	КодUNICODE = КодСимвола(Символ); 
	Если ((КодUNICODE > 1039) И (КодUNICODE < 1104)) Тогда 
		Возврат (КодUNICODE - 848); 
	ИначеЕсли КодUNICODE = 8470 Тогда 
		Возврат 185; 
	ИначеЕсли КодUNICODE = 1105 Тогда 
		Возврат 184; 
	ИначеЕсли КодUNICODE = 1025 Тогда 
		Возврат 168; 
	Иначе 
		Возврат КодUNICODE; 
	КонецЕсли; 
КонецФункции
