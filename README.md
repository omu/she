Betikleme araç seti
===================

TODO
----

- [ ] manuel test
- [ ] API overhaul ve ekleme/düzeltmeler
- [ ] Stil/tutarlılık bakımı
- [ ] blob unpack
- [ ] bin unpack desteği
- [ ] README asgari dokümantasyonu
- [ ] Mevcut provizyonlama uyumluluğu için ekleme/düzeltmeler
- [ ] scripts aracının yeni sürümü
- [ ] etc'nin durumu
- [ ] Fikir: builtin olmayan versiyonu `i` olarak isimlendir

Stil
----

### İşlev isimleri

- İşlev isimleri `<modül>.<tanımlayıcı>` biçimindedir

- Bir işlev 4 tipte olabilir

  1. Komut fonksiyonları: `_ komut altkomut` şeklinde dışarı açılan komutların gerçeklemesi

  2. Açık fonksiyonlar: "She" tüketicileri tarafından kitaplık düzeyinde kullanılabilen olağan fonksiyonlar

  3. Alt tire değişkeni kullanan fonksiyonlar: `_` öntanımlı değişkenini kullanan fonksiyonlar

  4. Kapalı fonksiyonlar: Sadece ilgili modülde kullanılabilecek fonksiyonlar

- Bu tiplerde aşağıdaki sözdizimleri kullanılır

  1. Fonksiyon başlığında `fonksiyon adı: açıklama` biçimiyle bildirilir

  2. Özel bir biçim kullanılmaz

  3. `<modül>.<tanımlayıcı>_` biçimi kullanılır

  4. `<modül>._<tanımlayıcı>` biçimi kullanılır (ayrıca 3 tipinde ise `<modül>._<tanımlayıcı>_`

### `_`

`_` değişkeni hash tipinde dönüş değişkeni olarak kullanılır.  Bu yapılırken:

- Daima yerel kapsamda `local -A _` ile bildirim yapılır

- Seçeneklerde `-option` biçimi kullanılır

- Ara değişkenler için `.variable` biçimi kullanılır

- `0` anahtarı asla kullanılmaz

- `${_[1]}`, `${_[9]}` değerleri konumsal parametreler için kullanılır

- `.error` değişkeni (varsa) hata iletisi taşır

- Bunun dışında kalan (seçenek, ara değişken veya konumsal parametre olmayan) tüm anahtarlar değişken olarak kullanılır

- Komut satırı parametrelerinin ayrıştırılmasında `flag` modülü kullanılır (`flag.parse "$@"`)

### Çıktı atamaları

- Sadece bang versiyon olarak backtick'ten kaçınan fonksiyonlara izin var.  Bu fonksiyonlarda girdi aynı zamanda çıktıdır.

Ortam
-----

| Tür                 | İç değişken  | Baskın değişken        | Geçerli değişken | Öntanımlı kullanıcı dizini | Öntanımlı sistem dizinleri
| ------------------- | ------------ | ---------------------- | ---------------- | -------------------------- | ---------------------------
| Programlar          | `_BIN_DIR`   | `UNDERSCORE_BIN_DIR`   | `BINDIR`         | `$HOME/.local/bin`         | `/run/_/bin`
| İndirilen kaynaklar | `_SRC_DIR`   | `UNDERSCORE_SRC_DIR`   | `SRCDIR`         | `$HOME/.local/src`         | `/run/_/src`
| Geçici dosyalar     | `_TMP_DIR`   | `UNDERSCORE_TMP_DIR`   | `TMPDIR`         | `/tmp`                     | `/tmp`
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
                using
                        *-backports|experimental|stable|testing|unstable|sid
                install
                        -shiny
                        -missings
                update
                uninstall

        etc

        file
                download
                install

                run
                        -test
                enter
                leave

                render

        bin
                use
                install

        git
                ...

        http
                get
                post

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
                install
                use

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
                bye
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
