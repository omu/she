Kabuk genişletmeleri
====================

Kabuk genişletmeleri `bin` dizininde bulunan `_` ve `t` programlarından oluşur.  Bu programlar, kendi başına
kullanılabilmekle birlikte önerilen kullanım yöntemi aşağıdaki gibidir:

```sh
. <(_)

_ KOMUT... [SEÇENEK]... [ARGÜMAN]...
```

Genişletme programları `src` dizinindeki kaynak dosyalardan basit bir derleyici yoluyla üretilir.  Kaynak dosyalar `cmd`
ve `lib` dizinlerindeki kabuk fonksiyonlarından hangilerinin kullanıldığını tanımlar.  Komutlar `cmd` dizininde bulunan
kabuk fonksiyonlarıyla oluşturulur.  Komutlarda kullanılan tüm kitaplık fonksiyonları `lib` dizinindedir.  Genel amaçlı
bu kitaplık fonksiyonları kabuk genişletmelerinde izlenen düzenden bağımsız olarak kopyala/yapıştır yoluyla her yerde
kullanılabilecek genelliktedir.

`_`
---

### Ortam

Kullanıcı için `XDG_*` ortam değişkenleri için öntanımlı değerler aşağıdaki gibi olmak kaydıyla:

| Değişken               | Öntanımlı              |
| ---------------------- | ---------------------- |
| `$XDG_RUNTIME_DIR`     | `/run/user/$EUID`      |
| `$XDG_CONFIG_HOME`     | `$HOME/.config/_`      |
| `$XDG_CACHE_HOME`      | `$HOME/.cache/_`       |

Çalışma ortamı:

| Tür                    | İç değişken  | Kontrol eden değişken          | Öntanımlı kullanıcı değeri                             | Öntanımlı sistem değeri
| ---------------------- | ------------ | ------------------------------ | ------------------------------------------------------ | ------------------------------------
| Geçici dizin ağacı     | `_RUN`       | `UNDERSCORE_VOLATILE_PREFIX`   | `$XDG_RUNTIME_DIR/_`                                   | `/run/_`
| Kalıcı dizin ağacı     | `_USR`       | `UNDERSCORE_PERSISTENT_PREFIX` | `$HOME/.local`                                         | `/usr/local`
| Yapılandırma dizinleri | `_ETC`       | `UNDERSCORE_CONFIG_PATH`       | `/etc/_:/usr/local/etc/_:$XDG_CONFIG_HOME/_:$_RUN/etc` | `/etc/_:$_USR/etc/_:$_RUN/etc`

Buna göre tipik dizin değerleri:

| Tür                                           | İç değişken  | Tipik kullanıcı değeri                                     | Tipik sistem değeri
| --------------------------------------------- | ------------ | ---------------------------------------------------------- | -------------------------
| Programlar için geçici kurulum dizini         | `_RUN/bin`   | `/run/user/1000/bin`                                       | `/run/_/bin`
| Programlar için kalıcı kurulum dizini         | `_USR/bin`   | `~/.local/bin`                                             | `/usr/local/bin`
| Yapılandırmalar (sondaki en yüksek öncelikli) | `_ETC`       | `/etc/_:/usr/local/etc/_:~/.config/_:/run/user/1000/_/etc` | `/etc/_:/usr/local/etc/_:/run/_/etc`

`t`
---

Test çatısı aşağıdaki tasarım ilkeleri ve özellikler çerçevesinde geliştirilmiştir:

- Her test dosyası doğrudan Bash ile çalıştırılabilir bir betik olmalı (testleri, en azından tek olarak çalıştırmak
  için, özel bir araç gerekmemeli)

- Ayrıntılı bir DSL'den kaçınılmalı

- Test çatısının test edilen betik üzerinde oluşturduğu kirlilik minimize edilmeli

- Test çıktıları TAP uyumlu olmalı

- Tek dosya halinde kolayca kurulum yapılabilmeli

- Docker veya chroot ile birinci sınıf sandbox desteği olmalı

- Zengin fixture ve fake olanakları olmalı

Buna göre test çatısının kullanımı basitçe aşağıdaki gibidir.

```sh
. <(t)

t KOMUT... -- İLETİ
```

İki tür test modeli desteklenir: basit ve kompozit model.

### Basit model

```sh
#!/bin/bash

. <(t) [.|_|RELPATH]...

t ok CASE -- MSG
```

