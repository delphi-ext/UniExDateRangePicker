# TUniDateRangePicker

**Компонент UniGUI** для выбора диапазонов дат.

## Особенности

- Выбор диапазонов дат и отдельных дат.
- Поддержка предустановленных диапазонов («Сегодня», «Вчера», «Последние 7 дней», «Этот месяц» и др.).
- Настраиваемое отображение календарей (включая ISO-нумерацию недель).
- Кастомизация позиции открытия (`Left`, `Right`, `Center`) и направления выпадения (`Down`, `Up`, `Auto`).
- Возможность очистки выбранного диапазона через триггер.
- Полностью настраиваемый формат даты.

## Установка

1. Установите пакет `UniExDateRangePicker.dpk`.
2. Зарегистрируйте компонент в IDE.
3. Скопируйте папку `web\daterangepicker` в папку UniGUI:  
..\uniGUI\uni-1.95.0.0000\daterangepicker\

## Свойства

- `DateStart`, `DateEnd` – даты начала и конца.
- `DateFormat` – формат отображения даты.
- `DatePickerOptions` – объект `TUniExDatePickerOptions` для настройки опций и диапазонов.
- `Text`, `Alignment`, `Font`, `Color`, `ReadOnly` – стандартные свойства `UniEdit`.

## Примечания

- Использует [daterangepicker](https://www.daterangepicker.com/) и [moment.js](https://momentjs.com/).
- Совместим с Web-режимом UniGUI.

## Пример

![alt text](image\image.png)
