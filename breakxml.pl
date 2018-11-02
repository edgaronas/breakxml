use strict;
use warnings FATAL => 'all';
use feature qw(say);
use Getopt::Long qw();

my $width=72;
my $space='    ';
my $fhout = *STDOUT;
my $biname='breakxml';
my @NOBR;
my $nobra=$biname.'NOBR';
my $nobrb=reverse($biname.'NOBR');

my $usage= "USAGE: $biname [--width=72] [--space='    '] input.xml [output.xml]";

Getopt::Long::GetOptions(
    'help|h'    => sub { say $usage; exit; },
    'space|s=s' => \$space,
    'width|w=i' => \$width,
) or die("error in command line arguments: $?, $!");

die("Missing arguments!\nShowing help text:\n$usage") unless(@ARGV);

my $xmlstring;
{
    local $/ = undef;
    open(my $fhin, '<', $ARGV[0]) or die("failed to open file '$ARGV[0]' for reading: $?, $!");
    $xmlstring=<$fhin>;
    close($fhin);
};
die "something wrong, possibly empty file: $ARGV[0]" unless(length($xmlstring)>0);

if($#ARGV>0){
    open($fhout, '>', $ARGV[1]) or die("failed to open file '$ARGV[1]' for writing $?, $!");
}

$xmlstring=~s/\s+/ /gs;
$xmlstring=~s/<!(--.+?--)>/hide_nobr($1)/egs; # comments
$xmlstring=~s/<!(\[.+?\]\])>/hide_nobr($1)/egs; # cdata
$xmlstring=~s/<!([A-Z]+ [\w ]*?\[.+?\])>/hide_nobr($1)/egs; # doctype
$xmlstring=~s/<\s*/\n</gs;
$xmlstring=~s/\s*> /> \n/gs;
$xmlstring=~s/\s*>([^ ])/>\n$1/gs;
$xmlstring=~s/> \n\n</> \n</gs;
$xmlstring=~s/>\n\n</>\n</gs;

my @XML = split(/\n/, $xmlstring);
shift @XML if(length($XML[0])==0);
pop @XML if(length($XML[$#XML])==0);
undef $xmlstring;

my $indent='';
my $level=0;
my $tagtype=0; # 0 - non-tag, 1 - special/nobr, 2 - standalone, 3 - close, 4 - open

# precompiled regex'es for possible speed improvement:
my $specialqr = qr/^(<[\!\?])(.+?)(> ?)$/; # comment, declaration, nobr
my $nobrqr = qr/^\Q$nobra\E(\d+)\Q$nobrb\E$/; # hidden nobr element
my $standaloneqr = qr/\/> ?$/;
my $openqr = qr/^</;
my $closeqr = qr/^<\//;

foreach my $xml (@XML){
    if($xml=~$specialqr){
        $tagtype=1;
        my ($beg, $mid, $end) = ($1, $2, $3);
        if($mid=~$nobrqr){
            $xml=$beg.$NOBR[$1].$end;
        }
    }
    elsif($xml=~$standaloneqr){
        $tagtype=2;
    }
    elsif($xml=~$closeqr){
        $tagtype=3;
    }
    elsif($xml=~$openqr){
        $tagtype=4
    }
    else {
        $tagtype=0;
    }
    $indent = $space x $level;
    if($tagtype==4){
        say $fhout $indent, $xml;
        $level++;
    }
    elsif($tagtype==3){
        $level-- if($level>0);
        $indent = $space x $level;
        say $fhout $indent, $xml;
    }
    elsif($tagtype==1){
        say $fhout $indent, $xml;
    }
    else {
        if(length($xml)<=$width){
            say $fhout $indent, $xml;
        }
        else {
            my @TMP = split(/ /, $xml);
            $xml = shift(@TMP);
            foreach my $tmp (@TMP){
                if(length($xml.' '.$tmp)<=$width){
                    $xml.=' '.$tmp;
                } 
                else {
                    say $fhout $indent, $xml;
                    $xml=$tmp;
                }
            }
            say $fhout $indent, $xml;
        }
    }
}

close($fhout) if($#ARGV>0);

sub hide_nobr {
    push @NOBR, $_[0];
    return '<!'.$nobra.$#NOBR.$nobrb.'>';
}
  
__END__

=head1 NAME

breakxml.pl - XML breaker

=head1 SYNOPSYS

    breakxml [options] <input.xml> [outuput.xml]

=head1 DESCRIPTION

Rough, simple and dummy XML/UNI/HTML breaker or so called pretty printer written in Perl.

=head1 WARNING

Do not use it in production, it's just for dump/debug/preview only.

=head1 OPTIONS

    --width, -w <number>

Number to break long non-tag (usually text) lines. Default: 72.

    --space, -s <space>

One level indent (spaces). Default: '    '.

    --help, -h

Display help.

=head1 EXAMPLES

    perl breakxml.pl foo.xml            # break (pretty print) foo.xml to standart outout
    perl breakxml.pl foo.xml out.xml    # break (pretty print) foo.xml to out.xml
    perl breakxml.pl -s "    " foo.xml  # indent broken lines with four spaces
    perl breakxml.pl -w 100 foo.xml     # break long text lines to 100 or less characters
    perl breakxml.pl -h                 # display help

=head1 IMPLEMENTATION STEPS

E<0x25B8> XML file is read as a single string.

E<0x25B8> All repetitive spaces and/or line breaks are changed to single space.

E<0x25B8> XML comments C<E<lt>!-- ... --E<gt>> are hidden.

E<0x25B8> CDATA-like elements C<E<lt>![...]]E<gt>> are hidden.

E<0x25B8> DOCTYPE-like elements with internal subset C<E<lt>!DOCTYPE ... [ ... ]E<gt>> are hidden.

E<0x25B8> Spaces after C<E<lt>> and before C<E<gt>> symbols are trimmed and corresponding line breaks added.

E<0x25B8> XML string is split to array by line breaks.

E<0x25B8> Every array element is processed by its type: 

E<emsp>E<0x25B9> non-tag, i.e. text is broken to C<--width> lines and printed with current indent level

E<emsp>E<0x25B9> special tag (comment, etc.) is decoded and printed with current indent level

E<emsp>E<0x25B9> standalone tag is printed with current indent level

E<emsp>E<0x25B9> open tag is printed with current indent level and indent level is increased by one

E<emsp>E<0x25B9> current indent level is decreased by minus one and close tag is printed

=head1 BUGS

E<0x25B8> XML tags which preserves formatted content are

E<0x25B8> Spaces and new lines are merged.

=head1 TODO

Improve speed by not reading all input file at once.

=head1 LICENSE

MIT License: L<https://github.com/edgaronas/breakxml/blob/master/LICENSE>.

=head1 AVAILABILITY

GitHub: L<https://github.com/edgaronas/breakxml.git>.

=head1 AUTHOR

2018-11-02, Edgaras E<Scaron>akuras L<edgaronas@yahoo.com|mailto:edgaronas@yahoo.com>
