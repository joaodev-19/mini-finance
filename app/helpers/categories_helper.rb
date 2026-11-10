module CategoriesHelper
  CATEGORY_ICONS = {
    "alimentacao"   => "bi-cup-hot",
    "supermercado"  => "bi-cart",
    "transporte"    => "bi-car-front",
    "casa"          => "bi-house",
    "saude"         => "bi-heart-pulse",
    "educacao"      => "bi-book",
    "lazer"         => "bi-controller",
    "salario"       => "bi-wallet2"
  }.freeze

  def category_icon(category)
    key = category&.name.to_s.parameterize

    icon = CATEGORY_ICONS.fetch(key, "bi-tag")

    tag.i(class: "bi #{icon}", aria: { hidden: true })
  end

  def category_entry_form_path
    entry_id = session[:category_return_entry_id]
    if entry_id.present? && Entry.exists?(entry_id)
      edit_entry_path(entry_id)
    else
      new_entry_path
    end
  end
end
