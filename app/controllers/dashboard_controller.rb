class DashboardController < ApplicationController
  def index
    month = params[:month].present? ? params[:month] : Date.current.strftime("%Y-%m")

    begin
      date = if month.is_a?(String) && month.match?(/\A\d{4}-(0[1-9]|1[0-2])\z/)
        Date.strptime(month, "%Y-%m")
      else
        Date.current.beginning_of_month
      end
    rescue Date::Error
      date = Date.current.beginning_of_month
    end

    @selected_month = date

    current_month_entries = Entry.where(occurred_on: date.all_month)
    previous_month_entries = Entry.where(occurred_on: date.prev_month.all_month)

    @income_entries = current_month_entries.income
    @expense_entries = current_month_entries.expense

    @expenses_by_category = @expense_entries.joins(:category).group("categories.name").sum(:amount)

    @income_entries_amount = @income_entries.sum(:amount)
    @expense_entries_amount = @expense_entries.sum(:amount)

    previous_income_amount = previous_month_entries.income.sum(:amount)
    previous_expense_amount = previous_month_entries.expense.sum(:amount)

    @income_count = @income_entries.count
    @expense_count = @expense_entries.count

    @balance_amount = @income_entries_amount - @expense_entries_amount

    @income_difference = @income_entries_amount - previous_income_amount
    @expense_difference = @expense_entries_amount - previous_expense_amount

    @income_variation = calculate_variation(
      @income_entries_amount,
      previous_income_amount
    )

    @expense_variation = calculate_variation(
      @expense_entries_amount,
      previous_expense_amount
    )

    @income_consumn = calculate_consumn(@expense_entries_amount, @income_entries_amount)
  end

  private

    def calculate_variation(current, previous)
      return nil if previous.zero?

      ((current - previous) / previous.to_d) * 100
    end

    def calculate_consumn(month_expense, month_income)
      return nil if month_income.zero?

      (month_expense / month_income.to_d) * 100
    end
end
