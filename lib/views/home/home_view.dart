import 'dart:async';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Timer: her 1 saniyede bir "akmakta olan iş"i günceller
  Timer? _timer;

  // Günün toplam süreleri (asla sıfırlanmaz; gün bitince resetlenebilir)
  Duration _productiveTotal = Duration.zero;
  Duration _unproductiveTotal = Duration.zero;

  // Şu anda aktif olan işin süresi (parça süre).
  // "Start" dendiğinde 0’dan başlar ve ilerler. "Kaydet" veya iş değiştirince sıfırlanır.
  Duration _currentJobTime = Duration.zero;

  // Hangisi çalışıyor? 'productive', 'unproductive' veya null
  String? _currentlyRunning;

  // History listesi (parça kayıtlar)
  final List<_HistoryItem> _history = [];

  // Kategori seçimi (örnek bir liste)
  final List<String> _mockCategories = ["Work1", "Work2"];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Varsayılan olarak bir kategori seçili olsun
    if (_mockCategories.isNotEmpty) {
      _selectedCategory = _mockCategories.first;
    }

    // Her 1 saniyede bir Timer tetiklenerek, mevcut iş varsa _currentJobTime artacak
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentlyRunning != null) {
        setState(() {
          _currentJobTime += const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    // Ekrandan çıkarken Timer’ı iptal et
    _timer?.cancel();
    super.dispose();
  }

  // Süreyi "HH:MM:SS" formatına çeviren yardımcı fonksiyon
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // Üstte gösterilen tarih formatı (örnek basit kullanım)
  String get _formattedDate {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  // Yeşil kutuya tıklama
  void _onTapGreen() {
    setState(() {
      // Eğer zaten yeşil çalışıyorsa => durdur
      if (_currentlyRunning == 'productive') {
        _currentlyRunning = null;
        // Burada durdurmak haricinde _currentJobTime sıfırlamıyoruz.
        // Çünkü "Kaydet" butonuna basılmadı. Kullanıcı kaydetmek isterse
        // bu süreden yararlanır veya farklı bir mantık kurabilirsin.
      }
      // Eğer kırmızı çalışıyorsa => onu durdur ve yeşili başlat (parça süreyi sıfırla)
      else if (_currentlyRunning == 'unproductive') {
        _currentlyRunning = 'productive';
        // Kırmızıdayken biriktirilmiş parça süreyi eğer kaydetmeden geçiyorsa
        // sıfırlayabilir veya otomatik kaydedebilirsin. Şimdilik sıfırlıyoruz.
        _currentJobTime = Duration.zero;
      }
      // Eğer hiçbir şey çalışmıyorsa => yeşili başlat
      else {
        _currentlyRunning = 'productive';
        _currentJobTime = Duration.zero;
      }
    });
  }

  // Kırmızı kutuya tıklama
  void _onTapRed() {
    setState(() {
      // Eğer zaten kırmızı çalışıyorsa => durdur
      if (_currentlyRunning == 'unproductive') {
        _currentlyRunning = null;
      }
      // Eğer yeşil çalışıyorsa => durdur ve kırmızı başlat
      else if (_currentlyRunning == 'productive') {
        _currentlyRunning = 'unproductive';
        _currentJobTime = Duration.zero;
      }
      // Eğer hiçbiri çalışmıyorsa => kırmızıyı başlat
      else {
        _currentlyRunning = 'unproductive';
        _currentJobTime = Duration.zero;
      }
    });
  }

  // Kaydet butonuna tıklama
  // O anda hangi iş çalışıyorsa onun parça süresi history'e eklenir;
  // toplam süreye eklenir; _currentJobTime = 0
  void _saveTimerData() {
    if (_currentlyRunning == null) {
      // Hiçbir iş çalışmıyor
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No active job to save.")),
      );
      return;
    }

    // O an hangi kategori seçili?
    final category = _selectedCategory ?? "Unknown";

    // Parça süre
    final chunk = _currentJobTime;

    // History'e ekle
    final color =
    (_currentlyRunning == 'productive') ? Colors.green : Colors.red;
    setState(() {
      _history.add(_HistoryItem(
        category: category,
        duration: chunk,
        color: color,
      ));

      // Günün toplamına ekle
      if (_currentlyRunning == 'productive') {
        _productiveTotal += chunk;
      } else {
        _unproductiveTotal += chunk;
      }

      // Parça süreyi sıfırla
      _currentJobTime = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Yeşil karede gösterilecek toplam süre
    // Eğer yeşil çalışıyorsa, (günün toplam süresi + parça süre)
    final productiveDisplay = (_currentlyRunning == 'productive')
        ? _productiveTotal + _currentJobTime
        : _productiveTotal;

    // Kırmızı karede gösterilecek toplam süre
    final unproductiveDisplay = (_currentlyRunning == 'unproductive')
        ? _unproductiveTotal + _currentJobTime
        : _unproductiveTotal;

    // “Mevcut iş süresi” göstermek için
    final currentJobText = (_currentlyRunning == null)
        ? "No active job"
        : "Current job time: ${_formatDuration(_currentJobTime)}";

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(_formattedDate),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                // Takvim ekranına geçiş
              },
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            // Kategori yönetimi ya da kullanıcı ayarları ekranına gidebilirsin
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              // WORK + Category + Save
              Row(
                children: [
                  const Text(
                    "Work:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: _mockCategories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveTimerData,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Yeşil ve Kırmızı kutular
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Yeşil
                  GestureDetector(
                    onTap: _onTapGreen,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _formatDuration(productiveDisplay),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Kırmızı
                  GestureDetector(
                    onTap: _onTapRed,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _formatDuration(unproductiveDisplay),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Mevcut iş süresi (Current job time)
              Text(
                currentJobText,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 30),

              // History
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "History",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Basit bir "History" item modeli
class _HistoryItem {
  final String category;
  final Duration duration;
  final Color color;

  _HistoryItem({
    required this.category,
    required this.duration,
    required this.color,
  });
}
