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

- Internal değişkenler için `.variable` biçimi kullanılır

- `0` anahtarı asla kullanılmaz

- `${_[1]}`, `${_[9]}` değerleri konumsal parametreler için kullanılır

- `.` değişkeni (isteğe bağlı olarak) dönüş değerini taşır (alt: `.reply` veya `_`)

- `!` değişkeni (varsa) hata iletisi taşır (alt: `.error`)

- Bunun dışında kalan (seçenek, ara değişken veya konumsal parametre olmayan) tüm anahtarlar değişken olarak kullanılır

- Komut satırı parametrelerinin ayrıştırılmasında `flag` modülü kullanılır (`flag.parse "$@"`)

### Çıktı atamaları

- Sadece bang versiyon olarak backtick'ten kaçınan fonksiyonlara izin var.  Bu fonksiyonlarda girdi aynı zamanda çıktıdır.

Test
----

Bash betikleri olağan bir programlama diliyle yazılan programlardan farklı.  Örneğin zengin veri yapılarına dayalı yoğun
bir lojik yok.  Bunun yerine sistemle sürekli etkileşim var.  Mevcut birim test kitaplıkları bu etkileşimi test etmekte
zayıf kalıyor.  Benzer şekilde genel amaçlı programlama dillerine kıyasla Bash'in ifade yetenekleri kısıtlı olduğundan
"test edilebilir" kod yazarak örneğin "dependency injection" gibi tekniklerle test süreçlerini yönetmek zor.  Test aracı
ister istemez betiğin gerçekleme detaylarına girebilmeli.

- Docker veya chroot ile birinci sınıf sandbox desteği olmalı

- Zengin fixture ve fake olanakları olmalı

- Test edilen betiği fazla kirletmemeli

- Kurulumu ve kullanımı çok kolay olmalı (idealde tek dosya)

- Test hatalarının ayıklanması sürecinde ayak bağı olmamalı (Bats kötü bir örnek)

- (Betiği çalıştırmak yerine source ederek) kolayca entegrasyon testi yapılabilmeli

- Perl `.t` test dosyalarından esinlen

- Her test dosyası doğrudan Bash ile çalıştırılabilir bir test betiği

- TAP uyumlu çıktı biçimi

- Tüm test yardımcıları `t` önekli

- `prove` gibi (fakat tercihen Docker altında) test dosyalarını orkestra eden araç ayrı yazılacak

- Testler daima `. <(t) [.|_|RELPATH]...` satırı ile başlıyor.  Opsiyonel argümanlar:

  + `_`: `_` yerleşiğini yükler

  + `RELPATH`: Göreceli dosya yolu verilen kabuk dosyasını yükler

- İki tür test modeli destekleniyor: basit ve kompozit model

  + Test dosyasında `t go` çağrısı varsa bu bir kompozit model

  + İki modelin birlikte de kullanılabilir (önerdiğimiz bir pratik değil)

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

TODO
----

- [ ] omu/debian entegrasyonundaki tüm çağrıları test et
- [ ] redirect ve usage lojiğini refaktörle
- [ ] cmd refaktörünü satır satır denetle
- [ ] scripts aracının yeni sürümü
- [ ] etc'nin durumu
- [ ] API'yi son bir kez elden geçir
- [ ] Stil bakımı son bir kez
- [ ] README minimal olarak tamamla
- [ ] Tüm yapıyı (policy dahil) BENİOKU'da dokümante et
