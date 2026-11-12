# Paginação do caderno

Categorias e lançamentos compartilham `shared/_notebook_pagination`, os tokens
`--note-*` e os materiais de papel de `_stationery.scss`. A folha atual usa uma
etiqueta com círculo de tinta; setas viram a página. O rodapé mostra intervalo,
total de registros e número da folha. A janela de números inclui a primeira e a
última página, com reticências para intervalos grandes.

Em celulares abaixo de 400 px, o rodapé prioriza a folha atual e as duas setas,
evitando que a janela de números ocupe várias linhas.

## Comportamento

- A listagem HTML filtra e ordena antes de aplicar `limit` e `offset`.
- Categorias seguem nome e ID; lançamentos seguem data e ID decrescentes.
- `page` e `per_page` ficam na URL. Filtros acompanham os links; aplicar um filtro
  começa na primeira página.
- `NotebookPagination` usa cinco registros por padrão, aceita entre um e vinte
  por página e limita páginas inexistentes à última disponível.
- JSON mantém o comportamento anterior, sem paginação.
- O controlador Stimulus mede o espaço entre o cabeçalho e o rodapé e ajusta o
  tamanho da página com Turbo, substituindo a URL no histórico. Ao redimensionar,
  mantém o primeiro registro anterior dentro da nova página.

## Layout e acessibilidade

As duas listagens usam a altura da tela (`100dvh`). Formulários e detalhes
continuam com sua altura natural. Textos longos recebem reticências na
listagem; o conteúdo completo continua disponível em “Abrir”.

Os controles têm nomes acessíveis, foco visível e alvos de pelo menos 44 px de
altura. A folha atual usa `aria-current`; setas indisponíveis são texto sem link,
com `aria-disabled`. O intervalo é uma região de status. Alto contraste mantém
um contorno na folha atual.

Sem JavaScript, a paginação continua funcionando e a lista permite rolagem
interna com teclado. Abaixo de 540 px de altura, a folha cresce naturalmente,
preservando acesso ao conteúdo em telas baixas e com zoom.

O estilo stationery solicitado prevalece sobre a identidade institucional da
skill de layout: papel pautado, paleta verde, tipografia e Bootstrap Icons
existentes são reutilizados.

## Folhas do painel

O dashboard usa duas folhas, preservando `month` e `page` na URL. Fitas com
números romanos identificam balanço/comparação e distribuição por categoria.
No desktop, ambas usam a mesma altura da tela e a mesma posição para os
marcadores. O espaço livre da primeira folha se distribui entre suas três
seções, sem aumentar a altura dos cartões. No mobile, a primeira folha segue a
altura natural do conteúdo e dispensa continuações horizontais; a segunda
folha mantém seu comportamento anterior.

`dashboard_layout_controller` mede a área de leitura com `ResizeObserver`.
Quando há espaço, exibe o balanço completo e organiza categorias em colunas.
Quando necessário, cria continuações horizontais, com setas e posição atual,
mantendo os dados acessíveis sem rolagem vertical ou redução das fontes.
Valores financeiros e percentuais continuam renderizados pelo Rails.

As continuações aceitam toque, setas, Home e End quando a região está em foco.
A última continuação mantém o alinhamento mesmo quando contém poucos itens;
o mês vazio usa a mesma folha. Movimento reduzido desativa a rolagem animada.
