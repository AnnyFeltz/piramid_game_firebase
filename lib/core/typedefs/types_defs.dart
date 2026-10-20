import '../failure/failure.dart';
import '../patterns/result.dart';
import '../../domain/models/avaliacao.dart';
import '../../domain/models/criterios_popularidade.dart';
import '../../domain/models/pessoa.dart';
import '../../domain/models/ranking_item.dart';
import '../../domain/models/usuario.dart';

// ── Resultados (padrão Result) ───────────────────────────────────────────────
typedef VoidResult = Result<void, Failure>;
typedef BoolResult = Result<bool, Failure>;

typedef UsuarioResult = Result<Usuario, Failure>;

typedef PessoaResult = Result<Pessoa, Failure>;
typedef OptPessoaResult = Result<Pessoa?, Failure>;
typedef ListPessoaResult = Result<List<Pessoa>, Failure>;

typedef AvaliacaoResult = Result<Avaliacao, Failure>;
typedef OptAvaliacaoResult = Result<Avaliacao?, Failure>;
typedef ListAvaliacaoResult = Result<List<Avaliacao>, Failure>;

typedef RankingResult = Result<List<RankingItem>, Failure>;

// ── Parâmetros dos use cases ─────────────────────────────────────────────────
typedef NoParams = ();
typedef CredenciaisParams = ({String email, String senha});
typedef PessoaParams = ({Pessoa pessoa});
typedef PessoaIdParams = ({String id});
typedef AvaliarParams = ({String pessoaId, CriteriosPopularidade criterios});
typedef TemaParams = ({bool escuro});
