# Experiência mobile do Mini Finance

Implementação sobre a versão local de `feature/pagination` (`9bb0cb1`), sem
restaurar arquivos de outra branch. O breakpoint compartilhado é 991,98 px:
telefones e tablets usam fluxo vertical; a partir de 992 px permanece o caderno
desktop com altura controlada. Não foram adicionadas dependências.

## Problemas encontrados e mudanças

- O shell acumulava margens, perfurações e camadas. No mobile, a folha aproveita
  a largura disponível, com textura discreta e três divisórias sempre visíveis,
  alvos de 48 px, estado ativo e `aria-current` preservados.
- Listagens limitadas por `100dvh` e linhas fixas passaram a ter altura natural.
  Lançamentos usam notas compactas: categoria, título, tipo, data, descrição e
  uma faixa inferior com valor e Abrir. Descrições legítimas continuam visíveis;
  marcadores de demonstração não recebem tratamento especial nem destaque.
- Categorias usam linhas compactas e ações separadas por 16 px. Abrir e Excluir
  continuam explícitos; a confirmação de exclusão foi preservada.
- Os filtros passaram a usar `details`: ficha expansível no mobile e dropdown
  de papel no desktop. Enter/Espaço funcionam nativamente; Escape fecha e
  devolve o foco. No desktop, clique externo fecha o painel.
- Pesquisa textual agora conta como filtro ativo e produz o estado vazio
  correto. Pesquisa, categoria e tipo persistem entre páginas; aplicar, limpar
  ou mudar a quantidade começa na primeira página. IDs dos controles não se
  repetem entre os formulários.
- O padrão do servidor passou de 5 para 10 registros, com opção explícita de
  20 no mobile. Não há detecção de aparelho no servidor. Em telefone/tablet,
  `ResizeObserver` não mede registros nem dispara `Turbo.visit`; teclado e
  barra de endereço não mudam a página. O ajuste desktop permanece.
- Links de abertura, retorno e exclusão preservam o contexto permitido da
  listagem. Exclusões na última página continuam limitadas a uma página válida.
  Categorias não herdam filtros de lançamentos.
- Formulários têm uma coluna, controles nativos de pelo menos 48 px, fontes de
  16 px e ações no fluxo da página. Valor usa `inputmode="decimal"`; tipo,
  `step`, validações e valor enviado continuam iguais. Data permanece nativa.
  Detalhes dão prioridade ao valor. Feedback de sucesso está em português.
- Modais têm corpo rolável quando necessário, Fechar de 44 px, Cancelar e
  APAGAR acessíveis mesmo em telas baixas. O Bootstrap continua responsável por
  backdrop, foco e retorno ao acionador. Stimulus prepara nome e destino sem
  acumular listeners inline a cada navegação Turbo.
- No dashboard mobile, receitas e despesas ficam lado a lado a partir de
  360 px; saldo ocupa a largura. Abaixo disso, ficam em uma coluna compacta.
  Calendário, comprometimento e comparação têm largura e altura naturais.
- A Folha II mostra todas as categorias verticalmente, com nome, valor, barra,
  participação e destaque da maior despesa. Não há paginação horizontal interna
  no mobile. No desktop, permanecem colunas de até quatro categorias.
  Os marcadores I/II continuam navegando entre as folhas com o mês preservado.

## Arquivos modificados

| Área | Arquivos |
| --- | --- |
| Estilos | `app/assets/stylesheets/_notebook_mobile.scss` (novo), `application.bootstrap.scss` |
| Paginação e contexto | `app/models/notebook_pagination.rb`, `app/helpers/application_helper.rb`, `app/controllers/entries_controller.rb`, `app/controllers/categories_controller.rb` |
| Apresentação e navegação | `app/javascript/controllers/notebook_pagination_controller.js`, `dashboard_layout_controller.js`, `filter_panel_controller.js` (novo), `delete_confirmation_controller.js` (novo) |
| Lançamentos | `app/views/entries/index.html.erb`, `_form.html.erb`, `show.html.erb` |
| Categorias | `app/views/categories/index.html.erb`, `_category.html.erb`, `_form.html.erb` |
| Compartilhados | `app/views/shared/_notebook_pagination.html.erb`, `_delete_modal.html.erb` |
| Testes | `test/integration/notebook_pagination_test.rb`, `notebook_navigation_test.rb`, `test/models/notebook_pagination_test.rb`, `test/javascript/mobile_navigation_test.mjs` (novo) |
| Documentação | `docs/notebook-pagination.md`, este relatório |

Os models de Entry e Category, cálculos, consultas SQL, controller e ERB do
dashboard, regras de exclusão, rotas, seeds e migrations não foram alterados.

## Validações

- CSS compilado e `git diff --check` sem problemas.
- 36 testes Rails focados: 425 assertions, sem falhas. Incluem filtros
  combinados, busca vazia, troca de quantidade, limites, CRUD e contexto após
  exclusão, navegação e cálculos do dashboard.
- Três verificações JavaScript: ausência de navegação automática no mobile,
  fluxo natural das categorias e limite de quatro linhas no desktop.
- Chrome renderizado em 320, 360, 375, 390, 430, 768 e 1024 px, além de paisagem
  844 × 390: listagens, criação, edição, detalhes, filtros e ambas as folhas,
  sem rolagem horizontal global.
- Interações com Turbo: filtros juntos, pesquisa preservada na próxima página,
  20 registros e limpeza. Modais conferidos com nomes longos, cancelamento,
  bloqueio de foco em controles de fundo e retorno ao acionador.
- Fontes a 200% em 320 px; nomes extensos e valores grandes; feedback de
  submissão inválida; filtros, paginação e categorias com JavaScript desativado.
- No desktop 1440 × 900, as medidas do shell, cabeçalho, cartões, linhas e
  rodapé foram comparadas com o CSS anterior e permaneceram iguais.
- Contraste dos tokens principais foi conferido; etiquetas mobile passaram a
  usar oliva, corrigindo o contraste insuficiente do texto secundário nelas.

## Limitações e diferenças intencionais

A suíte completa começou com oito falhas. Duas expectativas antigas de
dashboard indisponível foram atualizadas para a navegação atual. Permanecem
seis falhas preexistentes em `CategoriesControllerTest`: fixtures com nomes
duplicados e expectativas de retorno ao formulário que a interface original
não implementa. O CRUD com nomes válidos foi verificado separadamente.

A conferência foi feita no Chrome com emulação de viewport, toque e mudança
de altura. Teclado real de iOS/Android, VoiceOver/TalkBack e uma auditoria WCAG
completa ainda exigem verificação em dispositivos. Não se declara certificação
de conformidade AA.

O mobile cresce verticalmente e exibe 10/20 registros estáveis; o desktop
conserva a folha ajustada ao viewport e suas continuações. Essas diferenças são
intencionais. Nenhum commit, merge ou push foi realizado.
