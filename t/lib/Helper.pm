package Helper;
use strict;
use warnings;
use Test::More;
use File::Spec;



BEGIN {
    use_ok( 'File::Path', qw(make_path remove_tree) ) or exit;
    use_ok( 'File::Copy' ) or exit;
}

sub prepare_input_files {
    my $args = shift;
    
    my $input_dir = $args->{input_dir} or die "Verzeichnis der Input-Dateien fehlt!";
    my $save_dir = File::Spec->catfile($input_dir, 'save');
    my @files = glob File::Spec->catfile($input_dir, "*.*");
    ok(unlink @files, 'L�sche Dateien in t/input_files') if @files;

    if (ref $args->{rmdir_dirs} eq 'ARRAY') {
        foreach my $rmdir  (@{$args->{rmdir_dirs}}) {
            my $path = File::Spec->catfile($input_dir, $rmdir);
            ok(remove_tree $path,
                'L�sche Verzeichnis ' . $path
            ) if -e $path;
        }
    }
    if (ref $args->{make_path} eq 'ARRAY') {    
        foreach my $make_path  (@{$args->{make_path}}) {
            my $path = File::Spec->catfile($input_dir, $make_path);
            ok(make_path($path), 'Neues Verzeichnis ' . $path); 
        }
    }    
    if (ref $args->{copy} eq 'ARRAY') {
        foreach my $copy (@{$args->{copy}}) {        
            if (!ref($copy)) {        
                my @files = glob File::Spec->catfile($save_dir, $copy);
                ok(copy($_, $input_dir), 'Kopiere ' . $_) foreach @files; 
            }
            elsif (ref $copy eq 'HASH') {
                my @files = glob File::Spec->catfile($save_dir, $copy->{glob})
                    if exists $copy->{glob};
                my $dir = $input_dir;
                $dir = File::Spec->catfile($dir, $copy->{dir}) if $dir;    
                ok(copy($_, $dir), 'Kopiere ' . $_) foreach @files; 
            }
        }
    }
}

1;


#my $input_dir = File::Spec->catfile($FindBin::Bin, 'input_files');
#my $save_dir = File::Spec->catfile($input_dir, 'save');
#
#my @files = glob File::Spec->catfile($input_dir, "*.*");
#ok(unlink @files, 'L�sche Dateien in t/input_files') if @files;
#my $dir = File::Spec->catfile($input_dir, 'archive');
#ok(remove_tree $dir, 'L�sche Verzeichnis in t/input_files/archive') if -e $dir;
#@files = glob File::Spec->catfile($save_dir,"ubr00003*.*");
#ok(copy($_, $input_dir), "Kopiere $_") foreach @files; 
