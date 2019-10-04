Kabuk genişletmeleri
====================

Ortam
-----

Kullanıcı için `XDG_*` ortam değişkenleri için öntanımlı değerler

| Değişken               | Öntanımlı              |
| ---------------------- | ---------------------- |
| `$XDG_RUNTIME_DIR`     | `/run/user/$EUID`      |
| `$XDG_CONFIG_HOME`     | `$HOME/.config/_`      |
| `$XDG_CACHE_HOME`      | `$HOME/.cache/_`       |

Çalışma ortamı

| Tür                    | İç değişken  | Kontrol eden değişken          | Öntanımlı kullanıcı değeri                             | Öntanımlı sistem değeri
| ---------------------- | ------------ | ------------------------------ | ------------------------------------------------------ | ------------------------------------
| Geçici dizin ağacı     | `_RUN`       | `UNDERSCORE_VOLATILE_PREFIX`   | `$XDG_RUNTIME_DIR/_`                                   | `/run/_`
| Kalıcı dizin ağacı     | `_USR`       | `UNDERSCORE_PERSISTENT_PREFIX` | `$HOME/.local`                                         | `/usr/local`
| Yapılandırma dizinleri | `_ETC`       | `UNDERSCORE_CONFIG_PATH`       | `/etc/_:/usr/local/etc/_:$XDG_CONFIG_HOME/_:$_RUN/etc` | `/etc/_:$_USR/etc/_:$_RUN/etc`

Buna göre tipik dizin değerleri

| Tür                                           | İç değişken  | Tipik kullanıcı değeri                                     | Tipik sistem değeri
| --------------------------------------------- | ------------ | ---------------------------------------------------------- | -------------------------
| Programlar için geçici kurulum dizini         | `_RUN/bin`   | `/run/user/1000/bin`                                       | `/run/_/bin`
| Programlar için kalıcı kurulum dizini         | `_USR/bin`   | `~/.local/bin`                                             | `/usr/local/bin`
| Yapılandırmalar (sondaki en yüksek öncelikli) | `_ETC`       | `/etc/_:/usr/local/etc/_:~/.config/_:/run/user/1000/_/etc` | `/etc/_:/usr/local/etc/_:/run/_/etc`

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

TODO
----

- [ ] manuel test
- [X] API overhaul ve ekleme/düzeltmeler
- [ ] Stil/tutarlılık bakımı
- [X] blob unpack
- [X] bin unpack desteği
- [ ] README asgari dokümantasyonu
- [ ] Mevcut provizyonlama uyumluluğu için ekleme/düzeltmeler
- [ ] scripts aracının yeni sürümü
- [ ] etc'nin durumu
- [X] Fikir: builtin olmayan versiyonu `i` olarak isimlendir
