/^>/ {
    header = $0

    if (header ~ /^>NC_[0-9]+\.[0-9]+ Homo sapiens chromosome [0-9]+,/) {
        match(header, /chromosome [0-9]+/)
        chromosome = substr(header, RSTART + 11, RLENGTH - 11)
        print ">chr" chromosome
    }
    else if (header ~ /^>NC_[0-9]+\.[0-9]+ Homo sapiens chromosome X,/) {
        print ">chrX"
    }
    else if (header ~ /^>NC_[0-9]+\.[0-9]+ Homo sapiens chromosome Y,/) {
        print ">chrY"
    }
    else {
        print header
    }

    next
}

{
    print
}
