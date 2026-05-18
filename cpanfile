requires 'perl', '5.038000';
requires 'Term::ReadKey';
requires 'PAR::Packer';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

on 'develop' => sub {
    requires 'Perl::Tidy';
    requires 'Perl::Critic';
    requires 'PAR::Packer';
};
