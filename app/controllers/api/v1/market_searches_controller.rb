class Api::V1::MarketSearchesController < ApplicationController
  def new
    market_column_labels = ["Product Name", "Category", "Province", "Country", "Sales"]
    market_column_names = ["product", "category", "province", "country", "sales"]
    marketProperties = []
    market_column_labels.each_with_index do |x, index|
      marketProperties << {
        label: market_column_labels[index],
        columnName: market_column_names[index]
      }
    end
    
    render json: {
      categories: Category.all.pluck(:name),
      marketProperties: marketProperties
    }
  end

  def results
    byebug
  end
end 