- Bu modelde `t go` ve test süiti yok, dosyanın kendisi bir süit

- Süit olmamakla birlikte kabuk fonksiyonları kullanılarak modülerlik sağlanabilir

- Setup işlevselliği mevcut, ama teardown yapılamaz

- Her test sırasında otomatik yaratılan ve kaldırılan bir geçici dizin yapısıyla teardown'a yaklaşılabilir

### Kompozit model

```sh
#!/bin/bash

. <(t) [.|_|RELPATH]...

test:startup() {
      :
}

test:shutdown() {
      :
}

test:setup() {
      :
}

test:teardown() {
      :
}


t go
```

- Her `.t` dosyası `test:` ile başlayan fonksiyonlarla kurulan bir süit topluluğu

- `test:startup` ve `test:shutdown` her test dosyasında çalışan özel setup/teardown fonksiyonları

- `test:setup` ve `test:teardown` her test süit'te çalışan özel setup/teardown fonksiyonları

- `t go` ile suit fonksiyonları sırayla veya rastgele çağrılıyor

### Doğrulayıcılar

- `t ok`/`t notok`

   Verilen argümanları değerlendirerek ("eval") sonucun doğruluğuna baka

- `t is`/`t isnt`

   Verilen ilk argümanın (gerçekteki değer) ikinci argümana (beklenen değer) denkliğini doğrular

- `t like`/`t unlike`

   Verilen ilk argümanın (gerçekteki değer) ikinci argümanla verilen düzenli ifadeyle (beklenen değer) uyuştuğunu doğrular

- `t out`/`t err`

  Verilen argümanlara karşı düşen komutu çalıştırarak stdin'deki belirtime uygunluğunu denetler

- `t pass`/`t fail`

  Başarılı/başarısız test sonucu döner

- Testi başarılı olarak işaretleyerek atlamak için açıklamanın başına `SKIP` (veya `skip`) ekle

- Testi başarısız olarak işaretleyerek TODO olduğunu vurgulamak için açıklamanın başına `TODO` (veya `todo`) ekle

#### out/err

- `out`: argüman olarak verilen komutun başarılı olduğunu doğrularken stdin verisinde boş satırla ayrılmış stdout ve
   (varsa) stderr eşleşmelerini de doğrular

- `err`: argüman olarak verilen komutun başarısız olduğunu doğrularken stdin verisinde boş satırla ayrılmış stderr ve
   (varsa) stdout eşleşmelerini de doğrular

- Matcher format: `[scope][match type]`

- scope, line veya range olabilir

- line: `-?\d+`

  + Negatif sayılar sondan eşleme yapar
  + `$` son satır (`-1`)
  + `.` güncel satır (son eşleşmeden **hemen sonraki satır**, eşleme henüz yoksa 1)

- range: `[line]:[line]`

  + Aralık başlangıcı boşsa 1, bitişi boşsa `$` alınır

- Satır başlangıcında "matcher" + 1 boşluk veya tab olmalı

- line `.` ise güncel satırda

- Matcher boşsa (yani satır bir boşluk veya sekme ile başlıyorsa) `.=` kullanılır, yani

  + Match type `=` semantiğiyle (exact line match) yapılır
  + Kapsam daima son eşlemeden sonraki satır olarak alınır
  + İlk satırda matcher boşsa son eşlemenin 0 nolu satırda olduğu varsayılarak eşleme 1'nci satırdan başlar

- match type: `=|!|~|^`, boşsa öntanımlı `=`

  + `=`: exact line match
  + `~`: regex line match
  + `!`: `=` değil
  + `^`: `~` değil

- stdin verisi boşsa ilgili komutun hiç bir çıktı üretmediği doğrulanır

#### Örnekler

```sh
t out cmd arg1 arg2
```

Komut başarılı ve ne stdout ne de stderr çıktısı üretmiyor

```sh
t out cmd arg1 arg2 <<'EOF'
	a
	b
EOF
```

(Örnekte `<<'EOF'` kullanılmasına dikkat, bu sayede satır başlangıçlarında sekme oluyor ve matcher boş alınıyor)

Komut başarılı ve stdout çıktısında:

- 1'nci satır `a`
- 2'nci satır `b`

```sh
t out cmd arg1 arg2 <<'EOF'
	a
	b

EOF
```

