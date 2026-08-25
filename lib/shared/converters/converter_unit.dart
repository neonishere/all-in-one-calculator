/// A single convertible unit within a family (length, weight, temperature...).
/// Conversions go through a shared base unit so any unit can convert to any
/// other without needing a factor between every pair.
class ConverterUnit {
  const ConverterUnit({
    required this.id,
    required this.label,
    required this.shortLabel,
    required double Function(double value) toBase,
    required double Function(double baseValue) fromBase,
  })  : _toBase = toBase,
        _fromBase = fromBase;

  /// Simple multiplicative unit (length, weight, area, ...): [factor] is how
  /// many base units one of this unit is worth.
  factory ConverterUnit.linear({
    required String id,
    required String label,
    required String shortLabel,
    required double factor,
  }) {
    return ConverterUnit(
      id: id,
      label: label,
      shortLabel: shortLabel,
      toBase: (value) => value * factor,
      fromBase: (baseValue) => baseValue / factor,
    );
  }

  final String id;
  final String label;
  final String shortLabel;
  final double Function(double value) _toBase;
  final double Function(double value) _fromBase;

  double toBase(double value) => _toBase(value);
  double fromBase(double baseValue) => _fromBase(baseValue);
}
