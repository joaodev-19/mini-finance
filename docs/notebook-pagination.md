# Paginação do caderno

Categorias e lançamentos compartilham `shared/_notebook_pagination`, os tokens
`--note-*` e os materiais de papel de `_stationery.scss`. A folha atual usa uma
etiqueta com círculo de tinta; setas viram a página. O rodapé mostra intervalo,
total de registros e número da folha. A janela de números inclui a primeira e a
última página, com reticências para intervalos grandes.

Até 991,98 px, o rodapé prioriza Anterior, folha atual e Próxima, com seleção
explícita de 10 ou 20 registros. O formulário funciona sem JavaScript e começa
na primeira página ao mudar a quantidade.

“Por página” usa uma ficha `details` com opções de rádio nativas em uma camada
absoluta acima do campo, sem aumentar a altura da página. A lista aberta não
depende do popup do sistema operacional e permanece dentro da largura da folha.
Ao abrir, as opções entram na área visível; escolher
uma opção atualiza o rótulo e devolve o foco. Atualizar continua submetendo o
formulário GET, preservando os filtros.

## Comportamento

- A listagem HTML filtra e ordena antes de aplicar `limit` e `offset`.
- Categorias seguem nome e ID; lançamentos seguem data e ID decrescentes.
- `page` e `per_page` ficam na URL. Filtros acompanham os links; aplicar um filtro
  começa na primeira página.
- `NotebookPagination` usa dez registros por padrão, aceita entre um e vinte
  por página e limita páginas inexistentes à última disponível.
- JSON mantém o comportamento anterior, sem paginação.
- Pesquisa, categoria e tipo acompanham a paginação de lançamentos. Categorias
  preservam somente página e quantidade. Nenhum parâmetro arbitrário é propagado.
- No desktop (a partir de 992 px), o controlador Stimulus mede o espaço entre o cabeçalho e o rodapé e ajusta o
  tamanho da página com Turbo, substituindo a URL no histórico. Ao redimensionar,
  mantém o primeiro registro anterior dentro da nova página.

## Layout e acessibilidade

No desktop, as listagens usam a altura da tela (`100dvh`). No mobile e tablet,
listagens, formulários, detalhes e ambas as folhas do dashboard seguem a altura
natural do conteúdo. A mudança de altura causada pela barra do navegador ou
teclado não inicia observação nem visita Turbo. O mesmo padrão inicial de dez
registros é usado no servidor, sem identificação do aparelho por user-agent.

Lançamentos usam notas compactas, com valor e Abrir na faixa inferior. Títulos
podem quebrar linhas e descrições têm até duas linhas; o conteúdo completo
continua disponível em Abrir. Os filtros usam `details`: dropdown no desktop e
painel no fluxo da página no mobile, inclusive sem JavaScript.

Os controles têm nomes acessíveis, foco visível e alvos de pelo menos 44 px de
altura. A folha atual usa `aria-current`; setas indisponíveis são texto sem link,
com `aria-disabled`. O intervalo é uma região de status. Alto contraste mantém
um contorno na folha atual.

Sem JavaScript, a paginação continua funcionando e a lista permite rolagem
interna com teclado no desktop. Abaixo de 540 px de altura, a folha cresce naturalmente,
preservando acesso ao conteúdo em telas baixas e com zoom.

O estilo stationery solicitado prevalece sobre a identidade institucional da
skill de layout: papel pautado, paleta verde, tipografia e Bootstrap Icons
existentes são reutilizados.

## Folhas do painel

O dashboard usa duas folhas, preservando `month` e `page` na URL. Fitas com
números romanos identificam balanço/comparação e distribuição por categoria.
No desktop, ambas usam a mesma altura da tela e a mesma posição para os
marcadores. O espaço livre da primeira folha se distribui entre suas três
seções, sem aumentar a altura dos cartões. Até 991,98 px, ambas as folhas seguem
a altura natural. A segunda mostra todas as categorias em lista vertical, sem
continuação horizontal ou medições. As fitas I e II continuam navegando entre
as duas perspectivas do mesmo mês.

`dashboard_layout_controller` mede a área de leitura com `ResizeObserver`.
Essa observação é exclusiva do desktop.
Quando há espaço, exibe o balanço completo e organiza categorias em colunas.
Quando necessário, cria continuações horizontais, com setas e posição atual,
mantendo os dados acessíveis sem rolagem vertical ou redução das fontes.
Valores financeiros e percentuais continuam renderizados pelo Rails.

As colunas de categorias no desktop possuem no máximo quatro itens. O mobile
não altera linhas, colunas ou tamanho de página quando somente a altura muda.

As continuações aceitam toque, setas, Home e End quando a região está em foco.
A última continuação mantém o alinhamento mesmo quando contém poucos itens;
o mês vazio usa a mesma folha. Movimento reduzido desativa a rolagem animada.

## Verificação

- `PARALLEL_WORKERS=1 bin/rails test test/models/notebook_pagination_test.rb test/integration/notebook_pagination_test.rb test/integration/notebook_navigation_test.rb test/controllers/entries_controller_test.rb test/controllers/dashboard_controller_test.rb`
- `node test/javascript/mobile_navigation_test.mjs`
- `npm run build:css`

As regras específicas de telefone/tablet ficam em `_notebook_mobile.scss`,
importado após os componentes desktop. Não há novas dependências. Os modais
continuam usando o foco e o backdrop do Bootstrap; Stimulus apenas prepara o
registro e o destino de exclusão, sem listeners inline acumulados pelo Turbo.