Komut başarılı ve stdout çıktısı önceki örnekle aynı, tek fark stderr çıktısı boş

```sh
t out cmd arg1 arg2 <<-'EOF'
	1	a
	3-8	b
	9~	c
	10!	d
	-2	x
	$	e
EOF
```

(Örnekte `<<-'EOF'` kullanılmasına dikkat, satır başlangıçlarındaki sekmeler dikkate alınmıyor)

Komut başarılı ve stdout çıktısında:

- 1'nci satır `a`
- 3-8 satırlarının herhangi biri `b`
- 9'ncu satırda `c` var
- 10'ncu satır `d` değil
- Sondan iki önceki satır `x`
- Son satır `e`

```sh
t err cmd arg1 arg2 <<-'EOF'
		E: fatal error
        	Command failed

		a
EOF
```

Komut başarısız ve stderr/stdout çıktılarında:

- stderr'de 1'nci satır `E: fatal error`
- 2'nci satır `Command failed`
- stdout'ta ilk satır `a`

Geliştirme
----------

Geliştirme sürecini, verilen iletiyi "NOTICE:" ön ekiyle standart hata çıktısında ("stderr") görüntüleyen bir komut
ekleyerek örneklendirelim.  Geliştirmede [stil](#stil) bölümünde dokümante edilen kurallara uyulmalıdır.

- Komutun adına ve hangi isim uzayında olacağına karar verilir.  Örnekteki komut kullanıcı arayüzüyle ilgili olduğundan
  `ui` isim uzayı uygun bir seçenektir.  İsmi `notice` olarak seçtiğimizi varsayarsak komut `_ ui notice` olacaktır.
  Örnek kullanım:

  ```sh
  $ _ ui notice 'Disk is getting full'
  NOTICE: Disk is getting full
  ```

  Buna göre (henüz yoksa) `cmd/ui.sh` dosyası oluşturulur.

- Standart hata çıktısına ileti yazmak genel bir eylem olduğundan bu işlem, örneğin `warn` gibi biri isimle `lib`
  altında uygun bir kitaplık fonksiyonu yazarak gerçeklenebilir.  Kitaplık fonksiyonlarının düzenlenmesinde komutlarda
  kullanılan isim uzaylarından bire bir yararlanılabilir.  Buna göre ilgili kitaplık fonksiyonunun uygun yeri
  `lib/ui.sh` dosyasıdır.

- Kitaplık fonksiyonları `<modül>.<tanımlayıcı>` biçiminde olduğundan yazılması gereken fonksiyonun adı `ui.warn` olarak
  seçilir.  `lib/ui.sh`'taki gerçekleme aşağıdaki gibidir:

  ```sh
  ui.warn() {
        echo >&2 "$*"
  }
  ```

- Komut fonksiyonları `<modül>:<tanımlayıcı>` biçiminde olduğundan yazılması gereken fonksiyonun adı `ui:notice` olarak
  seçilir.  `cmd/ui.sh`'taki ilk gerçekleme aşağıdaki gibidir:

  ```sh
  ui:notice() {
        ui.warn "NOTICE: $*"
  }
  ```

- Komutlar aşağıdaki koşulları sağlamalıdır:

  1. Tüm komutlar listelendiğinde komut kısa bir tanımla görüntülenebilmelidir.

  2. Komuta geçirilen argümanlar denetlenebilmeli ve hatalı kullanımlar yakalanabilmeli.

  3. Komutla ilgili kısa yardım bilgisi alınabilmesi.

- İlk koşul fonksiyona tanımdan hemen önce eklenecek kısa bir açıklama satırıyla sağlanır.  Derleyici bu kısa tanımları
  ayrıştırarak `bin/_` programını uygun şekilde yeniden üretecektir.

  ```sh
  # Print notice on stderr
  ui:notice() {
        ui.warn "NOTICE: $*"
  }
  ```

- Diğer iki koşul `flag` kitaplığı kullanılarak sağlanır.

  ```sh
  # Print notice on stderr
  ui:notice() {
        local -A _=(
                [.help]='MESSAGE'
                [.argc]=1
        )

        flag.parse

        ui.warn "NOTICE: $*"
  }
  ```

  Gerçeklemede görülen `.help` anahtarı hatalı kullanımda veya açık yardım istendiğinde komutun kullanımı
  görüntülenirken yazdırılacak kısa yardım iletisidir.  `.argc` anahtarı ise komutun tam olarak `1` argüman
  gerektirdiğini belirtir.

  ```sh
  $ _ ui notice
  Usage: _ ui notice MESSAGE
  ✗ Too few arguments

  $ _ help ui notice
  Print notice on stderr
  Usage: _ ui notice MESSAGE
  ```

- Gerçeklemenin etkinleştirilmesi için kaynaklar yeniden derlenir (bu işlem her değişiklikte tekrarlanır)

  ```sh
  $ rake
  ...
  ```

Stil
----

### Fonksiyonlar

- `cmd` dizininde bulunan komut fonksiyonları `<modül>:<tanımlayıcı>` biçimindedir

- `lib` dizininde bulunan kitaplık fonksiyonları `<modül>.<tanımlayıcı>` biçimindedir

- İsimleri alt tireyle (`_`) sonlanan fonksiyonlar korunmuş ("protected") fonksiyonlardır

- Korunmuş komut fonksiyonları tüm komut dosyalarında kullanılabilir

- Korunmuş kitaplık fonksiyonları sadece tanımlandığı dosyada kullanılabilir

- Kitaplık fonksiyonları komut fonksiyonları kullanamaz

- Korunmuş olmayan komut fonksiyonları fonksiyon tanımından önceki satırda mutlaka dokümante edilmelidir

- Korunmuş olmayan komut fonksiyonları `flag` kitaplığıyla komut arayüzü tanımlar

### `_` değişkeni

`_` değişkeni `flag` kitaplığı gibi kabuk programlamanın sınırlarını zorlayan veri yapısı odaklı fonksiyonlarda sözlük
("hash") tipinde bir değişken olarak kullanılır.  Bu yapılırken:

- Daima yerel kapsamda `local -A _` ile bildirim yapılır

- `0` anahtarı asla kullanılmaz

- `1` ve `9` arası anahtarlar (ör. `${_[1]}`, `${_[9]}`) konumsal parametreler için kullanılır

- Seçeneklerde tire (`-`) ile başlayan anahtarlar kullanılır (ör. `-force`)

- İç değişkenlerde nokta (`.`) ile başlayan anahtarlar kullanılır (ör. `.help`)

- `.` özel anahtarı (isteğe bağlı olarak) öntanımlı dönüş değerini taşır

- `!` özel anahtarı (varsa) hata iletisini taşır

- Bunun dışında kalan (seçenek, iç değişken veya konumsal parametre olmayan) ve `a-z` ile başlayan tüm anahtarlar
  değişken olarak kullanılır (ör. `variable`)

Dikkat!  `_` değişkeni sadece `flag` kitaplığı (ve buna bağlı olarak) komut fonksiyonlarında kullanılmalıdır.

### İsim başvuruları

Özellikle dizi veya sözlük tipinde veriler üzerinde çalışması gereken fonksiyonlara değer aktarımı isim başvuruları
ile gerçekleştirilir.

```sh

declare -a packages

func() {
        local -n func_packages_=${1?${FUNCNAME[0]}: missing argument}; shift
        ...
}

func packages
```

- Başvuru değişkenleri isim çakışmalarını önlemek amacıyla (yukarıdaki örnekte görüldüğü gibi) fonksiyon ismiyle
  ön eklenerek oluşturulur ve isim daima alt tire ile sonlandırılır

- Kitaplık fonksiyonlarında dönüş değeri genel olarak `$()` ile alınır.  Fakat giriş değerini değiştirerek dönen bazı
  fonksiyonlarda değer aktarımı için isim başvurusu kullanılabilir.

  ```sh

  string.downcase() {
        local -n string_downcase_=${1?${FUNCNAME[0]}: missing argument}; shift

        string_downcase=${string_downcase_,,}
  }
  ```

TODO
----

- [ ] web/src/file ayrımını olgunlaştır
- [ ] redirect ve usage lojiğini refaktörle
- [ ] cmd refaktörünü satır satır denetle
- [ ] omu/debian entegrasyonundaki tüm çağrıları test et
- [ ] scripts aracının yeni sürümü
- [ ] etc'nin durumu
- [ ] API'yi son bir kez elden geçir
- [ ] Stil bakımı son bir kez
- [ ] README minimal olarak tamamla
- [ ] Tüm yapıyı (policy dahil) BENİOKU'da dokümante et
- [ ] Bootstrap betiklerini yaz
