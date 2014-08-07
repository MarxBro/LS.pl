#!/usr/bin/perl
##################################################################################
# Un LS tipo grilla, con tamaÃ±o de archivos, MD5's y permeable a regexs.
##################################################################################
use Getopt::Std;
use Pod::Usage;
use Digest::MD5;
use utf8;

$| = 1;

my %opts = ();
getopts( 'hu', \%opts );

pod2usage(1) and exit 0 if ( $opts{h} );
pod2usage( -verbose => 2 ) if ( $opts{u} );

my $filtro = "$ARGV[0]" || '.*';
my ( $nombre, $dir, $sym, $perm, $tama, $r, $w, $x, $st, $total, $mod ) = 0;

sub hashito {
    my $file = shift @_;
    open( FILE, $file ) or die "No pude abrir $file: $!";
    binmode(FILE);
    my $md5 = Digest::MD5->new;
    while (<FILE>) {
        $md5->add($_);
    }
    close(FILE);
    return $md5->hexdigest;
}

sub ac {
    my $a  = shift(@_);
    my @ch = split( undef, $a );
    my $ln = $#ch + 1;
    if ( $ln <= 35 ) {
        return $a;
    }
    else {
        my ( $nn, $ext ) = $a =~ m/^(.+)([\.].+)$/sx;
        my @nn_a = split( undef, $nn );
        my $ln_nn = $#nn_a + 1;
        until ( $ln_nn <= 25 ) {
            splice( @nn_a, int( $ln_nn / 2 ) + 1, 1 );
            $ln_nn = $#nn_a + 1;
        }
        my $asd = join( '', @nn_a ) . '[...]' . $ext;
        return $asd;
    }
}

# Ancho, 184 caracteres... Mucho? ^_^
format STDOUT_TOP =
======================================================================================================================================
NOMBRE                               DIR  SYM    TAMAÑO        HASH(MD5)                         R  W  X      ÚLTIMA MODIFICACIÓN
======================================================================================================================================
.
format STDOUT=
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   @|   @|   @>>>>>>>>>  @>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> @> @> @>  @>>>>>>>>>>>>>>>>>>>>>>>>>
$nombre_ff,                              $dir,$sym,$tama,   $md5,                               $r,$w,$x ,$mod
.
foreach $_ (<*>) {
    if ( $_ =~ m/$filtro/ ) {
        $nombre    = $_;
        $nombre_ff = ac("$nombre");
        $r         = -R ($nombre);
        $w         = -W ($nombre);
        $x         = -X ($nombre);
        $dir       = -d ($nombre);
        $sym       = -l ($nombre);
        $mod       = localtime( ( stat $nombre )[9] );
        if ( $dir eq 1 ) {
            $tama = q//;
            $md5  = q//;    #$tama;
        }
        else {
            $tama = -s ($nombre);
            $total += $tama;
            if ( $tama >= 1024**2 ) {
                $tama = sprintf( "%4.2f", ( $tama / 1024 ) / 1024 ) . ' Mb';
            }
            elsif ( $tama >= 1024 ) {
                $tama = sprintf( "%5.1f", $tama / 1024 ) . ' Kb';
            }
            else {
                $tama = sprintf( "%4.f", $tama ) . ' by';
            }
            $md5 = hashito("$nombre");
        }
        write STDOUT;
        $st++;

    }
    else {
        next;
    }
}

$st    = sprintf( "%5.f", $st );
$total = sprintf( "%8.f", $total / 1024 / 1024 ) . ' Mb';
print '_' x 134 . "\n"
  . '=' x ( 72 - 58 )
  . "$total, $st archivos."
  . '=' x 60
  . q/~.GsTv.2012.~/
  . '=' x 19 . "\n"
  if ( $st > 0 );
exit 0;
__END__
######################################################################
# POD ZONE
######################################################################

=pod

=head1 Descripcion.

Este programa es un complemento para I<ls>.

No tiene muchas opciones y solo toma como argumento un regexp, a traves
del cual filtra la salida.

=head1 SYNOPSIS

I<Forma de Uso>:

B<LS.pl>  -->                       Imprime todo.

B<LS.pl 'regexp'>  -->              Imprime los archivos que coinciden 
                                    con la expresion regular a buscar.

B<LS.pl -h> -->                     (Esta) Ayuda.

B<LS.pl -u> -->                     Toda la documentacion (no es tanta :P)

Script para listar archivos, symlinks y carpetas en I<pwd>, mostrando de
cada uno:

=over

=item * Tamagno

=item * Hash (MD5)

=item * Permisos (respecto al usuario que ejecuta el script).

=item * Fecha de la ultima modificacion.

=back

Las columnas I<Sym> y I<Dir> son booleanos que indican si el 
archivo es del tipo en cuestion. Los archivos siempre muestran MD5,
a diferencia de los directorios y symlinks.

Los nombres de archivos largos son truncados desde la mitad, donde
se agrega I<[...]> y siempre se mantiene la extension al final.

I<Los archivos ocultos son ignorados>, cualquiera sea el caso.

=head1 Autor y Licencia.

Programado por B<Marxbro> aka B<Gstv>, ditribuir preferentemente bajo la licencia
WTFPL: I<Do What the Fuck You Want To Public License>.

                                                            Zaijian.

=head2 WTFPL

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2014 MarxBro <allthemarxbrothers@gmail.com>>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.

