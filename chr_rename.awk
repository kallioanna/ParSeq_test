BEGIN {
    FS = OFS = "\t"
}

/^#/ {
    header[++header_count] = $0
    next
}

$3 == "region" {
    if ($1 == "NC_012920.1") {
        chromosome_map[$1] = "chrM"
    }
    else if (match($9, /chromosome=[^;]+/)) {
        chromosome = substr($9, RSTART + 11, RLENGTH - 11)

        if (chromosome ~ /^[0-9]+$/ ||
            chromosome == "X" ||
            chromosome == "Y") {
            chromosome_map[$1] = "chr" chromosome
        }
    }

    records[++record_count] = $0
    next
}

{
    records[++record_count] = $0
}

END {
    for (i = 1; i <= header_count; i++) {
        print header[i]
    }

    for (i = 1; i <= record_count; i++) {
        field_count = split(records[i], fields, "\t")

        if (fields[1] in chromosome_map) {
            fields[1] = chromosome_map[fields[1]]
        }

        output = fields[1]

        for (j = 2; j <= field_count; j++) {
            output = output OFS fields[j]
        }

        print output
    }
}
