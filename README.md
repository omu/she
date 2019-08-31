Betikleme araç seti
===================

kernel
        ui.*
        src.*
        text.*
        etc.*
        file.*

Standard
---------

array (alias: args)
        join
        include
        uniq
        reverse
        sort
        shuffle

blob
        zip
        unzip
        verify
        sign
        encrypt
        decrypt

color

data (alias: ayaml)
        read
                -json
                -yaml (default)
        write
                -json
                -yaml (default)

deb
        use
                backports|experimental|URL
        install
                -missing
        update
        upgrade
        clean
                -aggresive
        uninstall

etc

file
        get
                -zip
                -unzip
        put
        bin
                -missing
        run
                -test
        enter
                -temp
        leave

        render

has/hasnt
        # which set

is/isnt
        # which set

path
        dir
                -map
        ext
                -map
        name
        base
                -map
        rel
        abs

self
        version
        update
        path
        use

src
        prelude

string (alias: arg)
        prefix
        suffix
        split
        downcase
        upcase
        titlecase
        trim
        reverse

text
        fix/unfix
                -append/prepend
                -insert
        fixed
        out

template
        render

ui
        ask
        say
        die
        cry
        fin
        bug
        setup # colored

url
        proto
        host
        user
        pass
        path
        frag

which
        virtual
                container
                vm
                lxc
                lxd
                docker
                kvm
                vmware
                virtualbox
        debian
                buster
                stretch
                sid
        ubuntu
        gui
        net
                ip
                interface
        deb
        bin

Optional
--------

api
        github
        gitlab
        slack

json
        query

mail
        send

yaml
        query
