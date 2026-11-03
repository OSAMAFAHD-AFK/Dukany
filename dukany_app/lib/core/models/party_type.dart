/// The two kinds of accounts the shop keeps: customers who owe the shop,
/// and suppliers (wholesale companies) the shop owes.
enum PartyType {
  customer,
  supplier;

  static PartyType fromName(String name) =>
      PartyType.values.firstWhere((type) => type.name == name, orElse: () => PartyType.customer);
}
