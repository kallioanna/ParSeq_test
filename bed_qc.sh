#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Ошибка: укажите BED-файл"
    echo "Использование: $0 <file.bed>"
    exit 1
fi

BED="$1"

# Удаление только строк track
DATA=$(grep -v '^track' "$BED")

# Количество целевых регионов
N=$(printf "%s\n" "$DATA" | wc -l)

echo "Количество целевых регионов: $N"

# Проверка количества полей
ERRORS=$(printf "%s\n" "$DATA" |
    awk -F'\t' 'NF != 6')

if [ -z "$ERRORS" ]; then
    echo "Проверка количества полей: ошибок нет"
else
    echo "Ошибка: найдены строки с количеством полей, отличным от 6:"
    echo "$ERRORS"
fi

# Проверка координат
ERRORS=$(printf "%s\n" "$DATA" |
    awk -F'\t' '$2 >= $3')

if [ -z "$ERRORS" ]; then
    echo "Проверка координат: ошибок нет"
else
    echo "Ошибка: начало координат не меньше конца:"
    echo "$ERRORS"
fi

# Проверка отрицательных координат
ERRORS=$(printf "%s\n" "$DATA" |
    awk -F'\t' '$2 < 0 || $3 < 0')

if [ -z "$ERRORS" ]; then
    echo "Проверка отрицательных координат: ошибок нет"
else
    echo "Ошибка: найдены отрицательные координаты:"
    echo "$ERRORS"
fi

# Проверка дубликатов ID
DUPLICATES=$(printf "%s\n" "$DATA" |
    cut -f4 |
    sort |
    uniq -d)

if [ -z "$DUPLICATES" ]; then
    echo "Проверка идентификаторов: дубликатов нет"
else
    echo "Ошибка: найдены повторяющиеся идентификаторы:"
    echo "$DUPLICATES"
fi

# Проверка дубликатов координат
DUPLICATES=$(printf "%s\n" "$DATA" |
    cut -f1-3 |
    sort |
    uniq -d)

if [ -z "$DUPLICATES" ]; then
    echo "Проверка координат: дубликатов нет"
else
    echo "Ошибка: найдены повторяющиеся координаты:"
    echo "$DUPLICATES"
fi

# Расчёт длины регионов
STATS=$(printf "%s\n" "$DATA" |
    awk -F'\t' '
    BEGIN {
        min_len = 999999999
        max_len = 0
        sum_len = 0
        n = 0
    }
    {
        region_len = $3 - $2

        if (region_len < min_len)
            min_len = region_len

        if (region_len > max_len)
            max_len = region_len

        sum_len += region_len
        n++
    }
    END {
        if (n > 0)
            printf "%d\t%d\t%.2f\n", min_len, max_len, sum_len / n
        else
            print "0\t0\t0"
    }
    ')

IFS=$'\t' read -r MIN MAX MEAN <<< "$STATS"

echo "Длина целевых регионов:"
echo "Минимальная: $MIN п.н."
echo "Максимальная: $MAX п.н."
echo "Средняя: $MEAN п.н."

# Три хромосомы с наибольшим количеством регионов
echo "Три хромосомы с наибольшим количеством участков:"

printf "%s\n" "$DATA" |
    cut -f1 |
    sort |
    uniq -c |
    sort -k1,1nr -k2,2V |
    head -n 3

echo "Проверка файла завершена"
