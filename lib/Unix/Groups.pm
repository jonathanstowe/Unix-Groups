use v6;

class Unix::Groups {

    constant GROUPFILE = '/etc/group';

    class Group {
        has Int $.gid;
        has Str $.name;
        has Str $.password;
        has Str @.users;

        multi submethod BUILD(Str :$line!) {
            my ( $name, $pass, $id, $users ) = $line.split(':');
            $!gid = $id.Int;
            $!name = $name;
            $!password = $pass;
            @!users = $users.split(',');
        }
    }

    has IO::Handle $!handle handles <lines>;

    has Group @.groups;
    has Group %!group-by-id;
    has Group %!group-by-name;

    submethod BUILD() {
        $!handle = GROUPFILE.IO.open();
    }

    method groups() returns Array[Group] {
        if !?@!groups.elems {
            for self.lines.map({Group.new(line => $_)}).sort({$^a.gid}) -> $g {
                @!groups.push($g);
                %!group-by-id{$g.gid} = $g;
                %!group-by-name{$g.name} = $g;
            }
        }
        @!groups;
    }

    method group-by-name(Str $name) returns Group {
        %!group-by-name{$name};
    }

    method group-by-id(Int $id) returns Group {
        %!group-by-id{$id};
    }

}

# vim: expandtab shiftwidth=4 ft=perl6

