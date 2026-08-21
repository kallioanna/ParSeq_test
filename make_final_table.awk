BEGIN {
    print "target_id\ttarget_chr\ttarget_start\ttarget_end\tofftarget_chr\tofftarget_start\tofftarget_end\tidentity\talignment_length\tstrand"
}

{
    # Извлечение идентификатора и координат целевого региона.
    full_id = $1

    split(full_id, id_parts, "::")
    target_id = id_parts[1]

    target_region = id_parts[2]
    split(target_region, region, /[:-]/)

    target_chr   = region[1]
    target_start = region[2]
    target_end   = region[3]

    # Нормализация идентификатора последовательности subject.
    offtarget_chr = $2
    sub(/^ref\|/, "", offtarget_chr)
    sub(/\|$/, "", offtarget_chr)

    # Преобразование координат BLAST (1-based, inclusive)
    # в координаты BED (0-based, end-exclusive).
    if ($9 <= $10) {
        offtarget_start = $9 - 1
        offtarget_end   = $10
        strand = "+"
    }
    else {
        offtarget_start = $10 - 1
        offtarget_end   = $9
        strand = "-"
    }

    print target_id \
        "\t" target_chr \
        "\t" target_start \
        "\t" target_end \
        "\t" offtarget_chr \
        "\t" offtarget_start \
        "\t" offtarget_end \
        "\t" $3 \
        "\t" $4 \
        "\t" strand
}
