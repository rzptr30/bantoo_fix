import 'package:flutter/material.dart';
import '../models/donasi_ini.dart';
import '../services/api_service.dart';
import '../widgets/widgets.dart';   // barrel file
import 'emergency_bantoo_screen.dart'; // Import halaman emergency bantoo
import 'add_campaign_screen.dart';  // Import halaman tambah campaign

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Donasi>> futureDonasi;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    futureDonasi = ApiService.getDonasi();
  }

  /* ───── helper ───── */
  void _refresh() => setState(() => futureDonasi = ApiService.getDonasi());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* ───────────  APP BAR  ─────────── */
      appBar: dashboardAppBar(onRefresh: _refresh),

      /* ───────────  BODY  ─────────── */
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: GreetingCard()),
            const SliverToBoxAdapter(child: SearchBarDash()),

            /* ── Section 1 : Campaign Emergency ── */
            SectionHeader(
              title: 'Emergency Bantoo!',
              showSeeAll: true,
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyBantooScreen(),
                  ),
                ).then((_) => _refresh()); // Refresh setelah kembali dari halaman Emergency
              },
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 230,
                child: FutureBuilder<List<Donasi>>(
                  future: futureDonasi,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    }
                    final data = snap.data ?? [];
                    if (data.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.campaign_outlined, 
                              size: 40, 
                              color: Colors.grey
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada donasi emergency',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddCampaignScreen(),
                                  ),
                                ).then((_) => _refresh());
                              },
                              child: const Text('Tambah Campaign'),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => CampaignCard(donasi: data[i]),
                    );
                  },
                ),
              ),
            ),

            /* ── Section 2 : Event ── */
            const SectionHeader(title: 'The Event Is About To Expire'),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 310,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => EventCard(
                    title: 'Pelatihan One Day Thousand Smiles',
                    subtitle: 'Surabaya, Jawa Timur • 14/05/2025',
                    imageAsset: 'assets/images/event_$i.jpg',
                    // Tambahkan error handler untuk gambar
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            /* ── Section 3 : Category chips ── */
            const SectionHeader(title: 'Choose Bantoo Favourite Category'),
            const SliverToBoxAdapter(child: CategoryChips()),

            /* ── Section 4 : Banner ajakan ── */
            const SectionHeader(title: 'Ask For New Campaign'),
            SliverToBoxAdapter(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddCampaignScreen(),
                    ),
                  ).then((_) => _refresh());
                },
                child: const BannerAddCampaign(),
              ),
            ),

            /* ── Footer ── */
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    '© 2025 Bantoo — All rights reserved',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      /* ───────────  BOTTOM NAV  ─────────── */
      bottomNavigationBar: mainBottomBar(
        current: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}