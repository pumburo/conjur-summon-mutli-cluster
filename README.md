# conjur-summon-multi-cluster

**Kısa Açıklama** ✅
Bu depo, Conjur ile entegrasyon yapan iki örnek uygulamayı ve bunların OpenShift/Kubernetes ile Conjur tarafı için gereken resource tanımlarını içerir. Amaç: farklı yöntemlerle (önceden yerleştirilmiş `secrets.yml` vs çalışma zamanında oluşturulan `secrets.yml`) Conjur'dan gizli bilgileri uygulamaya almaktır.

---

## İçindekiler
- **app/** — iki örnek uygulama
- **prod/** — production için Conjur policy ve OpenShift manifestleri
- **test/** — test için Conjur policy ve OpenShift manifestleri

---

## app/ dizini — Uygulamalar ve dosya rolleri 🔧
Her iki uygulama da basit bir Python uygulamasıdır (`app.py`) — döngü ile her 10 saniyede bir iki çevresel değişken (`APP_USERNAME` ve `APP_PASSWORD`) yazdırır. Değişkenler Conjur'dan alınır (Summon + Conjur provider kullanılarak).

### Ortak dosyalar
- `app.py` — Uygulamanın ana kodu (env değişkenlerini okur, yazdırır).
- `Dockerfile` — İmajı oluşturur (baz `nginx`, `python3` yüklemesi, `summon`/`summon-conjur` kopyalanması vs).
- `entrypoint.sh` — Container başladığında çalıştırılan komut; `summon` kullanarak `secrets.yml` içeriğini çözer ve uygulamayı başlatır.
- `summon`, `summon-conjur` — Summon ve Conjur provider ikilisi (repo içinde çalıştırılabilir dosyalar olarak bulunur).

---

### change_entrypoint/ 🔁
- **Özet:** `secrets.yml` imaj içine dahil edilir. `entrypoint.sh` çalıştırılırken `summon -e ${ENV_SELECTOR}` kullanılarak `secrets.yml` içindeki `test` ya da `prod` bölümü seçilir.
- **Dosyalar:**
  - `secrets.yml` — `test:` ve `prod:` blokları; `APP_USERNAME`/`APP_PASSWORD` için Conjur değişken yolları (`!var ...`).
  - `entrypoint.sh` — `/usr/local/bin/summon -e ${ENV_SELECTOR} --provider /usr/local/bin/summon-conjur -f /app/secrets.yml python3 /app/app.py`
- **Dockerfile notu:** `COPY secrets.yml /app/secrets.yml` ve `chmod 644 /app/secrets.yml` uygulanır.

### create_yml/ ✏️
- **Özet:** `secrets.yml` imajda yok; entrypoint runtime'da `SECRET_PATH_1` ve `SECRET_PATH_2` env değerlerinden yola çıkarak dosyayı oluşturur ve ardından `summon` ile uygulamayı başlatır.
- **Dosyalar:**
  - `entrypoint.sh` — `cat << EOF >> /app/secrets.yml` ile `APP_USERNAME: !var ${SECRET_PATH_1}` gibi satırlar ekler ve `chmod 644 /app/secrets.yml` yapar.
- **Dockerfile notu:** `secrets.yml` kopyalanmaz; dosya çalışma zamanında yaratılır.

---

## Dockerfile açıklamaları 📦
- `FROM nginx` — baz imaj
- `apt-get update && apt-get install -y python3` — Python kurulumu
- `/usr/local/bin/summon` ve `/usr/local/bin/summon-conjur` kopyalanır ve çalıştırılabilir yapılır
- `ENTRYPOINT ["/app/entrypoint.sh"]`

**Fark:** `change_entrypoint` imajı önceden hazırlanmış `secrets.yml` içerir; `create_yml` ise runtime sırasında `secrets.yml` üretir.

---

## Uygulamalar Arasındaki Önemli Farklar (Kısa) 📋
| Özellik | change_entrypoint | create_yml |
|---|---:|---:|
| secrets.yml kaynağı | İmaj içinde (repo) | Runtime'da oluşturulur |
| Seçim parametresi | `ENV_SELECTOR` (ör. `prod` veya `test`) | `SECRET_PATH_1`, `SECRET_PATH_2` (örn. `prod_secrets/username`) |
| İmaj güvenliği | Secrets imajda ise risk oluşturur | Daha iyi (secrets imajda durmaz) |

---

## prod/ ve test/ dizinleri — İçerikler ve görevleri 📂
Her iki ortam için benzer dosyalar vardır; yalnızca isimler ve namespace değerleri farklıdır.

### conjur_resources/
- `create_*_host.yml` — Conjur içinde uygulamanın host kaydını oluşturur (authn-k8s annotation'ları dahil).
- `create_*_secret.yml` — `*_secrets` policy'sini, içindeki `username` & `password` değişkenlerini ve `consumers` grubunu tanımlar.
- `give_access_to_host.yml` — Belirtilen host'a (`read`, `execute`) izinleri verir.

### oc_resources/
- `conjur-cm.yaml` — Conjur bağlantı ayarlarını (CONJUR_ACCOUNT, CONJUR_APPLIANCE_URL, CONJUR_AUTHN_LOGIN, CONJUR_AUTHN_URL, CONJUR_SSL_CERTIFICATE) içerir.
- `change_entrypoint_deploy.yaml` — `ENV_SELECTOR` (prod/test) ile deploy edilir; init container olarak Conjur authenticator çalışır ve `/run/conjur/access-token` sağlar.
- `create_yml_deploy.yaml` — `SECRET_PATH_1`/`SECRET_PATH_2` env'leri ile deploy edilir; diğer konfiglar similar.
- `create_serviceaccount*.yaml` — `summon-app-sa` ServiceAccount'u oluşturur.
- `give_access_to_follower.yaml` — Follower (Conjur follower) için gerekli RoleBinding örneği.

---

## Hızlı Dağıtım Adımları ⚙️
1. Conjur tarafında `conjur_resources/*` dosyalarını kullanarak policy, host ve izinleri oluşturun.
2. Kubernetes/Openshift tarafında `oc_resources/conjur-cm.yaml` ile ConfigMap'i ekleyin.
3. `create_serviceaccount*.yaml` ile ServiceAccount oluşturun.
4. İlgili deployment manifestini (`change_entrypoint_deploy.yaml` veya `create_yml_deploy.yaml`) uygulayın.

> İpucu: Prod ortamında secrets dosyasını imajda saklamaktan kaçının; `create_yml` ya da daha gelişmiş secret management akışları tercih edin. ⚠️

---

## Son Notlar
README'yi isteğinize göre daha da genişletebilirim (ör. örnek `conjur` komutları, CI/CD entegrasyonu, imaj build & tag kuralları vb.).

**Hazırlayan:** Repo içeriğine göre açıklayıcı dökümantasyon
