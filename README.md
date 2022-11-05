# conjur-summon-mutli-cluster

Use same application image on multiple environment

**Kullanım özelliklerini app dizini içerisinde bulabilirsiniz.**

# Metod kullanımları

# 1- Dinamik entrypoint

Tüm conjur secretlarını ortamlara göre ayırarak secrets.yml dosyası içine yazın. (Syntaxa app/change_entrypoint/secrets.yml dosyası içerisinden bakılabilir.)
Container içerisinde key: ENV_SELECTOR ve value: <grup_ismi> şeklide bir çevre değişkeni tanımlayın. ({prod,test}/oc_resources/create_yml_deploy.yaml dosyasından referans alınabilir.)
entrypoiont.sh dosyası çalışırken dinamik olarak ilgili grubun secretlarını çekecektir.

# Container'ı run ederken secrets.yml dosyasını oluşturma.

Container içinde SECRET_PATH_1 ve SECRET_PATH_2 şeklinde çevre değişkenleri tanımlayın. Bu değişken isimleri app/create_yml/entrypoint.sh dosyası içindekiler ile aynı olmalı. Farklı isimde yada sayıda secret çekilecek ise entrypoint.sh dosyası ilgili şekilde editlenebilir.
Tanımlanan değişkenlerin valueları secretların conjur üzerindeki pathleri olmalı.
Container run edildiğinde önce secrets.yml dosyası ilgili değişkenlere göre oluşturulacak ve sonrasında uygulama çalışacaktır.

# Metodları incelemek için aşağıdaki dizineleri kontrol edebilirsiniz.

- **app dizininin tamamı.**
- **prod yada test dizinlerindeki deployment dosyaları.**