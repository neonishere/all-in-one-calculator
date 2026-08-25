/// Free key from https://www.exchangerate-api.com/ (open access, no card required).
/// Get one and paste it below — the currency converter won't fetch live rates without it.
const String exchangeRateApiKey = String.fromEnvironment(
  'EXCHANGE_RATE_API_KEY',
  defaultValue: '',
);
