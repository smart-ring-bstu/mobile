
import 'package:flutter/material.dart';

void main() {
  runApp(const SmartRingApp());
}

class SmartRingApp extends StatelessWidget {
  const SmartRingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Ring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5267D8),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

class FamilyMember {
  final String id;
  final String name;
  final String relation;
  int heartRate;
  int battery;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.heartRate,
    required this.battery,
  });
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedTab = 0;

  bool _isConnected = true;
  bool _isSynced = true;
  bool _isSyncing = false;

  String _selectedMemberId = '1';
  DateTime _lastUpdated = DateTime.now();

  final List<FamilyMember> _familyMembers = [
    FamilyMember(
      id: '1',
      name: 'Александр',
      relation: 'Владелец аккаунта',
      heartRate: 72,
      battery: 85,
    ),
    FamilyMember(
      id: '2',
      name: 'Мария',
      relation: 'Член семьи',
      heartRate: 78,
      battery: 64,
    ),
    FamilyMember(
      id: '3',
      name: 'Дмитрий',
      relation: 'Член семьи',
      heartRate: 68,
      battery: 92,
    ),
  ];

  FamilyMember get _selectedMember {
    return _familyMembers.firstWhere(
      (member) => member.id == _selectedMemberId,
    );
  }

  String get _formattedLastUpdated {
    final hour = _lastUpdated.hour.toString().padLeft(2, '0');
    final minute = _lastUpdated.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  void _selectMember(String? memberId) {
    if (memberId == null) return;

    setState(() {
      _selectedMemberId = memberId;
    });
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
      _lastUpdated = DateTime.now();
    });

    _showMessage(
      _isConnected
          ? 'Кольцо подключено'
          : 'Кольцо отключено',
    );
  }

  void _updateMeasurements() {
    setState(() {
      _selectedMember.heartRate =
          65 + DateTime.now().second % 35;

      _selectedMember.battery =
          (_selectedMember.battery - 1).clamp(1, 100);

      _lastUpdated = DateTime.now();
    });

    _showMessage('Показатели обновлены');
  }

  Future<void> _synchronize() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _isSynced = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSyncing = false;
      _isSynced = true;
      _lastUpdated = DateTime.now();
    });

    _showMessage('Синхронизация завершена');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: [
            _buildHomePage(),
            _buildHistoryPage(),
            _buildRingPage(),
            _buildProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: 'История',
          ),
          NavigationDestination(
            icon: Icon(Icons.watch_outlined),
            selectedIcon: Icon(Icons.watch),
            label: 'Кольцо',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    final member = _selectedMember;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMART RING',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Главная',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            CircleAvatar(
              radius: 23,
              backgroundColor: const Color(0xFFE5E9FF),
              child: Icon(
                Icons.notifications_none,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildMemberSelector(member),

        const SizedBox(height: 20),

        _buildHeartRateCard(member),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildBatteryCard(member),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildConnectionCard(),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildSyncCard(),

        const SizedBox(height: 24),

        const Text(
          'Быстрые действия',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.show_chart,
                title: 'История',
                onTap: () => _selectTab(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                icon: Icons.watch,
                title: 'Управление',
                onTap: () => _selectTab(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                icon: Icons.person,
                title: 'Профиль',
                onTap: () => _selectTab(3),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        OutlinedButton.icon(
          onPressed: _updateMeasurements,
          icon: const Icon(Icons.refresh),
          label: const Text('Обновить тестовые показатели'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: Text(
            'Последнее обновление: $_formattedLastUpdated',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberSelector(FamilyMember member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE5E9FF),
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  member.relation,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: _selectedMemberId,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: _familyMembers.map((item) {
              return DropdownMenuItem(
                value: item.id,
                child: Text(item.name),
              );
            }).toList(),
            onChanged: _selectMember,
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateCard(FamilyMember member) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5267D8),
            Color(0xFF7889ED),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Текущий пульс',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'BPM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${member.heartRate}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 58,
                  height: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8, left: 8),
                child: Text(
                  'уд/мин',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Тестовое значение пульса',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryCard(FamilyMember member) {
    return _buildInfoCard(
      icon: Icons.battery_charging_full,
      title: 'Заряд кольца',
      value: '${member.battery}%',
      subtitle: 'Уровень заряда',
      iconColor: Colors.green,
    );
  }

  Widget _buildConnectionCard() {
    return _buildInfoCard(
      icon: _isConnected
          ? Icons.bluetooth_connected
          : Icons.bluetooth_disabled,
      title: 'Подключение',
      value: _isConnected ? 'Подключено' : 'Отключено',
      subtitle: 'Bluetooth',
      iconColor: _isConnected ? Colors.green : Colors.red,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncCard() {
    final Color statusColor = _isSyncing
        ? Colors.orange
        : _isSynced
            ? Colors.green
            : Colors.red;

    final String statusText = _isSyncing
        ? 'Выполняется синхронизация'
        : _isSynced
            ? 'Данные синхронизированы'
            : 'Ожидает синхронизации';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            Icons.sync,
            color: statusColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Синхронизация',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isSyncing ? null : _synchronize,
            icon: const Icon(Icons.refresh),
            tooltip: 'Синхронизировать',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(
                icon,
                size: 25,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryPage() {
    return _buildPlaceholderPage(
      icon: Icons.show_chart,
      title: 'История измерений',
      description:
          'Здесь будет отображаться история измерений пульса и графики за выбранный период.',
    );
  }

  Widget _buildRingPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Управление кольцом',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          icon: Icons.watch,
          title: 'Устройство',
          value: _isConnected ? 'Smart Ring' : 'Не подключено',
          subtitle: 'Тестовый режим',
          iconColor: _isConnected ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _toggleConnection,
          icon: Icon(
            _isConnected
                ? Icons.bluetooth_disabled
                : Icons.bluetooth_connected,
          ),
          label: Text(
            _isConnected
                ? 'Отключить кольцо'
                : 'Подключить кольцо',
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _updateMeasurements,
          icon: const Icon(Icons.refresh),
          label: const Text('Сгенерировать тестовые показатели'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePage() {
    final member = _selectedMember;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Профиль участника',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        CircleAvatar(
          radius: 42,
          backgroundColor: const Color(0xFFE5E9FF),
          child: Icon(
            Icons.person,
            size: 45,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            member.name,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Text(
            member.relation,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(height: 24),
        _buildProfileItem(
          Icons.favorite,
          'Текущий пульс',
          '${member.heartRate} уд/мин',
        ),
        _buildProfileItem(
          Icons.battery_charging_full,
          'Заряд кольца',
          '${member.battery}%',
        ),
        _buildProfileItem(
          Icons.bluetooth,
          'Состояние кольца',
          _isConnected ? 'Подключено' : 'Отключено',
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            _showMessage('Настройки будут добавлены позднее');
          },
          icon: const Icon(Icons.settings),
          label: const Text('Настройки'),
        ),
      ],
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 14,
    );
  }

  Widget _buildPlaceholderPage({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 65,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Chip(
              label: Text('В разработке'),
            ),
          ],
        ),
      ),
    );
  }
}
