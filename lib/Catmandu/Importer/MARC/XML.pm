=head1 NAME

Catmandu::Importer::MARC::XML - Package that imports MARCXML records

=head1 SYNOPSIS

    # From the command line 
    $ catmandu convert MARC --type XML --fix "marc_map('245a','title')" < /foo/data.xml

    # From perl
    use Catmandu;

    # import records from file
    my $importer = Catmandu->importer('MARC',file => '/foo/data.xml', type => 'XML');
    my $fixer    = Catmandu->fixer("marc_map('245a','title')");

    $importer->each(sub {
        my $item = shift;
        ...
    });

    # or using the fixer

    $fixer->fix($importer)->each(sub {
        my $item = shift;
        printf "title: %s\n" , $item->{title};
    });

=head1 METHODS

=head2 new(file => $file , fh => $fh , id => $field)

Parse a file or a filehandle into a L<Catmandu::Iterable>. Optionally provide an
id attribute specifying the source of the system identifer '_id' field (e.g. '001').

=head1 INHERTED METHODS

=head2 count

=head2 each(&callback)

=head2 ...

Every Catmandu::Importer is a Catmandu::Iterable all its methods are inherited. 

=head1 SEE ALSO

L<MARC::File::XML>

=cut
package Catmandu::Importer::MARC::XML;
use Catmandu::Sane;
use Moo;
use Catmandu::Importer::MARC::Decoder;
use MARC::File::XML (BinaryEncoding => 'UTF-8', DefaultEncoding => 'UTF-8', RecordFormat => 'MARC21');

with 'Catmandu::Importer';

has id        => (is => 'ro' , default => sub { '001' });
has decoder   => (
    is   => 'ro',
    lazy => 1 , 
    builder => sub {
        Catmandu::Importer::MARC::Decoder->new;
    } );

sub generator {
    my ($self) = @_;
    my $file = MARC::File::XML->in($self->fh);
    sub  {
      $self->decoder->decode($file->next(),$self->id);
    }
}

1;