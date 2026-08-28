import 'package:flutter/material.dart';

import '../../features/algebra/average_screen.dart';
import '../../features/algebra/combinations_screen.dart';
import '../../features/algebra/equations_screen.dart';
import '../../features/algebra/gcf_lcm_screen.dart';
import '../../features/algebra/number_generator_screen.dart';
import '../../features/algebra/percentage_screen.dart';
import '../../features/algebra/prime_checker_screen.dart';
import '../../features/algebra/proportion_screen.dart';
import '../../features/algebra/ratio_screen.dart';
import '../../features/date_time/age_calculator_screen.dart';
import '../../features/finance/currency_converter_screen.dart';
import '../../features/finance/sales_tax_screen.dart';
import '../../features/finance/tip_screen.dart';
import '../../features/geometry/shapes_screen.dart';
import '../../features/health/bmi_screen.dart';
import '../../features/other/ohms_law_screen.dart';
import '../../features/unit_converters/length_screen.dart';
import '../../features/unit_converters/temperature_screen.dart';
import '../../features/unit_converters/weight_screen.dart';
import 'tool_category.dart';
import 'tool_entry.dart';

/// Every tool the app offers, grouped by category. Tools without a
/// `builder` are on the roadmap and show a "coming soon" placeholder.
final List<ToolEntry> toolCatalog = [
  // Algebra
  ToolEntry(id: 'percentage', title: 'Percentage', category: ToolCategory.algebra, icon: Icons.percent, builder: (_) => const PercentageScreen()),
  ToolEntry(id: 'average', title: 'Average', category: ToolCategory.algebra, icon: Icons.show_chart, builder: (_) => const AverageScreen()),
  ToolEntry(id: 'proportion', title: 'Proportion', category: ToolCategory.algebra, icon: Icons.balance, builder: (_) => const ProportionScreen()),
  ToolEntry(id: 'ratio', title: 'Ratio', category: ToolCategory.algebra, icon: Icons.compare_arrows, builder: (_) => const RatioScreen()),
  ToolEntry(id: 'equations', title: 'Equations', category: ToolCategory.algebra, icon: Icons.functions, builder: (_) => const EquationsScreen()),
  ToolEntry(id: 'gcf_lcm', title: 'GCF & LCM', category: ToolCategory.algebra, icon: Icons.grid_3x3, builder: (_) => const GcfLcmScreen()),
  ToolEntry(id: 'combinations', title: 'Combinations', category: ToolCategory.algebra, icon: Icons.shuffle, builder: (_) => const CombinationsScreen()),
  ToolEntry(id: 'prime_checker', title: 'Prime checker', category: ToolCategory.algebra, icon: Icons.tag, builder: (_) => const PrimeCheckerScreen()),
  ToolEntry(id: 'number_generator', title: 'Number generator', category: ToolCategory.algebra, icon: Icons.casino, builder: (_) => const NumberGeneratorScreen()),

  // Geometry
  ToolEntry(id: 'shapes', title: 'Shapes', category: ToolCategory.geometry, icon: Icons.category, builder: (_) => const ShapesScreen()),
  const ToolEntry(id: 'bodies', title: 'Bodies', category: ToolCategory.geometry, icon: Icons.view_in_ar),

  // Unit converters
  ToolEntry(id: 'length', title: 'Length', category: ToolCategory.unitConverters, icon: Icons.straighten, builder: (_) => const LengthScreen()),
  ToolEntry(id: 'weight', title: 'Weight', category: ToolCategory.unitConverters, icon: Icons.fitness_center, builder: (_) => const WeightScreen()),
  const ToolEntry(id: 'speed', title: 'Speed', category: ToolCategory.unitConverters, icon: Icons.speed),
  ToolEntry(id: 'temperature', title: 'Temperature', category: ToolCategory.unitConverters, icon: Icons.thermostat, builder: (_) => const TemperatureScreen()),
  const ToolEntry(id: 'area', title: 'Area', category: ToolCategory.unitConverters, icon: Icons.crop_square),
  const ToolEntry(id: 'volume', title: 'Volume', category: ToolCategory.unitConverters, icon: Icons.local_drink),
  const ToolEntry(id: 'time', title: 'Time', category: ToolCategory.unitConverters, icon: Icons.timer),
  const ToolEntry(id: 'data_storage', title: 'Data storage', category: ToolCategory.unitConverters, icon: Icons.storage),
  const ToolEntry(id: 'data_transfer', title: 'Data transfer', category: ToolCategory.unitConverters, icon: Icons.swap_vert),
  const ToolEntry(id: 'energy', title: 'Energy', category: ToolCategory.unitConverters, icon: Icons.bolt),
  const ToolEntry(id: 'power', title: 'Power', category: ToolCategory.unitConverters, icon: Icons.electric_bolt),
  const ToolEntry(id: 'pressure', title: 'Pressure', category: ToolCategory.unitConverters, icon: Icons.compress),
  const ToolEntry(id: 'force', title: 'Force', category: ToolCategory.unitConverters, icon: Icons.compress),
  const ToolEntry(id: 'fuel', title: 'Fuel economy', category: ToolCategory.unitConverters, icon: Icons.local_gas_station),
  const ToolEntry(id: 'angle', title: 'Angle', category: ToolCategory.unitConverters, icon: Icons.rotate_right),
  const ToolEntry(id: 'acceleration', title: 'Acceleration', category: ToolCategory.unitConverters, icon: Icons.speed),
  const ToolEntry(id: 'torque', title: 'Torque', category: ToolCategory.unitConverters, icon: Icons.settings),
  const ToolEntry(id: 'numeric_base', title: 'Numeric base', category: ToolCategory.unitConverters, icon: Icons.pin),
  const ToolEntry(id: 'roman_numerals', title: 'Roman numerals', category: ToolCategory.unitConverters, icon: Icons.abc),
  const ToolEntry(id: 'shoe_size', title: 'Shoe size', category: ToolCategory.unitConverters, icon: Icons.check_box_outline_blank),
  const ToolEntry(id: 'ring_size', title: 'Ring size', category: ToolCategory.unitConverters, icon: Icons.circle_outlined),
  const ToolEntry(id: 'cooking', title: 'Cooking', category: ToolCategory.unitConverters, icon: Icons.restaurant),
  const ToolEntry(id: 'volumetric_flow', title: 'Volumetric flow', category: ToolCategory.unitConverters, icon: Icons.water),

  // Finance
  ToolEntry(id: 'currency_converter', title: 'Currency converter', category: ToolCategory.finance, icon: Icons.currency_exchange, builder: (_) => const CurrencyConverterScreen()),
  const ToolEntry(id: 'unit_price', title: 'Unit price', category: ToolCategory.finance, icon: Icons.local_offer),
  ToolEntry(id: 'sales_tax', title: 'Sales tax', category: ToolCategory.finance, icon: Icons.receipt_long, builder: (_) => const SalesTaxScreen()),
  ToolEntry(id: 'tip', title: 'Tip', category: ToolCategory.finance, icon: Icons.volunteer_activism, builder: (_) => const TipScreen()),
  const ToolEntry(id: 'loan', title: 'Loan', category: ToolCategory.finance, icon: Icons.account_balance),
  const ToolEntry(id: 'interest', title: 'Interest', category: ToolCategory.finance, icon: Icons.savings),

  // Health
  ToolEntry(id: 'bmi', title: 'Body mass index', category: ToolCategory.health, icon: Icons.monitor_weight, builder: (_) => const BmiScreen()),
  const ToolEntry(id: 'caloric_burn', title: 'Caloric burn', category: ToolCategory.health, icon: Icons.local_fire_department),
  const ToolEntry(id: 'body_fat', title: 'Body fat', category: ToolCategory.health, icon: Icons.accessibility_new),

  // Date & time
  ToolEntry(id: 'age_calculator', title: 'Age calculator', category: ToolCategory.dateTime, icon: Icons.cake, builder: (_) => const AgeCalculatorScreen()),
  const ToolEntry(id: 'add_subtract', title: 'Add & subtract', category: ToolCategory.dateTime, icon: Icons.date_range),
  const ToolEntry(id: 'time_interval', title: 'Time interval', category: ToolCategory.dateTime, icon: Icons.hourglass_bottom),

  // Other
  const ToolEntry(id: 'mileage', title: 'Mileage', category: ToolCategory.other, icon: Icons.directions_car),
  ToolEntry(id: 'ohms_law', title: "Ohm's law", category: ToolCategory.other, icon: Icons.electrical_services, builder: (_) => const OhmsLawScreen()),
];
