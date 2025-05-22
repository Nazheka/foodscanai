import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';
import 'package:read_the_label/views/widgets/food_item_card.dart';
import 'package:read_the_label/views/widgets/total_nutrients_card.dart';
import '../widgets/food_item_card_shimmer.dart';
import '../widgets/total_nutrients_card_shimmer.dart';

class FoodAnalysisScreen extends StatefulWidget {
  const FoodAnalysisScreen({
    super.key,
  });

  @override
  _FoodAnalysisScreenState createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {
  late int currentIndex;
  @override
  void initState() {
    super.initState();
    // Initialize with a default value or get from provider
    currentIndex = context.read<UiViewModel>().currentIndex;
  }

  Future<void> _saveToHistory(BuildContext context) async {
    final mealViewModel = context.read<MealAnalysisViewModel>();
    final dailyIntakeViewModel = context.read<DailyIntakeViewModel>();

    if (mealViewModel.analyzedFoodItems.isNotEmpty) {
      // Save each food item to history
      for (var item in mealViewModel.analyzedFoodItems) {
        final nutrients = item.calculateTotalNutrients();
        await dailyIntakeViewModel.addToFoodHistory(
          foodName: item.name,
          nutrients: nutrients,
          source: 'analyzed',
          imagePath: '', // Add image path if available
        );
      }

      // Save total meal nutrients
      await dailyIntakeViewModel.addMealToDailyIntake(
        mealName: mealViewModel.mealName,
        totalPlateNutrients: mealViewModel.totalPlateNutrients,
        foodImage: mealViewModel.foodImage,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Food items saved to history'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        title: const Text('Food Analysis'),
        actions: [
          Consumer<MealAnalysisViewModel>(
            builder: (context, mealViewModel, _) {
              if (mealViewModel.analyzedFoodItems.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () => _saveToHistory(context),
                  tooltip: 'Save to history',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 80,
          ),
          child: Consumer2<UiViewModel, MealAnalysisViewModel>(
            builder: (context, uiViewModel, mealViewModel, _) {
              if (uiViewModel.loading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Analyzing food items...',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (uiViewModel.loading)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Analysis Results',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                        const FoodItemCardShimmer(),
                        const FoodItemCardShimmer(),
                        const TotalNutrientsCardShimmer(),
                      ],
                    ),
                  // Results Section
                  if (mealViewModel.analyzedFoodItems.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Analysis Results',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...mealViewModel.analyzedFoodItems
                            .asMap()
                            .entries
                            .map((entry) => FoodItemCard(
                                  item: entry.value,
                                  index: entry.key,
                                )),
                        const TotalNutrientsCard(),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () => _saveToHistory(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Save to History',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  // No results state
                  if (!uiViewModel.loading &&
                      mealViewModel.analyzedFoodItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No food items analyzed yet',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
