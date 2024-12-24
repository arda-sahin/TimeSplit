import 'dart:async';
import 'package:flutter/material.dart';

// Bu dosyayı lib/views/home/home_view.dart olarak kaydedebilirsin.
// Dosya yapına göre import yollarını düzenlemeyi unutma.

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Gün kontrolü için, uygulama açıldığında tuttuğumuz gün bilgisi
  late DateTime _currentDate;

  // Her 1 saniyede bir zaman güncellemesi yapacağız
  Timer? _timer;

  // ---- YEŞİL (Productive) ----
  // Productive kategorileri listesi (örneğin "ders", "iş", "yazılım geliştirme" vb.)
  final List<String> _productiveCategories = ["Ders", "İş", "Proje"];
  // Seçili kategori
  String? _selectedProductiveCategory;
  // Toplam süre (gün sonunda sıfırlanır)
  Duration _productiveTotal = Duration.zero;
  // Şu anda kaydedilmemiş oturum süresi (pause yaptığında artmayı durdurur)
  Duration _productiveCurrentSession = Duration.zero;
  // Çalışıyor mu?
  bool _isProductiveRunning = false;

  // ---- KIRMIZI (Unproductive) ----
  final List<String> _unproductiveCategories = ["Youtube", "Sosyal Medya", "TV"];
  String? _selectedUnproductiveCategory;
  Duration _unproductiveTotal = Duration.zero;
  Duration _unproductiveCurrentSession = Duration.zero;
  bool _isUnproductiveRunning = false;

  // ---- History (günün kayıtları) ----
  // Kayıtlar: kategori, süre, renk gibi bilgileri tutan basit bir sınıf
  final List<_HistoryItem> _history = [];

  @override
  void initState() {
    super.initState();

    // Uygulama ilk açıldığında bugünkü tarihi saklıyoruz
    final now = DateTime.now();
    _currentDate = DateTime(now.year, now.month, now.day);

    // Varsayılan olarak listelerin ilk kategorisi seçilsin
    if (_productiveCategories.isNotEmpty) {
      _selectedProductiveCategory = _productiveCategories.first;
    }
    if (_unproductiveCategories.isNotEmpty) {
      _selectedUnproductiveCategory = _unproductiveCategories.first;
    }

    // 1 saniyede bir timer: Süreleri increment edecek + her dakikada bir gün değişimini kontrol edecek
    // (Gün değişimini gerçek zamanlı tespit etmek için 1 dakika da yeterli olabilir,
    //  ama basit tutmak adına her 1 saniyede bir check yapıyoruz.)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimers();
      // Dakikanın ilk saniyesinde day check yapmak daha verimli olur ama
      // basit tutmak için her seferinde kontrol ediyoruz.
      _checkNewDay();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Her 1 saniyede bir çağrılacak fonksiyon:
  // Hangi kronometreler çalışıyorsa oturum süresi +1 saniye artacak
  void _updateTimers() {
    setState(() {
      if (_isProductiveRunning) {
        _productiveCurrentSession += const Duration(seconds: 1);
      }
      if (_isUnproductiveRunning) {
        _unproductiveCurrentSession += const Duration(seconds: 1);
      }
    });
  }

  // Eğer gün değişmişse, o ana kadar aktif işleri otomatik kaydeder ve timer’ları sıfırlar.
  void _checkNewDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Tarih değişmiş mi?
    if (today.isAfter(_currentDate)) {
      // Bir önceki günü kaydetmek için otomatik kayıt
      _autoSaveDayEnd();

      // Yeni günü başlat
      _currentDate = today;
      _resetForNewDay();
    }
  }

  // Gün sonunda otomatik kayıt: eğer herhangi bir oturum süresi varsa, “History”e ekle.
  void _autoSaveDayEnd() {
    // Productive
    if (_productiveCurrentSession.inSeconds > 0) {
      _history.add(_HistoryItem(
        category: _selectedProductiveCategory ?? "Unknown Productive",
        duration: _productiveCurrentSession,
        color: Colors.green,
        date: _currentDate,
      ));
    }
    // Unproductive
    if (_unproductiveCurrentSession.inSeconds > 0) {
      _history.add(_HistoryItem(
        category: _selectedUnproductiveCategory ?? "Unknown Unproductive",
        duration: _unproductiveCurrentSession,
        color: Colors.red,
        date: _currentDate,
      ));
    }
  }

  // Yeni güne geçerken total süreleri ve oturum sürelerini sıfırlar,
  // fakat “koşan” iş aynı kategoride devam etsin diye _isRunning boole’larını koruyabilir
  // ya da istersen kapatabilirsin.
  void _resetForNewDay() {
    setState(() {
      _productiveTotal = Duration.zero;
      _productiveCurrentSession = Duration.zero;

      _unproductiveTotal = Duration.zero;
      _unproductiveCurrentSession = Duration.zero;

      // İstersek timer’ı durdurabiliriz veya aynı category’de 0’dan devam da edebiliriz:
      // Örnek: durdurup, kullanıcı isterse tekrar başlatır.
      _isProductiveRunning = false;
      _isUnproductiveRunning = false;
    });
  }

  // Yeşil (productive) kutuya tıkla => başlat ya da durdur
  void _toggleProductive() {
    setState(() {
      // Eğer şu an productive çalışıyorsa => durdur (pause)
      if (_isProductiveRunning) {
        _isProductiveRunning = false;
      }
      else {
        // Çalışmıyorsa => başlat
        _isProductiveRunning = true;
        // Kırmızıyı aynı anda da çalıştırabilirsin. İstersen kapatmak istersin => _isUnproductiveRunning=false;
      }
    });
  }

  // Kırmızı (unproductive) kutuya tıkla => başlat ya da durdur
  void _toggleUnproductive() {
    setState(() {
      if (_isUnproductiveRunning) {
        _isUnproductiveRunning = false;
      } else {
        _isUnproductiveRunning = true;
      }
    });
  }

  // “Kaydet” butonuna basınca: Seçili (running) olan değil,
  // her bir kutuda o an birikmiş oturum sürelerini manual kaydederiz.
  // (İstersen sadece o an çalışanı kaydedebilirsin. Tasarım tercihi.)
  void _onSavePress() {
    // Onay penceresi aç: orada hangi veri kaydedilecek, göster
    _showConfirmDialog();
  }

  // Onay penceresi
  void _showConfirmDialog() {
    // Kaydedilecek veriler: yeşil ve kırmızı oturum süreleri
    final prodCat = _selectedProductiveCategory ?? "Unknown Prod";
    final unprodCat = _selectedUnproductiveCategory ?? "Unknown Unprod";

    final prodTime = _productiveCurrentSession;
    final unprodTime = _unproductiveCurrentSession;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Save Confirmation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Green ($prodCat): ${_formatDuration(prodTime)}"),
              Text("Red ($unprodCat): ${_formatDuration(unprodTime)}"),
              const SizedBox(height: 12),
              const Text("Kaydetmek istediğine emin misin?"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(), // iptal
              child: const Text("Vazgeç"),
            ),
            TextButton(
              onPressed: () {
                // Onaylandı => kayıt yap
                Navigator.of(ctx).pop();
                _saveConfirmed();
              },
              child: const Text("Onayla"),
            ),
          ],
        );
      },
    );
  }

  // Kullanıcı onaylarsa kaydet
  void _saveConfirmed() {
    setState(() {
      // 1) Productive
      if (_productiveCurrentSession.inSeconds > 0) {
        // History'ye ekle
        _history.add(_HistoryItem(
          category: _selectedProductiveCategory ?? "Unknown Prod",
          duration: _productiveCurrentSession,
          color: Colors.green,
          date: _currentDate,
        ));
        // Gün toplamını arttır
        _productiveTotal += _productiveCurrentSession;
        // Oturum süreyi sıfırla
        _productiveCurrentSession = Duration.zero;
      }

      // 2) Unproductive
      if (_unproductiveCurrentSession.inSeconds > 0) {
        _history.add(_HistoryItem(
          category: _selectedUnproductiveCategory ?? "Unknown Unprod",
          duration: _unproductiveCurrentSession,
          color: Colors.red,
          date: _currentDate,
        ));
        _unproductiveTotal += _unproductiveCurrentSession;
        _unproductiveCurrentSession = Duration.zero;
      }
    });
    // Not: Timer’ı durdurmadık. Kullanıcı isterse devam edebilir.
    // Mola vermek isterse, yine kutuya tıklayarak duraklatabilir.
  }

  // Süreyi HH:MM:SS formatında yazmak için
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String get _formattedDate {
    return "${_currentDate.day}/${_currentDate.month}/${_currentDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    // Yeşil kutuda gösterilecek: günün toplam + o anki oturum
    final greenDisplay = _productiveTotal + _productiveCurrentSession;
    // Kırmızı kutu
    final redDisplay = _unproductiveTotal + _unproductiveCurrentSession;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            // Kategori yönetimi ekranına gidebilirsin
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(_formattedDate),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                // Takvim ekranına geç => orada _history verilerini günlük bazda gösterebilirsin
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              // Kayıt Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Kayıt"),
                    onPressed: _onSavePress,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ------ YEŞİL BÖLÜM (Productive) ------
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Productive Work",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Kategori seçimi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedProductiveCategory,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: _productiveCategories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProductiveCategory = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Gösterge kutusu
                    GestureDetector(
                      onTap: _toggleProductive,
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _formatDuration(greenDisplay),
                            style: const TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isProductiveRunning
                          ? "Çalışıyor..."
                          : "Duraklatıldı (Devam etmek için dokun)",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ------ KIRMIZI BÖLÜM (Unproductive) ------
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Unproductive Work",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Kategori seçimi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedUnproductiveCategory,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: _unproductiveCategories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUnproductiveCategory = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Gösterge kutusu
                    GestureDetector(
                      onTap: _toggleUnproductive,
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _formatDuration(redDisplay),
                            style: const TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isUnproductiveRunning
                          ? "Çalışıyor..."
                          : "Duraklatıldı (Devam etmek için dokun)",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ------ HISTORY ------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "History (Bugün)",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          // Sadece bugünkü kayıtları göster
                          // (Daha önceki günler takvim ekranında gösterilebilir)
                          if (item.date == _currentDate) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.category),
                                  Text(_formatDuration(item.duration)),
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: item.color,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const SizedBox.shrink(); // Geçmiş günleri gizle
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Basit bir HistoryItem sınıfı
class _HistoryItem {
  final String category;
  final Duration duration;
  final Color color;
  final DateTime date; // Kaydedilen gün

  _HistoryItem({
    required this.category,
    required this.duration,
    required this.color,
    required this.date,
  });
}
