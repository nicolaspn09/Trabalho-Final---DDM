class Transacao {
  final String? id;
  final String titulo;
  final double valor;
  final String tipo; // 'receita' ou 'despesa'
  final String data;
  final String categoria;

  Transacao({
    this.id,
    required this.titulo,
    required this.valor,
    required this.tipo,
    required this.data,
    required this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'valor': valor,
      'tipo': tipo,
      'data': data,
      'categoria': categoria,
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
    );
  }

  @override
  String toString() {
    return 'Transacao{id: $id, titulo: $titulo, valor: $valor, tipo: $tipo, data: $data}';
  }
}
