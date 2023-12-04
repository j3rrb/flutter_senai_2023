class LocationModel {
  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String localidade;
  final String uf;
  final String ibge;
  final String gia;
  final String ddd;
  final String siafi;

  const LocationModel({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.ibge,
    required this.gia,
    required this.ddd,
    required this.siafi,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "cep": String cep,
        "logradouro": String logradouro,
        "complemento": String complemento,
        "bairro": String bairro,
        "localidade": String localidade,
        "uf": String uf,
        "ibge": String ibge,
        "gia": String gia,
        "ddd": String ddd,
        "siafi": String siafi
      } =>
        LocationModel(
            bairro: bairro,
            cep: cep,
            complemento: complemento,
            ddd: ddd,
            gia: gia,
            ibge: ibge,
            localidade: localidade,
            logradouro: logradouro,
            uf: uf,
            siafi: siafi),
      _ => throw const FormatException('Failed to load location.'),
    };
  }
}
