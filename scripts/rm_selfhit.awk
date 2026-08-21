{
    # Извлечение идентификатора и координат целевого региона.
    target = $1
    sub(/^.*::/, "", target)
    split(target, t, /[:-]/)
    target_chr   = t[1]
    target_start = t[2]
    target_end   = t[3]
    # Нормализация идентификатора последовательности subject.
    subject = $2
    sub(/^ref\|/, "", subject)
    sub(/\|$/, "", subject)
    # Преобразование координат BLAST в BED-координаты.
    if ($9 <= $10) {
        subject_start = $9 - 1
        subject_end   = $10
    }
    else {
        subject_start = $10 - 1
        subject_end   = $9
    }
    # Идентификация полного совпадения с исходным целевым регионом.
    self_hit = (subject == target_chr && \
                subject_start == target_start && \
                subject_end == target_end)
    # Сохранение только нецелевых совпадений.
    if (!self_hit) {
        print
    }
}
