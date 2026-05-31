import 'package:flutter/material.dart';

class CountriesInfoScreen extends StatefulWidget {
  const CountriesInfoScreen({super.key});

  @override
  State<CountriesInfoScreen> createState() => _CountriesInfoScreenState();
}

class _CountriesInfoScreenState extends State<CountriesInfoScreen> {
  String? _selectedCountryName;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final Color _primaryColor = const Color(0xFF1E7E6C);

  // Full detailed countries database supporting dynamic border linking
  final List<Map<String, dynamic>> _countriesData = [
    {
      'name': 'Afghanistan',
      'flagUrl': 'https://flagcdn.com/w160/af.png',
      'flagEmoji': '🇦🇫',
      'abbreviation': 'AFG',
      'demonym': 'Afghan',
      'callingCode': '+93',
      'currency': 'Afghan Afghani',
      'population': '40 million+',
      'region': 'Asia',
      'timezone': 'UTC +04:30',
      'capital': 'Kabul',
      'borders': ['Iran', 'Pakistan', 'Turkmenistan', 'Uzbekistan', 'Tajikistan', 'China'],
    },
    {
      'name': 'Pakistan',
      'flagUrl': 'https://flagcdn.com/w160/pk.png',
      'flagEmoji': '🇵🇰',
      'abbreviation': 'PAK',
      'demonym': 'Pakistani',
      'callingCode': '+92',
      'currency': 'Pakistani Rupee',
      'population': '230 million+',
      'region': 'Asia',
      'timezone': 'UTC +05:00',
      'capital': 'Islamabad',
      'borders': ['Afghanistan', 'China', 'India', 'Iran'],
    },
    {
      'name': 'India',
      'flagUrl': 'https://flagcdn.com/w160/in.png',
      'flagEmoji': '🇮🇳',
      'abbreviation': 'IND',
      'demonym': 'Indian',
      'callingCode': '+91',
      'currency': 'Indian Rupee',
      'population': '1.4 billion+',
      'region': 'Asia',
      'timezone': 'UTC +05:30',
      'capital': 'New Delhi',
      'borders': ['Pakistan', 'China'],
    },
    {
      'name': 'China',
      'flagUrl': 'https://flagcdn.com/w160/cn.png',
      'flagEmoji': '🇨🇳',
      'abbreviation': 'CHN',
      'demonym': 'Chinese',
      'callingCode': '+86',
      'currency': 'Renminbi',
      'population': '1.4 billion+',
      'region': 'Asia',
      'timezone': 'UTC +08:00',
      'capital': 'Beijing',
      'borders': ['Afghanistan', 'Pakistan', 'India', 'Tajikistan', 'Uzbekistan'],
    },
    {
      'name': 'Iran',
      'flagUrl': 'https://flagcdn.com/w160/ir.png',
      'flagEmoji': '🇮🇷',
      'abbreviation': 'IRN',
      'demonym': 'Iranian',
      'callingCode': '+98',
      'currency': 'Iranian Rial',
      'population': '88 million+',
      'region': 'Asia',
      'timezone': 'UTC +03:30',
      'capital': 'Tehran',
      'borders': ['Pakistan', 'Afghanistan', 'Turkmenistan'],
    },
    {
      'name': 'Tajikistan',
      'flagUrl': 'https://flagcdn.com/w160/tj.png',
      'flagEmoji': '🇹🇯',
      'abbreviation': 'TJK',
      'demonym': 'Tajikistani',
      'callingCode': '+992',
      'currency': 'Tajikistani Somoni',
      'population': '10 million+',
      'region': 'Asia',
      'timezone': 'UTC +05:00',
      'capital': 'Dushanbe',
      'borders': ['Afghanistan', 'China', 'Uzbekistan'],
    },
    {
      'name': 'Uzbekistan',
      'flagUrl': 'https://flagcdn.com/w160/uz.png',
      'flagEmoji': '🇺🇿',
      'abbreviation': 'UZB',
      'demonym': 'Uzbek',
      'callingCode': '+998',
      'currency': 'Uzbek Som',
      'population': '36 million+',
      'region': 'Asia',
      'timezone': 'UTC +05:00',
      'capital': 'Tashkent',
      'borders': ['Tajikistan', 'Afghanistan', 'Turkmenistan'],
    },
    {
      'name': 'Turkmenistan',
      'flagUrl': 'https://flagcdn.com/w160/tm.png',
      'flagEmoji': '🇹🇲',
      'abbreviation': 'TKM',
      'demonym': 'Turkmen',
      'callingCode': '+993',
      'currency': 'Turkmen Somoni',
      'population': '6 million+',
      'region': 'Asia',
      'timezone': 'UTC +05:00',
      'capital': 'Ashgabat',
      'borders': ['Uzbekistan', 'Afghanistan', 'Iran'],
    }
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter countries list based on query
  List<Map<String, dynamic>> _getFilteredCountries() {
    if (_searchQuery.isEmpty) return _countriesData;
    return _countriesData
        .where((c) =>
            c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c['capital'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedCountryName != null) {
      final country = _countriesData.firstWhere(
        (c) => c['name'] == _selectedCountryName,
        orElse: () => _countriesData[0],
      );
      return _buildCountryDetailsView(country);
    }

    return _buildCountriesIndexView();
  }

  // ── VIEW 1: SEARCH & BROWSING LISTING ──
  Widget _buildCountriesIndexView() {
    final list = _getFilteredCountries();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Countries Info',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Text Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(fontSize: 16, color: Color(0xFF1F1F1F)),
                  decoration: InputDecoration(
                    hintText: 'Search countries or capitals...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF), size: 18),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Countries ListView
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          const Text(
                            'No countries found',
                            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(color: Color(0xFFF3F4F6)),
                      itemBuilder: (context, index) {
                        final c = list[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          leading: _buildRoundFlag(c['flagUrl'], c['flagEmoji'], 44),
                          title: Text(
                            c['name'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111111)),
                          ),
                          subtitle: Text(
                            'Capital: ${c['capital']}',
                            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                          onTap: () {
                            setState(() {
                              _selectedCountryName = c['name'];
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── VIEW 2: COUNTRY DETAILS VIEW (Pixel-Perfect Mockup Copy) ──
  Widget _buildCountryDetailsView(Map<String, dynamic> c) {
    final List<String> borders = List<String>.from(c['borders']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () {
            setState(() {
              _selectedCountryName = null;
            });
          },
        ),
        title: const Text(
          'Country Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Round Flag + Teal-Green Name ──
              Row(
                children: [
                  _buildRoundFlag(c['flagUrl'], c['flagEmoji'], 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      c['name'],
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── 8-Card structural data sheet grid (2 Column layout) ──
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 2.1,
                children: [
                  _buildDetailsCard('Abbreviation', c['abbreviation']),
                  _buildDetailsCard('Demonym', c['demonym']),
                  _buildDetailsCard('Calling Code', c['callingCode']),
                  _buildDetailsCard('Currency', c['currency']),
                  _buildDetailsCard('Population', c['population']),
                  _buildDetailsCard('Region', c['region']),
                  _buildDetailsCard('Time Zone', c['timezone']),
                  _buildDetailsCard('Capital', c['capital']),
                ],
              ),
              const SizedBox(height: 32),

              // ── Borders Title ──
              const Text(
                'Borders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),

              // ── Bordering Countries List Frame ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: borders.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No bordering countries',
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: borders.length,
                        itemBuilder: (context, index) {
                          final borderName = borders[index];
                          // Match against database
                          final matchedBorder = _countriesData.firstWhere(
                            (x) => x['name'] == borderName,
                            orElse: () => <String, dynamic>{},
                          );

                          final hasData = matchedBorder.isNotEmpty;
                          final bUrl = hasData ? matchedBorder['flagUrl'] : null;
                          final bEmoji = hasData ? matchedBorder['flagEmoji'] : '🏳️';

                          return GestureDetector(
                            onTap: () {
                              if (hasData) {
                                setState(() {
                                  _selectedCountryName = borderName;
                                });
                              } else {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Details for "$borderName" are coming soon!'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildRoundFlag(bUrl, bEmoji, 38),
                                const SizedBox(height: 6),
                                Text(
                                  borderName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Details Card builder
  Widget _buildDetailsCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }

  // Circular flag asset builder with vector fallback
  Widget _buildRoundFlag(String? url, String emoji, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: url != null
            ? Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, prog) {
                  if (prog == null) return child;
                  return const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5)));
                },
                errorBuilder: (_, __, ___) => _buildEmojiBadge(emoji, size),
              )
            : _buildEmojiBadge(emoji, size),
      ),
    );
  }

  Widget _buildEmojiBadge(String emoji, double size) {
    return Center(
      child: Text(
        emoji,
        style: TextStyle(fontSize: size * 0.52),
      ),
    );
  }
}
