import '../../core/typedefs/types_defs.dart';

abstract interface class IPreferenceRepository {
  /// true quando o usuário escolheu o tema escuro (padrão: claro).
  Future<BoolResult> getTemaEscuro();
  Future<VoidResult> salvarTemaEscuro(bool escuro);
}
