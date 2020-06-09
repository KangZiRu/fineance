String formatCurrency({int nominal, String currency="Rp"}) {
  String stringNominal = nominal.toString();

  if (nominal < 0) {
    stringNominal = stringNominal.substring(1);
  }
  
  List<String> real = new List<String>();
  int index = 1;
  for (int i = stringNominal.length - 1; i >= 0; i--) {
    real.add(stringNominal[i]);
    if (index % 3 == 0 && i > 0) {
      real.add(",");
    }

    index++;
  }

  return currency + " " + (nominal >= 0 ? "" : "-") +  real.reversed.join("");
}
