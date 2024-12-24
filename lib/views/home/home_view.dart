import 'dart:async';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late DateTime _currentDate;
  Timer? _timer;

  // -- YEŞİL --
  final List<String> _productiveCategories = ["Ders", "Proje", "İş"];
  String? _selectedProductive;
  Duration _productiveTotal = Duration.zero;
  Duration _productiveCurrentSession = Duration.zero;
  bool _isProductiveRunning = false;

  // -- KIRMIZI --
  final List<String> _unproductiveCategories = ["Youtube", "Sosyal Medya", "TV"];
  String? _selectedUnproductive;
  Duration _unproductiveTotal = Duration.zero;
  Duration _unproductiveCurrentSession = Duration.zero;
  bool _isUnproductiveRunning = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentDate = DateTime(now.year, now.month, now.day);

    if (_productiveCategories.isNotEmpty) {
      _selectedProductive = _productiveCategories.first;
    }
    if (_unproductiveCategories.isNotEmpty) {
      _selectedUnproductive = _unproductiveCategories.first;
    }

    // Her 1 saniyede bir timers güncellenir
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_isProductiveRunning) {
          _productiveCurrentSession += const Duration(seconds: 1);
        }
        if (_isUnproductiveRunning) {
          _unproductiveCurrentSession += const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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

  // Yeşile tıklama => çalışıyorsa duraklat, duraklatıksa devam ettir
  void _toggleProductive() {
    setState(() {
      _isProductiveRunning = !_isProductiveRunning;
    });
  }

  // Kırmızıya tıklama
  void _toggleUnproductive() {
    setState(() {
      _isUnproductiveRunning = !_isUnproductiveRunning;
    });
  }

  @override
  Widget build(BuildContext context) {
    final greenDisplay = _productiveTotal + _productiveCurrentSession;
    final redDisplay = _unproductiveTotal + _unproductiveCurrentSession;

    // “Duraklatıldı... (süre)” veya “Çalışıyor... (süre)”
    final productiveStatus = _isProductiveRunning
        ? "Çalışıyor... (${_formatDuration(_productiveCurrentSession)})"
        : "Duraklatıldı... (${_formatDuration(_productiveCurrentSession)})";

    final unproductiveStatus = _isUnproductiveRunning
        ? "Çalışıyor... (${_formatDuration(_unproductiveCurrentSession)})"
        : "Duraklatıldı... (${_formatDuration(_unproductiveCurrentSession)})";

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            // Kategori yönetimi veya kullanıcı profili
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
                // Takvim ekranına geç
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Yeşil Kısım
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text("Productive Work",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Kategori Seçimi
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedProductive,
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
                              _selectedProductive = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Kronometre Göstergesi
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
                        productiveStatus,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Kırmızı Kısım
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text("Unproductive Work",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Kategori Seçimi
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedUnproductive,
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
                              _selectedUnproductive = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Kronometre Göstergesi
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
                        unproductiveStatus,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Buraya "Kayıt", "History" vb. ekleyebilirsin
              ],
            ),
          ),
        ),
      ),
    );
  }
}
