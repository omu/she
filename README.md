Betikleme araç seti
===================

Ortam
-----

| Tür                 | İç değişken  | Baskın değişken        | Geçerli değişken | Öntanımlı kullanıcı dizini | Öntanımlı sistem dizinleri
| ------------------- | ------------ | ---------------------- | ---------------- | -------------------------- | ---------------------------
| İndirilen kaynaklar | `_SRC_DIR`   | `UNDERSCORE_SRC_DIR`   | `SRCDIR`         | `$HOME/.local/src`         | `/run/_/src`
| Geçici dosyalar     | `_TMP_DIR`   | `UNDERSCORE_TMP_DIR`   | `TMPDIR`         | `$XDG_RUNTIME_DIR/_/tmp`   | `/run/_/tmp`
| Yapılandırmalar     | `_ETC_DIR`   | `UNDERSCORE_ETC_DIR`   | `ETCDIR`         | `$XDG_CONFIG_HOME/_`       | `/usr/local/etc/_` `/etc/_`
| Önbellek            | `_CACHE_DIR` | `UNDERSCORE_CACHE_DIR` | `CACHEDIR`       | `$XDG_CACHE_HOME/_`        | `/run/_/cache`
| Değişken dosyalar   | `_VAR_DIR`   | `UNDERSCORE_VAR_DIR`   | `VARDIR`         | `$XDG_RUNTIME_DIR/_/var`   | `/run/_/var`

Kullanıcı için `XDG_*` ortam değişkenleri için öntanımlı değerler

| Değişken            | Öntanımlı              |
| ------------------- | ---------------------- |
| `$XDG_RUNTIME_DIR`  | `/run/$EUID/_`         |
| `$XDG_CONFIG_HOME`  | `$HOME/.config/_`      |
| `$XDG_CACHE_HOME`   | `$HOME/.cache/_`       |

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
