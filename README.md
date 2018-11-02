# NAME

breakxml.pl - XML breaker

# SYNOPSYS

    breakxml [options] <input.xml> [outuput.xml]

# DESCRIPTION

Rough, simple and dummy XML/UNI/HTML breaker or so called pretty printer written in Perl.

# WARNING

Do not use it in production, it's just for dump/debug/preview only.

# OPTIONS

    --width, -w <number>

Number to break long non-tag (usually text) lines. Default: 72.

    --space, -s <space>

One level indent (spaces). Default: '    '.

    --help, -h

Display help.

# EXAMPLES

    perl breakxml.pl foo.xml            # break (pretty print) foo.xml to standart outout
    perl breakxml.pl foo.xml out.xml    # break (pretty print) foo.xml to out.xml
    perl breakxml.pl -s "    " foo.xml  # indent broken lines with four spaces
    perl breakxml.pl -w 100 foo.xml     # break long text lines to 100 or less characters
    perl breakxml.pl -h                 # display help

# IMPLEMENTATION STEPS

▸ XML file is read as a single string.

▸ All repetitive spaces and/or line breaks are changed to single space.

▸ XML comments `<!-- ... -->` are hidden.

▸ CDATA-like elements `<![...]]>` are hidden.

▸ DOCTYPE-like elements with internal subset `<!DOCTYPE ... [ ... ]>` are hidden.

▸ Spaces after `<` and before `>` symbols are trimmed and corresponding line breaks added.

▸ XML string is split to array by line breaks.

▸ Every array element is processed by its type: 

 ▹ non-tag, i.e. text is broken to `--width` lines and printed with current indent level

 ▹ special tag (comment, etc.) is decoded and printed with current indent level

 ▹ standalone tag is printed with current indent level

 ▹ open tag is printed with current indent level and indent level is increased by one

 ▹ current indent level is decreased by minus one and close tag is printed

# BUGS

▸ XML tags which preserves formatted content are

▸ Spaces and new lines are merged.

# TODO

Improve speed by not reading all input file at once.

# LICENSE

MIT License: [https://github.com/edgaronas/breakxml/blob/master/LICENSE](https://github.com/edgaronas/breakxml/blob/master/LICENSE).

# AVAILABILITY

GitHub: [https://github.com/edgaronas/breakxml.git](https://github.com/edgaronas/breakxml.git).

# AUTHOR

2018-11-02, Edgaras Šakuras [edgaronas@yahoo.com](mailto:edgaronas@yahoo.com)
