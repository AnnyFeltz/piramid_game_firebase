/// Os 15 critérios de popularidade (nome na tela + explicação).
/// `chave` é o mesmo nome do campo em CriteriosPopularidade.toMap()/Firestore,
/// por isso as telas leem/gravam as notas por esse nome sem precisar de um
/// `switch` gigante.
typedef CriterioInfo = ({String chave, String label, String descricao});

const List<CriterioInfo> criteriosInfo = [
  (chave: 'resenha',               label: 'Resenha',                    descricao: 'Anima a turma e puxa conversa'),
  (chave: 'presencaVip',           label: 'Presença VIP',               descricao: 'É lembrado e reconhecido pelos colegas'),
  (chave: 'aura',                  label: 'Aura',                       descricao: 'Energia, estilo e impacto no ambiente'),
  (chave: 'modoParceiro',          label: 'Modo Parceiro',              descricao: 'Colabora e demonstra espírito de parceria'),
  (chave: 'carismaNatural',        label: 'Carisma Natural',            descricao: 'Facilidade de socializar e criar relações'),
  (chave: 'humorDeMilhoes',        label: 'Humor de Milhões',           descricao: 'Bom humor e momentos divertidos'),
  (chave: 'energiaDeGrupo',        label: 'Energia de Grupo',           descricao: 'Participa de trabalhos e eventos coletivos'),
  (chave: 'criatividadeCaotica',   label: 'Criatividade Caótica',       descricao: 'Ideias diferentes e soluções inesperadas'),
  (chave: 'modoAtleta',            label: 'Modo Atleta',                descricao: 'Aptidão esportiva e espírito competitivo'),
  (chave: 'talentoDePalco',        label: 'Talento de Palco',           descricao: 'Aptidão artística e presença em apresentações'),
  (chave: 'dripEscolar',           label: 'Drip Escolar',               descricao: 'Estilo pessoal e presença visual'),
  (chave: 'coracaoDeDorama',       label: 'Coração de Dorama',          descricao: 'Carisma afetivo e gentileza'),
  (chave: 'queridinhoProfessores', label: 'Queridinho dos Professores', descricao: 'Boa relação com os professores'),
  (chave: 'cerebroTurbo',          label: 'Cérebro Turbo',              descricao: 'Desempenho nos estudos e raciocínio'),
  (chave: 'caosControlado',        label: 'Caos Controlado',            descricao: 'Bagunceiro, mas dentro dos limites saudáveis'),
];
