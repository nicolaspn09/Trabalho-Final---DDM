class Transacao {
  final String? id;
  final String titulo;
  final double valor;
  final String tipo; // 'receita' ou 'despesa'
  final String data;
  final String categoria;
  final String? icone; // E.g., '🍔', '🚗', '💰'
  final String? banco; // E.g., 'Nubank Crédito **** 2059'

  Transacao({
    this.id,
    required this.titulo,
    required this.valor,
    required this.tipo,
    required this.data,
    required this.categoria,
    this.icone,
    this.banco,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'valor': valor,
      'tipo': tipo,
      'data': data,
      'categoria': categoria,
      if (icone != null) 'icone': icone,
      if (banco != null) 'banco': banco,
    };
  }

  factory Transacao.fromMap(Map<String, dynamic> map, String idVal) {
    return Transacao(
      id: idVal,
      titulo: map['titulo'] as String,
      valor: (map['valor'] as num).toDouble(),
      tipo: map['tipo'] as String,
      data: map['data'] as String,
      categoria: map['categoria'] as String,
      icone: map['icone'] as String?,
      banco: map['banco'] as String?,
    );
  }

  @override
  String toString() {
    return 'Transacao{id: $id, titulo: $titulo, valor: $valor, tipo: $tipo, data: $data, icone: $icone, banco: $banco}';
  }
}
