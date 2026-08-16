# Single-currency app (COP) until per-commerce currency exists — see
# Product::CURRENCY. Setting the default here is what lets `monetize` omit a
# per-row currency column entirely.
MoneyRails.configure do |config|
  config.default_currency = :cop
end
