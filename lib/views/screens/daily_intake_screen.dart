import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/providers/connectivity_provider.dart';
import 'package:read_the_label/services/auth_service.dart';
import 'package:read_the_label/models/user.dart';
import 'package:read_the_label/viewmodels/auth_view_model.dart';

class DailyIntakeScreen extends StatefulWidget {
  const DailyIntakeScreen({super.key});

  @override
  State<DailyIntakeScreen> createState() => _DailyIntakeScreenState();
}

class _DailyIntakeScreenState extends State<DailyIntakeScreen> with SingleTickerProviderStateMixin {
  bool _isRefreshing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    _animationController.forward();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    _animationController.reverse();
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Intake'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Today\'s Summary',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Refresh',
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: _isRefreshing ? null : _refreshData,
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              tooltip: 'Calendar',
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: () {
                                // Your calendar logic here
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              context,
                              'Calories',
                              '1,200',
                              Icons.local_fire_department,
                              Colors.orange,
                            ),
                            _buildStatItem(
                              context,
                              'Protein',
                              '60g',
                              Icons.fitness_center,
                              Colors.blue,
                            ),
                            _buildStatItem(
                              context,
                              'Carbs',
                              '150g',
                              Icons.grain,
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Meals',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMealItem(
                          context,
                          'Breakfast',
                          'Oatmeal with fruits',
                          '350 cal',
                          Icons.wb_sunny,
                        ),
                        const Divider(),
                        _buildMealItem(
                          context,
                          'Lunch',
                          'Chicken salad',
                          '450 cal',
                          Icons.restaurant,
                        ),
                        const Divider(),
                        _buildMealItem(
                          context,
                          'Dinner',
                          'Grilled salmon',
                          '400 cal',
                          Icons.nightlight_round,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isRefreshing)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Refreshing...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildMealItem(
    BuildContext context,
    String mealType,
    String description,
    String calories,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Text(
            calories,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
} 